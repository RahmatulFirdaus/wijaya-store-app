import 'package:flutter/material.dart';

class PenjualanHarianPage extends StatefulWidget {
  const PenjualanHarianPage({super.key});

  @override
  State<PenjualanHarianPage> createState() => _PenjualanHarianPageState();
}

class _PenjualanHarianPageState extends State<PenjualanHarianPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penjualan Harian'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Halaman Penjualan Harian',
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
