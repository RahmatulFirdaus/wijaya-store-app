import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TransaksiOnlinePage extends StatefulWidget {
  const TransaksiOnlinePage({super.key});

  @override
  State<TransaksiOnlinePage> createState() => _TransaksiOnlinePageState();
}

class _TransaksiOnlinePageState extends State<TransaksiOnlinePage> {
  late Future<List<DataTransaksiOnline>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = DataTransaksiOnline.fetchDataTransaksiOnline();
  }

  Future<void> generatePDF(List<DataTransaksiOnline> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        header:
            (context) => pw.Container(
              alignment: pw.Alignment.centerLeft,
              margin: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LAPORAN TRANSAKSI ONLINE',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Container(height: 2, width: 200, color: PdfColors.black),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Tanggal Cetak: ${DateTime.now().toString().split(' ')[0]}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
        footer:
            (context) => pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ),
        build:
            (context) =>
                data.asMap().entries.map((entry) {
                  int index = entry.key;
                  DataTransaksiOnline transaksi = entry.value;

                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 20),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300, width: 1),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        // Header
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(12),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey100,
                            borderRadius: pw.BorderRadius.only(
                              topLeft: pw.Radius.circular(8),
                              topRight: pw.Radius.circular(8),
                            ),
                          ),
                          child: pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'TRANSAKSI #${(index + 1).toString().padLeft(3, '0')}',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: pw.BoxDecoration(
                                  color:
                                      transaksi.status.toLowerCase() ==
                                              'berhasil'
                                          ? PdfColors.green100
                                          : PdfColors.orange100,
                                  borderRadius: pw.BorderRadius.circular(12),
                                  border: pw.Border.all(
                                    color:
                                        transaksi.status.toLowerCase() ==
                                                'berhasil'
                                            ? PdfColors.green
                                            : PdfColors.orange,
                                    width: 0.5,
                                  ),
                                ),
                                child: pw.Text(
                                  transaksi.status.toUpperCase(),
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                    color:
                                        transaksi.status.toLowerCase() ==
                                                'berhasil'
                                            ? PdfColors.green800
                                            : PdfColors.orange800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Info Transaksi
                        pw.Container(
                          padding: const pw.EdgeInsets.all(12),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: _buildPdfInfoRow(
                                      'Pembeli',
                                      transaksi.namaPengguna,
                                    ),
                                  ),
                                  pw.SizedBox(width: 20),
                                  pw.Expanded(
                                    child: _buildPdfInfoRow(
                                      'Tanggal',
                                      transaksi.tanggalOrder,
                                    ),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 10),
                              pw.Text(
                                'DETAIL PRODUK:',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              // List Produk
                              ...transaksi.produk
                                  .map(
                                    (produk) => pw.Container(
                                      margin: const pw.EdgeInsets.only(
                                        bottom: 8,
                                      ),
                                      padding: const pw.EdgeInsets.all(8),
                                      decoration: pw.BoxDecoration(
                                        color: PdfColors.grey50,
                                        borderRadius: pw.BorderRadius.circular(
                                          4,
                                        ),
                                      ),
                                      child: pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                            produk.namaProduk,
                                            style: pw.TextStyle(
                                              fontSize: 9,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                          pw.SizedBox(height: 4),
                                          pw.Row(
                                            children: [
                                              pw.Expanded(
                                                child: pw.Column(
                                                  crossAxisAlignment:
                                                      pw
                                                          .CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    _buildPdfInfoRow(
                                                      'Warna',
                                                      produk.warna,
                                                    ),
                                                    _buildPdfInfoRow(
                                                      'Ukuran',
                                                      produk.ukuran.toString(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              pw.SizedBox(width: 10),
                                              pw.Expanded(
                                                child: pw.Column(
                                                  crossAxisAlignment:
                                                      pw
                                                          .CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    _buildPdfInfoRow(
                                                      'Jumlah',
                                                      '${produk.jumlahOrder} pcs',
                                                    ),
                                                    _buildPdfInfoRow(
                                                      'Harga',
                                                      'Rp ${produk.hargaSatuan}',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              pw.SizedBox(height: 10),
                              // Total
                              pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.grey100,
                                  borderRadius: pw.BorderRadius.circular(4),
                                  border: pw.Border.all(
                                    color: PdfColors.grey300,
                                  ),
                                ),
                                child: pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                      'TOTAL HARGA:',
                                      style: pw.TextStyle(
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.Text(
                                      'Rp ${transaksi.totalHarga}',
                                      style: pw.TextStyle(
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPdfInfoRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 60,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: isTotal ? 10 : 8,
                fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: isTotal ? 10 : 8,
                fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: isTotal ? PdfColors.black : PdfColors.grey800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                color: isHighlight ? Colors.black : Colors.grey[800],
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'berhasil':
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        icon = Icons.check_circle_outline;
        break;
      case 'proses':
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        icon = Icons.access_time;
        break;
      case 'pending':
        backgroundColor = Colors.yellow[50]!;
        textColor = Colors.yellow[700]!;
        icon = Icons.schedule;
        break;
      default:
        backgroundColor = Colors.grey[50]!;
        textColor = Colors.grey[700]!;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(DataTransaksiOnline transaksi, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          // Header Card
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'TRANSAKSI #${(index + 1).toString().padLeft(3, '0')}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                _buildStatusChip(transaksi.status),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Umum
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow('Pembeli', transaksi.namaPengguna),
                    ),
                    Expanded(
                      child: _buildInfoRow('Tanggal', transaksi.tanggalOrder),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Header Produk
                Text(
                  'Detail Produk (${transaksi.produk.length} item)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                // List Produk
                ...transaksi.produk
                    .map(
                      (produk) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produk.namaProduk,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow('Warna', produk.warna),
                                      _buildInfoRow(
                                        'Ukuran',
                                        produk.ukuran.toString(),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow(
                                        'Jumlah',
                                        '${produk.jumlahOrder} pcs',
                                      ),
                                      _buildInfoRow(
                                        'Harga',
                                        'Rp ${produk.hargaSatuan}',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                // Total
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Harga:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Rp ${transaksi.totalHarga}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Transaksi Online',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: FutureBuilder<List<DataTransaksiOnline>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Memuat data transaksi...',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada transaksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada data transaksi online yang tersedia.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            );
          } else {
            final data = snapshot.data!;
            // Hitung total item produk
            int totalItems = data.fold(
              0,
              (sum, transaksi) => sum + transaksi.produk.length,
            );

            return Stack(
              children: [
                Column(
                  children: [
                    // Stats Header
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'Total Transaksi',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${data.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white24,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'Total Item',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$totalItems',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white24,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'Berhasil',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${data.where((t) => t.status.toLowerCase() == 'berhasil').length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return buildCard(data[index], index);
                        },
                      ),
                    ),
                  ],
                ),
                // Floating Action Button
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton.extended(
                    onPressed: () => generatePDF(data),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text(
                      'Export PDF',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
