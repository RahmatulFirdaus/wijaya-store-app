import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/pages/admin_pages/list_chat_pembeli.dart';
import 'package:frontend/pages/admin_pages/pages/admin_karyawan_pages/admin_absensi_karyawan.dart';
import 'package:frontend/pages/admin_pages/pages/admin_karyawan_pages/admin_pengajuan_izin_karyawan.dart';
import 'package:frontend/pages/admin_pages/pages/admin_master_pages/admin_lobby_akun.dart';
import 'package:frontend/pages/admin_pages/pages/admin_master_pages/admin_gaji_karyawan.dart';
import 'package:frontend/pages/admin_pages/pages/admin_master_pages/admin_harga_original.dart';
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

class MainAdmin extends StatefulWidget {
  const MainAdmin({super.key});

  @override
  State<MainAdmin> createState() => _MainAdminState();
}

class _MainAdminState extends State<MainAdmin> {
  final TextEditingController _searchTextController = TextEditingController();
  bool _isSearchVisible = false;
  String _searchQuery = '';

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
    _initializeMenuCategories();
  }

  void _initializeMenuCategories() {
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
            color: const Color(0xFFE53E3E),
            gradient: const LinearGradient(
              colors: [Color(0xFFE53E3E), Color(0xFFFF6B6B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            isUrgent: true,
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
              ], // gradasi oranye ke merah
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
            color: const Color(0xFF66BB6A),
            gradient: const LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap:
                (context) => _navigateToPage(context, const AdminLobbyAkun()),
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
      padding: const EdgeInsets.all(20),
      sliver:
          _searchQuery.isEmpty
              ? _buildCategorizedMenu()
              : _buildSearchResults(),
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
        'Customer Service',
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

  AdminMenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.gradient,
    this.subtitle,
    this.isUrgent = false,
    required this.onTap,
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
                      child: Icon(item.icon, color: Colors.white, size: 28),
                    ),
                    if (item.isUrgent)
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
                const Spacer(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
