import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    try {
      debugPrint("Verifying phone number: $phoneNumber");
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          debugPrint("Phone number automatically verified and user signed in");
          _showSnackBar("Phone number automatically verified!");
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint("Verification failed: ${e.message}");
          _showSnackBar("Verification failed: ${e.message}");
        },
        codeSent: (String verId, int? resendToken) {
          setState(() {
            verificationId = verId;
          });
          _showSnackBar("OTP Sent to $phoneNumber");
        },
        codeAutoRetrievalTimeout: (String verId) {
          setState(() {
            verificationId = verId;
          });
          _showSnackBar("OTP Timeout, please try again");
        },
      );
    } catch (e) {
      debugPrint("Error during phone verification: $e");
      _showSnackBar("Error: $e");
    }
  }

  Future<void> signInWithOTP(String smsCode) async {
    try {
      if (verificationId == null) {
        _showSnackBar("Verification ID is null");
        return;
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: smsCode,
      );

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      String? idToken = await userCredential.user?.getIdToken();

      _showSnackBar("Signed in successfully!");
      debugPrint("User Token: $idToken");
    } catch (e) {
      debugPrint("Failed to sign in: $e");
      _showSnackBar("Failed to sign in: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color appBarColor = Color(0xFFA3A2F1);

    return Scaffold(
      appBar: AppBar(
        title:  Text("Phone Authentication",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),),
        backgroundColor: appBarColor,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA3A2F1), Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // โลโก้
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.phone, size: 60, color: appBarColor),
                ),
                const SizedBox(height: 24),

                // ข้อความต้อนรับ
                Text(
                  "Phone Authentication",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter your phone number to get started",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // ฟอร์มกรอกเบอร์โทรศัพท์
                _buildTextField(
                  controller: phoneController,
                  label: "Phone Number",
                  hint: "+66998888888",
                  icon: Icons.phone,
                ),
                const SizedBox(height: 16),

                // ปุ่ม Verify Phone Number
                _buildButton(
                  text: "Send OTP",
                  icon: Icons.send,
                  onPressed: () {
                    verifyPhoneNumber(phoneController.text.trim());
                  },
                ),
                const SizedBox(height: 24),

                // ฟอร์มกรอก OTP
                _buildTextField(
                  controller: otpController,
                  label: "OTP",
                  hint: "Enter OTP",
                  icon: Icons.lock,
                ),
                const SizedBox(height: 16),

                // ปุ่ม Verify OTP
                _buildButton(
                  text: "Verify OTP",
                  icon: Icons.verified,
                  buttonColor: Colors.green,
                  onPressed: () {
                    signInWithOTP(otpController.text.trim());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      style: GoogleFonts.poppins(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500),
        floatingLabelBehavior: FloatingLabelBehavior.always, // ทำให้ Label ค้างไว้เสมอ
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }


  Widget _buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    Color buttonColor = Colors.white,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: buttonColor == Colors.white ? Colors.deepPurpleAccent : Colors.white,
        ),
        label: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: buttonColor == Colors.white ? Colors.deepPurpleAccent : Colors.white,
          ),
        ),
      ),
    );
  }
}
