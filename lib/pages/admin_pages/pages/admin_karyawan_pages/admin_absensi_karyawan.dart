import 'package:flutter/material.dart';

class AbsensiKaryawanPage extends StatefulWidget {
  const AbsensiKaryawanPage({super.key});

  @override
  State<AbsensiKaryawanPage> createState() => _AbsensiKaryawanPageState();
}

class _AbsensiKaryawanPageState extends State<AbsensiKaryawanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Absensi Karyawan')),
      body: Center(child: Text('Halaman Absensi Karyawan')),
    );
  }
}
