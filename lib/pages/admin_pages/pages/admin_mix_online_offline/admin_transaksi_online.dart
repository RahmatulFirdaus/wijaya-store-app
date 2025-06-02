import 'package:flutter/material.dart';

class TransaksiOnlinePage extends StatefulWidget {
  const TransaksiOnlinePage({super.key});

  @override
  State<TransaksiOnlinePage> createState() => _TransaksiOnlinePageState();
}

class _TransaksiOnlinePageState extends State<TransaksiOnlinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Online'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Halaman Transaksi Online',
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
