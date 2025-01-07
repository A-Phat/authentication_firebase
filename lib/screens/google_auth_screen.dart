import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

class GoogleAuthScreen extends StatefulWidget {
  const GoogleAuthScreen({super.key});

  @override
  _GoogleAuthScreenState createState() => _GoogleAuthScreenState();
}

class _GoogleAuthScreenState extends State<GoogleAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

// ฟังก์ชันสำหรับ Google Sign-In พร้อมแสดง Token ที่ได้
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return; // ผู้ใช้ยกเลิกการเข้าสู่ระบบ
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // สร้าง Credential สำหรับ Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // เข้าสู่ระบบ Firebase ด้วย Google Credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // รับ Token เพื่อส่งไป Backend
      String? idToken = await userCredential.user?.getIdToken();
      debugPrint("Firebase ID Token: $idToken");

      // แสดง Token ใน SnackBar (เพื่อการตรวจสอบ)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Signed in! ")),
      );

      // ส่ง Token ไปยัง Backend ได้ที่นี่
      // sendTokenToBackend(idToken);  // <-- สามารถเพิ่มฟังก์ชันนี้ได้ตามต้องการ
    } catch (e) {
      print("Error during Google Sign-In: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign in: $e")),
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signed out successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // โลโก้ Google
                // CircleAvatar(
                //   radius: 60,
                //   backgroundColor: Colors.white,
                //   child: Image.asset(
                //     'assets/google_logo.png', // เพิ่มโลโก้ Google (เพิ่มใน assets)
                //     height: 60,
                //   ),
                // ),
                const SizedBox(height: 24),

                // ข้อความต้อนรับ
                Text(
                  "Google Authentication",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Sign in with your Google account",
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // ปุ่ม Sign in ด้วย Google
                _buildButton(
                  text: "Sign in with Google",
                  icon: Icons.login,
                  onPressed: signInWithGoogle,
                  buttonColor: Colors.white,
                  iconColor: Colors.redAccent,
                  textColor: Colors.black87,
                ),
                const SizedBox(height: 16),

                // ปุ่ม Sign Out
                _buildButton(
                  text: "Sign Out",
                  icon: Icons.logout,
                  buttonColor: Colors.redAccent,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  onPressed: signOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    Color buttonColor = Colors.white,
    Color iconColor = Colors.white,
    Color textColor = Colors.white,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5, // เพิ่มเงา
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor),
        label: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 18, color: textColor),
        ),
      ),
    );
  }
}
