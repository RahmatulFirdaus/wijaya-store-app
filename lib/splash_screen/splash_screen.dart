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
  int _currentStep = 1; // Menandai animasi ke-1 atau ke-2

  @override
  void initState() {
    super.initState();

    // Inisialisasi controller animasi untuk Lottie
    _controller = AnimationController(vsync: this);

    // Menangani saat animasi selesai dimainkan
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_currentStep == 1) {
          // Setelah animasi pertama selesai, ganti ke animasi kedua
          setState(() {
            _currentStep = 2;
          });
          _controller.reset(); // Reset controller sebelum animasi berikutnya
          // forward() akan dipanggil kembali di onLoaded animasi ke-2
        } else if (_currentStep == 2) {
          // Setelah animasi kedua selesai, pindah ke halaman LoginPage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      }
    });
  }

  @override
  //fungsi
  void dispose() {
    _controller.dispose(); // Hapus controller saat widget dibuang
    super.dispose();
  }

  // Mendapatkan path file animasi berdasarkan step saat ini
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
          _currentAnimationAsset, // Animasi berdasarkan step
          controller: _controller, // Controller yang mengatur durasi & play
          frameRate: FrameRate.max, // Mengatur frame rate maksimal (60 FPS)
          onLoaded: (composition) {
            // Atur durasi controller berdasarkan durasi animasi
            _controller.duration = composition.duration;
            _controller.forward(); // Mainkan animasi setelah durasi diketahui
          },
        ),
      ),
    );
  }
}
