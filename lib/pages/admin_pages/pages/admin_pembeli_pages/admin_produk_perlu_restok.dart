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
    with SingleTickerProviderStateMixin {
  List<ProdukPerluRestok> produkList = [];
  List<ProdukPerluRestok> filteredProdukList = [];
  List<String> availableKategori = [];
  String selectedKategori = 'all';
  String searchQuery = '';

  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _loadData({String kategori = 'all'}) async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        selectedKategori = kategori;
      });

      final result = await ProdukPerluRestok.getDataProdukPerluRestok(
        kategori: kategori,
      );

      setState(() {
        produkList = result['produk'];
        availableKategori = result['kategori'];
        _applyFilters();
        isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    filteredProdukList =
        produkList.where((produk) {
          bool matchesSearch =
              searchQuery.isEmpty ||
              produk.namaProduk.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              produk.warna.toLowerCase().contains(searchQuery.toLowerCase());

          return matchesSearch;
        }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      _applyFilters();
    });
  }

  void _onKategoriChanged(String kategori) {
    if (kategori != selectedKategori) {
      _loadData(kategori: kategori);
    }
  }

  Future<void> _exportToPdf() async {
    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final urgentProducts =
          filteredProdukList.where((p) => p.stok < 3).toList();
      final lowStockProducts =
          filteredProdukList.where((p) => p.stok < 5).toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build:
              (pw.Context context) => [
                _buildPdfHeader(now),
                pw.SizedBox(height: 20),
                _buildPdfSummary(lowStockProducts, urgentProducts),
                pw.SizedBox(height: 20),
                if (urgentProducts.isNotEmpty)
                  _buildPdfAlert(urgentProducts.length),
                pw.SizedBox(height: 20),
                _buildPdfTable(),
              ],
          header: (context) => _buildPdfPageHeader(),
          footer: (context) => _buildPdfPageFooter(context),
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
      _showToast('PDF berhasil diekspor', ToastificationType.success);
    } catch (e) {
      _showToast('Gagal mengekspor PDF: $e', ToastificationType.error);
    }
  }

  void _showToast(String message, ToastificationType type) {
    toastification.show(
      context: context,
      title: Text(message),
      type: type,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  // ===== UI COMPONENTS =====

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'PRODUK RESTOK',
          style: TextStyle(
            fontSize: 16,
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
        ),
      ),
      actions: [
        if (filteredProdukList.isNotEmpty) ...[
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportToPdf,
            tooltip: 'Export PDF',
          ),
        ],
        Container(
          margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${filteredProdukList.length}',
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
    if (isLoading) return _buildLoadingState();
    if (hasError) return _buildErrorState();
    if (produkList.isEmpty) return _buildEmptyState();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildFiltersSection(),
          _buildStatsSection(),
          if (filteredProdukList.isNotEmpty) _buildWarningHeader(),
          _buildProductList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      margin: const EdgeInsets.all(20),
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
          const Text(
            'Filter & Pencarian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari produk atau warna...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Category Filter
          const Text(
            'Kategori',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('all', 'Semua', selectedKategori == 'all'),
                ...availableKategori.map(
                  (kategori) => _buildCategoryChip(
                    kategori,
                    _formatKategori(kategori),
                    selectedKategori == kategori,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _onKategoriChanged(value),
        selectedColor: Colors.black,
        backgroundColor: Colors.grey[100],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  String _formatKategori(String kategori) {
    return kategori
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1)
                  : word,
        )
        .join(' ');
  }

  Widget _buildStatsSection() {
    final urgentCount = filteredProdukList.where((p) => p.stok < 3).length;
    final lowStockCount = filteredProdukList.where((p) => p.stok < 5).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Produk',
              '${filteredProdukList.length}',
              Icons.inventory_2_rounded,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Stok Rendah',
              '$lowStockCount',
              Icons.warning_rounded,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Urgent',
              '$urgentCount',
              Icons.priority_high_rounded,
              Colors.red,
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
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
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
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE53E3E).withOpacity(0.1),
            const Color(0xFFFF6B6B).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE53E3E).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE53E3E),
              borderRadius: BorderRadius.circular(12),
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
                  'Produk berikut memerlukan restok untuk menghindari kehabisan stok',
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
    if (filteredProdukList.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada produk yang ditemukan',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Produk (${filteredProdukList.length})',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...filteredProdukList.asMap().entries.map((entry) {
            final index = entry.key;
            final produk = entry.value;
            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 50)),
              curve: Curves.easeOutCubic,
              child: _buildProductCard(produk),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProdukPerluRestok produk) {
    final imageUrl =
        'http://192.168.1.96:3000/uploads/${produk.linkGambarVarian}';
    final isUrgent = produk.stok < 3;
    final isLowStock = produk.stok < 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            isUrgent
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
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: Container(
              width: 100,
              height: 120,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(color: Colors.grey[100]),
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: BoxDecoration(color: Colors.grey[100]),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
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
                    children: [
                      Expanded(
                        child: Text(
                          produk.namaProduk,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUrgent)
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
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildChip(
                        '${_formatKategori(produk.kategori)}',
                        Icons.category,
                        Colors.purple,
                      ),
                      _buildChip(
                        'Size ${produk.ukuran}',
                        Icons.straighten,
                        Colors.blue,
                      ),
                      _buildChip(produk.warna, Icons.palette, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_rounded,
                        size: 18,
                        color:
                            isUrgent
                                ? const Color(0xFFE53E3E)
                                : isLowStock
                                ? Colors.orange
                                : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Stok: ${produk.stok}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              isUrgent
                                  ? const Color(0xFFE53E3E)
                                  : isLowStock
                                  ? Colors.orange
                                  : Colors.green,
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
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.black),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadData(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Semua Produk Tersedia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada produk yang perlu direstok',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (filteredProdukList.isNotEmpty)
          FloatingActionButton(
            heroTag: "pdf",
            onPressed: _exportToPdf,
            backgroundColor: Colors.black,
            child: const Icon(Icons.picture_as_pdf, color: Colors.white),
          ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: "refresh",
          onPressed: () => _loadData(kategori: selectedKategori),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          child: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }

  // ===== PDF COMPONENTS (Simplified) =====

  pw.Widget _buildPdfHeader(DateTime now) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.black,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'RESTOCK REPORT',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Laporan Produk yang Memerlukan Restok',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey300),
              ),
            ],
          ),
          pw.Text(
            '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSummary(
    List<ProdukPerluRestok> lowStock,
    List<ProdukPerluRestok> urgent,
  ) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: _buildPdfSummaryCard(
            'Total',
            '${filteredProdukList.length}',
            PdfColors.blue,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _buildPdfSummaryCard(
            'Perlu Restok',
            '${lowStock.length}',
            PdfColors.orange,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _buildPdfSummaryCard(
            'Urgent',
            '${urgent.length}',
            PdfColors.red,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfSummaryCard(String title, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: color.shade(0.1),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: color, width: 1),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.black),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfAlert(int urgentCount) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.red50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.red200, width: 1),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 40,
            height: 40,
            decoration: pw.BoxDecoration(
              color: PdfColors.red,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Center(
              child: pw.Text(
                '!',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 15),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PERHATIAN: STOK KRITIS',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red800,
                  ),
                ),
                pw.Text(
                  '$urgentCount produk memiliki stok sangat rendah dan memerlukan restok segera.',
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.red700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTable() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(1),
        6: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey800),
          children: [
            _buildPdfTableHeader('No'),
            _buildPdfTableHeader('Nama Produk'),
            _buildPdfTableHeader('Kategori'),
            _buildPdfTableHeader('Ukuran'),
            _buildPdfTableHeader('Warna'),
            _buildPdfTableHeader('Stok'),
            _buildPdfTableHeader('Status'),
          ],
        ),
        ...filteredProdukList.asMap().entries.map((entry) {
          final index = entry.key;
          final produk = entry.value;
          final isUrgent = produk.stok < 3;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index % 2 == 0 ? PdfColors.grey50 : PdfColors.white,
            ),
            children: [
              _buildPdfTableCell('${index + 1}', isCenter: true),
              _buildPdfTableCell(produk.namaProduk),
              _buildPdfTableCell(_formatKategori(produk.kategori)),
              _buildPdfTableCell('${produk.ukuran}', isCenter: true),
              _buildPdfTableCell(produk.warna),
              _buildPdfTableCell(
                '${produk.stok}',
                isCenter: true,
                isBold: isUrgent,
                textColor: isUrgent ? PdfColors.red : PdfColors.black,
              ),
              _buildPdfStatusCell(produk.stok),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildPdfTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildPdfTableCell(
    String text, {
    bool isCenter = false,
    bool isBold = false,
    PdfColor? textColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor ?? PdfColors.black,
        ),
        textAlign: isCenter ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  pw.Widget _buildPdfStatusCell(int stok) {
    String status;
    PdfColor color;

    if (stok < 3) {
      status = 'URGENT';
      color = PdfColors.red;
    } else if (stok < 5) {
      status = 'LOW';
      color = PdfColors.orange;
    } else {
      status = 'OK';
      color = PdfColors.green;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Text(
          status,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  pw.Widget _buildPdfPageHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Text(
        'Inventaris Restok',
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey600,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildPdfPageFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Text(
        'Halaman ${context.pageNumber} dari ${context.pagesCount}',
        style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
