import 'package:flutter/material.dart';

class KeranjangPembeli extends StatefulWidget {
  const KeranjangPembeli({super.key});

  @override
  State<KeranjangPembeli> createState() => _KeranjangPembeliState();
}

class _KeranjangPembeliState extends State<KeranjangPembeli> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang Pembeli"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Selamat Datang di Halaman Keranjang Pembeli",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your action here
              },
              child: const Text("Lihat Produk di Keranjang"),
            ),
          ],
        ),
      ),
    );
  }
}
