import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class PenjualanHarianPage extends StatefulWidget {
  const PenjualanHarianPage({super.key});

  @override
  State<PenjualanHarianPage> createState() => _PenjualanHarianPageState();
}

class _PenjualanHarianPageState extends State<PenjualanHarianPage>
    with SingleTickerProviderStateMixin {
  bool tampilOnline = true;
  final String baseUrl = "http://192.168.1.96:3000/uploads/";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildModernAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _fetchAllData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }
            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            final data = snapshot.data!;
            final onlineData = data['online'] as List<DataTransaksiOnlineFull>;
            final offlineData = data['offline'] as List<DataTransaksiOffline>;
            final laporanData = data['laporan'] as List<LaporanHarian>;

            return Column(
              children: [
                _buildToggleSection(),
                _buildImprovedStats(onlineData, offlineData, laporanData),
                Expanded(child: _buildTransactionList(onlineData, offlineData)),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchAllData() async {
    final transaksiData =
        await TransaksiService.fetchSemuaHasilTransaksiPenjualanHarian();
    final laporanData = await LaporanHarian.fetchLaporanHarian();
    return {
      'online': transaksiData['online'] ?? [],
      'offline': transaksiData['offline'] ?? [],
      'laporan': laporanData,
    };
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      title: _buildAppBarTitle(),
      actions: [_buildPdfButton()],
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.analytics_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Penjualan Harian',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildPdfButton() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
        onPressed: _handlePdfGeneration,
      ),
    );
  }

  Future<void> _handlePdfGeneration() async {
    try {
      final laporan = await LaporanHarian.fetchLaporanHarian();
      final pdf = await generateLaporanPDF(laporan);
      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.black),
          SizedBox(height: 16),
          Text(
            'Memuat data penjualan...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          _buildToggleButton(true, 'Online', Icons.cloud_outlined),
          _buildToggleButton(false, 'Offline', Icons.store_outlined),
        ],
      ),
    );
  }

  Widget _buildToggleButton(bool isOnline, String label, IconData icon) {
    final isActive = tampilOnline == isOnline;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tampilOnline = isOnline),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow:
                isActive
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey[600],
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // IMPROVED STATS SECTION - Perbaikan utama untuk tampilan card
  Widget _buildImprovedStats(
    List<DataTransaksiOnlineFull> onlineData,
    List<DataTransaksiOffline> offlineData,
    List<LaporanHarian> laporanData,
  ) {
    final stats = _calculateStats(laporanData, onlineData, offlineData);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Row 1: Main totals with larger cards
          Row(
            children: [
              Expanded(
                child: _buildImprovedStatCard(
                  'Total Penjualan',
                  formatRupiah(stats['totalPenjualan']),
                  Icons.trending_up_outlined,
                  Colors.green,
                  isMain: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildImprovedStatCard(
                  'Total Keuntungan',
                  formatRupiah(stats['totalKeuntungan']),
                  Icons.monetization_on_outlined,
                  Colors.blue,
                  isMain: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2-4: Smaller cards in 2x2 grid
          Row(
            children: [
              Expanded(
                child: _buildImprovedStatCard(
                  'Online',
                  formatRupiah(stats['totalOnline']),
                  Icons.cloud_outlined,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildImprovedStatCard(
                  'Offline',
                  formatRupiah(stats['totalOffline']),
                  Icons.store_outlined,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildImprovedStatCard(
                  'Transaksi Online',
                  '${stats['countOnline']} order',
                  Icons.receipt_long_outlined,
                  Colors.cyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildImprovedStatCard(
                  'Transaksi Offline',
                  '${stats['countOffline']} item',
                  Icons.point_of_sale_outlined,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats(
    List<LaporanHarian> laporanData,
    List<DataTransaksiOnlineFull> onlineData,
    List<DataTransaksiOffline> offlineData,
  ) {
    final totalOnline = laporanData.fold(
      0,
      (sum, item) => sum + item.totalPenjualanOnline,
    );
    final totalOffline = laporanData.fold(
      0,
      (sum, item) => sum + item.totalPenjualanOffline,
    );
    final totalKeuntungan = laporanData.fold(
      0,
      (sum, item) => sum + item.totalKeuntunganHarian,
    );

    return {
      'totalPenjualan': totalOnline + totalOffline,
      'totalKeuntungan': totalKeuntungan,
      'totalOnline': totalOnline,
      'totalOffline': totalOffline,
      'countOnline': onlineData.length,
      'countOffline': offlineData.length,
    };
  }

  Widget _buildImprovedStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isMain = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMain ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMain ? 8 : 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isMain ? 18 : 16),
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: isMain ? 12 : 8),
          // VALUE DIPINDAH KE BAWAH
          Text(
            value,
            style: TextStyle(
              fontSize: isMain ? 16 : 14, // Ukuran font diperkecil
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // TITLE DI BAWAH VALUE
          Text(
            title,
            style: TextStyle(
              fontSize: isMain ? 12 : 10, // Ukuran font diperkecil
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    List<DataTransaksiOnlineFull> onlineData,
    List<DataTransaksiOffline> offlineData,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child:
          tampilOnline
              ? _buildOnlineTransactionList(onlineData)
              : _buildOfflineTransactionList(offlineData),
    );
  }

  Widget _buildOnlineTransactionList(List<DataTransaksiOnlineFull> onlineData) {
    if (onlineData.isEmpty) {
      return _buildEmptyState('Tidak ada transaksi online hari ini');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: onlineData.length,
      itemBuilder:
          (context, index) => _buildOnlineTransactionCard(onlineData[index]),
    );
  }

  Widget _buildOnlineTransactionCard(DataTransaksiOnlineFull order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          leading: _buildTransactionIcon(
            Icons.shopping_bag_outlined,
            Colors.blue,
          ),
          title: Text(
            "Order #${order.idOrderan}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: _buildOnlineTransactionSubtitle(order),
          children:
              order.produk.map((produk) => _buildProductCard(produk)).toList(),
        ),
      ),
    );
  }

  Widget _buildOnlineTransactionSubtitle(DataTransaksiOnlineFull order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          order.namaPengguna,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 12,
              color: Colors.grey[500],
            ),
            const SizedBox(width: 4),
            Text(
              order.tanggalOrder,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.monetization_on_outlined,
              size: 12,
              color: Colors.grey[500],
            ),
            const SizedBox(width: 4),
            Text(
              order.totalHarga,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOfflineTransactionList(List<DataTransaksiOffline> offlineData) {
    if (offlineData.isEmpty) {
      return _buildEmptyState('Tidak ada transaksi offline hari ini');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: offlineData.length,
      itemBuilder:
          (context, index) => _buildOfflineTransactionCard(offlineData[index]),
    );
  }

  Widget _buildOfflineTransactionCard(DataTransaksiOffline transaksi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildProductImage(transaksi.linkGambarVarian, 60),
          const SizedBox(width: 12),
          Expanded(child: _buildOfflineTransactionDetails(transaksi)),
          _buildTransactionIcon(Icons.store_outlined, Colors.green),
        ],
      ),
    );
  }

  Widget _buildOfflineTransactionDetails(DataTransaksiOffline transaksi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          transaksi.namaProduk,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 12,
              color: Colors.grey[500],
            ),
            const SizedBox(width: 4),
            Text(
              transaksi.tanggal,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "${transaksi.warna} • ${transaksi.ukuran}",
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            transaksi.harga,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildProductCard(dynamic produk) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          _buildProductImage(produk.linkGambarVarian, 50),
          const SizedBox(width: 12),
          Expanded(child: _buildProductDetails(produk)),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imagePath, double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        baseUrl + imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey,
              ),
            ),
      ),
    );
  }

  Widget _buildProductDetails(dynamic produk) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          produk.namaProduk,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          "${produk.warna} • ${produk.ukuran}",
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              "Qty: ${produk.jumlahOrder}",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(width: 12),
            Text(
              produk.hargaSatuan,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, color: Colors.grey[400], size: 48),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

String formatRupiah(int amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

Future<pw.Document> generateLaporanPDF(List<LaporanHarian> data) async {
  // Initialize Indonesian locale for PDF generation
  await initializeDateFormatting('id_ID', null);

  final pdf = pw.Document();

  // Calculate totals
  int totalPenjualanOfflineSum = data.fold(
    0,
    (sum, item) => sum + item.totalPenjualanOffline,
  );
  int totalPenjualanOnlineSum = data.fold(
    0,
    (sum, item) => sum + item.totalPenjualanOnline,
  );
  int totalKeuntunganSum = data.fold(
    0,
    (sum, item) => sum + item.totalKeuntunganHarian,
  );
  int totalGajiSum = data.fold(0, (sum, item) => sum + item.gajiKaryawanHarian);
  int totalKeuntunganBersihSum = data.fold(
    0,
    (sum, item) => sum + item.keuntunganBersih,
  );
  int grandTotalPenjualan = totalPenjualanOfflineSum + totalPenjualanOnlineSum;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build:
          (context) => [
            // Header Section
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                gradient: const pw.LinearGradient(
                  colors: [PdfColors.blue900, PdfColors.blue700],
                ),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'LAPORAN PENJUALAN HARIAN',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Periode: ${data.isNotEmpty ? data.first.tanggal : ''} - ${data.isNotEmpty ? data.last.tanggal : ''}',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Tanggal Generate:',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.Text(
                        DateFormat(
                          'dd MMMM yyyy',
                          'id_ID',
                        ).format(DateTime.now()),
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Summary Cards
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green50,
                      border: pw.Border.all(color: PdfColors.green200),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Total Penjualan',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green800,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          formatRupiah(grandTotalPenjualan),
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      border: pw.Border.all(color: PdfColors.blue200),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Total Keuntungan',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          formatRupiah(totalKeuntunganSum),
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.purple50,
                      border: pw.Border.all(color: PdfColors.purple200),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Keuntungan Bersih',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.purple800,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          formatRupiah(totalKeuntunganBersihSum),
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.purple900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 24),

            // Table Section
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Table(
                border: pw.TableBorder(
                  horizontalInside: pw.BorderSide(
                    color: PdfColors.grey200,
                    width: 0.5,
                  ),
                  verticalInside: pw.BorderSide(
                    color: PdfColors.grey200,
                    width: 0.5,
                  ),
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.2), // Tanggal
                  1: const pw.FlexColumnWidth(1.3), // Offline
                  2: const pw.FlexColumnWidth(1.3), // Online
                  3: const pw.FlexColumnWidth(1.2), // Untung Offline
                  4: const pw.FlexColumnWidth(1.2), // Untung Online
                  5: const pw.FlexColumnWidth(1.3), // Total Harian
                  6: const pw.FlexColumnWidth(1.2), // Total Untung
                  7: const pw.FlexColumnWidth(1.2), // Gaji Harian
                  8: const pw.FlexColumnWidth(1.3), // Untung Bersih
                },
                children: [
                  // Header Row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey800,
                    ),
                    children: [
                      _buildHeaderCell('Tanggal'),
                      _buildHeaderCell('Penjualan\nOffline'),
                      _buildHeaderCell('Penjualan\nOnline'),
                      _buildHeaderCell('Untung\nOffline'),
                      _buildHeaderCell('Untung\nOnline'),
                      _buildHeaderCell('Total\nHarian'),
                      _buildHeaderCell('Total\nUntung'),
                      _buildHeaderCell('Gaji\nHarian'),
                      _buildHeaderCell('Untung\nBersih'),
                    ],
                  ),
                  // Data Rows
                  ...data.asMap().entries.map((entry) {
                    int index = entry.key;
                    LaporanHarian laporan = entry.value;
                    bool isEven = index % 2 == 0;

                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isEven ? PdfColors.grey50 : PdfColors.white,
                      ),
                      children: [
                        _buildDataCell(
                          DateFormat(
                            'dd/MM/yy',
                          ).format(DateTime.parse(laporan.tanggal)),
                        ),
                        _buildDataCell(
                          formatRupiah(laporan.totalPenjualanOffline),
                        ),
                        _buildDataCell(
                          formatRupiah(laporan.totalPenjualanOnline),
                        ),
                        _buildDataCell(
                          formatRupiah(laporan.keuntunganPenjualanOffline),
                        ),
                        _buildDataCell(
                          formatRupiah(laporan.keuntunganPenjualanOnline),
                        ),
                        _buildDataCell(formatRupiah(laporan.totalHarian)),
                        _buildDataCell(
                          formatRupiah(laporan.totalKeuntunganHarian),
                        ),
                        _buildDataCell(
                          formatRupiah(laporan.gajiKaryawanHarian),
                        ),
                        _buildDataCell(
                          formatRupiah(laporan.keuntunganBersih),
                          color:
                              laporan.keuntunganBersih >= 0
                                  ? PdfColors.green800
                                  : PdfColors.red800,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ],
                    );
                  }).toList(),
                  // Total Row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.blue100,
                    ),
                    children: [
                      _buildTotalCell('TOTAL'),
                      _buildTotalCell(formatRupiah(totalPenjualanOfflineSum)),
                      _buildTotalCell(formatRupiah(totalPenjualanOnlineSum)),
                      _buildTotalCell('-'),
                      _buildTotalCell('-'),
                      _buildTotalCell(formatRupiah(grandTotalPenjualan)),
                      _buildTotalCell(formatRupiah(totalKeuntunganSum)),
                      _buildTotalCell(formatRupiah(totalGajiSum)),
                      _buildTotalCell(
                        formatRupiah(totalKeuntunganBersihSum),
                        color:
                            totalKeuntunganBersihSum >= 0
                                ? PdfColors.green800
                                : PdfColors.red800,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Footer
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Catatan: Keuntungan bersih sudah dipotong gaji karyawan harian',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    'Total Hari: ${data.length} hari',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
          ],
    ),
  );

  return pdf;
}

// Helper function to build header cells
pw.Widget _buildHeaderCell(String text) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

// Helper function to build data cells
pw.Widget _buildDataCell(
  String text, {
  PdfColor? color,
  pw.FontWeight? fontWeight,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 8,
        color: color ?? PdfColors.black,
        fontWeight: fontWeight,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

// Helper function to build total cells
pw.Widget _buildTotalCell(String text, {PdfColor? color}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
        color: color ?? PdfColors.blue900,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}
