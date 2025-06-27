import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AbsensiKaryawanPage extends StatefulWidget {
  const AbsensiKaryawanPage({super.key});

  @override
  State<AbsensiKaryawanPage> createState() => _AbsensiKaryawanPageState();
}

class _AbsensiKaryawanPageState extends State<AbsensiKaryawanPage> {
  List<AbsensiKaryawan> _absensiList = [];
  List<AbsensiKaryawan> _filteredAbsensiList = [];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadAbsensiData();
  }

  Future<void> _loadAbsensiData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final data = await AbsensiKaryawan.getDataAbsensiKaryawan();
      setState(() {
        _absensiList = data;
        _filteredAbsensiList = data;
        _isLoading = false;
      });
      _applyDateFilter();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyDateFilter() {
    if (_selectedDate != null) {
      String selectedDateStr =
          "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
      setState(() {
        _filteredAbsensiList =
            _absensiList.where((absensi) {
              return absensi.tanggal.contains(selectedDateStr);
            }).toList();
      });
    } else {
      setState(() {
        _filteredAbsensiList = _absensiList;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _applyDateFilter();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
    _applyDateFilter();
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    final dataToExport = _filteredAbsensiList;

    // Modern color palette
    final primaryColor = PdfColor.fromHex('#2563EB'); // Modern blue
    final secondaryColor = PdfColor.fromHex('#F8FAFC'); // Light gray
    final accentColor = PdfColor.fromHex('#10B981'); // Modern green
    final textDark = PdfColor.fromHex('#1F2937'); // Dark gray
    final textLight = PdfColor.fromHex('#6B7280'); // Light gray

    String reportTitle = 'LAPORAN ABSENSI KARYAWAN';
    String dateSubtitle = '';
    if (_selectedDate != null) {
      String formattedDate =
          "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
      dateSubtitle = 'Periode: $formattedDate';
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            // Modern Header with gradient-like effect
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    reportTitle,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  if (dateSubtitle.isNotEmpty) ...[
                    pw.SizedBox(height: 8),
                    pw.Text(
                      dateSubtitle,
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.white.shade(0.9),
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Info Card
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: secondaryColor,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(
                  color: PdfColor.fromHex('#E5E7EB'),
                  width: 1,
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Tanggal Cetak',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: textLight,
                          fontWeight: pw.FontWeight.normal,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        DateTime.now().toString().split(' ')[0],
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: textDark,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Total Records',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: textLight,
                          fontWeight: pw.FontWeight.normal,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '${dataToExport.length}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: accentColor,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Modern Table
            pw.Container(
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(
                  color: PdfColor.fromHex('#E5E7EB'),
                  width: 1,
                ),
              ),
              child: pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(0.8),
                  1: const pw.FlexColumnWidth(2.5),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Modern Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                      borderRadius: const pw.BorderRadius.only(
                        topLeft: pw.Radius.circular(8),
                        topRight: pw.Radius.circular(8),
                      ),
                    ),
                    children: [
                      _buildTableHeader('No'),
                      _buildTableHeader('Nama Karyawan'),
                      _buildTableHeader('Tanggal'),
                      _buildTableHeader('Status Absen'),
                    ],
                  ),
                  // Data rows with alternating colors
                  ...dataToExport.asMap().entries.map((entry) {
                    int index = entry.key;
                    AbsensiKaryawan absensi = entry.value;
                    bool isEven = index % 2 == 0;

                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isEven ? PdfColors.white : secondaryColor,
                      ),
                      children: [
                        _buildTableCell('${index + 1}', isCenter: true),
                        _buildTableCell(absensi.nama),
                        _buildTableCell(absensi.tanggal, isCenter: true),
                        _buildStatusCell(absensi.absenMasuk),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),

            pw.SizedBox(height: 32),

            // Modern Footer
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F9FAFB'),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Generated by Rahmatul Firdaus',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: textLight,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
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

  // Helper method for table headers
  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 12,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // Helper method for table cells
  pw.Widget _buildTableCell(String text, {bool isCenter = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 11, color: PdfColor.fromHex('#374151')),
        textAlign: isCenter ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  // Helper method for status cells with color coding
  pw.Widget _buildStatusCell(String status) {
    PdfColor statusColor;
    PdfColor bgColor;

    switch (status.toLowerCase()) {
      case 'hadir':
      case 'present':
        statusColor = PdfColor.fromHex('#059669'); // Green
        bgColor = PdfColor.fromHex('#D1FAE5'); // Light green
        break;
      case 'sakit':
      case 'sick':
        statusColor = PdfColor.fromHex('#DC2626'); // Red
        bgColor = PdfColor.fromHex('#FEE2E2'); // Light red
        break;
      case 'izin':
      case 'permission':
        statusColor = PdfColor.fromHex('#D97706'); // Orange
        bgColor = PdfColor.fromHex('#FED7AA'); // Light orange
        break;
      case 'alpha':
      case 'absent':
        statusColor = PdfColor.fromHex('#7C2D12'); // Dark red
        bgColor = PdfColor.fromHex('#FEE2E2'); // Light red
        break;
      default:
        statusColor = PdfColor.fromHex('#6B7280'); // Gray
        bgColor = PdfColor.fromHex('#F3F4F6'); // Light gray
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Center(
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: bgColor,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            status,
            style: pw.TextStyle(
              fontSize: 10,
              color: statusColor,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),
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
          'Absensi Karyawan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat data',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadAbsensiData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Filter Section
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filter Tanggal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 20,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _selectedDate != null
                                            ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                            : "Pilih Tanggal",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              _selectedDate != null
                                                  ? Colors.black
                                                  : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (_selectedDate != null) ...[
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: _clearDateFilter,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.clear,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (_selectedDate != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Menampilkan ${_filteredAbsensiList.length} data dari ${_absensiList.length} total data',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        _filteredAbsensiList.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _selectedDate != null
                                        ? 'Tidak ada data absensi\npada tanggal yang dipilih'
                                        : 'Tidak ada data absensi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                            : RefreshIndicator(
                              onRefresh: _loadAbsensiData,
                              color: Colors.black,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: _filteredAbsensiList.length,
                                itemBuilder: (context, index) {
                                  final absensi = _filteredAbsensiList[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: const Icon(
                                              Icons.person_outline,
                                              color: Colors.black54,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  absensi.nama,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Status: ${absensi.absenMasuk}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Tanggal: ${absensi.tanggal}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
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
                  ),
                  if (_filteredAbsensiList.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _generatePDF,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Export PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
    );
  }
}
