import 'package:flutter/material.dart';
import 'package:frontend/services/notification_service.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/pembeli_pages/home_pembeli.dart';
import 'package:frontend/pages/pembeli_pages/keranjang_pembeli.dart';
import 'package:frontend/pages/pembeli_pages/profile_pembeli.dart';
import 'package:frontend/pages/pembeli_pages/riwayat_transaksi_pembeli.dart';

class MainPembeli extends StatefulWidget {
  const MainPembeli({super.key});

  @override
  State<MainPembeli> createState() => _MainPembeliState();
}

class _MainPembeliState extends State<MainPembeli>
    with TickerProviderStateMixin {
  final NavigationController _navController = Get.put(NavigationController());
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    NotificationService.saveTokenToBackend();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        extendBody: true,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: _navController.screen[_navController.selectedIndex.value],
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey.shade50],
                ),
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: const Color(0xFF6C5CE7),
                unselectedItemColor: Colors.grey.shade500,
                showUnselectedLabels: false,
                showSelectedLabels: true,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                currentIndex: _navController.selectedIndex.value,
                onTap: (index) {
                  _navController.updateIndex(index);
                  _animationController.reset();
                  _animationController.forward();
                },
                items: [
                  _buildNavItem(
                    Icons.home_rounded,
                    Icons.home_outlined,
                    "Home",
                    0,
                  ),
                  _buildNavItem(
                    Icons.shopping_cart,
                    Icons.shopping_cart_outlined,
                    "Keranjang",
                    1,
                  ),
                  _buildNavItem(
                    Icons.history,
                    Icons.history_outlined,
                    "Riwayat",
                    2,
                  ),
                  _buildNavItem(
                    Icons.person,
                    Icons.person_outline,
                    "Profile",
                    3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    int index,
  ) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(
          _navController.selectedIndex.value == index ? 8 : 4,
        ),
        decoration: BoxDecoration(
          gradient:
              _navController.selectedIndex.value == index
                  ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6C5CE7).withOpacity(0.2),
                      const Color(0xFF74B9FF).withOpacity(0.1),
                    ],
                  )
                  : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _navController.selectedIndex.value == index
                ? activeIcon
                : inactiveIcon,
            key: ValueKey(_navController.selectedIndex.value == index),
            size: _navController.selectedIndex.value == index ? 26 : 24,
          ),
        ),
      ),
      label: label,
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final List<Widget> screen = [
    const HomePembeli(),
    const KeranjangPembeli(),
    const RiwayatTransaksiPembeli(),
    const ProfilePembeli(),
  ];

  void updateIndex(int index) {
    selectedIndex.value = index;
  }

  // Method untuk smooth transition antar halaman
  void navigateWithAnimation(int index) {
    if (selectedIndex.value != index) {
      selectedIndex.value = index;
    }
  }
}

// Widget tambahan untuk efek ripple yang lebih smooth
class AnimatedNavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AnimatedNavItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<AnimatedNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward().then((_) => _controller.reverse());
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isSelected ? _scaleAnimation.value : 1.0,
            child: Transform.rotate(
              angle: widget.isSelected ? _rotationAnimation.value : 0.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient:
                      widget.isSelected
                          ? LinearGradient(
                            colors: [
                              const Color(0xFF6C5CE7).withOpacity(0.3),
                              const Color(0xFF74B9FF).withOpacity(0.2),
                            ],
                          )
                          : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isSelected ? widget.activeIcon : widget.icon,
                      color:
                          widget.isSelected
                              ? const Color(0xFF6C5CE7)
                              : Colors.grey.shade500,
                      size: 24,
                    ),
                    if (widget.isSelected) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: const Color(0xFF6C5CE7),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
