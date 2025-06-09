import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:toastification/toastification.dart';

class AdminMetodePembayaranTambah extends StatefulWidget {
  const AdminMetodePembayaranTambah({super.key});

  @override
  State<AdminMetodePembayaranTambah> createState() =>
      _AdminMetodePembayaranTambahState();
}

class _AdminMetodePembayaranTambahState
    extends State<AdminMetodePembayaranTambah>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaMetodeController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final pesan =
            await TambahMetodePembayaranService.tambahMetodePembayaran(
              namaMetode: _namaMetodeController.text,
              deskripsi: _deskripsiController.text,
            );

        setState(() => _isLoading = false);

        if (pesan.contains('berhasil')) {
          // Success toast
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.fillColored,
            title: const Text(
              'Berhasil!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            description: Text(
              pesan,
              style: const TextStyle(color: Colors.white),
            ),
            alignment: Alignment.topCenter,
            direction: TextDirection.ltr,
            animationDuration: const Duration(milliseconds: 300),
            animationBuilder: (context, animation, alignment, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.elasticOut)),
                ),
                child: child,
              );
            },
            icon: const Icon(Icons.check_circle, color: Colors.white),
            primaryColor: Colors.green,
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x07000000),
                blurRadius: 16,
                offset: Offset(0, 16),
                spreadRadius: 0,
              ),
            ],
            closeButtonShowType: CloseButtonShowType.onHover,
            closeOnClick: false,
            pauseOnHover: true,
            dragToClose: true,
            applyBlurEffect: true,
            autoCloseDuration: const Duration(seconds: 3),
          );

          // Delay navigation to show toast
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          // Error toast
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.fillColored,
            title: const Text(
              'Gagal!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            description: Text(
              pesan,
              style: const TextStyle(color: Colors.white),
            ),
            alignment: Alignment.topCenter,
            direction: TextDirection.ltr,
            animationDuration: const Duration(milliseconds: 300),
            animationBuilder: (context, animation, alignment, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.elasticOut)),
                ),
                child: child,
              );
            },
            icon: const Icon(Icons.error, color: Colors.white),
            primaryColor: Colors.red,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x07000000),
                blurRadius: 16,
                offset: Offset(0, 16),
                spreadRadius: 0,
              ),
            ],
            closeButtonShowType: CloseButtonShowType.onHover,
            closeOnClick: false,
            pauseOnHover: true,
            dragToClose: true,
            applyBlurEffect: true,
            autoCloseDuration: const Duration(seconds: 4),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);

        // Error toast for exceptions
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          title: const Text(
            'Error!',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          description: const Text(
            'Terjadi kesalahan saat menambahkan metode pembayaran',
            style: TextStyle(color: Colors.white),
          ),
          alignment: Alignment.topCenter,
          direction: TextDirection.ltr,
          animationDuration: const Duration(milliseconds: 300),
          icon: const Icon(Icons.error_outline, color: Colors.white),
          primaryColor: Colors.red,
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: BorderRadius.circular(16),
          autoCloseDuration: const Duration(seconds: 4),
        );
      }
    } else {
      // Validation error toast
      toastification.show(
        context: context,
        type: ToastificationType.warning,
        style: ToastificationStyle.fillColored,
        title: const Text(
          'Peringatan!',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        description: const Text(
          'Mohon lengkapi semua field yang diperlukan',
          style: TextStyle(color: Colors.white),
        ),
        alignment: Alignment.topCenter,
        direction: TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),
        icon: const Icon(Icons.warning, color: Colors.white),
        primaryColor: Colors.orange,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: BorderRadius.circular(16),
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void dispose() {
    _namaMetodeController.dispose();
    _deskripsiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
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
          'Tambah Metode Pembayaran',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey.shade50, Colors.grey.shade100],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.payment,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Metode Pembayaran Baru',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lengkapi informasi di bawah untuk menambahkan metode pembayaran baru',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Form Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Metode Field
                        const Text(
                          'Nama Metode Pembayaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _namaMetodeController,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Nama metode wajib diisi'
                                      : null,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Contoh: Bank BCA, OVO, GoPay',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.black87,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Deskripsi Field
                        const Text(
                          'Deskripsi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _deskripsiController,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Deskripsi wajib diisi'
                                      : null,
                          maxLines: 5,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Masukkan deskripsi metode pembayaran...\nContoh: Transfer bank dengan biaya admin rendah dan proses cepat',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                              height: 1.5,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.black87,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(20),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Submit Button
                  Container(
                    width: double.infinity,
                    height: 56,
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
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child:
                          _isLoading
                              ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Menambahkan...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              )
                              : const Text(
                                'Tambahkan Metode Pembayaran',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info Footer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pastikan informasi yang Anda masukkan sudah benar sebelum menyimpan.',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
