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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'berhasil':
        return Colors.green;
      case 'gagal':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'berhasil':
        return Icons.check_circle;
      case 'gagal':
        return Icons.cancel;
      case 'pending':
        return Icons.access_time;
      default:
        return Icons.help;
    }
  }

  void _cetakPDF(List<VerifikasiPembayaran> data) async {
    final pdf = pw.Document();

    // Custom theme untuk PDF
    final theme = pw.ThemeData.withFont(
      base: await PdfGoogleFonts.notoSansRegular(),
      bold: await PdfGoogleFonts.notoSansBold(),
    );

    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header:
            (context) => pw.Container(
              alignment: pw.Alignment.centerLeft,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LAPORAN VERIFIKASI PEMBAYARAN',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(height: 2, color: PdfColors.black),
                  pw.SizedBox(height: 16),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Tanggal Cetak: ${DateTime.now().toString().split(' ')[0]}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'Total Data: ${data.length}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        footer:
            (context) => pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
        build:
            (context) => [
              pw.ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 24),
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(8),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'DATA PEMBAYARAN #${index + 1}',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: pw.BoxDecoration(
                                color:
                                    item.status.toLowerCase() == 'berhasil'
                                        ? PdfColors.green100
                                        : item.status.toLowerCase() == 'gagal'
                                        ? PdfColors.red100
                                        : PdfColors.orange100,
                                borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(12),
                                ),
                              ),
                              child: pw.Text(
                                item.status.toUpperCase(),
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color:
                                      item.status.toLowerCase() == 'berhasil'
                                          ? PdfColors.green800
                                          : item.status.toLowerCase() == 'gagal'
                                          ? PdfColors.red800
                                          : PdfColors.orange800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 12),
                        pw.Table(
                          columnWidths: {
                            0: const pw.FlexColumnWidth(2),
                            1: const pw.FlexColumnWidth(3),
                          },
                          children: [
                            _buildTableRow('Nama Pengirim', item.namaPengirim),
                            _buildTableRow('Bank Pengirim', item.bankPengirim),
                            _buildTableRow(
                              'Tanggal Transfer',
                              item.tanggalTransfer,
                            ),
                            _buildTableRow(
                              'Catatan Admin',
                              item.catatanAdmin ?? '-',
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Verifikasi Pembayaran',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              onPressed: () async {
                final data = await _data;
                _cetakPDF(_filterData(data));
              },
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<VerifikasiPembayaran>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "Terjadi kesalahan: ${snapshot.error}",
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Tidak ada data pembayaran",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final verifikasiList = _filterData(snapshot.data!);

          return Column(
            children: [
              // Filter Section
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, color: Colors.black),
                    const SizedBox(width: 12),
                    const Text(
                      "Filter Status:",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          value: selectedStatus,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: 'Semua',
                              child: Text('Semua Status'),
                            ),
                            DropdownMenuItem(
                              value: 'pending',
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: 'berhasil',
                              child: Text('Berhasil'),
                            ),
                            DropdownMenuItem(
                              value: 'gagal',
                              child: Text('Gagal'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Data Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      "Menampilkan ${verifikasiList.length} dari ${snapshot.data!.length} data",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // List Data
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: verifikasiList.length,
                  itemBuilder: (context, index) {
                    final item = verifikasiList[index];
                    final imageUrl = baseUrl + item.buktiTransfer.first;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header with Status
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getStatusIcon(item.status),
                                  color: _getStatusColor(item.status),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Pembayaran #${index + 1}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      item.status,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    item.status.toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(item.status),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Content
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow(
                                        Icons.person_outline,
                                        "Nama Pengirim",
                                        item.namaPengirim,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        Icons.account_balance,
                                        "Bank Pengirim",
                                        item.bankPengirim,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        Icons.calendar_today_outlined,
                                        "Tanggal Transfer",
                                        item.tanggalTransfer,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        Icons.note_outlined,
                                        "Catatan Admin",
                                        item.catatanAdmin ?? '-',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      imageUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 100,
                                                height: 100,
                                                color: Colors.grey[100],
                                                child: const Icon(
                                                  Icons.broken_image_outlined,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Action Button
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48,
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      "Edit Verifikasi",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
