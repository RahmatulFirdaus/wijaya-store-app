import 'package:flutter/material.dart';

class MainKaryawan extends StatefulWidget {
  const MainKaryawan({super.key});

  @override
  State<MainKaryawan> createState() => _MainKaryawanState();
}

class _MainKaryawanState extends State<MainKaryawan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Main Karyawan')),
      body: Center(child: Text('Welcome to the Karyawan Page!')),
    );
  }
}
