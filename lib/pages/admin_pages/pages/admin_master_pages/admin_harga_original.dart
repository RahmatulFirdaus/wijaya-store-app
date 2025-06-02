import 'package:flutter/material.dart';

class HargaOriginalPage extends StatefulWidget {
  const HargaOriginalPage({super.key});

  @override
  State<HargaOriginalPage> createState() => _HargaOriginalPageState();
}

class _HargaOriginalPageState extends State<HargaOriginalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harga Original'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Halaman Harga Original',
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
