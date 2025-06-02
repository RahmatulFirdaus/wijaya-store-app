import 'package:flutter/material.dart';

class FakturOnlinePage extends StatefulWidget {
  const FakturOnlinePage({super.key});

  @override
  State<FakturOnlinePage> createState() => _FakturOnlinePageState();
}

class _FakturOnlinePageState extends State<FakturOnlinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faktur Online'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Halaman Faktur Online',
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
