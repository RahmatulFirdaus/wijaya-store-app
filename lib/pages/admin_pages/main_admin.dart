import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/pages/admin_pages/list_chat_pembeli.dart';
import 'package:frontend/pages/admin_pages/pages/admin_karyawan_pages/admin_absensi_karyawan.dart';
import 'package:frontend/pages/admin_pages/pages/admin_karyawan_pages/admin_pengajuan_izin_karyawan.dart';
import 'package:frontend/pages/admin_pages/pages/admin_master_pages/admin_akun.dart';
import 'package:frontend/pages/admin_pages/pages/admin_master_pages/admin_gaji_karyawan.dart';
import 'package:frontend/pages/admin_pages/pages/admin_master_pages/admin_harga_original.dart';
import 'package:frontend/pages/admin_pages/pages/admin_mix_online_offline/admin_penjualan_harian.dart';
import 'package:frontend/pages/admin_pages/pages/admin_mix_online_offline/admin_penjualan_offline.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/admin_daftar_produk.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/admin_faktur_online.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/admin_pembayaran_online.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/admin_pengiriman.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/admin_produk_perlu_restok.dart';
import 'package:frontend/pages/admin_pages/pages/admin_mix_online_offline/admin_transaksi_online.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/admin_ulasan_produk.dart';

class MainAdmin extends StatefulWidget {
  const MainAdmin({super.key});

  @override
  State<MainAdmin> createState() => _MainAdminState();
}

class _MainAdminState extends State<MainAdmin> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _searchController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _searchAnimation;

  TextEditingController _searchTextController = TextEditingController();
  bool _isSearchVisible = false;
  String _searchQuery = '';

  // Declare the list without initialization
  late List<AdminMenuItem> _allMenuItems;

  List<AdminMenuItem> get _filteredMenuItems {
    if (_searchQuery.isEmpty) {
      return _allMenuItems;
    }
    return _allMenuItems
        .where(
          (item) =>
              item.title.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();

    // Initialize the menu items here instead of in the field declaration
    _allMenuItems = [
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
            (context) => _navigateToPage(context, const AbsensiKaryawanPage()),
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
        onTap: (context) => _navigateToPage(context, const IzinKaryawanPage()),
      ),
      AdminMenuItem(
        title: 'Daftar Produk',
        icon: Icons.inventory_2_rounded,
        color: const Color(0xFF4ECDC4),
        gradient: const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: (context) => _navigateToPage(context, const DaftarProdukPage()),
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
            (context) => _navigateToPage(context, const TransaksiOnlinePage()),
      ),
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
            (context) => _navigateToPage(context, const PenjualanHarianPage()),
      ),
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
            (context) => _navigateToPage(context, const PembayaranOnlinePage()),
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
        onTap: (context) => _navigateToPage(context, const FakturOnlinePage()),
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
        onTap: (context) => _navigateToPage(context, const UlasanProdukPage()),
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
        onTap: (context) => _navigateToPage(context, const ProdukRestokPage()),
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
            (context) => _navigateToPage(context, const PenjualanOfflinePage()),
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
        onTap: (context) => _navigateToPage(context, const PengirimanPage()),
      ),
      AdminMenuItem(
        title: 'Akun',
        icon: Icons.account_circle_rounded,
        color: const Color(0xFF66BB6A),
        gradient: const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: (context) => _navigateToPage(context, const AkunPage()),
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
        onTap: (context) => _navigateToPage(context, const HargaOriginalPage()),
      ),
      AdminMenuItem(
        title: 'Gaji Karyawan',
        icon: Icons.attach_money,
        color: const Color(0xFFAB47BC),
        gradient: const LinearGradient(
          colors: [Color(0xFFAB47BC), Color(0xFF8E24AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: (context) => _navigateToPage(context, const AdminGajiKaryawan()),
      ),
    ];

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _searchController.forward();
      } else {
        _searchController.reverse();
        _searchTextController.clear();
        _searchQuery = '';
      }
    });
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _navigateToChatCustomerService() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => PembeliListPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
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
            SliverAppBar(
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
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedBuilder(
                            animation: _fadeAnimation,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _fadeAnimation,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Welcome Back',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
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
                              );
                            },
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
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _isSearchVisible
                            ? Icons.close_rounded
                            : Icons.search_rounded,
                        key: ValueKey(_isSearchVisible),
                        size: 26,
                        color: Colors.white,
                      ),
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
            ),
            if (_isSearchVisible)
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _searchAnimation,
                  builder: (context, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: Offset.zero,
                      ).animate(_searchAnimation),
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
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.grey.shade500,
                            ),
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
                  },
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.1,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = _filteredMenuItems[index];
                          return TweenAnimationBuilder<double>(
                            duration: Duration(
                              milliseconds: 300 + (index * 100),
                            ),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 50 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: AdminMenuCard(
                                    item: item,
                                    index: index,
                                  ),
                                ),
                              );
                            },
                          );
                        }, childCount: _filteredMenuItems.length),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
      floatingActionButton: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1000),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: FloatingActionButton.extended(
              onPressed: _navigateToChatCustomerService,
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
              elevation: 12,
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 24),
              label: const Text(
                'Customer Service',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
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

class AdminMenuCard extends StatefulWidget {
  final AdminMenuItem item;
  final int index;

  const AdminMenuCard({super.key, required this.item, required this.index});

  @override
  State<AdminMenuCard> createState() => _AdminMenuCardState();
}

class _AdminMenuCardState extends State<AdminMenuCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 8.0, end: 16.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.item.color.withOpacity(0.3),
                  blurRadius: _elevationAnimation.value,
                  offset: Offset(0, _elevationAnimation.value / 2),
                ),
              ],
            ),
            child: Material(
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  widget.item.onTap(context);
                },
                onTapDown: (_) => _hoverController.forward(),
                onTapUp: (_) => _hoverController.reverse(),
                onTapCancel: () => _hoverController.reverse(),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: widget.item.gradient,
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
                            child: Icon(
                              widget.item.icon,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          if (widget.item.isUrgent)
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
                        widget.item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.item.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.item.subtitle!,
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
          ),
        );
      },
    );
  }
}
