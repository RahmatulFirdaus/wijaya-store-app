import 'package:flutter/material.dart';
import 'package:frontend/pages/login_page/login_page.dart';
import 'package:toastification/toastification.dart';
import 'package:frontend/models/pembeli_model.dart'; // Adjust import based on your project structure

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Form controllers
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController noTelpController = TextEditingController();

  // Password visibility toggles
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Form validation key
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Registrasi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade50],
            ),
          ),
          child: Stack(
            children: [
              // Modern geometric decorations
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

              // Main content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Header
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.05),
                              ),
                              child: const Icon(
                                Icons.person_add_outlined,
                                size: 40,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "BUAT AKUN BARU",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: Colors.black,
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

                      const SizedBox(height: 30),

                      // Registration form
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Form explanation text
                              Text(
                                "Silahkan isi data berikut untuk membuat akun baru",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 25),

                              // Username field
                              _buildTextField(
                                controller: usernameController,
                                labelText: "Username",
                                prefixIcon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Username tidak boleh kosong";
                                  }
                                  if (value.contains(' ')) {
                                    return "Jangan mengandung spasi";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 15),

                              // Full name field
                              _buildTextField(
                                controller: namaController,
                                labelText: "Nama Lengkap",
                                prefixIcon: Icons.badge_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Nama tidak boleh kosong";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),

                              // Email field
                              _buildTextField(
                                controller: emailController,
                                labelText: "Email",
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.email_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Email tidak boleh kosong";
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return "Email tidak valid";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),

                              // Phone number field
                              _buildTextField(
                                controller: noTelpController,
                                labelText: "Nomor Telepon",
                                keyboardType: TextInputType.phone,
                                prefixIcon: Icons.phone_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Nomor telepon tidak boleh kosong";
                                  }
                                  if (!RegExp(
                                    r'^[0-9]{10,13}$',
                                  ).hasMatch(value)) {
                                    return "Nomor telepon tidak valid";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),

                              // Password field
                              _buildPasswordField(
                                controller: passwordController,
                                labelText: "Password",
                                isVisible: isPasswordVisible,
                                toggleVisibility: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Password tidak boleh kosong";
                                  }
                                  if (value.length < 6) {
                                    return "Password minimal 6 karakter";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),

                              // Confirm password field
                              _buildPasswordField(
                                controller: confirmPasswordController,
                                labelText: "Konfirmasi Password",
                                isVisible: isConfirmPasswordVisible,
                                toggleVisibility: () {
                                  setState(() {
                                    isConfirmPasswordVisible =
                                        !isConfirmPasswordVisible;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Konfirmasi password tidak boleh kosong";
                                  }
                                  if (value != passwordController.text) {
                                    return "Password tidak cocok";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 30),

                              // Register button
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0.9, end: 1.0),
                                duration: const Duration(milliseconds: 800),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ElevatedButton(
                                        onPressed:
                                            _isLoading
                                                ? null
                                                : () {
                                                  _handleRegistration();
                                                },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.black,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                        ).copyWith(
                                          overlayColor:
                                              MaterialStateProperty.resolveWith<
                                                Color?
                                              >((Set<MaterialState> states) {
                                                if (states.contains(
                                                  MaterialState.pressed,
                                                )) {
                                                  return Colors.grey.shade800;
                                                }
                                                if (states.contains(
                                                  MaterialState.hovered,
                                                )) {
                                                  return Colors.grey.shade900;
                                                }
                                                return null;
                                              }),
                                        ),
                                        child:
                                            _isLoading
                                                ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                )
                                                : const Text(
                                                  "DAFTAR",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Login link
                              const SizedBox(height: 20),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => LoginPage(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Sudah punya akun? ",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Footer text
                      Center(
                        child: Text(
                          "© 2025 Wijaya Store. All rights reserved.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, color: Colors.black),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          prefixIcon: Icon(prefixIcon, size: 20, color: Colors.grey.shade800),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }

  // Helper function to build password fields
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        style: const TextStyle(fontSize: 15, color: Colors.black),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          prefixIcon: Icon(
            Icons.lock_outline,
            size: 20,
            color: Colors.grey.shade800,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: Colors.grey.shade700,
            ),
            onPressed: toggleVisibility,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }

  // Handle registration logic
  Future<void> _handleRegistration() async {
    // Validate form
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? result = await PembeliDaftarAkun.daftarAkunPembeli(
          usernameController.text
              .trim(), // trim digunakan untuk menghapus spasi
          passwordController.text.trim(),
          namaController.text.trim(),
          emailController.text.trim(),
          confirmPasswordController.text.trim(),
          noTelpController.text.trim(),
        );

        // Handle response
        if (result ==
            "Pendaftaran berhasil! Akun Anda menunggu persetujuan admin.") {
          toastification.show(
            context: context,
            title: const Text("Registrasi Berhasil"),
            description: const Text(
              "Akun berhasil didaftarkan. Silakan tunggu persetujuan admin.",
            ),
            type: ToastificationType.success,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          // Show error message from API
          toastification.show(
            context: context,
            title: const Text("Daftar Akun Gagal"),
            description: Text(result ?? "Terjadi kesalahan"),
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
            alignment: Alignment.topCenter,
            autoCloseDuration: const Duration(seconds: 5),
            icon: const Icon(Icons.error_outline),
          );
        }
      } catch (e) {
        // Handle exceptions
        toastification.show(
          context: context,
          title: const Text("Terjadi Kesalahan"),
          description: Text("Error: ${e.toString()}"),
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 5),
          icon: const Icon(Icons.error_outline),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
