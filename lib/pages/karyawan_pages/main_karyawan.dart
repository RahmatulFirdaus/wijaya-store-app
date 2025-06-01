import 'package:flutter/material.dart';
import 'package:frontend/pages/karyawan_pages/absensi/lobby_absensi.dart';
import 'package:frontend/pages/karyawan_pages/pengajuan_izin/lobby_pengajuan_izin.dart';
import 'package:frontend/pages/karyawan_pages/penjualan_offline/lobby_penjualan_offline.dart';

class MainKaryawan extends StatefulWidget {
  const MainKaryawan({super.key});

  @override
  State<MainKaryawan> createState() => _MainKaryawanState();
}

class _MainKaryawanState extends State<MainKaryawan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              const SizedBox(height: 40),
              Text(
                'Semangat Bekerja !',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),

              // Menu Buttons
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Absensi Button
                    _buildMenuButton(
                      context,
                      icon: Icons.access_time_rounded,
                      title: 'Absensi',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LobbyAbsensi(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Catatan Offline Button
                    _buildMenuButton(
                      context,
                      icon: Icons.laptop_mac_rounded,
                      title: 'Catatan Offline',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LobbyPenjualanOffline(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Pengajuan Izin Button
                    _buildMenuButton(
                      context,
                      icon: Icons.schedule_rounded,
                      title: 'Pengajuan Izin',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LobbyPengajuanIzin(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black87, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.black54,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
