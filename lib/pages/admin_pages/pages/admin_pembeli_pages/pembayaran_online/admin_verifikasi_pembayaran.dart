import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/pembayaran_online/admin_verifikasi_pembayaran_edit/admin_verifikasi_pembayaran_edit.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminVerifikasiPembayaran extends StatefulWidget {
  const AdminVerifikasiPembayaran({super.key});

  @override
  State<AdminVerifikasiPembayaran> createState() =>
      _AdminVerifikasiPembayaranState();
}

class _AdminVerifikasiPembayaranState extends State<AdminVerifikasiPembayaran> {
  late Future<List<VerifikasiPembayaran>> _data;
  String selectedStatus = 'Semua';

  final String baseUrl = "http://192.168.1.96:3000/uploads/";

  @override
  void initState() {
    super.initState();
    _data = VerifikasiPembayaran.getDataVerifikasiPembayaran();
  }

  List<VerifikasiPembayaran> _filterData(List<VerifikasiPembayaran> data) {
    if (selectedStatus == 'Semua') return data;
    return data
        .where(
          (item) => item.status.toLowerCase() == selectedStatus.toLowerCase(),
        )
        .toList();
  }

  void _cetakPDF(List<VerifikasiPembayaran> data) {
    final pdf = pw.Document();

    for (var item in data) {
      pdf.addPage(
        pw.Page(
          build:
              (context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Nama Pengirim: ${item.namaPengirim}"),
                  pw.Text("Bank Pengirim: ${item.bankPengirim}"),
                  pw.Text("Tanggal Transfer: ${item.tanggalTransfer}"),
                  pw.Text("Status Pembayaran: ${item.status}"),
                  pw.Text("Catatan Admin: ${item.catatanAdmin ?? '-'}"),
                  pw.SizedBox(height: 20),
                ],
              ),
        ),
      );
    }

    Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Pembayaran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final data = await _data;
              _cetakPDF(_filterData(data));
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<VerifikasiPembayaran>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada data pembayaran"));
          }

          final verifikasiList = _filterData(snapshot.data!);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Text("Filter Status: "),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'berhasil',
                          child: Text('Berhasil'),
                        ),
                        DropdownMenuItem(value: 'gagal', child: Text('Gagal')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: verifikasiList.length,
                  itemBuilder: (context, index) {
                    final item = verifikasiList[index];
                    final imageUrl = baseUrl + item.buktiTransfer.first;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Nama Pengirim: ${item.namaPengirim}",
                                      ),
                                      Text(
                                        "Bank Pengirim: ${item.bankPengirim}",
                                      ),
                                      Text(
                                        "Tanggal Transfer: ${item.tanggalTransfer}",
                                      ),
                                      Text("Status Pembayaran: ${item.status}"),
                                      Text(
                                        "Catatan Admin: ${item.catatanAdmin ?? '-'}",
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 100,
                                            ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              AdminVerifikasiPembayaranEdit(
                                                pembayaran: item,
                                              ),
                                    ),
                                  );
                                },
                                child: const Text("Ubah"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
