import 'package:flutter/material.dart';

class MainPembeli extends StatefulWidget {
  const MainPembeli({super.key});

  @override
  State<MainPembeli> createState() => _MainPembeliState();
}

class _MainPembeliState extends State<MainPembeli> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Pembeli')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Welcome to the Pembeli Page!',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
