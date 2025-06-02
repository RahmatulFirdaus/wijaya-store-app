import 'package:flutter/material.dart';

class PembayaranOnlinePage extends StatefulWidget {
  const PembayaranOnlinePage({super.key});

  @override
  State<PembayaranOnlinePage> createState() => _PembayaranOnlinePageState();
}

class _PembayaranOnlinePageState extends State<PembayaranOnlinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Online'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Halaman Pembayaran Online',
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
