import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:toastification/toastification.dart';

class ProdukRestokPage extends StatefulWidget {
  const ProdukRestokPage({super.key});

  @override
  State<ProdukRestokPage> createState() => _ProdukRestokPageState();
}

class _ProdukRestokPageState extends State<ProdukRestokPage>
    with TickerProviderStateMixin {
  List<ProdukPerluRestok> produkList = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      final data = await ProdukPerluRestok.getDataProdukPerluRestok();

      setState(() {
        produkList = data;
        isLoading = false;
      });

      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Replace your existing _exportToPdf method with this modern version
  Future<void> _exportToPdf() async {
    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final lowStockProducts = produkList.where((p) => p.stok < 5).toList();
      final urgentProducts = produkList.where((p) => p.stok < 3).toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Modern Header with Gradient-like Effect
              _buildPdfHeader(now),
              pw.SizedBox(height: 30),

              // Executive Summary Cards
              _buildExecutiveSummary(lowStockProducts, urgentProducts),
              pw.SizedBox(height: 30),

              // Alert Section for Urgent Items
              if (urgentProducts.isNotEmpty) ...[
                _buildUrgentAlert(urgentProducts.length),
                pw.SizedBox(height: 25),
              ],

              // Modern Data Table
              _buildModernTable(),
              pw.SizedBox(height: 30),
            ];
          },
          header: (context) => _buildPageHeader(),
          footer: (context) => _buildPageFooter(context),
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      if (mounted) {
        _showSuccessToast('PDF laporan berhasil diekspor');
      }
    } catch (e) {
      if (mounted) {
        _showErrorToast('Gagal mengekspor PDF: $e');
      }
    }
  }

  // Modern PDF Header
  pw.Widget _buildPdfHeader(DateTime now) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(25),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.black, PdfColors.grey800],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(15),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'RESTOCK REPORT',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Laporan Produk yang Memerlukan Restok',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey300,
                        fontWeight: pw.FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(20),
                      ),
                      child: pw.Text(
                        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Executive Summary with Modern Cards
  pw.Widget _buildExecutiveSummary(
    List<ProdukPerluRestok> lowStock,
    List<ProdukPerluRestok> urgent,
  ) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: _buildSummaryCard(
            'Total Produk',
            '${produkList.length}',
            PdfColors.blue600,
            PdfColors.blue50,
          ),
        ),
        pw.SizedBox(width: 15),
        pw.Expanded(
          child: _buildSummaryCard(
            'Perlu Restok',
            '${lowStock.length}',
            PdfColors.orange600,
            PdfColors.orange50,
          ),
        ),
        pw.SizedBox(width: 15),
        pw.Expanded(
          child: _buildSummaryCard(
            'Urgent',
            '${urgent.length}',
            PdfColors.red600,
            PdfColors.red50,
          ),
        ),
        pw.SizedBox(width: 15),
        pw.Expanded(
          child: _buildSummaryCard(
            'Status Baik',
            '${produkList.length - lowStock.length}',
            PdfColors.green600,
            PdfColors.green50,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSummaryCard(
    String title,
    String value,
    PdfColor color,
    PdfColor bgColor,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: color.shade(0.3), width: 1),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Urgent Alert Box
  pw.Widget _buildUrgentAlert(int urgentCount) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.red50,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.red200, width: 2),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 50,
            height: 50,
            decoration: pw.BoxDecoration(
              color: PdfColors.red600,
              borderRadius: pw.BorderRadius.circular(25),
            ),
            child: pw.Center(
              child: pw.Text(
                '!',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 20),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PERHATIAN: STOK KRITIS',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red800,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  '$urgentCount produk memiliki stok sangat rendah (< 3 unit) dan memerlukan restok segera.',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.red700,
                    lineSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modern Data Table
  pw.Widget _buildModernTable() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DETAIL PRODUK YANG MEMERLUKAN RESTOK',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
            letterSpacing: 0.5,
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
          columnWidths: {
            0: const pw.FixedColumnWidth(40),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(1.2),
            3: const pw.FlexColumnWidth(1.5),
            4: const pw.FlexColumnWidth(1),
            5: const pw.FlexColumnWidth(1.2),
          },
          children: [
            // Header Row
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [PdfColors.grey800, PdfColors.grey700],
                ),
              ),
              children: [
                _buildTableHeaderCell('No'),
                _buildTableHeaderCell('Nama Produk'),
                _buildTableHeaderCell('Ukuran'),
                _buildTableHeaderCell('Warna'),
                _buildTableHeaderCell('Stok'),
                _buildTableHeaderCell('Status'),
              ],
            ),
            // Data Rows
            ...produkList.asMap().entries.map((entry) {
              int index = entry.key;
              ProdukPerluRestok produk = entry.value;
              bool isUrgent = produk.stok < 3;
              bool isLowStock = produk.stok < 5;

              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: index % 2 == 0 ? PdfColors.grey50 : PdfColors.white,
                ),
                children: [
                  _buildTableCell('${index + 1}', isCenter: true),
                  _buildTableCell(produk.namaProduk, isBold: isUrgent),
                  _buildTableCell(produk.ukuran.toString(), isCenter: true),
                  _buildTableCell(produk.warna),
                  _buildTableCell(
                    '${produk.stok}',
                    isCenter: true,
                    textColor:
                        isUrgent
                            ? PdfColors.red600
                            : isLowStock
                            ? PdfColors.orange600
                            : PdfColors.black,
                    isBold: isUrgent || isLowStock,
                  ),
                  _buildStatusCell(produk.stok),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTableHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 15),
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
    bool isBold = false,
    PdfColor? textColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor ?? PdfColors.black,
        ),
        textAlign: isCenter ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  pw.Widget _buildStatusCell(int stok) {
    String status;
    PdfColor bgColor;
    PdfColor textColor;

    if (stok < 3) {
      status = 'URGENT';
      bgColor = PdfColors.red600;
      textColor = PdfColors.white;
    } else if (stok < 5) {
      status = 'LOW';
      bgColor = PdfColors.orange600;
      textColor = PdfColors.white;
    } else {
      status = 'OK';
      bgColor = PdfColors.green600;
      textColor = PdfColors.white;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: pw.BoxDecoration(
          color: bgColor,
          borderRadius: pw.BorderRadius.circular(12),
        ),
        child: pw.Text(
          status,
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

  // Page Header
  pw.Widget _buildPageHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Inventaris Restok',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Page Footer
  pw.Widget _buildPageFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessToast(String message) {
    toastification.show(
      context: context,
      title: Text(message),
      type: ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showErrorToast(String message) {
    toastification.show(
      context: context,
      title: Text(message),
      type: ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 4),
      alignment: Alignment.topCenter,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildBody()),
        ],
      ),
      floatingActionButton:
          produkList.isNotEmpty ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'PRODUK RESTOK',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.black, Color(0xFF2C2C2C)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (produkList.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.picture_as_pdf, size: 20),
              ),
              onPressed: _exportToPdf,
              tooltip: 'Export PDF',
            ),
          ),
        ],
        Container(
          margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '${produkList.length}',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (hasError) {
      return _buildErrorState();
    }

    if (produkList.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildStatsSection(),
            _buildWarningHeader(),
            _buildProductList(),
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Produk',
              '${produkList.length}',
              Icons.inventory_2_rounded,
              Colors.black,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Perlu Restok',
              '${produkList.where((p) => p.stok < 5).length}',
              Icons.warning_rounded,
              const Color(0xFFE53E3E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE53E3E).withOpacity(0.1),
            const Color(0xFFFF6B6B).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE53E3E).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE53E3E),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE53E3E).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.priority_high_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Peringatan Stok Rendah',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Produk berikut memerlukan restok segera untuk menghindari kehabisan stok',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Produk (${produkList.length})',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...produkList.asMap().entries.map((entry) {
            final index = entry.key;
            final produk = entry.value;
            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 50)),
              curve: Curves.easeOutCubic,
              child: _buildProductCard(produk, index),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProdukPerluRestok produk, int index) {
    final imageUrl =
        'http://192.168.1.96:3000/uploads/${produk.linkGambarVarian}';
    final isLowStock = produk.stok < 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            isLowStock
                ? Border.all(
                  color: const Color(0xFFE53E3E).withOpacity(0.3),
                  width: 2,
                )
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[100]!, Colors.grey[50]!],
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[100]!, Colors.grey[50]!],
                        ),
                      ),
                      child: const Icon(
                        Icons.image_not_supported_rounded,
                        color: Colors.grey,
                        size: 40,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[100]!, Colors.grey[50]!],
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            produk.namaProduk,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isLowStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53E3E),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'URGENT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildModernChip(
                          'Size ${produk.ukuran}',
                          Icons.straighten_rounded,
                          Colors.blue[600]!,
                        ),
                        _buildModernChip(
                          produk.warna,
                          Icons.palette_rounded,
                          Colors.purple[600]!,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_rounded,
                          size: 18,
                          color:
                              isLowStock
                                  ? const Color(0xFFE53E3E)
                                  : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Stok: ${produk.stok}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isLowStock
                                    ? const Color(0xFFE53E3E)
                                    : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
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
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Memuat data produk...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53E3E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFE53E3E),
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Gagal Memuat Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(40),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Semua Produk Tersedia',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tidak ada produk yang perlu direstok saat ini.\nSemua stok dalam kondisi aman.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "pdf",
          onPressed: _exportToPdf,
          backgroundColor: Colors.black,
          elevation: 8,
          child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: "refresh",
          onPressed: _loadData,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 8,
          child: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }
}
