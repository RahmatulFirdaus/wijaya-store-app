import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:toastification/toastification.dart';

class AdminMetodePembayaranEdit extends StatefulWidget {
  final String id;
  final String namaMetode;
  final String deskripsi;

  const AdminMetodePembayaranEdit({
    super.key,
    required this.id,
    required this.namaMetode,
    required this.deskripsi,
  });

  @override
  State<AdminMetodePembayaranEdit> createState() =>
      _AdminMetodePembayaranEditState();
}

class _AdminMetodePembayaranEditState extends State<AdminMetodePembayaranEdit>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _deskripsiController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  final FocusNode _namaFocusNode = FocusNode();
  final FocusNode _deskripsiFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.namaMetode);
    _deskripsiController = TextEditingController(text: widget.deskripsi);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _animationController.dispose();
    _namaFocusNode.dispose();
    _deskripsiFocusNode.dispose();
    super.dispose();
  }

  void _showToast(String message, {bool isSuccess = true}) {
    toastification.show(
      context: context,
      type: isSuccess ? ToastificationType.success : ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: Text(
        isSuccess ? 'Berhasil' : 'Gagal',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      description: Text(message, style: const TextStyle(fontSize: 14)),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final result =
            await UpdateMetodePembayaranService.updateMetodePembayaran(
              id: widget.id,
              namaMetode: _namaController.text.trim(),
              deskripsi: _deskripsiController.text.trim(),
            );

        setState(() => _isLoading = false);

        if (result.toLowerCase().contains("berhasil")) {
          _showToast(result, isSuccess: true);
          await Future.delayed(const Duration(milliseconds: 1500));
          Navigator.pop(context);
        } else {
          _showToast(result, isSuccess: false);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showToast('Terjadi kesalahan: ${e.toString()}', isSuccess: false);
      }
    } else {
      _showToast(
        'Mohon lengkapi semua field yang diperlukan',
        isSuccess: false,
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required FocusNode focusNode,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            validator: validator,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: maxLines > 1 ? 16 : 14,
              ),
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
            onTap: () {
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Edit Metode Pembayaran',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        shadowColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.payment,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Ubah Informasi Metode Pembayaran',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pastikan informasi yang Anda masukkan sudah benar',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Form Fields
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'Nama Metode Pembayaran',
                          controller: _namaController,
                          focusNode: _namaFocusNode,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama metode pembayaran harus diisi';
                            }
                            if (value.trim().length < 3) {
                              return 'Nama metode minimal 3 karakter';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        _buildTextField(
                          label: 'Deskripsi',
                          controller: _deskripsiController,
                          focusNode: _deskripsiFocusNode,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Deskripsi harus diisi';
                            }
                            if (value.trim().length < 10) {
                              return 'Deskripsi minimal 10 karakter';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors:
                            _isLoading
                                ? [Colors.grey.shade300, Colors.grey.shade400]
                                : [
                                  const Color(0xFF1A1A1A),
                                  const Color(0xFF2D2D2D),
                                ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              _isLoading
                                  ? Colors.transparent
                                  : Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cancel Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE5E5E5),
                        width: 1.5,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
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
