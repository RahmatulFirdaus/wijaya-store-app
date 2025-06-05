import 'package:flutter/material.dart';

class AdminVerifikasiAkun extends StatefulWidget {
  const AdminVerifikasiAkun({super.key});

  @override
  State<AdminVerifikasiAkun> createState() => _AdminVerifikasiAkunState();
}

class _AdminVerifikasiAkunState extends State<AdminVerifikasiAkun> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Akun'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Halaman Verifikasi Akun',
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
