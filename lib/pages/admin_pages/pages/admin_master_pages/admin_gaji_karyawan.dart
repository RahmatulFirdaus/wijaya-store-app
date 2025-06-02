import 'package:flutter/material.dart';

class AdminGajiKaryawan extends StatefulWidget {
  const AdminGajiKaryawan({super.key});

  @override
  State<AdminGajiKaryawan> createState() => _AdminGajiKaryawanState();
}

class _AdminGajiKaryawanState extends State<AdminGajiKaryawan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gaji Karyawan'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Halaman Gaji Karyawan',
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
