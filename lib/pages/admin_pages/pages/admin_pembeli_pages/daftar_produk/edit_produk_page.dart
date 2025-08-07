import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';
import 'package:mime/mime.dart';
import 'dart:io';

class EditProdukPage extends StatefulWidget {
  final GetDataProduk product;
  const EditProdukPage({super.key, required this.product});

  @override
  State<EditProdukPage> createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Base URL untuk gambar
  static const String baseUrl = 'http://192.168.1.96:3000/uploads/';

  // Controllers untuk form
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _hargaProdukController = TextEditingController();
  final TextEditingController _hargaAwalController = TextEditingController();

  // Data produk detail
  DataDetailProduk? _produkDetail;
  bool _isLoading = true;
  bool _isUpdating = false;

  // File gambar utama produk (jika diganti)
  File? _gambarProdukBaru;

  // File video demo produk (jika diganti)
  File? _videoDemoBaru;

  // List varian produk
  List<EditVarianProduk> _varianList = [];

  @override
  void initState() {
    super.initState();
    _loadProdukDetail();
  }

  @override
  void dispose() {
    _namaProdukController.dispose();
    _deskripsiController.dispose();
    _hargaProdukController.dispose();
    _hargaAwalController.dispose();

    // Bersihkan file video jika ada
    _videoDemoBaru = null;

    super.dispose();
  }

  // Load detail produk dari API
  Future<void> _loadProdukDetail() async {
    try {
      final detail = await DataDetailProduk.fetchDataDetailProduk(
        widget.product.id,
      );
      if (detail != null) {
        setState(() {
          _produkDetail = detail;
          _populateForm();
          _isLoading = false;
        });
      } else {
        _showToast('Gagal memuat data produk', type: ToastificationType.error);
        Navigator.pop(context);
      }
    } catch (e) {
      _showToast('Error: $e', type: ToastificationType.error);
      Navigator.pop(context);
    }
  }

  // Populate form dengan data yang ada
  void _populateForm() {
    if (_produkDetail != null) {
      _namaProdukController.text = _produkDetail!.nama;
      _deskripsiController.text = _produkDetail!.deskripsi;
      _hargaProdukController.text = _produkDetail!.harga;
      _hargaAwalController.text = _produkDetail!.hargaAwal;

      // Convert varian ke EditVarianProduk
      _varianList =
          _produkDetail!.varian.map((varian) {
            return EditVarianProduk(
              id: varian.id,
              warna: varian.warna,
              ukuran: varian.ukuran,
              stok: varian.stok,
              linkGambarVarian: varian.linkGambarVarian,
              isExisting: true,
            );
          }).toList();
    }
  }

