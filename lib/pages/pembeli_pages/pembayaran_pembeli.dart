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

class _PembayaranPembeliState extends State<PembayaranPembeli> {
  final _formKey = GlobalKey<FormState>();
  final _namaPengirimController = TextEditingController();
  final _bankPengirimController = TextEditingController();
  final _alamatPengirimanController = TextEditingController();

  List<GetDataMetodePembayaran> _metodePembayaranList = [];
  GetDataMetodePembayaran? _selectedMetodePembayaran;
  File? _buktiPembayaran;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMetodePembayaran();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat metode pembayaran: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pilihFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _buktiPembayaran = File(image.path);
      });
    }
  }

  Future<void> _submitPembayaran() async {
    if (!_formKey.currentState!.validate()) return;
    if (_buktiPembayaran == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih bukti pembayaran'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedMetodePembayaran == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih metode pembayaran'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await TambahPembayaran.addPembayaran(
        id_metode_pembayaran: _selectedMetodePembayaran!.id,
        total_harga: widget.totalHarga.toString(),
        nama_pengirim: _namaPengirimController.text,
        bank_pengirim: _bankPengirimController.text,
        alamat_pengiriman: _alamatPengirimanController.text,
        bukti_pembayaran: _buktiPembayaran!.path,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ?? 'Pembayaran berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Metode Pembayaran Dropdown
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonFormField<GetDataMetodePembayaran>(
                  value: _selectedMetodePembayaran,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: InputBorder.none,
                    hintText: 'Metode Pembayaran',
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                  items:
                      _metodePembayaranList.map((metode) {
                        return DropdownMenuItem<GetDataMetodePembayaran>(
                          value: metode,
                          child: Text(
                            metode.nama_metode,
                            style: const TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                  onChanged: (GetDataMetodePembayaran? newValue) {
                    setState(() {
                      _selectedMetodePembayaran = newValue;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Deskripsi Metode Pembayaran
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deskripsi Metode Pembayaran yang dipilih',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _selectedMetodePembayaran?.deskripsi ?? '',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Nama Pengirim
              const Text(
                'Nama Pengirim',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: _namaPengirimController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama pengirim tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Bank Pengirim
              const Text(
                'Bank Pengirim',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: _bankPengirimController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bank pengirim tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Alamat Pengiriman
              const Text(
                'Alamat Pengiriman',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: _alamatPengirimanController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat pengiriman tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 25),

              // Upload Bukti Pembayaran
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder untuk foto
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child:
                        _buktiPembayaran != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Image.file(
                                _buktiPembayaran!,
                                fit: BoxFit.cover,
                              ),
                            )
                            : const Icon(
                              Icons.close,
                              size: 40,
                              color: Colors.black54,
                            ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unggah Bukti Pembayaran',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: OutlinedButton(
                            onPressed: _pilihFoto,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text(
                              'Pilih Foto',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Tombol Konfirmasi
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPembayaran,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'KONFIRMASI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaPengirimController.dispose();
    _bankPengirimController.dispose();
    _alamatPengirimanController.dispose();
    super.dispose();
  }
}
