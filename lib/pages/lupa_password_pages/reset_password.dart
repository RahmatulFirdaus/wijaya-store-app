import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with TickerProviderStateMixin {
  TextEditingController otpController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return "Password tidak boleh kosong";
    if (password.length < 8) return "Password minimal 8 karakter";
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return "Password harus mengandung huruf besar";
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return "Password harus mengandung angka";
    }
    return null;
  }

  Future<void> resetPassword() async {
    if (otpController.text.isEmpty) {
      _showSnackBar("Kode OTP tidak boleh kosong", Colors.red.shade600);
      return;
    }

    if (passwordController.text.isEmpty) {
      _showSnackBar("Password baru tidak boleh kosong", Colors.red.shade600);
      return;
    }

    String? passwordError = validatePassword(passwordController.text);
    if (passwordError != null) {
      _showSnackBar(passwordError, Colors.red.shade600);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("Konfirmasi password tidak cocok", Colors.red.shade600);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.96:3000/api/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
          "otp": otpController.text,
          "passwordBaru": passwordController.text,
        }),
      );

      setState(() => isLoading = false);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showSnackBar(data['pesan'], Colors.green.shade600);

        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        _showSnackBar(
          data['pesan'] ?? "Gagal reset password",
          Colors.red.shade600,
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Terjadi kesalahan: $e", Colors.red.shade600);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade50],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -120,
                right: -100,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.03),
                  ),
                ),
              ),
              Positioned(
                top: -80,
                right: -180,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.02),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.03),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(top: 20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade100,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.black,
                                size: 20,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.8, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withOpacity(0.05),
                                      ),
                                      child: Icon(
                                        Icons.lock_person_outlined,
                                        size: 60,
                                        color: Colors.black.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      "RESET PASSWORD",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      widget.email,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      width: 40,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        // ================= FORM ===============
                        Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Verifikasi & Reset",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Masukkan kode OTP yang dikirim ke email Anda dan buat password baru.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 30),

                              // OTP
                              _buildOtpField(context),

                              const SizedBox(height: 20),

                              // Password Baru
                              _buildPasswordField(),

                              const SizedBox(height: 20),

                              // Konfirmasi Password
                              _buildConfirmPasswordField(),

                              const SizedBox(height: 10),

                              // Password Requirement
                              _buildPasswordRequirements(),

                              const SizedBox(height: 35),

                              // Reset Button
                              _buildResetButton(),
                            ],
                          ),
                        ),

                        // GANTI Spacer -> SizedBox agar tidak error
                        const SizedBox(height: 40),

                        Center(
                          child: Text(
                            "© 2025 Wijaya Store. All rights reserved.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================== Widget Builder ===================
  Widget _buildOtpField(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
        ),
      ),
      child: TextField(
        controller: otpController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black,
          letterSpacing: 4,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          labelText: "Kode OTP",
          hintText: "123456",
          prefixIcon: Icon(
            Icons.security_outlined,
            size: 20,
            color: Colors.grey.shade800,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        labelText: "Password Baru",
        prefixIcon: Icon(
          Icons.lock_outline,
          size: 20,
          color: Colors.grey.shade800,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
            color: Colors.grey.shade700,
          ),
          onPressed: () {
            setState(() => isPasswordVisible = !isPasswordVisible);
          },
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextField(
      controller: confirmPasswordController,
      obscureText: !isConfirmPasswordVisible,
      decoration: InputDecoration(
        labelText: "Konfirmasi Password",
        prefixIcon: Icon(
          Icons.lock_clock_outlined,
          size: 20,
          color: Colors.grey.shade800,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isConfirmPasswordVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
            color: Colors.grey.shade700,
          ),
          onPressed: () {
            setState(
              () => isConfirmPasswordVisible = !isConfirmPasswordVisible,
            );
          },
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Persyaratan Password:",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          _buildPasswordRequirement(
            "• Minimal 8 karakter",
            passwordController.text.length >= 8,
          ),
          _buildPasswordRequirement(
            "• Mengandung huruf besar (A-Z)",
            passwordController.text.contains(RegExp(r'[A-Z]')),
          ),
          _buildPasswordRequirement(
            "• Mengandung angka (0-9)",
            passwordController.text.contains(RegExp(r'[0-9]')),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : resetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? Colors.grey.shade400 : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child:
            isLoading
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "MERESET...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                : const Text(
                  "RESET PASSWORD",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: isMet ? Colors.green.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: isMet ? Colors.green.shade600 : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
