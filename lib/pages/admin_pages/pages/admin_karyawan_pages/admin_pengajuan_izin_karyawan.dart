import 'package:flutter/material.dart';

class IzinKaryawanPage extends StatefulWidget {
  const IzinKaryawanPage({super.key});

  @override
  State<IzinKaryawanPage> createState() => _IzinKaryawanPageState();
}

class _IzinKaryawanPageState extends State<IzinKaryawanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan Izin Karyawan'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Halaman Pengajuan Izin Karyawan',
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
