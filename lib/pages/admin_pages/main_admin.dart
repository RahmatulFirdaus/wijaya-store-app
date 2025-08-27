import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:frontend/pages/admin_pages/list_chat_pembeli.dart';
import 'package:frontend/pages/admin_pages/pages/admin_karyawan_pages/admin_absensi_karyawan.dart';
import 'package:frontend/pages/admin_pages/pages/admin_karyawan_pages/admin_pengajuan_izin_karyawan.dart';
import 'package:frontend/pages/admin_pages/pages/admin_master_pages/admin_lobby_akun.dart';
import 'package:frontend/pages/admin_pages/pages/admin_master_pages/admin_gaji_karyawan.dart';
import 'package:frontend/pages/admin_pages/pages/admin_master_pages/admin_harga_original.dart';
import 'package:frontend/pages/admin_pages/pages/admin_master_pages/admin_operasional.dart';
import 'package:frontend/pages/admin_pages/pages/admin_mix_online_offline/admin_penjualan_harian.dart';
import 'package:frontend/pages/admin_pages/pages/admin_mix_online_offline/admin_penjualan_offline.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/admin_daftar_produk.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/admin_faktur_online.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/admin_pengiriman.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/admin_produk_perlu_restok.dart';
import 'package:frontend/pages/admin_pages/pages/admin_mix_online_offline/admin_transaksi_online.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/admin_ulasan_produk.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/manajemen_pesanan_produk/manajemen_pesanan_produk.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/pembayaran_online/admin_lobby_pembayaran_online.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pengiriman/admin_pengiriman.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/pages/admin_pages/pages/admin_send_promo.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProdukPerluRestok {
  String namaProduk;
  String linkGambarVarian;
  String warna;
  int ukuran;
  int stok;

  ProdukPerluRestok({
    required this.namaProduk,
    required this.linkGambarVarian,
    required this.warna,
    required this.ukuran,
    required this.stok,
  });

  static Future<List<ProdukPerluRestok>> getDataProdukPerluRestok() async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTampilProdukPerluRestok',
    );

    try {
      final hasilResponse = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (hasilResponse.statusCode == 200 || hasilResponse.statusCode == 201) {
        final List<dynamic> data = jsonDecode(hasilResponse.body)['data'];
        return data.map((item) {
          return ProdukPerluRestok(
            namaProduk: item['nama_produk'].toString(),
            linkGambarVarian: item['link_gambar_varian'].toString(),
            warna: item['warna'].toString(),
            ukuran:
                item['ukuran'] is int
                    ? item['ukuran']
                    : int.tryParse(item['ukuran'].toString()) ?? 0,
            stok:
                item['stok'] is int
                    ? item['stok']
                    : int.tryParse(item['stok'].toString()) ?? 0,
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Gagal memuat data produk perlu restok: $e');
    }
  }
}

class MainAdmin extends StatefulWidget {
  const MainAdmin({super.key});

  @override
  State<MainAdmin> createState() => _MainAdminState();
}

class _MainAdminState extends State<MainAdmin> {
  final TextEditingController _searchTextController = TextEditingController();
  bool _isSearchVisible = false;
  String _searchQuery = '';
  int _restockCount = 0;
  bool _isLoadingRestockData = true;
  int _verifikasiCount = 0;
  bool _isLoadingVerifikasiData = true;
  DashboardSummary? summary;
  List<DashboardPoint> data = [];
  bool loadingDashboard = true;
  // Organized menu items by categories
  late List<MenuCategory> _menuCategories;

  List<AdminMenuItem> get _filteredMenuItems {
    if (_searchQuery.isEmpty) {
      return _getAllMenuItems();
    }
    return _getAllMenuItems()
        .where(
          (item) =>
              item.title.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<AdminMenuItem> _getAllMenuItems() {
    return _menuCategories.expand((category) => category.items).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadRestockData();
    _loadVerifikasiData();
    _loadDashboardData(); // TAMBAHAN BARU
    _initializeMenuCategories();
  }

  Future<void> _loadDashboardData() async {
    setState(() => loadingDashboard = true);
    try {
      final s = await DashboardApi.fetchSummary();
      final g = await DashboardApi.fetchGrafik(yearsBack: 3, yearsForward: 2);
      setState(() {
        summary = s;
        data = g;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => loadingDashboard = false);
    }
  }

  List<FlSpot> _spotsTotal({required bool forecast}) {
    final points = <FlSpot>[];
    int idx = 0;
    for (final d in data) {
      final isF = d.forecast;
      if (isF == forecast) {
        points.add(FlSpot(idx.toDouble(), d.total.toDouble()));
      }
      idx++;
    }
    return points;
  }

  List<String> _labels() => data.map((e) => e.ym).toList();

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final pos = s.length - i;
      buf.write(s[i]);
      if (pos > 1 && pos % 3 == 1) buf.write('.');
    }
    return buf.toString();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoadingRestockData = true;
      _isLoadingVerifikasiData = true;
      loadingDashboard = true; // TAMBAHAN BARU
    });

    await Future.wait([
      _loadRestockData(),
      _loadVerifikasiData(),
      _loadDashboardData(), // TAMBAHAN BARU
    ]);
  }

  Future<void> _loadVerifikasiData() async {
    try {
      final verifikasi = await JumlahVerifikasi.getJumlahPending();
      setState(() {
        _verifikasiCount = verifikasi?.jumlahPending ?? 0;
        _isLoadingVerifikasiData = false;
      });
      // Reinitialize menu categories with updated verifikasi count
      _initializeMenuCategories();
    } catch (e) {
      setState(() {
        _verifikasiCount = 0;
        _isLoadingVerifikasiData = false;
      });
      _initializeMenuCategories();
    }
  }

  Future<void> _loadRestockData() async {
    try {
      final products = await ProdukPerluRestok.getDataProdukPerluRestok();
      setState(() {
        _restockCount = products.length;
        _isLoadingRestockData = false;
      });
      // Reinitialize menu categories with updated restock count
      _initializeMenuCategories();
    } catch (e) {
      setState(() {
        _restockCount = 0;
        _isLoadingRestockData = false;
      });
      _initializeMenuCategories();
    }

    // Juga reload verifikasi data
    _loadVerifikasiData();
  }

  Map<String, dynamic> _getVerifikasiStyle() {
    if (_verifikasiCount == 0) {
      return {
        'color': const Color(0xFF4CAF50),
        'gradient': const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'isUrgent': false,
        'statusText': 'Tidak Ada',
      };
    } else if (_verifikasiCount <= 5) {
      return {
        'color': const Color(0xFFFF9800),
        'gradient': const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'isUrgent': false,
        'statusText': '$_verifikasiCount Akun',
      };
    } else {
      return {
        'color': const Color(0xFFE53E3E),
        'gradient': const LinearGradient(
          colors: [Color(0xFFE53E3E), Color(0xFFFF6B6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'isUrgent': true,
        'statusText':
            _verifikasiCount > 99 ? '99+ Akun' : '$_verifikasiCount Akun',
      };
    }
  }

  // Get color and gradient based on restock count
  Map<String, dynamic> _getRestockStyle() {
    if (_restockCount == 0) {
      return {
        'color': const Color(0xFF4CAF50),
        'gradient': const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'isUrgent': false,
        'statusText': 'Stok Aman',
      };
    } else if (_restockCount <= 5) {
      return {
        'color': const Color(0xFFFF9800),
        'gradient': const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'isUrgent': false,
        'statusText': '$_restockCount Item', // Changed from "Produk" to "Item"
      };
    } else {
      return {
        'color': const Color(0xFFE53E3E),
        'gradient': const LinearGradient(
          colors: [Color(0xFFE53E3E), Color(0xFFFF6B6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'isUrgent': true,
        // Use shorter format for large numbers
        'statusText': _restockCount > 99 ? '99+ Item' : '$_restockCount Item',
      };
    }
  }

  void _initializeMenuCategories() {
    final restockStyle = _getRestockStyle();
    final verifikasiStyle = _getVerifikasiStyle();

    _menuCategories = [
      // Karyawan Management
      MenuCategory(
        title: 'Manajemen Karyawan',
        icon: Icons.people_rounded,
        items: [
          AdminMenuItem(
            title: 'Absensi Karyawan',
            icon: Icons.access_time_rounded,
            color: const Color(0xFF667EEA),
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap:
                (context) =>
                    _navigateToPage(context, const AbsensiKaryawanPage()),
          ),
          AdminMenuItem(
            title: 'Izin/Sakit Karyawan',
            icon: Icons.sick_rounded,
            color: const Color(0xFFFF6B6B),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap:
                (context) => _navigateToPage(context, const IzinKaryawanPage()),
          ),
          AdminMenuItem(
            title: 'Gaji Karyawan',
            icon: Icons.attach_money,
            color: const Color(0xFF4CAF50),
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap:
                (context) =>
                    _navigateToPage(context, const AdminGajiKaryawan()),
          ),
        ],
      ),

      // Product Management
      MenuCategory(
        title: 'Manajemen Produk',
        icon: Icons.inventory_rounded,
        items: [
          AdminMenuItem(
            title: 'Daftar Produk',
            icon: Icons.inventory_2_rounded,
            color: const Color(0xFF4ECDC4),
            gradient: const LinearGradient(
              colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap:
                (context) => _navigateToPage(context, const DaftarProdukPage()),
          ),
          AdminMenuItem(
            title: 'Produk Perlu Restok',
            icon: Icons.warning_amber_rounded,
            color: restockStyle['color'],
            gradient: restockStyle['gradient'],
            isUrgent: restockStyle['isUrgent'],
            notificationCount: _restockCount,
            notificationText: restockStyle['statusText'],
            showNotification: true,
            isLoading: _isLoadingRestockData,
            onTap:
                (context) => _navigateToPage(context, const ProdukRestokPage()),
          ),
          AdminMenuItem(
            title: 'Harga Original Produk',
            icon: Icons.price_change,
            color: const Color(0xFFAB47BC),
            gradient: const LinearGradient(
              colors: [Color(0xFFAB47BC), Color(0xFF8E24AA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap:
                (context) =>
                    _navigateToPage(context, const HargaOriginalPage()),
          ),
          AdminMenuItem(
            title: 'Ulasan Produk',
            icon: Icons.star_rate_rounded,
            color: const Color(0xFFFFB74D),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap:
                (context) => _navigateToPage(context, const UlasanProdukPage()),
          ),
          AdminMenuItem(
            title: 'Manajemen Pesanan Produk',
            icon: Icons.production_quantity_limits_outlined,
            color: Colors.blue[700]!,
            gradient: const LinearGradient(
              colors: [Color(0xFF42A5F5), Color(0xFF7E57C2)], // biru ke ungu
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap:
                (context) =>
                    _navigateToPage(context, const ManajemenPesananProduk()),
          ),
        ],
      ),

      // Sales & Transactions
      MenuCategory(
        title: 'Penjualan & Transaksi',
        icon: Icons.analytics_rounded,
        items: [
          AdminMenuItem(
            title: 'Penjualan Harian',
            icon: Icons.analytics_rounded,
            color: const Color(0xFFFFA726),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFA726), Color(0xFFFFCC02)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            subtitle: '(Online + Offline)',
            onTap:
                (context) =>
                    _navigateToPage(context, const PenjualanHarianPage()),
          ),
          AdminMenuItem(
            title: 'Transaksi Online',
            icon: Icons.credit_card_rounded,
            color: const Color(0xFF845EC2),
            gradient: const LinearGradient(
              colors: [Color(0xFF845EC2), Color(0xFFB39BC8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap:
                (context) =>
                    _navigateToPage(context, const TransaksiOnlinePage()),
          ),
          AdminMenuItem(
            title: 'Penjualan Offline',
            icon: Icons.store_rounded,
            color: const Color(0xFF5C6BC0),
            gradient: const LinearGradient(
              colors: [Color(0xFF5C6BC0), Color(0xFF7986CB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap:
                (context) =>
                    _navigateToPage(context, const PenjualanOfflinePage()),
          ),
        ],
      ),

      // Payment & Order Management
      MenuCategory(
        title: 'Pembayaran & Pengiriman',
        icon: Icons.payment_rounded,
        items: [
          AdminMenuItem(
            title: 'Pembayaran Online',
            icon: Icons.payment_rounded,
            color: const Color(0xFF26C6DA),
            gradient: const LinearGradient(
              colors: [Color(0xFF26C6DA), Color(0xFF00ACC1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap:
                (context) => _navigateToPage(
                  context,
                  const AdminLobbyPembayaranOnline(),
                ),
          ),
          AdminMenuItem(
            title: 'Faktur Online',
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFF7B68EE),
            gradient: const LinearGradient(
              colors: [Color(0xFF7B68EE), Color(0xFF9A7BF2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap:
                (context) => _navigateToPage(context, const FakturOnlinePage()),
          ),
          AdminMenuItem(
            title: 'Pengiriman',
            icon: Icons.local_shipping_rounded,
            color: const Color(0xFF42A5F5),
            gradient: const LinearGradient(
              colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap:
                (context) => _navigateToPage(context, const PengirimanPage()),
          ),
          AdminMenuItem(
            title: 'Setting Pengantaran',
            icon: Icons.local_shipping_rounded,
            color: const Color(0xFFFF7043), // oranye terang
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF7043),
                Color(0xFFFF5722),
              ], // gradasi oranje ke merah
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap:
                (context) => _navigateToPage(context, const AdminPengiriman()),
          ),
        ],
      ),

      // System Management
      MenuCategory(
        title: 'Sistem',
        icon: Icons.settings_rounded,
        items: [
          AdminMenuItem(
            title: 'Akun',
            icon: Icons.account_circle_rounded,
            color: verifikasiStyle['color'], // Ganti dari static color
            gradient: verifikasiStyle['gradient'], // Ganti dari static gradient
            isUrgent: verifikasiStyle['isUrgent'], // Tambahkan ini
            notificationCount: _verifikasiCount, // Tambahkan ini
            notificationText: verifikasiStyle['statusText'], // Tambahkan ini
            showNotification: true, // Tambahkan ini
            isLoading: _isLoadingVerifikasiData, // Tambahkan ini
            onTap:
                (context) => _navigateToPage(context, const AdminLobbyAkun()),
          ),
          AdminMenuItem(
            title: 'Notifikasi & Promosi',
            icon: Icons.notifications_rounded,
            color: verifikasiStyle['color'], // Ganti dari static color
            gradient: verifikasiStyle['gradient'], // Ganti dari static gradient
            isUrgent: verifikasiStyle['isUrgent'], // Tambahkan ini
            notificationCount: _verifikasiCount, // Tambahkan ini
            notificationText: verifikasiStyle['statusText'], // Tambahkan ini
            showNotification: true, // Tambahkan ini
            isLoading: _isLoadingVerifikasiData, // Tambahkan ini
            onTap:
                (context) =>
                    _navigateToPage(context, const AdminSendPromoPage()),
          ),
        ],
      ),
      MenuCategory(
        title: 'Operasional',
        icon: Icons.broadcast_on_personal_outlined,
        items: [
          AdminMenuItem(
            title: 'Operasional',
            icon: Icons.settings_backup_restore,
            color: verifikasiStyle['color'], // Ganti dari static color
            gradient: verifikasiStyle['gradient'], // Ganti dari static gradient
            isUrgent: verifikasiStyle['isUrgent'], // Tambahkan ini
            notificationCount: _verifikasiCount, // Tambahkan ini
            notificationText: verifikasiStyle['statusText'], // Tambahkan ini
            showNotification: true, // Tambahkan ini
            isLoading: _isLoadingVerifikasiData, // Tambahkan ini
            onTap:
                (context) => _navigateToPage(context, const AdminOperasional()),
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchTextController.clear();
        _searchQuery = '';
      }
    });
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void _navigateToChatCustomerService() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PembeliListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFEDF2F7)],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            if (_isSearchVisible) _buildSearchBar(),
            _buildContent(),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      // TAMBAHKAN LEADING UNTUK TOMBOL REFRESH
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: IconButton(
          onPressed: _refreshData,
          icon: const Icon(
            Icons.refresh_rounded,
            size: 26,
            color: Colors.white,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
          ),
          child: const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: _toggleSearch,
            icon: Icon(
              _isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
              size: 26,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchTextController,
          autofocus: true,
          style: const TextStyle(
            color: Color(0xFF2D3748),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Cari menu admin...',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      sliver:
          _searchQuery.isEmpty
              ? SliverList(
                delegate: SliverChildListDelegate([
                  // TAMBAHAN: Dashboard sebagai item pertama
                  if (_searchQuery.isEmpty) ...[
                    const SizedBox(height: 20),
                    _buildCategoryHeader(
                      MenuCategory(
                        title: 'Dashboard Overview',
                        icon: Icons.dashboard_rounded,
                        items: [],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDashboardCards(),
                    _buildDashboardChart(),
                    const SizedBox(height: 32),
                  ],
                  // Menu categories
                  ..._menuCategories.asMap().entries.map((entry) {
                    final categoryIndex = entry.key;
                    final category = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (categoryIndex > 0) const SizedBox(height: 32),
                        _buildCategoryHeader(category),
                        const SizedBox(height: 16),
                        _buildCategoryGrid(category),
                      ],
                    );
                  }).toList(),
                ]),
              )
              : _buildSearchResults(),
    );
  }

  Widget _buildDashboardCards() {
    if (loadingDashboard) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _infoCard('Omzet Hari Ini', summary?.todayOmzet ?? 0),
        _infoCard('Profit Hari Ini', summary?.todayProfit ?? 0),
        _infoCard('Omzet Bulan Ini', summary?.monthOmzet ?? 0),
        _infoCard('Profit Bulan Ini', summary?.monthProfit ?? 0),
      ],
    );
  }

  Widget _buildDashboardChart() {
    if (loadingDashboard || data.isEmpty) {
      return const SizedBox.shrink();
    }

    final label = _labels();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Grafik Penjualan (Total)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 260,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: _spotsTotal(forecast: false),
                        isCurved: true,
                        color: const Color(0xFF667EEA),
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                      ),
                      LineChartBarData(
                        spots: _spotsTotal(forecast: true),
                        isCurved: true,
                        dashArray: [8, 6],
                        color: const Color(0xFFFF9800),
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) {
                            final i = v.toInt();
                            if (i < 0 || i >= label.length) {
                              return const SizedBox.shrink();
                            }
                            if (i % 3 != 0) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                label[i],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  _LegendDot(),
                  SizedBox(width: 6),
                  Text('Historis'),
                  SizedBox(width: 16),
                  _LegendDot(dashed: true),
                  SizedBox(width: 6),
                  Text('Forecast'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    if (loadingDashboard) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final label = _labels();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          children: [
            // Cards summary
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _infoCard('Omzet Hari Ini', summary?.todayOmzet ?? 0),
                _infoCard('Profit Hari Ini', summary?.todayProfit ?? 0),
                _infoCard('Omzet Bulan Ini', summary?.monthOmzet ?? 0),
                _infoCard('Profit Bulan Ini', summary?.monthProfit ?? 0),
              ],
            ),
            const SizedBox(height: 16),

            // LineChart total
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grafik Penjualan (Total)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 260,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: _spotsTotal(forecast: false),
                              isCurved: true,
                              color: const Color(0xFF667EEA),
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: _spotsTotal(forecast: true),
                              isCurved: true,
                              dashArray: [8, 6],
                              color: const Color(0xFFFF9800),
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 42,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, meta) {
                                  final i = v.toInt();
                                  if (i < 0 || i >= label.length) {
                                    return const SizedBox.shrink();
                                  }
                                  if (i % 3 != 0)
                                    return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      label[i],
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: const FlGridData(show: true),
                          borderData: FlBorderData(show: true),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        _LegendDot(),
                        SizedBox(width: 6),
                        Text('Historis'),
                        SizedBox(width: 16),
                        _LegendDot(dashed: true),
                        SizedBox(width: 6),
                        Text('Forecast'),
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

  Widget _infoCard(String title, int value) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 12 * 3) / 2,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${_fmt(value)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorizedMenu() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, categoryIndex) {
        final category = _menuCategories[categoryIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (categoryIndex > 0) const SizedBox(height: 32),
            _buildCategoryHeader(category),
            const SizedBox(height: 16),
            _buildCategoryGrid(category),
          ],
        );
      }, childCount: _menuCategories.length),
    );
  }

  Widget _buildCategoryHeader(MenuCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(category.icon, color: const Color(0xFF667EEA), size: 24),
          const SizedBox(width: 12),
          Text(
            category.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(MenuCategory category) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: category.items.length,
      itemBuilder: (context, index) {
        final item = category.items[index];
        return AdminMenuCard(item: item);
      },
    );
  }

  Widget _buildSearchResults() {
    final filteredItems = _filteredMenuItems;
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = filteredItems[index];
        return AdminMenuCard(item: item);
      }, childCount: filteredItems.length),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToChatCustomerService,
      backgroundColor: const Color(0xFF667EEA),
      foregroundColor: Colors.white,
      elevation: 12,
      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 24),
      label: const Text(
        'Chat Pembeli',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

// Model classes
class MenuCategory {
  final String title;
  final IconData icon;
  final List<AdminMenuItem> items;

  MenuCategory({required this.title, required this.icon, required this.items});
}

class AdminMenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final Gradient gradient;
  final String? subtitle;
  final bool isUrgent;
  final Function(BuildContext) onTap;
  final bool showNotification;
  final int? notificationCount;
  final String? notificationText;
  final bool isLoading;

  AdminMenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.gradient,
    this.subtitle,
    this.isUrgent = false,
    required this.onTap,
    this.showNotification = false,
    this.notificationCount,
    this.notificationText,
    this.isLoading = false,
  });
}

class AdminMenuCard extends StatelessWidget {
  final AdminMenuItem item;

  const AdminMenuCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            item.onTap(context);
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: item.gradient,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child:
                          item.isLoading
                              ? const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Icon(item.icon, color: Colors.white, size: 28),
                    ),
                    if (item.isUrgent && !item.isLoading)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'URGENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE53E3E),
                          ),
                        ),
                      ),
                  ],
                ),
                Flexible(
                  // Add Flexible here to prevent overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Add this
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (item.showNotification && !item.isLoading) ...[
                        const SizedBox(height: 6), // Reduced from 8
                        Flexible(
                          // Wrap notification in Flexible
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, // Reduced from 12
                              vertical: 4, // Reduced from 6
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
                                Icon(
                                  item.notificationCount == 0
                                      ? Icons.check_circle_outline
                                      : Icons.info_outline,
                                  color: Colors.white,
                                  size: 12, // Reduced from 14
                                ),
                                const SizedBox(width: 4), // Reduced from 6
                                Flexible(
                                  child: Text(
                                    item.notificationText ?? '',
                                    style: const TextStyle(
                                      fontSize: 11, // Reduced from 12
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (item.isLoading) ...[
                        const SizedBox(height: 6), // Reduced from 8
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, // Reduced from 12
                            vertical: 4, // Reduced from 6
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Memuat...',
                            style: TextStyle(
                              fontSize: 11, // Reduced from 12
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final bool dashed;
  const _LegendDot({this.dashed = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 8,
      decoration: BoxDecoration(
        border: dashed ? Border.all() : null,
        color: dashed ? Colors.transparent : const Color(0xFF667EEA),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
