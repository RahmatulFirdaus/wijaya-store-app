import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminUlasanProdukDetail extends StatefulWidget {
  final String productId, productName;

  const AdminUlasanProdukDetail({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<AdminUlasanProdukDetail> createState() =>
      _AdminUlasanProdukDetailState();
}

class _AdminUlasanProdukDetailState extends State<AdminUlasanProdukDetail> {
  List<UlasanProduk> ulasanList = [];
  List<UlasanProduk> filteredUlasanList = [];
  bool isLoading = true;
  String errorMessage = '';

  // Filter variables
  int? selectedRating;
  String sortBy = 'terbaru'; // terbaru, terlama, rating_tinggi, rating_rendah
  DateTime? startDate;
  DateTime? endDate;
  bool showFilters = false;

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
        filteredUlasanList = data;
        isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      filteredUlasanList =
          ulasanList.where((ulasan) {
            // Filter by rating
            if (selectedRating != null && ulasan.rating != selectedRating) {
              return false;
            }

            // Filter by date range
            if (startDate != null || endDate != null) {
              try {
                DateTime ulasanDate = DateTime.parse(ulasan.tanggalKomentar);
                if (startDate != null && ulasanDate.isBefore(startDate!)) {
                  return false;
                }
                if (endDate != null && ulasanDate.isAfter(endDate!)) {
                  return false;
                }
              } catch (e) {
                // If date parsing fails, include the review
                return true;
              }
            }

            return true;
          }).toList();

      // Apply sorting
      switch (sortBy) {
        case 'terlama':
          filteredUlasanList.sort((a, b) {
            try {
              return DateTime.parse(
                a.tanggalKomentar,
              ).compareTo(DateTime.parse(b.tanggalKomentar));
            } catch (e) {
              return 0;
            }
          });
          break;
        case 'rating_tinggi':
          filteredUlasanList.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'rating_rendah':
          filteredUlasanList.sort((a, b) => a.rating.compareTo(b.rating));
          break;
        case 'terbaru':
        default:
          filteredUlasanList.sort((a, b) {
            try {
              return DateTime.parse(
                b.tanggalKomentar,
              ).compareTo(DateTime.parse(a.tanggalKomentar));
            } catch (e) {
              return 0;
            }
          });
          break;
      }
    });
  }

  void _clearFilters() {
    setState(() {
      selectedRating = null;
      startDate = null;
      endDate = null;
      sortBy = 'terbaru';
      filteredUlasanList = ulasanList;
    });
    _applyFilters();
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    if (!showFilters) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Filter
          const Text(
            'Filter Rating:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            children: [
              _buildFilterChip('Semua', selectedRating == null, () {
                setState(() => selectedRating = null);
                _applyFilters();
              }),
              for (int i = 1; i <= 5; i++)
                _buildFilterChip('$i★', selectedRating == i, () {
                  setState(() => selectedRating = i);
                  _applyFilters();
                }),
            ],
          ),

          const SizedBox(height: 16),

          // Sort Filter
          const Text('Urutkan:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            children: [
              _buildFilterChip('Terbaru', sortBy == 'terbaru', () {
                setState(() => sortBy = 'terbaru');
                _applyFilters();
              }),
              _buildFilterChip('Terlama', sortBy == 'terlama', () {
                setState(() => sortBy = 'terlama');
                _applyFilters();
              }),
              _buildFilterChip('Rating Tinggi', sortBy == 'rating_tinggi', () {
                setState(() => sortBy = 'rating_tinggi');
                _applyFilters();
              }),
              _buildFilterChip('Rating Rendah', sortBy == 'rating_rendah', () {
                setState(() => sortBy = 'rating_rendah');
                _applyFilters();
              }),
            ],
          ),

          const SizedBox(height: 16),

          // Date Range Filter
          const Text(
            'Filter Tanggal:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => startDate = date);
                      _applyFilters();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      startDate != null
                          ? 'Dari: ${startDate!.day}/${startDate!.month}/${startDate!.year}'
                          : 'Pilih tanggal mulai',
                      style: TextStyle(
                        color: startDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => endDate = date);
                      _applyFilters();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      endDate != null
                          ? 'Sampai: ${endDate!.day}/${endDate!.month}/${endDate!.year}'
                          : 'Pilih tanggal akhir',
                      style: TextStyle(
                        color: endDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Clear Filters Button
          Center(
            child: TextButton(
              onPressed: _clearFilters,
              child: const Text('Reset Filter'),
            ),
          ),
        ],
      ),
    );
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
            width: 10,
            height: 10,
            margin: const pw.EdgeInsets.only(right: 1),
            child: pw.Text(
              '★',
              style: pw.TextStyle(
                fontSize: 8,
                color: index < rating ? PdfColors.orange : PdfColors.grey400,
              ),
            ),
          );
        }),
      );
    }

    // Calculate statistics for filtered data
    final totalReviews = filteredUlasanList.length;
    final avgRating =
        totalReviews > 0
            ? filteredUlasanList.map((e) => e.rating).reduce((a, b) => a + b) /
                totalReviews
            : 0.0;

    // Rating distribution
    Map<int, int> ratingDistribution = {};
    for (int i = 1; i <= 5; i++) {
      ratingDistribution[i] =
          filteredUlasanList.where((u) => u.rating == i).length;
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
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    widget.productName,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Tanggal Cetak: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Container(
                    margin: const pw.EdgeInsets.symmetric(vertical: 10),
                    height: 2,
                    color: PdfColors.blue800,
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Filter Information
            if (selectedRating != null ||
                startDate != null ||
                endDate != null ||
                sortBy != 'terbaru')
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Filter yang Diterapkan:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    if (selectedRating != null)
                      pw.Text('• Rating: $selectedRating bintang'),
                    if (startDate != null)
                      pw.Text(
                        '• Tanggal mulai: ${startDate!.day}/${startDate!.month}/${startDate!.year}',
                      ),
                    if (endDate != null)
                      pw.Text(
                        '• Tanggal akhir: ${endDate!.day}/${endDate!.month}/${endDate!.year}',
                      ),
                    if (sortBy != 'terbaru') pw.Text('• Diurutkan: $sortBy'),
                  ],
                ),
              ),

            pw.SizedBox(height: 20),

            // Enhanced Summary with Rating Distribution
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  // Main Stats
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      pw.Column(
                        children: [
                          pw.Text(
                            'Total Ulasan',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          pw.Text(
                            '$totalReviews',
                            style: const pw.TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text(
                            'Rating Rata-rata',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                avgRating.toStringAsFixed(1),
                                style: const pw.TextStyle(fontSize: 18),
                              ),
                              pw.SizedBox(width: 4),
                              buildPDFStars(avgRating.round()),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 16),
                  pw.Divider(),
                  pw.SizedBox(height: 8),

                  // Rating Distribution
                  pw.Text(
                    'Distribusi Rating:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  ...List.generate(5, (index) {
                    int rating = 5 - index;
                    int count = ratingDistribution[rating] ?? 0;
                    double percentage =
                        totalReviews > 0 ? (count / totalReviews) * 100 : 0;

                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 4),
                      child: pw.Row(
                        children: [
                          pw.Text(
                            '$rating',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                          pw.SizedBox(width: 4),
                          buildPDFStars(rating),
                          pw.SizedBox(width: 8),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Stack(
                              children: [
                                pw.Container(
                                  height: 12,
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.grey300,
                                    borderRadius: pw.BorderRadius.circular(6),
                                  ),
                                ),
                                pw.Container(
                                  height: 12,
                                  width:
                                      percentage *
                                      2, // Approximate width based on percentage
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.blue,
                                    borderRadius: pw.BorderRadius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Text(
                            '$count (${percentage.toStringAsFixed(1)}%)',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Reviews List Header
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 8),
              child: pw.Text(
                'Daftar Ulasan (${filteredUlasanList.length} ulasan)',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            // Reviews List
            ...filteredUlasanList.asMap().entries.map((entry) {
              int index = entry.key;
              UlasanProduk ulasan = entry.value;

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                  color: index % 2 == 0 ? PdfColors.white : PdfColors.grey50,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // User Avatar
                        pw.Container(
                          width: 24,
                          height: 24,
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            color: PdfColors.blue200,
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              ulasan.nama.isNotEmpty
                                  ? ulasan.nama[0].toUpperCase()
                                  : 'U',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                                color: PdfColors.blue800,
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                ulasan.nama,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Row(
                                children: [
                                  buildPDFStars(ulasan.rating),
                                  pw.SizedBox(width: 4),
                                  pw.Text(
                                    '(${ulasan.rating}/5)',
                                    style: const pw.TextStyle(
                                      fontSize: 9,
                                      color: PdfColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        pw.Text(
                          ulasan.tanggalKomentar,
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Container(
                      padding: const pw.EdgeInsets.only(left: 32),
                      child: pw.Text(
                        ulasan.komentar,
                        style: const pw.TextStyle(fontSize: 10, height: 1.3),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            // Footer
            pw.SizedBox(height: 20),
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text(
                'Laporan ini digenerate secara otomatis pada ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Ulasan Produk'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(
              showFilters ? Icons.filter_list : Icons.filter_list_outlined,
            ),
            onPressed: () {
              setState(() => showFilters = !showFilters);
            },
            tooltip: 'Filter',
          ),
          if (filteredUlasanList.isNotEmpty)
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
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
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
                : Column(
                  children: [
                    // Filters Section
                    _buildFiltersSection(),
                    if (showFilters) const SizedBox(height: 16),

                    // Summary Card
                    if (ulasanList.isNotEmpty)
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
                                  '${filteredUlasanList.length}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  filteredUlasanList.length != ulasanList.length
                                      ? 'dari ${ulasanList.length} Ulasan'
                                      : 'Total Ulasan',
                                  style: const TextStyle(
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
                                      filteredUlasanList.isEmpty
                                          ? '0.0'
                                          : (filteredUlasanList
                                                      .map((e) => e.rating)
                                                      .reduce((a, b) => a + b) /
                                                  filteredUlasanList.length)
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

                    // Reviews List or Empty State
                    Expanded(
                      child:
                          filteredUlasanList.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      ulasanList.isEmpty
                                          ? Icons.rate_review_outlined
                                          : Icons.search_off,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      ulasanList.isEmpty
                                          ? 'Belum ada ulasan untuk produk ini'
                                          : 'Tidak ada ulasan yang sesuai dengan filter',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (ulasanList.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: _clearFilters,
                                        child: const Text('Reset Filter'),
                                      ),
                                    ],
                                  ],
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: filteredUlasanList.length,
                                itemBuilder: (context, index) {
                                  final ulasan = filteredUlasanList[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundColor:
                                                    Colors.grey[300],
                                                child: Text(
                                                  ulasan.nama.isNotEmpty
                                                      ? ulasan.nama[0]
                                                          .toUpperCase()
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    _buildStarRating(
                                                      ulasan.rating,
                                                    ),
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