  // Fungsi untuk memilih gambar produk utama
  Future<void> _pilihGambarProduk() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _gambarProdukBaru = File(image.path);
        });
      }
    } catch (e) {
      _showToast('Gagal memilih gambar: $e', type: ToastificationType.error);
    }
  }

  // Fungsi untuk memilih video demo
  Future<void> _pilihVideoDemo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5), // Maksimal 5 menit
      );

      if (video != null) {
        final file = File(video.path);

        // Validasi ukuran file (maksimal 50MB)
        final fileSizeInMB = PostUpdateProduk.getFileSizeInMB(file);
        if (fileSizeInMB > 50) {
          _showToast(
            'Video terlalu besar (${fileSizeInMB.toStringAsFixed(1)}MB). Maksimal 50MB.',
            type: ToastificationType.error,
          );
          return;
        }

        // Validasi format video
        if (!PostUpdateProduk.isValidVideoFile(file)) {
          _showToast(
            'Format video tidak didukung. Gunakan MP4, MOV, atau AVI.',
            type: ToastificationType.error,
          );
          return;
        }

        setState(() {
          _videoDemoBaru = file;
        });
      }
    } catch (e) {
      _showToast('Gagal memilih video: $e', type: ToastificationType.error);
    }
  }

  // Fungsi untuk menghapus video demo
  void _hapusVideoDemo() {
    setState(() {
      _videoDemoBaru = null;
    });
    _showToast('Video demo dihapus');
  }

  // Validasi harga
  String? _validatePrice(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }

    final numericValue = double.tryParse(
      value.replaceAll(RegExp(r'[^\d]'), ''),
    );
    if (numericValue == null || numericValue <= 0) {
      return '$fieldName harus berupa angka positif';
    }

    return null;
  }

  // Validasi khusus untuk harga dengan perbandingan
  String? _validateHargaKhusus() {
    final hargaProduk =
        double.tryParse(
          _hargaProdukController.text.replaceAll(RegExp(r'[^\d]'), ''),
        ) ??
        0;
    final hargaAwal =
        double.tryParse(
          _hargaAwalController.text.replaceAll(RegExp(r'[^\d]'), ''),
        ) ??
        0;

    if (hargaProduk >= hargaAwal) {
      return 'Harga produk harus lebih kecil dari harga sebelum diskon';
    }

    return null;
  }

  // Validasi duplikasi warna varian
  bool _isDuplicateColor(String warna, {int? excludeIndex}) {
    final normalizedWarna = warna.toLowerCase().trim();

    for (int i = 0; i < _varianList.length; i++) {
      if (excludeIndex != null && i == excludeIndex) continue;

      if (_varianList[i].warna.toLowerCase().trim() == normalizedWarna) {
        return true;
      }
    }
    return false;
  }

  // Fungsi untuk menambah varian baru
  void _tambahVarian() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => _DialogTambahEditVarian(
            existingColors:
                _varianList.map((v) => v.warna.toLowerCase().trim()).toList(),
            onTambahVarian: (varian) {
              // Double check validasi warna duplikat
              if (_isDuplicateColor(varian.warna)) {
                _showToast(
                  'Warna "${varian.warna}" sudah ada. Pilih warna lain.',
                  type: ToastificationType.error,
                );
                return;
              }

              setState(() {
                _varianList.add(varian);
              });
            },
          ),
    );
  }

  // Fungsi untuk edit varian existing
  void _editVarian(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => _DialogTambahEditVarian(
            existingVarian: _varianList[index],
            existingColors:
                _varianList.map((v) => v.warna.toLowerCase().trim()).toList(),
            excludeIndex: index,
            onTambahVarian: (varian) {
              // Validasi warna duplikat (kecuali index yang sedang diedit)
              if (_isDuplicateColor(varian.warna, excludeIndex: index)) {
                _showToast(
                  'Warna "${varian.warna}" sudah ada. Pilih warna lain.',
                  type: ToastificationType.error,
                );
                return;
              }

              setState(() {
                _varianList[index] = varian;
              });
            },
          ),
    );
  }

  // Fungsi untuk menghapus varian
  void _hapusVarian(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Hapus Varian',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Apakah Anda yakin ingin menghapus varian ini?',
              style: TextStyle(color: Colors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _varianList.removeAt(index);
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Hapus',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }

  // Fungsi untuk menampilkan toast
  void _showToast(
    String message, {
    ToastificationType type = ToastificationType.success,
  }) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flatColored,
      title: Text(message),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 16,
          offset: Offset(0, 16),
          spreadRadius: 0,
        ),
      ],
    );
  }

  // Fungsi untuk submit update
  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validasi harga khusus
    final hargaError = _validateHargaKhusus();
    if (hargaError != null) {
      _showToast(hargaError, type: ToastificationType.error);
      return;
    }

    if (_varianList.isEmpty) {
      _showToast(
        'Minimal harus ada 1 varian produk',
        type: ToastificationType.error,
      );
      return;
    }

    // Validasi setiap varian baru harus punya gambar
    for (var varian in _varianList) {
      if (!varian.isExisting &&
          varian.gambarVarianFile == null &&
          varian.linkGambarVarian.isEmpty) {
        _showToast(
          'Varian "${varian.warna}" harus memiliki gambar',
          type: ToastificationType.error,
        );
        return;
      }
    }

    // Validasi tidak ada warna duplikat
    final colors = <String>[];
    for (var varian in _varianList) {
      final normalizedColor = varian.warna.toLowerCase().trim();
      if (colors.contains(normalizedColor)) {
        _showToast(
          'Terdapat warna varian yang sama: "${varian.warna}"',
          type: ToastificationType.error,
        );
        return;
      }
      colors.add(normalizedColor);
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      // Siapkan data file dengan urutan yang benar
      List<File> fileList = [];

      // LANGKAH 1: Tambahkan gambar utama HANYA jika ada yang baru
      bool adaGambarUtamaBaru = _gambarProdukBaru != null;
      if (adaGambarUtamaBaru) {
        fileList.add(_gambarProdukBaru!);
        print("🔵 Gambar utama baru ditambahkan ke index 0");
      }

      // LANGKAH 2: Tambahkan gambar varian yang baru dalam urutan yang benar
      List<int> varianDenganGambarBaru = [];
      for (int i = 0; i < _varianList.length; i++) {
        var varian = _varianList[i];
        if (varian.gambarVarianFile != null) {
          fileList.add(varian.gambarVarianFile!);
          varianDenganGambarBaru.add(i);
          print(
            "🟢 Gambar varian ${varian.warna} ditambahkan ke index ${fileList.length - 1}",
          );
        }
      }

      // LANGKAH 3: Tambahkan video demo jika ada yang baru
      bool adaVideoDemoBaru = _videoDemoBaru != null;
      if (adaVideoDemoBaru) {
        fileList.add(_videoDemoBaru!);
        print("🟣 Video demo baru ditambahkan ke index ${fileList.length - 1}");
      }

      // Validasi file sebelum upload
      final validasi = PostUpdateProduk.validateFiles(fileList);
      if (!validasi['valid']) {
        for (String error in validasi['errors']) {
          _showToast(error, type: ToastificationType.error);
        }
        return;
      }

      // LANGKAH 3: Convert varian ke format yang dibutuhkan API
      List<Map<String, dynamic>> varianData = [];

      for (int i = 0; i < _varianList.length; i++) {
        var varian = _varianList[i];

        // Set has_new_image dengan benar
        bool hasNewImage = varian.gambarVarianFile != null;

        // PERBAIKAN UTAMA: Pastikan ID varian tidak null untuk existing
        int? varianId = varian.isExisting ? varian.id : null;

        // VALIDASI KHUSUS: Jika existing tapi ID null, skip atau beri warning
        if (varian.isExisting && varianId == null) {
          print(
            "⚠️ WARNING: Varian existing '${varian.warna}' tidak memiliki ID yang valid!",
          );
          _showToast(
            'Error: Varian "${varian.warna}" tidak memiliki ID yang valid',
            type: ToastificationType.error,
          );
          return;
        }

        varianData.add({
          'id_varian': varianId,
          'warna': varian.warna,
          'ukuran': varian.ukuran,
          'stok': varian.stok,
          'is_new': !varian.isExisting,
          'has_new_image': hasNewImage,
        });
      }

      // Debug logging yang lebih detail
      print("=== DEBUG SUBMIT DETAIL ===");
      print("Ada gambar utama baru: $adaGambarUtamaBaru");
      print("Varian dengan gambar baru: ${varianDenganGambarBaru.length}");

      for (int i = 0; i < varianData.length; i++) {
        var varian = varianData[i];
        print("Varian $i:");
        print("  - ID: ${varian['id_varian']}");
        print("  - Warna: ${varian['warna']}");
        print("  - Ukuran: ${varian['ukuran']}");
        print("  - Stok: ${varian['stok']}");
        print("  - IsNew: ${varian['is_new']}");
        print("  - HasNewImage: ${varian['has_new_image']}");
      }

      // LANGKAH 4: Kirim data ke server
      final result = await PostUpdateProduk.kirimUpdateProduk(
        id: widget.product.id.toString(),
        namaProduk: _namaProdukController.text,
        deskripsi: _deskripsiController.text,
        hargaProduk: _hargaProdukController.text,
        hargaAwal: _hargaAwalController.text,
        fileList: fileList,
        varianList: varianData,
        adaGambarUtamaBaru: adaGambarUtamaBaru,
        adaVideoDemoBaru: adaVideoDemoBaru,
      );

      if (result.success) {
        _showToast(result.pesan);
        Navigator.pop(context, true);
      } else {
        _showToast(result.pesan, type: ToastificationType.error);
      }
    } catch (e) {
      _showToast('Terjadi kesalahan: $e', type: ToastificationType.error);
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Theme(
        data: ThemeData.dark(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Edit Produk'),
            backgroundColor: const Color(0xFF1E1E1E),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          backgroundColor: const Color(0xFF121212),
          body: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        primaryColor: Colors.white,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey,
          surface: Color(0xFF1E1E1E),
          background: Color(0xFF121212),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.grey),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Produk'),
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Informasi Produk', Icons.info_outline),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _namaProdukController,
                  label: 'Nama Produk',
                  icon: Icons.shopping_bag_outlined,
                  hint: 'Masukkan nama produk',
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _deskripsiController,
                  label: 'Deskripsi',
                  icon: Icons.description_outlined,
                  hint: 'Masukkan deskripsi produk',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                _buildSectionHeader('Harga Produk', Icons.attach_money),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _hargaProdukController,
                        label: 'Harga Produk',
                        icon: Icons.attach_money_outlined,
                        hint: '0',
                        keyboardType: TextInputType.number,
                        prefixText: 'Rp ',
                        validator:
                            (value) => _validatePrice(value, 'Harga produk'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _hargaAwalController,
                        label: 'Harga Sebelum Diskon',
                        icon: Icons.local_offer_outlined,
                        hint: '0',
                        keyboardType: TextInputType.number,
                        prefixText: 'Rp ',
                        validator:
                            (value) =>
                                _validatePrice(value, 'Harga sebelum diskon'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildSectionHeader(
                  'Media Produk',
                  Icons.photo_library_outlined,
                ),
                const SizedBox(height: 16),

                _buildImagePicker(),
                const SizedBox(height: 20),

                _buildVideoPicker(),
                const SizedBox(height: 24),

                _buildSectionHeader('Varian Produk', Icons.palette_outlined),
                const SizedBox(height: 16),

                _buildVarianSection(),
                const SizedBox(height: 32),

                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    String? prefixText,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        prefixIcon: Icon(icon, color: Colors.grey),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gambar Produk Utama *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pilihGambarProduk,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                _gambarProdukBaru != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_gambarProdukBaru!, fit: BoxFit.cover),
                    )
                    : _produkDetail?.linkGambar != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        '$baseUrl${_produkDetail!.linkGambar}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 48, color: Colors.red),
                              SizedBox(height: 8),
                              Text(
                                'Gagal memuat gambar',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                    : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap untuk memilih gambar',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Video Demo (Opsional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            if (_videoDemoBaru != null)
              IconButton(
                onPressed: _hapusVideoDemo,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Hapus video',
              ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _videoDemoBaru == null ? _pilihVideoDemo : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color:
                  _videoDemoBaru != null
                      ? const Color(0xFF1B5E20).withOpacity(0.2)
                      : const Color(0xFF2A2A2A),
              border: Border.all(
                color:
                    _videoDemoBaru != null
                        ? Colors.green.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                _videoDemoBaru != null
                    ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_file_outlined,
                          size: 48,
                          color: Colors.green,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Video Baru Dipilih',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tap tombol hapus untuk mengganti',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    )
                    : _produkDetail?.videoDemo != null &&
                        _produkDetail!.videoDemo!.isNotEmpty
                    ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 48,
                          color: Colors.blue,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Video Demo Tersedia',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tap untuk mengganti video',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    )
                    : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap untuk memilih video demo',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Maksimal 50MB, format MP4/MOV/AVI',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildVarianSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Varian Produk *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _tambahVarian,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Varian'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_varianList.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: const Center(
              child: Text(
                'Belum ada varian produk.\nTambahkan minimal 1 varian.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ..._varianList.asMap().entries.map((entry) {
            int index = entry.key;
            EditVarianProduk varian = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading:
                    varian.gambarVarianFile != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            varian.gambarVarianFile!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                        : varian.linkGambarVarian.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            '$baseUrl${varian.linkGambarVarian}',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        )
                        : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                          ),
                        ),
                title: Text(
                  'Warna: ${varian.warna}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Ukuran: ${varian.ukuran} | Stok: ${varian.stok}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            varian.isExisting
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        varian.isExisting ? 'Existing' : 'Baru',
                        style: TextStyle(
                          color: varian.isExisting ? Colors.blue : Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _editVarian(index),
                      tooltip: 'Edit varian',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _hapusVarian(index),
                      tooltip: 'Hapus varian',
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isUpdating ? null : _submitUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            _isUpdating
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
                : const Text(
                  'Update Produk',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }
}

// Class untuk varian yang bisa diedit
class EditVarianProduk {
  int? id;
  String warna;
  int ukuran;
  int stok;
  String linkGambarVarian;
  File? gambarVarianFile;
  bool isExisting;

  EditVarianProduk({
    this.id,
    required this.warna,
    required this.ukuran,
    required this.stok,
    this.linkGambarVarian = '',
    this.gambarVarianFile,
    this.isExisting = false,
  });
}

// Dialog untuk tambah/edit varian dengan modern dark theme
class _DialogTambahEditVarian extends StatefulWidget {
  final Function(EditVarianProduk) onTambahVarian;
  final EditVarianProduk? existingVarian;
  final List<String> existingColors;
  final int? excludeIndex;

  const _DialogTambahEditVarian({
    required this.onTambahVarian,
    this.existingVarian,
    required this.existingColors,
    this.excludeIndex,
  });

  @override
  State<_DialogTambahEditVarian> createState() =>
      _DialogTambahEditVarianState();
}

class _DialogTambahEditVarianState extends State<_DialogTambahEditVarian> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Base URL untuk gambar
  static const String baseUrl = 'http://192.168.1.96:3000/uploads/';

  final TextEditingController _warnaController = TextEditingController();
  final TextEditingController _ukuranController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  File? _gambarVarian;
  String _linkGambarLama = '';

  @override
  void initState() {
    super.initState();
    if (widget.existingVarian != null) {
      _warnaController.text = widget.existingVarian!.warna;
      _ukuranController.text = widget.existingVarian!.ukuran.toString();
      _stokController.text = widget.existingVarian!.stok.toString();
      _linkGambarLama = widget.existingVarian!.linkGambarVarian;
    }
  }

  @override
  void dispose() {
    _warnaController.dispose();
    _ukuranController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Future<void> _pilihGambarVarian() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _gambarVarian = File(image.path);
        });
      }
    } catch (e) {
      _showErrorToast('Gagal memilih gambar: $e');
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _simpanVarian() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // PERBAIKAN: Validasi gambar untuk varian baru
    if (widget.existingVarian == null && _gambarVarian == null) {
      _showErrorToast('Varian baru harus memiliki gambar');
      return;
    }

    final varian = EditVarianProduk(
      id: widget.existingVarian?.id,
      warna: _warnaController.text.trim(),
      ukuran: int.parse(_ukuranController.text),
      stok: int.parse(_stokController.text),
      linkGambarVarian: _linkGambarLama,
      gambarVarianFile: _gambarVarian,
      isExisting: widget.existingVarian != null,
    );

    widget.onTambahVarian(varian);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        dialogBackgroundColor: const Color(0xFF1E1E1E),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
      ),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        widget.existingVarian != null ? Icons.edit : Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.existingVarian != null
                            ? 'Edit Varian'
                            : 'Tambah Varian',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Input Warna
                  TextFormField(
                    controller: _warnaController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Warna Varian',
                      hintText: 'Contoh: Hitam, Putih, Merah',
                      prefixIcon: Icon(Icons.palette, color: Colors.grey),
                      labelStyle: TextStyle(color: Colors.grey),
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Warna tidak boleh kosong';
                      }
                      if (value.trim().length < 2) {
                        return 'Warna minimal 2 karakter';
                      }

                      // Validasi duplikasi warna (case insensitive)
                      final normalizedValue = value.toLowerCase().trim();

                      // Cek duplikasi dengan existing colors (kecuali yang sedang diedit)
                      for (int i = 0; i < widget.existingColors.length; i++) {
                        if (widget.excludeIndex != null &&
                            i == widget.excludeIndex)
                          continue;

                        if (widget.existingColors[i] == normalizedValue) {
                          return 'Warna "$value" sudah ada. Pilih warna lain.';
                        }
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Input Ukuran
                  TextFormField(
                    controller: _ukuranController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Ukuran',
                      hintText: 'Contoh: 38, 39, 40',
                      prefixIcon: Icon(Icons.straighten, color: Colors.grey),
                      labelStyle: TextStyle(color: Colors.grey),
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ukuran tidak boleh kosong';
                      }
                      final ukuran = int.tryParse(value);
                      if (ukuran == null) {
                        return 'Masukkan angka yang valid';
                      }
                      if (ukuran <= 0) {
                        return 'Ukuran harus lebih dari 0';
                      }
                      if (ukuran > 999) {
                        return 'Ukuran terlalu besar';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Input Stok
                  TextFormField(
                    controller: _stokController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Stok',
                      hintText: 'Contoh: 10',
                      prefixIcon: Icon(Icons.inventory, color: Colors.grey),
                      labelStyle: TextStyle(color: Colors.grey),
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stok tidak boleh kosong';
                      }
                      final stok = int.tryParse(value);
                      if (stok == null) {
                        return 'Masukkan angka yang valid';
                      }
                      if (stok < 0) {
                        return 'Stok tidak boleh negatif';
                      }
                      if (stok > 9999) {
                        return 'Stok maksimal 9999';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Gambar Varian
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gambar Varian *',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (widget.existingVarian == null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Wajib untuk varian baru',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pilihGambarVarian,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        border: Border.all(
                          color:
                              _gambarVarian != null
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.grey.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          _gambarVarian != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _gambarVarian!,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : _linkGambarLama.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  '$baseUrl$_linkGambarLama',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 36,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Pilih Gambar Baru',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              )
                              : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 36,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Pilih Gambar Varian',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _simpanVarian,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            widget.existingVarian != null
                                ? 'Update Varian'
                                : 'Simpan Varian',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
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
