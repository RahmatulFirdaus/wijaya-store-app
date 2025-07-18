import 'package:flutter/material.dart';
import 'package:frontend/models/karyawan_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:toastification/toastification.dart'; // Add this import

class PenjualanOfflinePage extends StatefulWidget {
  const PenjualanOfflinePage({super.key});

  @override
  State<PenjualanOfflinePage> createState() => _PenjualanOfflinePageState();
}

class _PenjualanOfflinePageState extends State<PenjualanOfflinePage>
    with TickerProviderStateMixin {
  final String baseUrl = "http://192.168.1.96:3000/uploads/";
  List<PenjualanOfflineKaryawan> penjualanList = [];
  bool isLoading = true;
  String searchQuery = '';
  String? selectedDate; // Filter tanggal yang dipilih
  final TextEditingController searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    loadData();
  }

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final data = await PenjualanOfflineKaryawan.getDataPenjualanOffline();
      setState(() {
        penjualanList = data;
        isLoading = false;
      });
      _animationController.forward();
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

  String _formatDateOnly(String dateTimeString) {
    try {
      // Parse dari format "YYYY-MM-DD HH:mm:ss"
      final parts = dateTimeString
          .split(' ')[0]
          .split('-'); // Ambil bagian tanggal saja
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}'; // Ubah ke DD/MM/YYYY
      }
      return dateTimeString;
    } catch (e) {
      return dateTimeString;
    }
  }

  DateTime _parseDate(String dateString) {
    try {
      // Assuming the date format is DD/MM/YYYY or similar
      final parts = dateString.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      }
      // If parsing fails, return current date
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  List<PenjualanOfflineKaryawan> get filteredPenjualanList {
    List<PenjualanOfflineKaryawan> filtered = penjualanList;

    // Apply date filter first
    if (selectedDate != null) {
      filtered =
          filtered.where((item) {
            final itemDateOnly = _formatDateOnly(item.tanggalPenjualan);
            return itemDateOnly == selectedDate;
          }).toList();
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered.where((item) {
            return item.namaProduk.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                item.namaKaryawan.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                item.warnaProduk.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                item.ukuranProduk.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
          }).toList();
    }

    return filtered;
  }

  Map<String, List<PenjualanOfflineKaryawan>> get groupedByDate {
    final filtered = filteredPenjualanList;
    final Map<String, List<PenjualanOfflineKaryawan>> grouped = {};

    for (final item in filtered) {
      // Gunakan fungsi _formatDateOnly untuk mendapatkan tanggal saja
      final dateOnly = _formatDateOnly(item.tanggalPenjualan);

      if (grouped[dateOnly] == null) {
        grouped[dateOnly] = [];
      }
      grouped[dateOnly]!.add(item);
    }

    // Sort by date (most recent first)
    final sortedKeys =
        grouped.keys.toList()..sort((a, b) {
          final dateA = _parseDate(a);
          final dateB = _parseDate(b);
          return dateB.compareTo(dateA);
        });

    final Map<String, List<PenjualanOfflineKaryawan>> sortedGrouped = {};
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  // Get unique dates for dropdown
  List<String> get availableDates {
    // Gunakan Set untuk menghindari duplikasi tanggal
    final dates =
        penjualanList
            .map((item) => _formatDateOnly(item.tanggalPenjualan))
            .toSet()
            .toList();

    dates.sort((a, b) {
      final dateA = _parseDate(a);
      final dateB = _parseDate(b);
      return dateB.compareTo(dateA);
    });
    return dates;
  }

  int _calculateTotalForDate(List<PenjualanOfflineKaryawan> items) {
    return items.fold(0, (total, item) {
      try {
        final price = int.parse(item.hargaProduk);
        final quantity = int.parse(item.jumlahProduk);
        return total + (price * quantity);
      } catch (e) {
        return total;
      }
    });
  }

  int get totalHargaKeseluruhan {
    return filteredPenjualanList.fold(0, (total, item) {
      try {
        final harga = int.parse(item.hargaProduk);
        final jumlah = int.parse(item.jumlahProduk);
        return total + (harga * jumlah);
      } catch (e) {
        return total;
      }
    });
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Function to generate PDF
  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    final filteredData = filteredPenjualanList;
    final groupedData = groupedByDate;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return <pw.Widget>[
            // Header
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Column(
                children: [
                  pw.Text(
                    'LAPORAN PENJUALAN OFFLINE',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    selectedDate != null
                        ? 'Tanggal: $selectedDate'
                        : 'Semua Tanggal',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Dicetak pada: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Item: ${filteredData.length}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Total Harga: ${_formatCurrency(totalHargaKeseluruhan)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Data by date
            ...groupedData.entries.map((entry) {
              final date = entry.key;
              final items = entry.value;
              final totalForDate = _calculateTotalForDate(items);

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Date header
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(4),
                      ),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Tanggal: $date',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          '${items.length} item - ${_formatCurrency(totalForDate)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  // Table
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1),
                      3: const pw.FlexColumnWidth(1),
                      4: const pw.FlexColumnWidth(1),
                      5: const pw.FlexColumnWidth(1.5),
                      6: const pw.FlexColumnWidth(1),
                    },
                    children: [
                      // Header
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey100,
                        ),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              'Produk',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              'Warna',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              'Ukuran',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              'Qty',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              'Harga',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              'Karyawan',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              'Subtotal',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Data rows
                      ...items.map(
                        (item) => pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                item.namaProduk,
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                item.warnaProduk,
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                item.ukuranProduk,
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                item.jumlahProduk,
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                _formatCurrency(int.parse(item.hargaProduk)),
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                item.namaKaryawan,
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                _formatCurrency(
                                  int.parse(item.hargaProduk) *
                                      int.parse(item.jumlahProduk),
                                ),
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16),
                ],
              );
            }).toList(),

            // Grand Total
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey800,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Text(
                'TOTAL KESELURUHAN: ${_formatCurrency(totalHargaKeseluruhan)}',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: pw.TextAlign.center,
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

  @override
  Widget build(BuildContext context) {
    final groupedData = groupedByDate;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 18,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Penjualan Offline',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          // PDF Export Button
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: filteredPenjualanList.isNotEmpty ? _generatePDF : null,
              icon: Icon(
                Icons.picture_as_pdf,
                color:
                    filteredPenjualanList.isNotEmpty
                        ? Colors.red.shade600
                        : Colors.grey.shade400,
                size: 24,
              ),
              tooltip: 'Export PDF',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Filter and Search Bar
          Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              children: [
                // Date Filter Dropdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: selectedDate,
                      hint: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pilih Tanggal',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey.shade600,
                      ),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Row(
                            children: [
                              Icon(
                                Icons.all_inclusive,
                                size: 18,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(width: 8),
                              const Text('Semua Tanggal'),
                            ],
                          ),
                        ),
                        ...availableDates.map(
                          (date) => DropdownMenuItem<String?>(
                            value: date,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: Colors.green.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(date),
                              ],
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedDate = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Cari produk, karyawan, atau varian...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                      suffixIcon:
                          searchQuery.isNotEmpty
                              ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey.shade600,
                                  size: 20,
                                ),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {
                                    searchQuery = '';
                                  });
                                },
                              )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active Filters Indicator
          if (selectedDate != null || searchQuery.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  if (selectedDate != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            selectedDate!,
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDate = null;
                              });
                            },
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (searchQuery.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search,
                            size: 14,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '"$searchQuery"',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              searchController.clear();
                              setState(() {
                                searchQuery = '';
                              });
                            },
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Results Counter
          if (filteredPenjualanList.isNotEmpty && !isLoading)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${filteredPenjualanList.length} item${filteredPenjualanList.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child:
                isLoading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Memuat data penjualan...',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : groupedData.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              searchQuery.isNotEmpty || selectedDate != null
                                  ? Icons.search_off
                                  : Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            searchQuery.isNotEmpty || selectedDate != null
                                ? 'Tidak ada hasil untuk filter ini'
                                : 'Belum ada data penjualan offline',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            searchQuery.isNotEmpty || selectedDate != null
                                ? 'Coba ubah filter atau kata kunci pencarian'
                                : 'Data akan muncul setelah ada transaksi',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                    : FadeTransition(
                      opacity: _fadeAnimation,
                      child: RefreshIndicator(
                        onRefresh: loadData,
                        color: Colors.black,
                        backgroundColor: Colors.white,
                        strokeWidth: 3,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          itemCount: groupedData.length,
                          itemBuilder: (context, dateIndex) {
                            final date = groupedData.keys.elementAt(dateIndex);
                            final items = groupedData[date]!;
                            final totalAmount = _calculateTotalForDate(items);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date Header with Total
                                Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 12,
                                    top: 16,
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.black, Color(0xFF333333)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            date,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${items.length} item${items.length > 1 ? 's' : ''}',
                                            style: TextStyle(
                                              color: Colors.grey.shade300,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            _formatCurrency(totalAmount),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Items for this date
                                ...items.asMap().entries.map((entry) {
                                  final itemIndex = entry.key;
                                  final item = entry.value;
                                  final globalIndex = penjualanList.indexOf(
                                    item,
                                  );

                                  return AnimatedContainer(
                                    duration: Duration(
                                      milliseconds: 300 + (itemIndex * 50),
                                    ),
                                    curve: Curves.easeOutQuart,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.06,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Enhanced Product Image
                                            Hero(
                                              tag: 'product_${globalIndex}',
                                              child: Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.grey.shade50,
                                                      Colors.grey.shade100,
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: Colors.grey.shade200,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  child:
                                                      item
                                                              .gambarProduk
                                                              .isNotEmpty
                                                          ? Image.network(
                                                            baseUrl +
                                                                item.gambarProduk,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Container(
                                                                decoration: BoxDecoration(
                                                                  gradient: LinearGradient(
                                                                    colors: [
                                                                      Colors
                                                                          .grey
                                                                          .shade100,
                                                                      Colors
                                                                          .grey
                                                                          .shade200,
                                                                    ],
                                                                    begin:
                                                                        Alignment
                                                                            .topLeft,
                                                                    end:
                                                                        Alignment
                                                                            .bottomRight,
                                                                  ),
                                                                ),
                                                                child: Icon(
                                                                  Icons
                                                                      .image_not_supported_outlined,
                                                                  color:
                                                                      Colors
                                                                          .grey
                                                                          .shade500,
                                                                  size: 32,
                                                                ),
                                                              );
                                                            },
                                                            loadingBuilder: (
                                                              context,
                                                              child,
                                                              loadingProgress,
                                                            ) {
                                                              if (loadingProgress ==
                                                                  null)
                                                                return child;
                                                              return Container(
                                                                decoration: BoxDecoration(
                                                                  gradient: LinearGradient(
                                                                    colors: [
                                                                      Colors
                                                                          .grey
                                                                          .shade100,
                                                                      Colors
                                                                          .grey
                                                                          .shade200,
                                                                    ],
                                                                    begin:
                                                                        Alignment
                                                                            .topLeft,
                                                                    end:
                                                                        Alignment
                                                                            .bottomRight,
                                                                  ),
                                                                ),
                                                                child: Center(
                                                                  child: SizedBox(
                                                                    width: 24,
                                                                    height: 24,
                                                                    child: CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
                                                                      valueColor: AlwaysStoppedAnimation<
                                                                        Color
                                                                      >(
                                                                        Colors
                                                                            .grey
                                                                            .shade400,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          )
                                                          : Container(
                                                            decoration: BoxDecoration(
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  Colors
                                                                      .grey
                                                                      .shade100,
                                                                  Colors
                                                                      .grey
                                                                      .shade200,
                                                                ],
                                                                begin:
                                                                    Alignment
                                                                        .topLeft,
                                                                end:
                                                                    Alignment
                                                                        .bottomRight,
                                                              ),
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .image_not_supported_outlined,
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade500,
                                                              size: 32,
                                                            ),
                                                          ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 16),

                                            // Enhanced Product Details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  _buildDetailRow(
                                                    'Nama Produk',
                                                    item.namaProduk,
                                                    Icons.local_offer_outlined,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _buildDetailRow(
                                                    'Spesifikasi',
                                                    '${item.warnaProduk} • ${item.ukuranProduk} • ${item.jumlahProduk} pcs',
                                                    Icons.tune_outlined,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _buildDetailRow(
                                                    'Harga',
                                                    _formatCurrency(
                                                      int.parse(
                                                        item.hargaProduk,
                                                      ),
                                                    ),
                                                    Icons.attach_money_outlined,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _buildDetailRow(
                                                    'Karyawan',
                                                    item.namaKaryawan,
                                                    Icons.person_outline,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _buildDetailRow(
                                                    'Subtotal',
                                                    _formatCurrency(
                                                      int.parse(
                                                            item.hargaProduk,
                                                          ) *
                                                          int.parse(
                                                            item.jumlahProduk,
                                                          ),
                                                    ),
                                                    Icons.receipt_outlined,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
          ),

          // Enhanced Total Harga Section
          if (filteredPenjualanList.isNotEmpty && !isLoading)
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade600, Colors.purple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Total Keseluruhan',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatCurrency(totalHargaKeseluruhan),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.inventory,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${filteredPenjualanList.length} Item',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (selectedDate != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tanggal: $selectedDate',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
