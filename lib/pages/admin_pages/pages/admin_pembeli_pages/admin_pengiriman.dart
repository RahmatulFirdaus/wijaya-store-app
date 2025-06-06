import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/admin_pengiriman_detail.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:toastification/toastification.dart';

class PengirimanPage extends StatefulWidget {
  const PengirimanPage({super.key});

  @override
  State<PengirimanPage> createState() => _PengirimanPageState();
}

class _PengirimanPageState extends State<PengirimanPage> {
  List<DetailPengiriman> pengirimanList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPengirimanData();
  }

  Future<void> _loadPengirimanData() async {
    try {
      final data = await DetailPengiriman.getPengiriman();
      setState(() {
        pengirimanList = data ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        toastification.show(
          context: context,
          title: Text('Error loading data: $e'),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 4),
          alignment: Alignment.bottomCenter,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return Colors.orange;
      case 'dikirim':
        return Colors.blue;
      case 'diterima':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return Icons.hourglass_empty;
      case 'dikirim':
        return Icons.local_shipping;
      case 'diterima':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header Laporan
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.only(bottom: 30),
              child: pw.Column(
                children: [
                  pw.Text(
                    'LAPORAN DATA PENGIRIMAN',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Tanggal Cetak: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                ],
              ),
            ),

            // Ringkasan Data
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(
                        'Total Pengiriman',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        '${pengirimanList.length}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        'Diproses',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.orange,
                        ),
                      ),
                      pw.Text(
                        '${pengirimanList.where((p) => p.statusPengiriman.toLowerCase() == 'diproses').length}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.orange,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        'Dikirim',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.blue,
                        ),
                      ),
                      pw.Text(
                        '${pengirimanList.where((p) => p.statusPengiriman.toLowerCase() == 'dikirim').length}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        'Diterima',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.green,
                        ),
                      ),
                      pw.Text(
                        '${pengirimanList.where((p) => p.statusPengiriman.toLowerCase() == 'diterima').length}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 25),

            // Detail Pengiriman
            pw.Text(
              'DETAIL PENGIRIMAN',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 15),

            // Loop untuk setiap pengiriman
            ...pengirimanList.map((pengiriman) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header Pengiriman
                    pw.Container(
                      padding: const pw.EdgeInsets.only(bottom: 10),
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(color: PdfColors.grey300),
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            pengiriman.namaPengguna,
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: pw.BoxDecoration(
                              color: _getPdfStatusColor(
                                pengiriman.statusPengiriman,
                              ),
                              borderRadius: pw.BorderRadius.circular(10),
                            ),
                            child: pw.Text(
                              pengiriman.statusPengiriman.toUpperCase(),
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 10),

                    // Info Pengiriman
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Kolom Kiri
                        pw.Expanded(
                          flex: 2,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildPdfInfoRow(
                                'Alamat:',
                                pengiriman.alamatPengiriman,
                              ),
                              pw.SizedBox(height: 5),
                              _buildPdfInfoRow(
                                'Tanggal:',
                                pengiriman.tanggalPengiriman,
                              ),
                              pw.SizedBox(height: 5),
                              _buildPdfInfoRow(
                                'Total:',
                                'Rp ${pengiriman.totalHarga}',
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 20),
                        // Kolom Kanan - Produk
                        pw.Expanded(
                          flex: 3,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'PRODUK YANG DIPESAN:',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.SizedBox(height: 8),
                              // Tabel Produk
                              pw.Table(
                                border: pw.TableBorder.all(
                                  color: PdfColors.grey300,
                                  width: 0.5,
                                ),
                                columnWidths: {
                                  0: const pw.FlexColumnWidth(3),
                                  1: const pw.FlexColumnWidth(1.5),
                                  2: const pw.FlexColumnWidth(1.5),
                                  3: const pw.FlexColumnWidth(1),
                                },
                                children: [
                                  // Header Tabel
                                  pw.TableRow(
                                    decoration: const pw.BoxDecoration(
                                      color: PdfColors.grey200,
                                    ),
                                    children: [
                                      _buildTableCell(
                                        'Nama Produk',
                                        isHeader: true,
                                      ),
                                      _buildTableCell('Warna', isHeader: true),
                                      _buildTableCell('Ukuran', isHeader: true),
                                      _buildTableCell('Qty', isHeader: true),
                                    ],
                                  ),
                                  // Data Produk
                                  ...pengiriman.items.map((item) {
                                    return pw.TableRow(
                                      children: [
                                        _buildTableCell(item.nama ?? '-'),
                                        _buildTableCell(item.warna ?? '-'),
                                        _buildTableCell(
                                          item.ukuran.toString() ?? '-',
                                        ),
                                        _buildTableCell(
                                          '${item.jumlahOrder ?? 0}',
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Helper untuk warna status di PDF
  PdfColor _getPdfStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return PdfColors.orange;
      case 'dikirim':
        return PdfColors.blue;
      case 'diterima':
        return PdfColors.green;
      default:
        return PdfColors.grey;
    }
  }

  // Helper untuk info row di PDF
  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 45,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.normal),
          ),
        ),
      ],
    );
  }

  // Helper untuk cell tabel
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.black : PdfColors.grey800,
        ),
        textAlign: pw.TextAlign.center,
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
        foregroundColor: Colors.black,
        title: const Text(
          'Pengiriman',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _generatePDF,
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
          ),
          IconButton(
            onPressed: _loadPengirimanData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
              : pengirimanList.isEmpty
              ? const Center(
                child: Text(
                  'Tidak ada data pengiriman',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: pengirimanList.length,
                  itemBuilder: (context, index) {
                    final pengiriman = pengirimanList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header dengan Nama dan Status (ID dihapus)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    pengiriman.namaPengguna,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      pengiriman.statusPengiriman,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _getStatusColor(
                                        pengiriman.statusPengiriman,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getStatusIcon(
                                          pengiriman.statusPengiriman,
                                        ),
                                        size: 14,
                                        color: _getStatusColor(
                                          pengiriman.statusPengiriman,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        pengiriman.statusPengiriman,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: _getStatusColor(
                                            pengiriman.statusPengiriman,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Alamat
                            _buildInfoRow(
                              Icons.location_on_outlined,
                              'Alamat Pengiriman',
                              pengiriman.alamatPengiriman,
                            ),
                            const SizedBox(height: 8),

                            // Tanggal
                            _buildInfoRow(
                              Icons.calendar_today_outlined,
                              'Tanggal Pengiriman',
                              pengiriman.tanggalPengiriman,
                            ),
                            const SizedBox(height: 8),

                            // Total Harga
                            _buildInfoRow(
                              Icons.attach_money_outlined,
                              'Total Harga',
                              'Rp ${pengiriman.totalHarga}',
                            ),
                            const SizedBox(height: 8),

                            // Jumlah Item
                            _buildInfoRow(
                              Icons.inventory_2_outlined,
                              'Jumlah Item',
                              '${pengiriman.items.length} produk',
                            ),

                            const SizedBox(height: 16),

                            // Tombol Ubah Status
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AdminPengirimanDetail(
                                            idPengiriman:
                                                pengiriman.idPengiriman,
                                          ),
                                    ),
                                  ).then((_) => _loadPengirimanData());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Ubah Status',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
