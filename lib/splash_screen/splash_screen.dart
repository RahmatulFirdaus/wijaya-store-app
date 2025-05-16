import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:frontend/pages/login_page/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_currentStep == 1) {
          setState(() {
            _currentStep = 2;
          });
          _controller.reset(); // siapkan untuk animasi berikutnya
          // forward() akan dipanggil di onLoaded animasi kedua
        } else if (_currentStep == 2) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _currentAnimationAsset {
    if (_currentStep == 1) {
      return 'assets/animations/splash_screen1.json';
    } else {
      return 'assets/animations/splash_screen2.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          _currentAnimationAsset,
          controller: _controller,
          onLoaded: (composition) {
            _controller.duration = composition.duration;
            _controller.forward();
          },
        ),
      ),
    );
  }
}
