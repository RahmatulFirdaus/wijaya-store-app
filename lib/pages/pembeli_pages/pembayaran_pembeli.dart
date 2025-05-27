import 'package:flutter/material.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PembayaranPembeli extends StatefulWidget {
  final double totalHarga;
  const PembayaranPembeli({super.key, required this.totalHarga});

  @override
  State<PembayaranPembeli> createState() => _PembayaranPembeliState();
}

class _PembayaranPembeliState extends State<PembayaranPembeli>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _namaPengirimController = TextEditingController();
  final _bankPengirimController = TextEditingController();
  final _alamatPengirimanController = TextEditingController();

  List<GetDataMetodePembayaran> _metodePembayaranList = [];
  GetDataMetodePembayaran? _selectedMetodePembayaran;
  List<File> _buktiTransferList = [];
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _loadMetodePembayaran();
    _animationController.forward();
  }

  Future<void> _loadMetodePembayaran() async {
    try {
      final metodeList =
          await GetDataMetodePembayaran.getDataMetodePembayaran();
      setState(() {
        _metodePembayaranList = metodeList;
        if (metodeList.isNotEmpty) {
          _selectedMetodePembayaran = metodeList.first;
        }
      });
    } catch (e) {
      _showSnackBar('Gagal memuat metode pembayaran: $e', isError: true);
    }
  }

  Future<void> _pilihFoto() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pilih Sumber Gambar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildImageSourceButton(
                        icon: Icons.photo_library_outlined,
                        label: 'Galeri',
                        onPressed: () async {
                          Navigator.pop(context);
                          final List<XFile> images =
                              await picker.pickMultiImage();
                          await _processSelectedImages(images);
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildImageSourceButton(
                        icon: Icons.camera_alt_outlined,
                        label: 'Kamera',
                        onPressed: () async {
                          Navigator.pop(context);
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.camera,
                          );
                          if (image != null) {
                            await _processSelectedImages([image]);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.black),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processSelectedImages(List<XFile> images) async {
    final List<File> validImages = [];
    final allowedExtensions = ['jpg', 'jpeg', 'png'];

    for (final image in images) {
      final fileExtension = image.path.split('.').last.toLowerCase();
      if (allowedExtensions.contains(fileExtension)) {
        validImages.add(File(image.path));
      }
    }

    if (validImages.isEmpty && images.isNotEmpty) {
      _showSnackBar(
        'Format gambar tidak didukung. Hanya JPG, JPEG, atau PNG.',
        isError: true,
      );
      return;
    }

    setState(() {
      _buktiTransferList.addAll(validImages);
    });

    if (validImages.length != images.length) {
      _showSnackBar(
        'Beberapa gambar tidak dapat ditambahkan karena format tidak didukung.',
        isError: true,
      );
    }
  }

  void _hapusGambar(int index) {
    setState(() {
      _buktiTransferList.removeAt(index);
    });
  }

  Future<void> _submitPembayaran() async {
    if (!_formKey.currentState!.validate()) return;

    if (_buktiTransferList.isEmpty) {
      _showSnackBar('Harap pilih minimal satu bukti pembayaran', isError: true);
      return;
    }

    if (_selectedMetodePembayaran == null) {
      _showSnackBar('Harap pilih metode pembayaran', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Untuk multiple images, Anda mungkin perlu memodifikasi API call
      // Saat ini menggunakan gambar pertama sebagai contoh
      final result = await TambahPembayaran.addPembayaran(
        id_metode_pembayaran: _selectedMetodePembayaran!.id,
        total_harga: widget.totalHarga.toString(),
        nama_pengirim: _namaPengirimController.text.trim(),
        bank_pengirim: _bankPengirimController.text.trim(),
        alamat_pengiriman: _alamatPengirimanController.text.trim(),
        bukti_transfer_path:
            _buktiTransferList
                .first
                .path, // Perlu dimodifikasi untuk multiple files
      );

      _showSnackBar(
        result ?? 'Pembayaran berhasil ditambahkan',
        isError: false,
      );
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Harga Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${widget.totalHarga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Metode Pembayaran
                _buildSectionTitle('Metode Pembayaran'),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<GetDataMetodePembayaran>(
                    value: _selectedMetodePembayaran,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: InputBorder.none,
                    ),
                    items:
                        _metodePembayaranList.map((metode) {
                          return DropdownMenuItem<GetDataMetodePembayaran>(
                            value: metode,
                            child: Text(
                              metode.nama_metode,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedMetodePembayaran = newValue;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Deskripsi metode pembayaran
                if (_selectedMetodePembayaran?.deskripsi != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      _selectedMetodePembayaran!.deskripsi,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[800],
                        height: 1.4,
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // Form Fields
                _buildTextField(
                  label: 'Nama Pengirim',
                  controller: _namaPengirimController,
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama pengirim tidak boleh kosong';
                    }
                    if (value.trim().length < 3) {
                      return 'Nama terlalu pendek';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  label: 'Bank Pengirim',
                  controller: _bankPengirimController,
                  icon: Icons.account_balance_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bank pengirim tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  label: 'Alamat Pengiriman',
                  controller: _alamatPengirimanController,
                  icon: Icons.location_on_outlined,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Alamat pengiriman tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Upload Bukti Transfer
                _buildSectionTitle('Bukti Pembayaran'),
                const SizedBox(height: 12),

                // Grid gambar yang sudah dipilih
                if (_buktiTransferList.isNotEmpty) ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemCount: _buktiTransferList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.file(
                                _buktiTransferList[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _hapusGambar(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Tombol upload
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: _pilihFoto,
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 32,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tambah Bukti Pembayaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'JPG, JPEG, atau PNG',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Tombol Konfirmasi
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitPembayaran,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'KONFIRMASI PEMBAYARAN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey[600]),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey[500]),
            ),
            style: const TextStyle(fontSize: 16, color: Colors.black),
            validator: validator,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _namaPengirimController.dispose();
    _bankPengirimController.dispose();
    _alamatPengirimanController.dispose();
    super.dispose();
  }
}
