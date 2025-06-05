import 'package:flutter/material.dart';
import 'admin_metode_pembayaran.dart'; // Import halaman metode pembayaran
import 'admin_verifikasi_pembayaran.dart'; // Import halaman verifikasi pembayaran

class AdminLobbyPembayaranOnline extends StatefulWidget {
  const AdminLobbyPembayaranOnline({super.key});

  @override
  State<AdminLobbyPembayaranOnline> createState() =>
      _AdminLobbyPembayaranOnlineState();
}

class _AdminLobbyPembayaranOnlineState
    extends State<AdminLobbyPembayaranOnline> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pembayaran Online',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Spacer untuk memberikan ruang di atas
            const Spacer(flex: 2),

            // Tombol Metode Pembayaran
            _buildMenuButton(
              context,
              title: 'Metode Pembayaran',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminMetodePembayaran(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Tombol Verifikasi Pembayaran
            _buildMenuButton(
              context,
              title: 'Verifikasi Pembayaran',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminVerifikasiPembayaran(),
                  ),
                );
              },
            ),

            // Spacer untuk memberikan ruang di bawah
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
