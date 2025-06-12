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

  // Fungsi untuk menambah varian baru
  void _tambahVarian() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => _DialogTambahVarian(
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
      // Siapkan data untuk dikirim
      List<File> gambarList = [_gambarProduk!];

      // Tambahkan gambar varian ke dalam list gambar
      for (var varian in _varianList) {
        if (varian.gambarVarian != null) {
          gambarList.add(varian.gambarVarian!);
        }
      }

      // Kirim data ke server dengan method baru
      final result = await PostTambahProduk.kirimProduk(
        namaProduk: _namaProdukController.text,
        deskripsi: _deskripsiController.text,
        hargaProduk: _hargaProdukController.text,
        hargaAwal: _hargaAwalController.text,
        hargaModal: _hargaModalController.text,
        kategori: _selectedKategori!,
        gambarList: gambarList,
        varianList: _varianList, // Langsung kirim list VarianProduk
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
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

              // Dropdown Kategori
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori Produk',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
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

              // Input Harga Modal
              TextFormField(
                controller: _hargaModalController,
                decoration: const InputDecoration(
                  labelText: 'Harga Modal',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga modal tidak boleh kosong';
                  }
                  return null;
                },
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
                      _gambarProduk != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _gambarProduk!,
                              fit: BoxFit.cover,
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
                VarianProduk varian = entry.value;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ExpansionTile(
                    leading:
                        varian.gambarVarian != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                varian.gambarVarian!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                            : const Icon(Icons.image_not_supported),
                    title: Text('Warna: ${varian.warna}'),
                    subtitle: Text(
                      '${varian.ukuranList.length} ukuran tersedia',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _hapusVarian(index),
                    ),
                    children:
                        varian.ukuranList.map((ukuran) {
                          return ListTile(
                            contentPadding: const EdgeInsets.only(
                              left: 72,
                              right: 16,
                            ),
                            title: Text('Ukuran: ${ukuran.ukuran}'),
                            subtitle: Text('Stok: ${ukuran.stok}'),
                          );
                        }).toList(),
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              // Tombol Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Simpan Produk',
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

// Dialog untuk tambah varian dengan desain modern
class _DialogTambahVarian extends StatefulWidget {
  final Function(VarianProduk) onTambahVarian;

  const _DialogTambahVarian({required this.onTambahVarian});

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
      // Show error toast
    }
  }

  void _tambahUkuran() {
    showDialog(
      context: context,
      builder:
          (context) => _DialogTambahUkuran(
            onTambahUkuran: (ukuranVarian) {
              setState(() {
                _ukuranList.add(ukuranVarian);
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

  void _simpanVarian() {
    if (_formKey.currentState!.validate()) {
      if (_ukuranList.isEmpty) {
        // Show error toast: minimal 1 ukuran
        return;
      }

      final varian = VarianProduk(
        warna: _warnaController.text,
        ukuranList: _ukuranList,
        gambarVarian: _gambarVarian,
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
                const Text(
                  'Tambah Varian',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                            : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate),
                                Text('Pilih Gambar'),
                              ],
                            ),
                  ),
                ),
                const SizedBox(height: 16),

                // Section Ukuran
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ukuran & Stok',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: _tambahUkuran,
                      child: const Text('Tambah Ukuran'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // List Ukuran
                ..._ukuranList.asMap().entries.map((entry) {
                  int index = entry.key;
                  UkuranVarian ukuran = entry.value;
                  return ListTile(
                    title: Text('Ukuran: ${ukuran.ukuran}'),
                    subtitle: Text('Stok: ${ukuran.stok}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _hapusUkuran(index),
                    ),
                  );
                }).toList(),

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

class _DialogTambahUkuran extends StatefulWidget {
  final Function(UkuranVarian) onTambahUkuran;

  const _DialogTambahUkuran({required this.onTambahUkuran});

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
      final ukuranVarian = UkuranVarian(
        ukuran: _ukuranController.text,
        stok: int.parse(_stokController.text),
      );

      widget.onTambahUkuran(ukuranVarian);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Ukuran'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _ukuranController,
              decoration: const InputDecoration(
                labelText: 'Ukuran',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ukuran tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _simpanUkuran, child: const Text('Simpan')),
      ],
    );
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required String hint,
  TextInputType? keyboardType,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.blue),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return '$label tidak boleh kosong';
      }
      if (keyboardType == TextInputType.number) {
        if (int.tryParse(value) == null) {
          return 'Masukkan angka yang valid';
        }
      }
      return null;
    },
  );
}
