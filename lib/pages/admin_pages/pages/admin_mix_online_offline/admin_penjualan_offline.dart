import 'package:flutter/material.dart';

class PenjualanOfflinePage extends StatefulWidget {
  const PenjualanOfflinePage({super.key});

  @override
  State<PenjualanOfflinePage> createState() => _PenjualanOfflinePageState();
}

class _PenjualanOfflinePageState extends State<PenjualanOfflinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penjualan Offline'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Halaman Penjualan Offline',
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
