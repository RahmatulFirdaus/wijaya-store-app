import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminUlasanProdukDetail extends StatefulWidget {
  final String productId;

  const AdminUlasanProdukDetail({super.key, required this.productId});

  @override
  State<AdminUlasanProdukDetail> createState() =>
      _AdminUlasanProdukDetailState();
}

class _AdminUlasanProdukDetailState extends State<AdminUlasanProdukDetail> {
  List<UlasanProduk> ulasanList = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUlasanData();
  }

  Future<void> _loadUlasanData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final data = await UlasanProduk.getDataUlasanProduk(widget.productId);

      setState(() {
        ulasanList = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    // Create star widget for PDF
    pw.Widget buildPDFStars(int rating) {
      return pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: List.generate(5, (index) {
          return pw.Container(
            width: 12,
            height: 12,
            margin: const pw.EdgeInsets.only(right: 2),
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: index < rating ? PdfColors.amber : PdfColors.grey300,
            ),
            child: pw.Center(
              child: pw.Text(
                '★',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: index < rating ? PdfColors.white : PdfColors.grey600,
                ),
              ),
            ),
          );
        }),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Column(
                children: [
                  pw.Text(
                    'LAPORAN ULASAN PRODUK',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Product ID: ${widget.productId}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    'Tanggal Cetak: ${DateTime.now().toString().split(' ')[0]}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(
                        'Total Ulasan',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('${ulasanList.length}'),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        'Rating Rata-rata',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        ulasanList.isEmpty
                            ? '0.0'
                            : (ulasanList
                                        .map((e) => e.rating)
                                        .reduce((a, b) => a + b) /
                                    ulasanList.length)
                                .toStringAsFixed(1),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Reviews List
            ...ulasanList.map((ulasan) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 30,
                          height: 30,
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            color: PdfColors.blue100,
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              ulasan.nama.isNotEmpty
                                  ? ulasan.nama[0].toUpperCase()
                                  : 'U',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue800,
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 12),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                ulasan.nama,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              buildPDFStars(ulasan.rating),
                            ],
                          ),
                        ),
                        pw.Text(
                          ulasan.tanggalKomentar,
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(ulasan.komentar, style: pw.TextStyle(fontSize: 11)),
                  ],
                ),
              );
            }).toList(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Ulasan Produk'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          if (ulasanList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _generatePDF,
              tooltip: 'Export PDF',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUlasanData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $errorMessage',
                        style: const TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _loadUlasanData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
                : ulasanList.isEmpty
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada ulasan untuk produk ini',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                )
                : Column(
                  children: [
                    // Summary Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '${ulasanList.length}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const Text(
                                'Total Ulasan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Container(width: 1, height: 40, color: Colors.grey),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    (ulasanList
                                                .map((e) => e.rating)
                                                .reduce((a, b) => a + b) /
                                            ulasanList.length)
                                        .toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ],
                              ),
                              const Text(
                                'Rating Rata-rata',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Reviews List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: ulasanList.length,
                        itemBuilder: (context, index) {
                          final ulasan = ulasanList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.grey[300],
                                        child: Text(
                                          ulasan.nama.isNotEmpty
                                              ? ulasan.nama[0].toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ulasan.nama,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            _buildStarRating(ulasan.rating),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        ulasan.tanggalKomentar,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    ulasan.komentar,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: Colors.black,
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
                ),
      ),
    );
  }
}
