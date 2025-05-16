import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';

import 'package:frontend/pages/login_page/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      ); // Ganti dengan halaman utama Anda
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          "assets/animations/splash_screen1.json",
          frameRate: const FrameRate(60),
        ),
      ),
    );
  }
}
