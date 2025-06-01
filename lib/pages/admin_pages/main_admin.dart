import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/pages/admin_pages/list_chat_pembeli.dart';

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

  final List<AdminMenuItem> _allMenuItems = [
    AdminMenuItem(
      title: 'Absensi Karyawan',
      icon: Icons.access_time_rounded,
      color: const Color(0xFF2D3748),
      onTap: () {},
    ),
    AdminMenuItem(
      title: 'Izin/Sakit Karyawan',
      icon: Icons.sick_rounded,
      color: const Color(0xFF2D3748),
      onTap: () {},
    ),
    AdminMenuItem(
      title: 'Daftar Produk',
      icon: Icons.inventory_2_rounded,
      color: const Color(0xFF2D3748),
      onTap: () {},
    ),
    AdminMenuItem(
      title: 'Transaksi Online',
      icon: Icons.credit_card_rounded,
      color: const Color(0xFF2D3748),
      onTap: () {},
    ),
    AdminMenuItem(
      title: 'Penjualan Harian',
      icon: Icons.analytics_rounded,
      color: const Color(0xFF2D3748),
      subtitle: '(Online + Offline)',
      onTap: () {},
    ),
    AdminMenuItem(
      title: 'Pembayaran Online',
      icon: Icons.payment_rounded,
      color: const Color(0xFF2D3748),
      onTap: () {},
    ),
    AdminMenuItem(
      title: 'Faktur Online',
      icon: Icons.receipt_long_rounded,
      color: const Color(0xFF2D3748),
      onTap: () {},
    ),
    AdminMenuItem(
      title: 'Ulasan Produk',
      icon: Icons.star_rate_rounded,
      color: const Color(0xFF2D3748),
      onTap: () {},
    ),
    AdminMenuItem(
      title: 'Produk Perlu Restok',
      icon: Icons.warning_amber_rounded,
      color: const Color(0xFFE53E3E),
      onTap: () {},
    ),
    AdminMenuItem(
      title: 'Penjualan Offline',
      icon: Icons.store_rounded,
      color: const Color(0xFF2D3748),
      onTap: () {},
    ),
    AdminMenuItem(
      title: 'Pengiriman',
      icon: Icons.local_shipping_rounded,
      color: const Color(0xFF2D3748),
      onTap: () {},
    ),
    AdminMenuItem(
      title: 'Akun',
      icon: Icons.account_circle_rounded,
      color: const Color(0xFF2D3748),
      onTap: () {},
    ),
    AdminMenuItem(
      title: 'Harga Original Produk',
      icon: Icons.price_change,
      color: const Color(0xFF2D3748),
      onTap: () {},
    ),
  ];

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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
      begin: const Offset(0, 0.3),
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

  void _navigateToChatCustomerService() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => PembeliListPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Changed to white background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        title: AnimatedBuilder(
          animation: _searchAnimation,
          builder: (context, child) {
            return _isSearchVisible
                ? FadeTransition(
                  opacity: _searchAnimation,
                  child: TextField(
                    controller: _searchTextController,
                    autofocus: true,
                    style: const TextStyle(
                      color: Color(0xFF2D3748),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Cari menu...',
                      hintStyle: TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 18,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                )
                : const Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                );
          },
        ),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
                key: ValueKey(_isSearchVisible),
                size: 28,
                color: const Color(0xFF2D3748),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.withOpacity(0.2),
                  Colors.grey.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white, // Ensure body background is white
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Admin',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D3748),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kelola sistem dengan mudah dan efisien',
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFF718096),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio:
                                  1.2, // Increased from 1.4 to give more height
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = _filteredMenuItems[index];
                          return TweenAnimationBuilder<double>(
                            duration: Duration(
                              milliseconds: 200 + (index * 50),
                            ),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 0.8 + (0.2 * value),
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
                    const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: FloatingActionButton.extended(
              onPressed: _navigateToChatCustomerService,
              backgroundColor: const Color(0xFF2D3748),
              foregroundColor: Colors.white,
              elevation: 8,
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 24),
              label: const Text(
                'Customer Service',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
  final String? subtitle;
  final VoidCallback onTap;

  AdminMenuItem({
    required this.title,
    required this.icon,
    required this.color,
    this.subtitle,
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
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(
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
          child: Material(
            elevation: _elevationAnimation.value,
            borderRadius: BorderRadius.circular(20),
            shadowColor: Colors.black.withOpacity(0.1),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.item.onTap();
              },
              onTapDown: (_) => _hoverController.forward(),
              onTapUp: (_) => _hoverController.reverse(),
              onTapCancel: () => _hoverController.reverse(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(16), // Reduced from 20 to 16
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(
                        10,
                      ), // Reduced from 12 to 10
                      decoration: BoxDecoration(
                        color: widget.item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.item.icon,
                        color: widget.item.color,
                        size: 24, // Reduced from 28 to 24
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ), // Fixed spacing instead of Spacer
                    Flexible(
                      // Added Flexible to prevent overflow
                      child: Text(
                        widget.item.title,
                        style: const TextStyle(
                          fontSize: 14, // Reduced from 16 to 14
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.item.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Flexible(
                        // Added Flexible to prevent overflow
                        child: Text(
                          widget.item.subtitle!,
                          style: const TextStyle(
                            fontSize: 11, // Reduced from 12 to 11
                            color: Color(0xFF718096),
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
