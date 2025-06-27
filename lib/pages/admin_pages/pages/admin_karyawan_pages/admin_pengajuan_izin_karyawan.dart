import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:frontend/pages/admin_pages/pages/admin_karyawan_pages/admin_pengajuan_izin_detail_karyawan.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class IzinKaryawanPage extends StatefulWidget {
  const IzinKaryawanPage({super.key});

  @override
  State<IzinKaryawanPage> createState() => _IzinKaryawanPageState();
}

class _IzinKaryawanPageState extends State<IzinKaryawanPage> {
  List<IzinKaryawan> dataIzin = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final data = await IzinKaryawan.getDataIzinKaryawan();
      setState(() {
        dataIzin = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'diterima':
      case 'approved':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: const Icon(Icons.check, color: Colors.black, size: 24),
        );
      case 'ditolak':
      case 'rejected':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: const Icon(Icons.close, color: Colors.black, size: 24),
        );
      case 'pending':
      default:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
        );
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'diterima':
      case 'approved':
        return 'Diterima';
      case 'ditolak':
      case 'rejected':
        return 'Ditolak';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    // Custom colors
    final primaryColor = PdfColor.fromHex('#1a1a1a');
    final accentColor = PdfColor.fromHex('#4f46e5');
    final lightGray = PdfColor.fromHex('#f8fafc');
    final mediumGray = PdfColor.fromHex('#e2e8f0');
    final darkGray = PdfColor.fromHex('#64748b');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 20),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'LAPORAN AJUAN IZIN KARYAWAN',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Tanggal Laporan',
                      style: pw.TextStyle(fontSize: 10, color: darkGray),
                    ),
                    pw.Text(
                      DateTime.now().toString().split(' ')[0],
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 20),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 1),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'HR Management System',
                  style: pw.TextStyle(fontSize: 10, color: darkGray),
                ),
                pw.Text(
                  'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                  style: pw.TextStyle(fontSize: 10, color: darkGray),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // Summary Cards
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: lightGray,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: mediumGray),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Total Ajuan',
                          style: pw.TextStyle(fontSize: 12, color: darkGray),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '${dataIzin.length}',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#dcfce7'),
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColor.fromHex('#bbf7d0')),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Diterima',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColor.fromHex('#15803d'),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '${dataIzin.where((izin) => izin.status.toLowerCase() == 'diterima' || izin.status.toLowerCase() == 'approved').length}',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#15803d'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#fef2f2'),
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColor.fromHex('#fecaca')),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Ditolak',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColor.fromHex('#dc2626'),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '${dataIzin.where((izin) => izin.status.toLowerCase() == 'ditolak' || izin.status.toLowerCase() == 'rejected').length}',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#dc2626'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#fef3c7'),
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColor.fromHex('#fde68a')),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Pending',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColor.fromHex('#d97706'),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '${dataIzin.where((izin) => izin.status.toLowerCase() == 'pending').length}',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#d97706'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 32),

            // Table Header
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 16),
              child: pw.Text(
                'Detail Ajuan Izin Karyawan',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),

            // Modern Table
            pw.Container(
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: mediumGray),
              ),
              child: pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(0.5),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(1.2),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(1.2),
                  5: const pw.FlexColumnWidth(1.2),
                  6: const pw.FlexColumnWidth(1),
                },
                children: [
                  // Modern Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                      borderRadius: const pw.BorderRadius.only(
                        topLeft: pw.Radius.circular(12),
                        topRight: pw.Radius.circular(12),
                      ),
                    ),
                    children: [
                      _buildTableHeader('No'),
                      _buildTableHeader('Nama Karyawan'),
                      _buildTableHeader('Tipe Izin'),
                      _buildTableHeader('Deskripsi'),
                      _buildTableHeader('Tanggal Mulai'),
                      _buildTableHeader('Tanggal Akhir'),
                      _buildTableHeader('Status'),
                    ],
                  ),

                  // Data rows with alternating colors
                  ...dataIzin.asMap().entries.map((entry) {
                    final index = entry.key;
                    final izin = entry.value;
                    final isEven = index % 2 == 0;

                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isEven ? PdfColors.white : lightGray,
                      ),
                      children: [
                        _buildTableCell('${index + 1}', isCenter: true),
                        _buildTableCell(izin.nama),
                        _buildTableCell(izin.tipeIzin),
                        _buildTableCell(izin.deskripsi, maxLines: 3),
                        _buildTableCell(izin.tanggalMulai, isCenter: true),
                        _buildTableCell(izin.tanggalAkhir, isCenter: true),
                        _buildStatusCell(izin.status),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Helper methods for table styling
  pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildTableCell(
    String text, {
    bool isCenter = false,
    int maxLines = 2,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#1a1a1a')),
        textAlign: isCenter ? pw.TextAlign.center : pw.TextAlign.left,
        maxLines: maxLines,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  pw.Widget _buildStatusCell(String status) {
    String statusText = _getStatusText(status);
    PdfColor bgColor;
    PdfColor textColor;

    switch (status.toLowerCase()) {
      case 'diterima':
      case 'approved':
        bgColor = PdfColor.fromHex('#dcfce7');
        textColor = PdfColor.fromHex('#15803d');
        break;
      case 'ditolak':
      case 'rejected':
        bgColor = PdfColor.fromHex('#fef2f2');
        textColor = PdfColor.fromHex('#dc2626');
        break;
      case 'pending':
      default:
        bgColor = PdfColor.fromHex('#fef3c7');
        textColor = PdfColor.fromHex('#d97706');
        break;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: pw.BoxDecoration(
          color: bgColor,
          borderRadius: pw.BorderRadius.circular(20),
        ),
        child: pw.Text(
          statusText,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: textColor,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AJUAN IZIN',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: loadData,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
              : error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi kesalahan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: loadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
              : dataIzin.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada data izin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: dataIzin.length,
                      itemBuilder: (context, index) {
                        final izin = dataIzin[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                _buildStatusIcon(izin.status),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              izin.nama,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.black,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              _getStatusText(izin.status),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        izin.tipeIzin,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        AdminPengajuanIzinDetailKaryawan(
                                                          izinId: izin.id,
                                                        ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                          ),
                                          child: const Text(
                                            'Lihat Detail',
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      floatingActionButton:
          dataIzin.isNotEmpty
              ? FloatingActionButton(
                onPressed: _generatePDF,
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                child: const Icon(Icons.picture_as_pdf),
              )
              : null,
    );
  }
}
