import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String? verificationId;

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    // phone number and otp for test
    // +66 94 436 5885  
    // 111222
    try {
      debugPrint("Verifying phone number: $phoneNumber");
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-sign-in เมื่อยืนยันสำเร็จ
          await FirebaseAuth.instance.signInWithCredential(credential);
          debugPrint("Phone number automatically verified and user signed in");
        },
        verificationFailed: (FirebaseAuthException e) {
          // หากการยืนยันล้มเหลว
          debugPrint("Verification failed: ${e.message}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification failed: ${e.message}")),
          );
        },
        codeSent: (String verId, int? resendToken) {
          // เก็บ verificationId ไว้สำหรับการยืนยัน OTP
          setState(() {
            verificationId = verId;
          });
          debugPrint("Verification code sent to $phoneNumber");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("OTP sent to $phoneNumber")),
          );
        },
        codeAutoRetrievalTimeout: (String verId) {
          // Timeout เมื่อไม่ได้ยืนยันในเวลาที่กำหนด
          setState(() {
            verificationId = verId;
          });
          debugPrint("Code auto-retrieval timeout");
        },
      );
    } catch (e) {
      debugPrint("Error during phone verification: $e");
    }
  }

  Future<void> signInWithOTP(String smsCode) async {
    try {
      if (verificationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification ID is null")),
        );
        return;
      }

      // สร้าง Credential ด้วย OTP ที่ได้รับ
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: smsCode,
      );

      // ทำการเข้าสู่ระบบด้วย Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signed in successfully!")),
      );
      // ดึง Token หลังจากเข้าสู่ระบบสำเร็จ
      String? idToken = await userCredential.user?.getIdToken();
      debugPrint("User signed in successfully with Token: $idToken");

      // ส่ง Token ไปยัง Backend
      // sendTokenToBackend(idToken);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Signed in successfully! Token Sent to Backend.")),
      );
    } catch (e) {
      debugPrint("Failed to sign in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign in: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Authentication"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone Number",
                hintText: "+66998888888",
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String phoneNumber = phoneController.text.trim();
                verifyPhoneNumber(phoneNumber);
              },
              child: Text("Verify Phone Number"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "OTP",
                hintText: "Enter OTP",
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String smsCode = otpController.text.trim();
                signInWithOTP(smsCode);
              },
              child: Text("Verify OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
