import 'package:flutter/material.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

LatLng? _lokasiPengirim;

class Pengiriman extends StatefulWidget {
  final String orderId; // Add order ID parameter

  const Pengiriman({super.key, required this.orderId});

  @override
  State<Pengiriman> createState() => _PengirimanState();
}

class _PengirimanState extends State<Pengiriman>
    with SingleTickerProviderStateMixin {
  StatusPengiriman? _statusPengiriman;
  bool _isLoading = true;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fetchStatus();
  }

  Future<void> _fetchLokasiPengirim() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.1.96:3000/api/get-location/${widget.orderId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['lat'] != null && data['lng'] != null) {
          final lat = double.tryParse(data['lat'].toString());
          final lng = double.tryParse(data['lng'].toString());

          if (lat != null && lng != null) {
            if (mounted) {
              setState(() {
                _lokasiPengirim = LatLng(lat, lng);
              });
            }
          }
        }
      } else {
        debugPrint('Gagal ambil lokasi, status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Gagal ambil lokasi pengirim: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    try {
      final status = await StatusPengiriman.fetchStatus(widget.orderId);
      setState(() {
        _statusPengiriman = status;
        _isLoading = false;
      });
      _animationController.forward();

      if (status.status.toLowerCase() == 'dikirim') {
        _fetchLokasiPengirim();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            size: 50,
            color: Colors.black87,
          ),
        );
      case 'dikirim':
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_shipping_outlined,
            size: 50,
            color: Colors.black87,
          ),
        );
      case 'diterima':
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 50,
            color: Colors.black87,
          ),
        );
      default:
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.help_outline,
            size: 50,
            color: Colors.black87,
          ),
        );
    }
  }

  String _getStatusTitle(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return 'PESANANMU SEDANG\nDALAM PROSES';
      case 'dikirim':
        return 'PESANANMU SEDANG\nDALAM PERJALANAN';
      case 'diterima':
        return 'PESANANMU SUDAH\nDITERIMA';
      default:
        return 'STATUS TIDAK\nDIKETAHUI';
    }
  }

  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return 'Pesanan Anda sedang diproses oleh penjual.\nMohon tunggu konfirmasi selanjutnya.';
      case 'dikirim':
        return 'Pesanan Anda sedang dalam perjalanan.\nSilakan pantau status pengiriman secara berkala.';
      case 'diterima':
        return 'Pesanan Anda telah berhasil diterima.\nTerima kasih telah berbelanja dengan kami!';
      default:
        return 'Status pengiriman tidak dapat diidentifikasi.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        title: const Text(
          'PENGIRIMAN',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.black87,
                  strokeWidth: 2,
                ),
              )
              : _error != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Terjadi Kesalahan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          _fetchStatus();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
              : AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            _buildStatusIcon(_statusPengiriman!.status),
                            const SizedBox(height: 32),
                            Text(
                              _getStatusTitle(_statusPengiriman!.status),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                letterSpacing: 1.0,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getStatusDescription(
                                  _statusPengiriman!.status,
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            ),
                            if (_statusPengiriman!.status.toLowerCase() ==
                                    'dikirim' &&
                                _lokasiPengirim != null) ...[
                              const SizedBox(height: 24),
                              Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: _lokasiPengirim!,
                                      zoom: 15,
                                    ),
                                    markers: {
                                      Marker(
                                        markerId: const MarkerId('pengirim'),
                                        position: _lokasiPengirim!,
                                        infoWindow: const InfoWindow(
                                          title: 'Kurir',
                                        ),
                                      ),
                                    },
                                    myLocationEnabled: false,
                                    myLocationButtonEnabled: false,
                                    zoomControlsEnabled: false,
                                    onMapCreated:
                                        (GoogleMapController controller) {},
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  'KEMBALI',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                });
                                _fetchStatus();
                              },
                              child: Text(
                                'Refresh Status',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
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
