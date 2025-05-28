import 'package:flutter/material.dart';

class DetailRiwayatTransaksi extends StatefulWidget {
  const DetailRiwayatTransaksi({super.key});

  @override
  State<DetailRiwayatTransaksi> createState() => _DetailRiwayatTransaksiState();
}

class _DetailRiwayatTransaksiState extends State<DetailRiwayatTransaksi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Riwayat Transaksi'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          'Detail Riwayat Transaksi akan ditampilkan di sini.',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ),
    );
  }
}
