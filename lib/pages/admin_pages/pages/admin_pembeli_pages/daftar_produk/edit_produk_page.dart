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

      // ❌ UBAH BAGIAN INI:
      Map<String, EditVarianProduk> varianMap = {};

      for (var varian in _produkDetail!.varian) {
        String warnaKey = varian.warna.toLowerCase().trim();

        if (varianMap.containsKey(warnaKey)) {
          varianMap[warnaKey]!.ukuranList.add(
            UkuranVarian(
              id: varian.id, // ✅ SIMPAN ID SETIAP UKURAN
              ukuran: varian.ukuran.toString(),
              stok: varian.stok,
              isNew: false, // ✅ TANDAI SEBAGAI EXISTING
            ),
          );
        } else {
          varianMap[warnaKey] = EditVarianProduk(
            warna: varian.warna,
            ukuranList: [
              UkuranVarian(
                id: varian.id, // ✅ SIMPAN ID SETIAP UKURAN
                ukuran: varian.ukuran.toString(),
                stok: varian.stok,
                isNew: false, // ✅ TANDAI SEBAGAI EXISTING
              ),
            ],
            linkGambarVarian: varian.linkGambarVarian,
            isExisting: true,
          );
        }
      }

      _varianList = varianMap.values.toList();
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

  // Fungsi untuk edit varian existing
  void _editVarian(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => _DialogEditVarian(
            existingVarian: _varianList[index],
            onUpdateVarian: (varian) {
              setState(() {
                // ✅ PERBAIKI: Pertahankan ID dan flag isNew dari ukuran asli
                List<UkuranVarian> updatedUkuranList = [];

                for (var newUkuran in varian.ukuranList) {
                  // Cari ukuran yang sama di varian asli untuk mempertahankan ID dan flag
                  UkuranVarian? existingUkuran;

                  try {
                    existingUkuran = _varianList[index].ukuranList.firstWhere(
                      (existing) =>
                          existing.ukuran.toLowerCase().trim() ==
                          newUkuran.ukuran.toLowerCase().trim(),
                    );
                  } catch (e) {
                    existingUkuran = null;
                  }

                  if (existingUkuran != null) {
                    // Ukuran sudah ada, pertahankan ID dan flag asli
                    updatedUkuranList.add(
                      UkuranVarian(
                        id: existingUkuran.id,
                        ukuran: newUkuran.ukuran,
                        stok: newUkuran.stok,
                        isNew: existingUkuran.isNew,
                      ),
                    );
                  } else {
                    // Ukuran baru
                    updatedUkuranList.add(
                      UkuranVarian(
                        id: null,
                        ukuran: newUkuran.ukuran,
                        stok: newUkuran.stok,
                        isNew: true,
                      ),
                    );
                  }
                }

                _varianList[index] = EditVarianProduk(
                  warna: varian.warna,
                  ukuranList: updatedUkuranList,
                  linkGambarVarian: varian.linkGambarVarian,
                  gambarVarianFile: varian.gambarVarianFile,
                  isExisting: _varianList[index].isExisting,
                );
              });

              // Debug log
              print("✅ Varian updated:");
              print("  - Warna: ${_varianList[index].warna}");
              print(
                "  - Jumlah ukuran: ${_varianList[index].ukuranList.length}",
              );
              for (var ukuran in _varianList[index].ukuranList) {
                print(
                  "    * ${ukuran.ukuran}: ${ukuran.stok} (ID: ${ukuran.id}, isNew: ${ukuran.isNew})",
                );
              }
            },
          ),
    );
  }

  // Fungsi untuk menghapus varian
  Future<void> _hapusVarian(int index) async {
    final varian = _varianList[index];

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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apakah Anda yakin ingin menghapus varian "${varian.warna}"?',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Varian ini memiliki ${varian.ukuranList.length} ukuran yang akan ikut terhapus.',
                  style: const TextStyle(color: Colors.orange, fontSize: 12),
                ),
                if (varian.isExisting) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '⚠️ Varian ini akan dihapus permanen dari database.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ],
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
                onPressed: () async {
                  Navigator.pop(context); // Tutup dialog terlebih dahulu

                  // Jika varian existing (ada di database), hapus dari server
                  if (varian.isExisting && varian.ukuranList.isNotEmpty) {
                    setState(() {
                      _isUpdating = true; // Tampilkan loading
                    });

                    try {
                      // Hapus semua ukuran dalam varian ini dari database
                      for (var ukuran in varian.ukuranList) {
                        if (ukuran.id != null) {
                          final result =
                              await AdminHapusVarianProduk.hapusVarianProduk(
                                ukuran.id.toString(),
                              );
                          print(
                            "Hapus ukuran ${ukuran.ukuran} (ID: ${ukuran.id}): $result",
                          );
                        }
                      }

                      // Hapus dari list lokal
                      setState(() {
                        _varianList.removeAt(index);
                        _isUpdating = false;
                      });

                      _showToast('Varian "${varian.warna}" berhasil dihapus');
                    } catch (e) {
                      setState(() {
                        _isUpdating = false;
                      });
                      _showToast(
                        'Gagal menghapus varian: $e',
                        type: ToastificationType.error,
                      );
                    }
                  } else {
                    // Varian baru (belum di database), langsung hapus dari list
                    setState(() {
                      _varianList.removeAt(index);
                    });
                    _showToast('Varian "${varian.warna}" dihapus');
                  }
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
        bool hasNewImage = varian.gambarVarianFile != null;

        // Convert setiap ukuran dalam varian
        for (var ukuran in varian.ukuranList) {
          varianData.add({
            'id_varian': ukuran.id, // ✅ GUNAKAN ID UKURAN, BUKAN ID VARIAN
            'warna': varian.warna,
            'ukuran': int.parse(ukuran.ukuran),
            'stok': ukuran.stok,
            'is_new': ukuran.isNew, // ✅ GUNAKAN FLAG DARI UKURAN
            'has_new_image': hasNewImage,
            'action':
                ukuran.isNew ? 'insert' : 'update', // ✅ TAMBAH FLAG ACTION
          });
        }
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
        const Text(
          'Varian Produk *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
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
                'Tidak ada varian produk tersedia.',
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
              child: ExpansionTile(
                leading:
                    varian.gambarVarianFile != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            varian.gambarVarianFile!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                        : varian.linkGambarVarian.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            '$baseUrl${varian.linkGambarVarian}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
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
                          width: 50,
                          height: 50,
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
                subtitle: Text(
                  '${varian.ukuranList.length} ukuran tersedia',
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ TAMBAHKAN KEMBALI tombol edit
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _editVarian(index),
                      tooltip: 'Edit varian',
                    ),
                    // ✅ TAMBAHKAN KEMBALI tombol hapus
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _hapusVarian(index),
                      tooltip: 'Hapus varian',
                    ),
                  ],
                ),
                children:
                    varian.ukuranList.map((ukuran) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ukuran: ${ukuran.ukuran}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              'Stok: ${ukuran.stok}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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

class UkuranVarian {
  int? id; // ID untuk setiap ukuran individual
  String ukuran;
  int stok;
  bool isNew; // Flag untuk menandai ukuran baru

  UkuranVarian({
    this.id,
    required this.ukuran,
    required this.stok,
    this.isNew = false,
  });
}

// Class untuk varian yang bisa diedit
class EditVarianProduk {
  String warna;
  List<UkuranVarian> ukuranList;
  String linkGambarVarian;
  File? gambarVarianFile;
  bool isExisting;

  EditVarianProduk({
    required this.warna,
    required this.ukuranList,
    this.linkGambarVarian = '',
    this.gambarVarianFile,
    this.isExisting = false,
  });
}

// Dialog untuk tambah/edit varian dengan modern dark theme
class _DialogEditVarian extends StatefulWidget {
  final Function(EditVarianProduk) onUpdateVarian;
  final EditVarianProduk existingVarian;

  const _DialogEditVarian({
    required this.onUpdateVarian,
    required this.existingVarian,
  });

  @override
  State<_DialogEditVarian> createState() => _DialogEditVarianState();
}

class _DialogEditVarianState extends State<_DialogEditVarian> {
  final ImagePicker _picker = ImagePicker();
  static const String baseUrl = 'http://192.168.1.96:3000/uploads/';

  List<UkuranVarian> _ukuranList = [];

  @override
  void initState() {
    super.initState();
    _ukuranList = List.from(widget.existingVarian.ukuranList);
  }

  void _showToast(
    String message, {
    ToastificationType type = ToastificationType.success,
  }) {
    // Gunakan method yang sama seperti di parent class
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            type == ToastificationType.error
                ? Colors.red
                : type == ToastificationType.info
                ? Colors.blue
                : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _tambahUkuran() {
    showDialog(
      context: context,
      builder:
          (context) => _DialogTambahUkuranEdit(
            existingSizes:
                _ukuranList.map((u) => u.ukuran.toLowerCase().trim()).toList(),
            onTambahUkuran: (ukuranVarian) {
              setState(() {
                // Cek apakah ukuran sudah ada
                final existingIndex = _ukuranList.indexWhere(
                  (existing) =>
                      existing.ukuran.toLowerCase().trim() ==
                      ukuranVarian.ukuran.toLowerCase().trim(),
                );

                if (existingIndex != -1) {
                  // Jika ukuran sudah ada, tambahkan stok ke ukuran yang sudah ada
                  _ukuranList[existingIndex] = UkuranVarian(
                    ukuran: _ukuranList[existingIndex].ukuran,
                    stok: _ukuranList[existingIndex].stok + ukuranVarian.stok,
                  );
                  _showToast(
                    'Stok ukuran ${_ukuranList[existingIndex].ukuran} ditambahkan. Total: ${_ukuranList[existingIndex].stok}',
                  );
                } else {
                  // Jika ukuran belum ada, tambahkan ukuran baru
                  _ukuranList.add(ukuranVarian);
                }
              });
            },
          ),
    );
  }

  void _editUkuran(int index) {
    showDialog(
      context: context,
      builder:
          (context) => _DialogEditUkuran(
            existingUkuran: _ukuranList[index],
            existingSizes:
                _ukuranList
                    .asMap()
                    .entries
                    .where((entry) => entry.key != index)
                    .map((entry) => entry.value.ukuran.toLowerCase().trim())
                    .toList(),
            onUpdateUkuran: (ukuranVarian) {
              setState(() {
                _ukuranList[index] = ukuranVarian;
              });
            },
          ),
    );
  }

  void _hapusUkuran(int index) async {
    if (_ukuranList.length <= 1) {
      _showErrorToast('Minimal harus ada 1 ukuran untuk varian ini');
      return;
    }

    final ukuran = _ukuranList[index];

    // Konfirmasi penghapusan
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Hapus Ukuran',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Apakah Anda yakin ingin menghapus ukuran "${ukuran.ukuran}" dengan stok ${ukuran.stok}?',
                  style: const TextStyle(color: Colors.grey),
                ),
                if (ukuran.id != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '⚠️ Ukuran ini akan dihapus permanen dari database.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
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

    if (shouldDelete == true) {
      // Jika ukuran ada di database (punya ID), hapus dari server
      if (ukuran.id != null && !ukuran.isNew) {
        try {
          // Tampilkan loading (opsional)
          _showToast('Menghapus ukuran...', type: ToastificationType.info);

          final result = await AdminHapusVarianProduk.hapusVarianProduk(
            ukuran.id.toString(),
          );

          print(
            "Hasil hapus ukuran ${ukuran.ukuran} (ID: ${ukuran.id}): $result",
          );

          // Hapus dari list lokal
          setState(() {
            _ukuranList.removeAt(index);
          });

          _showToast('Ukuran "${ukuran.ukuran}" berhasil dihapus');
        } catch (e) {
          _showErrorToast('Gagal menghapus ukuran: $e');
        }
      } else {
        // Ukuran baru (belum di database), langsung hapus dari list
        setState(() {
          _ukuranList.removeAt(index);
        });
        _showToast('Ukuran "${ukuran.ukuran}" dihapus');
      }
    }
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
    if (_ukuranList.isEmpty) {
      _showErrorToast('Minimal harus ada 1 ukuran untuk varian ini');
      return;
    }

    final varian = EditVarianProduk(
      warna: widget.existingVarian.warna, // Warna tidak bisa diubah
      ukuranList: _ukuranList,
      linkGambarVarian:
          widget.existingVarian.linkGambarVarian, // ✅ Pertahankan gambar lama
      gambarVarianFile: null, // ❌ Tidak ada gambar baru
      isExisting: true,
    );

    widget.onUpdateVarian(varian);
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Edit Varian: ${widget.existingVarian.warna}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ❌ HAPUS SELURUH SECTION GAMBAR VARIAN
                // Langsung ke Section Ukuran
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ukuran & Stok',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _tambahUkuran,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // List Ukuran
                Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _ukuranList.length,
                    separatorBuilder:
                        (context, index) => Divider(
                          color: Colors.grey.withOpacity(0.3),
                          height: 1,
                        ),
                    itemBuilder: (context, index) {
                      UkuranVarian ukuran = _ukuranList[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        title: Text(
                          'Ukuran: ${ukuran.ukuran}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Stok: ${ukuran.stok} pcs',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.blue,
                                size: 18,
                              ),
                              onPressed: () => _editUkuran(index),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                              onPressed: () => _hapusUkuran(index),
                            ),
                          ],
                        ),
                      );
                    },
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
                        child: const Text(
                          'Update Varian',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}

class _DialogTambahUkuranEdit extends StatefulWidget {
  final Function(UkuranVarian) onTambahUkuran;
  final List<String> existingSizes;

  const _DialogTambahUkuranEdit({
    required this.onTambahUkuran,
    required this.existingSizes,
  });

  @override
  State<_DialogTambahUkuranEdit> createState() =>
      _DialogTambahUkuranEditState();
}

class _DialogTambahUkuranEditState extends State<_DialogTambahUkuranEdit> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ukuranController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  @override
  void dispose() {
    _ukuranController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  void _simpanUkuran() {
    if (_formKey.currentState!.validate()) {
      final ukuranValue = _ukuranController.text.trim();
      final stokValue = int.parse(_stokController.text);

      // ✅ BUAT UKURAN BARU DENGAN FLAG isNew = true
      final ukuranVarian = UkuranVarian(
        id: null, // ID null untuk ukuran baru
        ukuran: ukuranValue,
        stok: stokValue,
        isNew: true, // ✅ TANDAI SEBAGAI BARU
      );

      final normalizedUkuran = ukuranValue.toLowerCase().trim();
      final existingIndex = widget.existingSizes.indexOf(normalizedUkuran);

      if (existingIndex != -1) {
        // Konfirmasi untuk menambah stok ke ukuran yang sudah ada
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  'Ukuran Sudah Ada',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'Ukuran "$ukuranValue" sudah ada.\nStok akan ditambahkan ke ukuran yang sudah ada.\n\nStok yang akan ditambah: $stokValue',
                  style: const TextStyle(color: Colors.grey),
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
                      Navigator.pop(context); // Tutup dialog konfirmasi
                      widget.onTambahUkuran(ukuranVarian);
                      Navigator.pop(context); // Tutup dialog tambah ukuran
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Tambah Stok',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
        );
      } else {
        widget.onTambahUkuran(ukuranVarian);
        Navigator.pop(context);
      }
    }
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
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Tambah Ukuran & Stok',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _ukuranController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Ukuran',
                  hintText:
                      widget.existingSizes.isNotEmpty
                          ? 'Jika ukuran sama, stok akan digabung'
                          : 'Contoh: S, M, L, XL, 38, 39',
                  prefixIcon: const Icon(Icons.straighten, color: Colors.grey),
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ukuran tidak boleh kosong';
                  }
                  if (value.trim().isEmpty) {
                    return 'Ukuran tidak boleh hanya spasi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
                  if (stok == 0) {
                    return 'Stok tidak boleh 0';
                  }
                  if (stok > 9999) {
                    return 'Stok maksimal 9999';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: _simpanUkuran,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Simpan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogEditUkuran extends StatefulWidget {
  final Function(UkuranVarian) onUpdateUkuran;
  final UkuranVarian existingUkuran;
  final List<String> existingSizes;

  const _DialogEditUkuran({
    required this.onUpdateUkuran,
    required this.existingUkuran,
    required this.existingSizes,
  });

  @override
  State<_DialogEditUkuran> createState() => _DialogEditUkuranState();
}

class _DialogEditUkuranState extends State<_DialogEditUkuran> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ukuranController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ukuranController.text = widget.existingUkuran.ukuran;
    _stokController.text = widget.existingUkuran.stok.toString();
  }

  @override
  void dispose() {
    _ukuranController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  void _simpanUkuran() {
    if (_formKey.currentState!.validate()) {
      final ukuranValue = _ukuranController.text.trim();
      final stokValue = int.parse(_stokController.text);

      // ✅ PERTAHANKAN ID dan flag dari ukuran asli
      final ukuranVarian = UkuranVarian(
        id: widget.existingUkuran.id, // ✅ PERTAHANKAN ID ASLI
        ukuran: ukuranValue,
        stok: stokValue,
        isNew: widget.existingUkuran.isNew, // ✅ PERTAHANKAN FLAG ASLI
      );

      widget.onUpdateUkuran(ukuranVarian);
      Navigator.pop(context);
    }
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
        ),
      ),
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Edit Ukuran & Stok',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _ukuranController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Ukuran',
                  prefixIcon: Icon(Icons.straighten, color: Colors.grey),
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ukuran tidak boleh kosong';
                  }
                  if (value.trim().isEmpty) {
                    return 'Ukuran tidak boleh hanya spasi';
                  }

                  // Cek duplikasi dengan ukuran lain (kecuali dirinya sendiri)
                  final normalizedValue = value.toLowerCase().trim();
                  if (widget.existingSizes.contains(normalizedValue)) {
                    return 'Ukuran "$value" sudah ada dalam varian ini';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stokController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  prefixIcon: Icon(Icons.inventory, color: Colors.grey),
                  labelStyle: TextStyle(color: Colors.grey),
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
                  if (stok == 0) {
                    return 'Stok tidak boleh 0';
                  }
                  if (stok > 9999) {
                    return 'Stok maksimal 9999';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: _simpanUkuran,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Update',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
