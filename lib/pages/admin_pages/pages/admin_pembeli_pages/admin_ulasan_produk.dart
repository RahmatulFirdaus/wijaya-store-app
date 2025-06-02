import 'package:flutter/material.dart';

class UlasanProdukPage extends StatefulWidget {
  const UlasanProdukPage({super.key});

  @override
  State<UlasanProdukPage> createState() => _UlasanProdukPageState();
}

class _UlasanProdukPageState extends State<UlasanProdukPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulasan Produk'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Halaman Ulasan Produk',
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
