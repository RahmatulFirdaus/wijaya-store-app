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
      _hargaAwalController.text =
          _produkDetail!.hargaAwal; // Sesuaikan jika ada field harga awal

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

  // Fungsi untuk menambah varian baru
  void _tambahVarian() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => _DialogTambahEditVarian(
            onTambahVarian: (varian) {
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
            onTambahVarian: (varian) {
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
            title: const Text('Hapus Varian'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus varian ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _varianList.removeAt(index);
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Hapus'),
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

    setState(() {
      _isUpdating = true;
    });

    try {
      // Siapkan data file dengan urutan yang benar
      List<File> fileList = []; // Ganti dari gambarList ke fileList

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
          'id_varian':
              varianId, // PERBAIKAN: Pastikan ini tidak null untuk existing
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
        fileList: fileList, // Ganti dari gambarList ke fileList
        varianList: varianData,
        adaGambarUtamaBaru: adaGambarUtamaBaru,
        adaVideoDemoBaru: adaVideoDemoBaru, // Tambahkan parameter ini
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
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Produk'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Produk'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input Nama Produk
              TextFormField(
                controller: _namaProdukController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input Deskripsi
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Row untuk harga
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hargaProdukController,
                      decoration: const InputDecoration(
                        labelText: 'Harga Produk',
                        border: OutlineInputBorder(),
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga produk tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _hargaAwalController,
                      decoration: const InputDecoration(
                        labelText: 'Harga Awal',
                        border: OutlineInputBorder(),
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga awal tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Section Gambar Produk
              const Text(
                'Gambar Produk Utama',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pilihGambarProduk,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      _gambarProdukBaru != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _gambarProdukBaru!,
                              fit: BoxFit.cover,
                            ),
                          )
                          : _produkDetail?.linkGambar != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              '$baseUrl${_produkDetail!.linkGambar}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error, size: 48),
                                    Text('Gagal memuat gambar'),
                                  ],
                                );
                              },
                            ),
                          )
                          : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 48),
                              Text('Tap untuk memilih gambar'),
                            ],
                          ),
                ),
              ),
              // Section Video Demo (tambahkan setelah gambar produk utama)
              const SizedBox(height: 16),
              const Text(
                'Video Demo Produk (Opsional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pilihVideoDemo,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      _videoDemoBaru != null
                          ? Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.videocam,
                                    size: 48,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Video Baru Dipilih',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                          : _produkDetail?.videoDemo != null &&
                              _produkDetail!.videoDemo!.isNotEmpty
                          ? Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    size: 48,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Video Demo Tersedia',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                          : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.videocam_outlined, size: 48),
                              Text('Tap untuk memilih video demo'),
                              Text(
                                'Maksimal 50MB, format MP4/MOV/AVI',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 24),

              // Section Varian Produk
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Varian Produk',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _tambahVarian,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Varian'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // List Varian
              ..._varianList.asMap().entries.map((entry) {
                int index = entry.key;
                EditVarianProduk varian = entry.value;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading:
                        varian.gambarVarianFile != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                varian.gambarVarianFile!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                            : varian.linkGambarVarian.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                '$baseUrl${varian.linkGambarVarian}',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image_not_supported);
                                },
                              ),
                            )
                            : const Icon(Icons.image_not_supported),
                    title: Text('Warna: ${varian.warna}'),
                    subtitle: Text(
                      'Ukuran: ${varian.ukuran} | Stok: ${varian.stok}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editVarian(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _hapusVarian(index),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              // Tombol Update
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUpdating ? null : _submitUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child:
                      _isUpdating
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Update Produk',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),
            ],
          ),
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

// Dialog untuk tambah/edit varian
class _DialogTambahEditVarian extends StatefulWidget {
  final Function(EditVarianProduk) onTambahVarian;
  final EditVarianProduk? existingVarian;

  const _DialogTambahEditVarian({
    required this.onTambahVarian,
    this.existingVarian,
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
      // Show error toast
    }
  }

  void _simpanVarian() {
    if (_formKey.currentState!.validate()) {
      // PERBAIKAN: Validasi gambar untuk varian baru
      if (widget.existingVarian == null && _gambarVarian == null) {
        // Ini varian baru tapi tidak ada gambar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Varian baru harus memiliki gambar'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final varian = EditVarianProduk(
        id: widget.existingVarian?.id,
        warna: _warnaController.text,
        ukuran: int.parse(_ukuranController.text),
        stok: int.parse(_stokController.text),
        linkGambarVarian: _linkGambarLama,
        gambarVarianFile: _gambarVarian,
        isExisting: widget.existingVarian != null,
      );

      widget.onTambahVarian(varian);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Text(
                  widget.existingVarian != null
                      ? 'Edit Varian'
                      : 'Tambah Varian',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Input Warna
                TextFormField(
                  controller: _warnaController,
                  decoration: const InputDecoration(
                    labelText: 'Warna Varian',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Warna tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input Ukuran
                TextFormField(
                  controller: _ukuranController,
                  decoration: const InputDecoration(
                    labelText: 'Ukuran',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ukuran tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input Stok
                TextFormField(
                  controller: _stokController,
                  decoration: const InputDecoration(
                    labelText: 'Stok',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Stok tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Gambar Varian
                const Text(
                  'Gambar Varian',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pilihGambarVarian,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        _gambarVarian != null
                            ? Image.file(_gambarVarian!, fit: BoxFit.cover)
                            : _linkGambarLama.isNotEmpty
                            ? Image.network(
                              '$baseUrl$_linkGambarLama',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate),
                                    Text('Pilih Gambar Baru'),
                                  ],
                                );
                              },
                            )
                            : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate),
                                Text('Pilih Gambar'),
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
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _simpanVarian,
                        child: const Text('Simpan'),
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
