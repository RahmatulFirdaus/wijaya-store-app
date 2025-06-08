import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/pembayaran_online/admin_metode_pembayaran_detail/admin_metode_pembayaran_edit.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/pembayaran_online/admin_metode_pembayaran_detail/admin_metode_pembayaran_tambah.dart';

class AdminMetodePembayaran extends StatefulWidget {
  const AdminMetodePembayaran({super.key});

  @override
  State<AdminMetodePembayaran> createState() => _AdminMetodePembayaranState();
}

class _AdminMetodePembayaranState extends State<AdminMetodePembayaran> {
  late Future<List<GetDataMetodePembayaran>> futureMetodePembayaran;

  @override
  void initState() {
    super.initState();
    futureMetodePembayaran = GetDataMetodePembayaran.getDataMetodePembayaran();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metode Pembayaran'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminMetodePembayaranTambah(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<GetDataMetodePembayaran>>(
        future: futureMetodePembayaran,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final metodeList = snapshot.data!;
          if (metodeList.isEmpty) {
            return const Center(child: Text('Belum ada metode pembayaran.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: metodeList.length,
            itemBuilder: (context, index) {
              final metode = metodeList[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.black, width: 1),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metode.nama_metode,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(metode.deskripsi),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AdminMetodePembayaranEdit(
                                        id: metode.id,
                                        namaMetode: metode.nama_metode,
                                        deskripsi: metode.deskripsi,
                                      ),
                                ),
                              );
                            },
                            child: const Text('Ubah'),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              HapusMetodePembayaranService.hapusMetodePembayaran(
                                metode.id,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text(
                              'Hapus',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
