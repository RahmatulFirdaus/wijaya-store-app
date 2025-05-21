import 'package:flutter/material.dart';

class RiwayatTransaksiPembeli extends StatefulWidget {
  const RiwayatTransaksiPembeli({super.key});

  @override
  State<RiwayatTransaksiPembeli> createState() =>
      _RiwayatTransaksiPembeliState();
}

class _RiwayatTransaksiPembeliState extends State<RiwayatTransaksiPembeli> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Transaksi"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Riwayat Transaksi Pembeli",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your action here
              },
              child: const Text("Lihat Detail Transaksi"),
            ),
          ],
        ),
      ),
    );
  }
}
