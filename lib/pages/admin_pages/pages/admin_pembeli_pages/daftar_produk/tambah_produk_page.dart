import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';
import 'dart:io';

class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers untuk form
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _hargaProdukController = TextEditingController();
  final TextEditingController _hargaAwalController = TextEditingController();
  final TextEditingController _hargaModalController = TextEditingController();

  // Dropdown kategori
  String? _selectedKategori;
  final List<String> _kategoriList = ['running shoes', 'sports', 'casual'];

  // File gambar utama produk
  File? _gambarProduk;

  // File video demo produk
  File? _videoDemo;

  // List varian produk
  List<VarianProduk> _varianList = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _namaProdukController.dispose();
    _deskripsiController.dispose();
    _hargaProdukController.dispose();
    _hargaAwalController.dispose();
    _hargaModalController.dispose();
    super.dispose();
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
          _gambarProduk = File(image.path);
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
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        final file = File(video.path);
        final fileSizeInBytes = await file.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 50) {
          _showToast(
            'Ukuran video terlalu besar. Maksimal 50MB',
            type: ToastificationType.error,
          );
          return;
        }

        setState(() {
          _videoDemo = file;
        });
        _showToast('Video demo berhasil dipilih');
      }
    } catch (e) {
      _showToast('Gagal memilih video: $e', type: ToastificationType.error);
    }
  }

  // Fungsi untuk menghapus video demo
  void _hapusVideoDemo() {
    setState(() {
      _videoDemo = null;
    });
    _showToast('Video demo dihapus');
  }

  // Fungsi untuk menambah varian baru
  void _tambahVarian() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => _DialogTambahVarian(
            existingColors:
                _varianList.map((v) => v.warna.toLowerCase().trim()).toList(),
            onTambahVarian: (varian) {
              setState(() {
                _varianList.add(varian);
              });
            },
          ),
    );
  }

  // Fungsi untuk menghapus varian
  void _hapusVarian(int index) {
    setState(() {
      _varianList.removeAt(index);
    });
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
    final hargaModal =
        double.tryParse(
          _hargaModalController.text.replaceAll(RegExp(r'[^\d]'), ''),
        ) ??
        0;

    if (hargaProduk >= hargaAwal) {
      return 'Harga produk harus lebih kecil dari harga sebelum diskon';
    }

    if (hargaProduk <= hargaModal) {
      return 'Harga produk harus lebih besar dari harga modal';
    }

    return null;
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

  // Fungsi untuk submit form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validasi harga khusus
    final hargaError = _validateHargaKhusus();
    if (hargaError != null) {
      _showToast(hargaError, type: ToastificationType.error);
      return;
    }

    if (_selectedKategori == null) {
      _showToast(
        'Silakan pilih kategori produk',
        type: ToastificationType.error,
      );
      return;
    }

    if (_gambarProduk == null) {
      _showToast('Silakan pilih gambar produk', type: ToastificationType.error);
      return;
    }

    if (_varianList.isEmpty) {
      _showToast(
        'Minimal harus ada 1 varian produk',
        type: ToastificationType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<File> gambarList = [_gambarProduk!];

      for (var varian in _varianList) {
        if (varian.gambarVarian != null) {
          gambarList.add(varian.gambarVarian!);
        }
      }

      final result = await PostTambahProduk.kirimProduk(
        namaProduk: _namaProdukController.text,
        deskripsi: _deskripsiController.text,
        hargaProduk: _hargaProdukController.text,
        hargaAwal: _hargaAwalController.text,
        hargaModal: _hargaModalController.text,
        kategori: _selectedKategori!,
        gambarList: gambarList,
        varianList: _varianList,
        videoDemo: _videoDemo,
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
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text('Tambah Produk'),
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
                const SizedBox(height: 16),

                _buildDropdown(),
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
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _hargaModalController,
                  label: 'Harga Modal',
                  icon: Icons.shopping_cart_outlined,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  prefixText: 'Rp ',
                  validator: (value) => _validatePrice(value, 'Harga modal'),
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

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedKategori,
      dropdownColor: const Color(0xFF2A2A2A),
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: 'Kategori Produk',
        prefixIcon: Icon(Icons.category, color: Colors.grey),
      ),
      items:
          _kategoriList.map((String kategori) {
            return DropdownMenuItem<String>(
              value: kategori,
              child: Text(kategori),
            );
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedKategori = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Silakan pilih kategori produk';
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
                _gambarProduk != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_gambarProduk!, fit: BoxFit.cover),
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
            if (_videoDemo != null)
              IconButton(
                onPressed: _hapusVideoDemo,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Hapus video',
              ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _videoDemo == null ? _pilihVideoDemo : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color:
                  _videoDemo != null
                      ? const Color(0xFF1B5E20).withOpacity(0.2)
                      : const Color(0xFF2A2A2A),
              border: Border.all(
                color:
                    _videoDemo != null
                        ? Colors.green.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                _videoDemo != null
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
                          'Video dipilih',
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
                    : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_call_outlined,
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
                          'Maksimal 50MB, durasi 2 menit',
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
            VarianProduk varian = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: ExpansionTile(
                leading:
                    varian.gambarVarian != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            varian.gambarVarian!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
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
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${varian.ukuranList.length} ukuran tersedia',
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _hapusVarian(index),
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
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
                : const Text(
                  'Simpan Produk',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }
}

// Dialog untuk tambah varian dengan desain modern dark theme
class _DialogTambahVarian extends StatefulWidget {
  final Function(VarianProduk) onTambahVarian;
  final List<String> existingColors;

  const _DialogTambahVarian({
    required this.onTambahVarian,
    required this.existingColors,
  });

  @override
  State<_DialogTambahVarian> createState() => _DialogTambahVarianState();
}

class _DialogTambahVarianState extends State<_DialogTambahVarian> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _warnaController = TextEditingController();
  File? _gambarVarian;
  List<UkuranVarian> _ukuranList = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _warnaController.dispose();
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
      _showToast('Gagal memilih gambar: $e');
    }
  }

  void _tambahUkuran() {
    showDialog(
      context: context,
      builder:
          (context) => _DialogTambahUkuran(
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

  void _hapusUkuran(int index) {
    setState(() {
      _ukuranList.removeAt(index);
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _simpanVarian() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_gambarVarian == null) {
      _showErrorToast('Silakan pilih gambar untuk varian ini');
      return;
    }

    if (_ukuranList.isEmpty) {
      _showErrorToast('Minimal harus ada 1 ukuran untuk varian ini');
      return;
    }

    final varian = VarianProduk(
      warna: _warnaController.text.trim(),
      ukuranList: _ukuranList,
      gambarVarian: _gambarVarian,
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
                  const Text(
                    'Tambah Varian Produk',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                      if (value.length < 2) {
                        return 'Warna minimal 2 karakter';
                      }

                      // Validasi duplikasi warna (case insensitive)
                      final normalizedValue = value.toLowerCase().trim();
                      if (widget.existingColors.contains(normalizedValue)) {
                        return 'Warna "$value" sudah ada. Pilih warna lain.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Gambar Varian
                  const Text(
                    'Gambar Varian *',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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
                  const SizedBox(height: 20),

                  // Section Ukuran
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ukuran & Stok *',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _tambahUkuran,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Tambah Ukuran'),
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
                  if (_ukuranList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: const Center(
                        child: Text(
                          'Belum ada ukuran.\nTambahkan minimal 1 ukuran.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
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
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () => _hapusUkuran(index),
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
                            'Simpan Varian',
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
      ),
    );
  }
}

// Dialog untuk tambah ukuran dengan desain modern dark theme
class _DialogTambahUkuran extends StatefulWidget {
  final Function(UkuranVarian) onTambahUkuran;
  final List<String> existingSizes;

  const _DialogTambahUkuran({
    required this.onTambahUkuran,
    required this.existingSizes,
  });

  @override
  State<_DialogTambahUkuran> createState() => _DialogTambahUkuranState();
}

class _DialogTambahUkuranState extends State<_DialogTambahUkuran> {
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

      // Cek apakah ukuran sudah ada
      final normalizedUkuran = ukuranValue.toLowerCase().trim();
      final isExisting = widget.existingSizes.contains(normalizedUkuran);

      final ukuranVarian = UkuranVarian(ukuran: ukuranValue, stok: stokValue);

      if (isExisting) {
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
        // Ukuran baru, langsung tambahkan
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
