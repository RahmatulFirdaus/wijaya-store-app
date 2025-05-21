import 'package:flutter/material.dart';
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

class _MainPembeliState extends State<MainPembeli> {
  final NavigationController _navController = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: _navController.screen[_navController.selectedIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
          showSelectedLabels: true,
          currentIndex: _navController.selectedIndex.value,
          onTap: (index) {
            _navController.updateIndex(index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: "Keranjang",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "Riwayat Transaksi",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
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
}
