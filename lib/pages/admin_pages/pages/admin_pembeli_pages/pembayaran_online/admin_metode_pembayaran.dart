import 'package:flutter/material.dart';

class AdminMetodePembayaran extends StatefulWidget {
  const AdminMetodePembayaran({super.key});

  @override
  State<AdminMetodePembayaran> createState() => _AdminMetodePembayaranState();
}

class _AdminMetodePembayaranState extends State<AdminMetodePembayaran> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metode Pembayaran'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Halaman Metode Pembayaran',
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
