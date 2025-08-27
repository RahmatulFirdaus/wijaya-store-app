import 'package:flutter/material.dart';
import 'package:frontend/splash_screen/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wijaya',
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      home: SplashScreen(),
    );
  }
}
