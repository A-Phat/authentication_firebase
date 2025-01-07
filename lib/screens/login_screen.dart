import 'package:authentication/src/phone-auth-screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _loginWithPhoneNumber(BuildContext context) {
    print("Login with Phone Number");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PhoneAuthScreen()),
    );
  }

  void _loginWithGoogle(BuildContext context) {
    print("Login with Google");
  }

  void _loginWithApple(BuildContext context) {
    print("Login with Apple ID");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB599FA), Color(0xFF233FCA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // โลโก้
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(Icons.lock, size: 60, color: Colors.blueAccent),
            ),
            const SizedBox(height: 32),

            // ข้อความต้อนรับ
            Text(
              "Welcome Back!",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please login to continue",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 48),

            // ปุ่ม Phone Number
            _buildLoginButton(
              icon: Icons.phone_android,
              text: "Login with Phone Number",
              onPressed: () => _loginWithPhoneNumber(context),
            ),
            const SizedBox(height: 16),

            // ปุ่ม Google
            _buildLoginButton(
              icon: Icons.g_mobiledata_rounded,
              text: "Login with Google",
              onPressed: () => _loginWithGoogle(context),
              buttonColor: Colors.redAccent,
            ),
            const SizedBox(height: 16),

            // ปุ่ม Apple ID
            _buildLoginButton(
              icon: Icons.apple,
              text: "Login with Apple ID",
              onPressed: () => _loginWithApple(context),
              buttonColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    Color buttonColor = Colors.white,
  }) {
    return SizedBox(
      width: double.infinity, // ปรับขนาดปุ่มเต็มความกว้าง
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 16), // ขยายพื้นที่ในปุ่ม
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // เพิ่มความโค้งมนให้ปุ่ม
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // จัดเรียงตรงกลาง
          children: [
            Icon(
              icon,
              size: 28,
              color: buttonColor == Colors.white ? Colors.black : Colors.white,
            ),
            const SizedBox(width: 12), // เพิ่มระยะห่างระหว่าง Icon กับ Text
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: buttonColor == Colors.white ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
