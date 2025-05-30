import 'package:flutter/material.dart';
import 'package:frontend/models/karyawan_model.dart';
import 'package:toastification/toastification.dart';

class LobbyAbsensi extends StatefulWidget {
  const LobbyAbsensi({super.key});

  @override
  State<LobbyAbsensi> createState() => _LobbyAbsensiState();
}

class _LobbyAbsensiState extends State<LobbyAbsensi>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _showToast({required String message, required bool isSuccess}) {
    toastification.show(
      context: context,
      title: Text(
        isSuccess ? 'Berhasil' : 'Gagal',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
      description: Text(
        message,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      type: isSuccess ? ToastificationType.success : ToastificationType.error,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: const Duration(seconds: 4),
      backgroundColor: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
      foregroundColor: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      showProgressBar: true,
    );
  }

  Future<void> _handleAbsensi() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await PostAbsensi.kirimAbsensi();

      if (!mounted) return;

      _showToast(message: response.pesan, isSuccess: response.success);

      // Jika berhasil, tambahkan efek visual tambahan
      if (response.success) {
        // Bisa menambahkan navigasi kembali atau refresh data
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          // Navigator.pop(context); // Uncomment jika ingin kembali setelah berhasil
        }
      }
    } catch (e) {
      if (!mounted) return;

      _showToast(
        message: 'Terjadi kesalahan tidak terduga: ${e.toString()}',
        isSuccess: false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black87,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'ABSENSI',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Icon dengan animasi
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fingerprint,
                  size: 60,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 40),

              // Judul
              const Text(
                'KEHADIRAN ANDA',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: 2.0,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Tekan tombol di bawah untuk\nmelakukan absensi kehadiran',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade700,
                  height: 1.5,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 60),

              // Tombol Absensi dengan animasi
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isLoading ? 1.0 : _pulseAnimation.value,
                    child: Container(
                      width: double.infinity,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleAbsensi,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isLoading
                                  ? Colors.grey.shade300
                                  : Colors.black87,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child:
                            _isLoading
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.grey.shade600,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'MEMPROSES...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'HADIR',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Informasi tambahan
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pastikan Anda berada di lokasi yang tepat\nsebelum melakukan absensi',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
