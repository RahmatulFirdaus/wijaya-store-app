import 'package:flutter/material.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:frontend/pages/admin_pages/main_admin.dart';
import 'package:frontend/pages/karyawan_pages/main_karyawan.dart';
import 'package:frontend/pages/lupa_password_pages/lupa_password.dart';
import 'package:frontend/pages/pembeli_pages/main_pembeli.dart';
import 'package:frontend/pages/register_page/register_page.dart';
import 'package:frontend/services/notification_service.dart';
import 'package:toastification/toastification.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isCapsLockOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height,
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

              // Main content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      // Logo section with subtle animation
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.8, end: 1.0),
                        duration: const Duration(seconds: 1),
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
                                    child: Image.asset(
                                      "assets/images/logo.png",
                                      width: 120,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "WIJAYA STORE",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
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
                          );
                        },
                      ),

                      const SizedBox(height: 60),

                      // Login form area
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
                              "Login",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Modern text fields - Username
                            Theme(
                              data: Theme.of(context).copyWith(
                                inputDecorationTheme: InputDecorationTheme(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              child: TextField(
                                controller: usernameController,
                                autocorrect: false,
                                enableSuggestions: false,
                                textCapitalization: TextCapitalization.none,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Username",
                                  labelStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    size: 20,
                                    color: Colors.grey.shade800,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Password field with caps lock detection
                            Theme(
                              data: Theme.of(context).copyWith(
                                inputDecorationTheme: InputDecorationTheme(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: passwordController,
                                    obscureText: !isPasswordVisible,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    onChanged: (value) {
                                      // Simple caps lock detection
                                      bool hasCaps = value.contains(
                                        RegExp(r'[A-Z]'),
                                      );
                                      bool hasLower = value.contains(
                                        RegExp(r'[a-z]'),
                                      );
                                      setState(() {
                                        isCapsLockOn =
                                            hasCaps &&
                                            !hasLower &&
                                            value.length > 2;
                                      });
                                    },
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: "Password",
                                      labelStyle: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
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
                                          setState(() {
                                            isPasswordVisible =
                                                !isPasswordVisible;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                    ),
                                  ),

                                  // Caps lock warning
                                  if (isCapsLockOn)
                                    Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.orange.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.warning_amber_outlined,
                                            size: 14,
                                            color: Colors.orange.shade700,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Caps Lock mungkin aktif",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.orange.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Forgot Password Link - Positioned after password field
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => const ForgotPasswordPage(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  "Lupa Password?",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Modern black button with animation
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0.9, end: 1.0),
                              duration: const Duration(milliseconds: 800),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (usernameController
                                                .text
                                                .isNotEmpty &&
                                            passwordController
                                                .text
                                                .isNotEmpty) {
                                          try {
                                            // Pastikan mengirim input persis seperti yang diketik user
                                            String?
                                            result = await LoginAkunPembeli.loginAkunPembeli(
                                              usernameController
                                                  .text, // Tidak diubah case-nya
                                              passwordController
                                                  .text, // Tidak diubah case-nya
                                            );

                                            if (result == "admin") {
                                              toastification.show(
                                                context: context,
                                                title: const Text(
                                                  "Login Berhasil",
                                                ),
                                                description: const Text(
                                                  "Selamat Datang Admin Wijaya Store",
                                                ),
                                                type:
                                                    ToastificationType.success,
                                                style: ToastificationStyle.flat,
                                                alignment: Alignment.topCenter,
                                                autoCloseDuration:
                                                    const Duration(seconds: 5),
                                                icon: const Icon(Icons.check),
                                              );
                                              await NotificationService.saveTokenToBackend();
                                              await Navigator.of(
                                                context,
                                              ).pushReplacement(
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const MainAdmin(),
                                                ),
                                              );
                                            } else if (result == "pembeli") {
                                              toastification.show(
                                                context: context,
                                                title: const Text(
                                                  "Login Berhasil",
                                                ),
                                                description: const Text(
                                                  "Selamat Datang, Silahkan Belanja",
                                                ),
                                                type:
                                                    ToastificationType.success,
                                                style: ToastificationStyle.flat,
                                                alignment: Alignment.topCenter,
                                                autoCloseDuration:
                                                    const Duration(seconds: 5),
                                                icon: const Icon(Icons.check),
                                              );
                                              await NotificationService.saveTokenToBackend();
                                              await Navigator.of(
                                                context,
                                              ).pushReplacement(
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const MainPembeli(),
                                                ),
                                              );
                                            } else if (result == "karyawan") {
                                              toastification.show(
                                                context: context,
                                                title: const Text(
                                                  "Login Berhasil",
                                                ),
                                                description: const Text(
                                                  "Semangat Pagi Karyawan Wijaya Store",
                                                ),
                                                type:
                                                    ToastificationType.success,
                                                style: ToastificationStyle.flat,
                                                alignment: Alignment.topCenter,
                                                autoCloseDuration:
                                                    const Duration(seconds: 5),
                                                icon: const Icon(Icons.check),
                                              );
                                              await NotificationService.saveTokenToBackend();
                                              await Navigator.of(
                                                context,
                                              ).pushReplacement(
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const MainKaryawan(),
                                                ),
                                              );
                                            } else {
                                              toastification.show(
                                                context: context,
                                                title: const Text(
                                                  "Login Gagal",
                                                ),
                                                description: Text(result!),
                                                type: ToastificationType.error,
                                                style: ToastificationStyle.flat,
                                                alignment: Alignment.topCenter,
                                                autoCloseDuration:
                                                    const Duration(seconds: 5),
                                                icon: const Icon(
                                                  Icons.error_outline,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            toastification.show(
                                              context: context,
                                              title: const Text("Login Gagal"),
                                              description: Text(
                                                "Terjadi kesalahan: $e",
                                              ),
                                              type: ToastificationType.error,
                                              style: ToastificationStyle.flat,
                                              alignment: Alignment.topCenter,
                                              autoCloseDuration: const Duration(
                                                seconds: 5,
                                              ),
                                              icon: const Icon(
                                                Icons.error_outline,
                                              ),
                                            );
                                          }
                                        } else {
                                          toastification.show(
                                            context: context,
                                            title: const Text("Login Gagal"),
                                            description: const Text(
                                              "Username dan Password tidak boleh kosong",
                                            ),
                                            type: ToastificationType.error,
                                            style: ToastificationStyle.flat,
                                            alignment: Alignment.topCenter,
                                            autoCloseDuration: const Duration(
                                              seconds: 5,
                                            ),
                                            icon: const Icon(
                                              Icons.error_outline,
                                            ),
                                          );
                                        }
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
                                      child: const Text(
                                        "LOGIN",
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
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Belum punya akun?",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: const Text(
                              " Daftar Sekarang",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

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

                      const SizedBox(height: 30),
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
}
