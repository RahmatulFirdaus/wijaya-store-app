import 'package:flutter/material.dart';

class ProdukRestokPage extends StatefulWidget {
  const ProdukRestokPage({super.key});

  @override
  State<ProdukRestokPage> createState() => _ProdukRestokPageState();
}

class _ProdukRestokPageState extends State<ProdukRestokPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk Perlu Restok'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Halaman Produk Perlu Restok',
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
