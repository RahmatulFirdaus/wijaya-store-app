import 'package:flutter/material.dart';

class AdminVerifikasiPembayaran extends StatefulWidget {
  const AdminVerifikasiPembayaran({super.key});

  @override
  State<AdminVerifikasiPembayaran> createState() =>
      _AdminVerifikasiPembayaranState();
}

class _AdminVerifikasiPembayaranState extends State<AdminVerifikasiPembayaran> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Pembayaran'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Halaman Verifikasi Pembayaran',
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
