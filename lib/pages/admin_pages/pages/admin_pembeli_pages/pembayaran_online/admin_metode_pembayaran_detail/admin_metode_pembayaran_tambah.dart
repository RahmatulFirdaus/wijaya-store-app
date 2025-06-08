import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';

class AdminMetodePembayaranTambah extends StatefulWidget {
  const AdminMetodePembayaranTambah({super.key});

  @override
  State<AdminMetodePembayaranTambah> createState() =>
      _AdminMetodePembayaranTambahState();
}

class _AdminMetodePembayaranTambahState
    extends State<AdminMetodePembayaranTambah> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaMetodeController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final pesan = await TambahMetodePembayaranService.tambahMetodePembayaran(
        namaMetode: _namaMetodeController.text,
        deskripsi: _deskripsiController.text,
      );

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(pesan)));

      if (pesan.contains('berhasil')) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _namaMetodeController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Metode'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nama Metode Pembayaran'),
              TextFormField(
                controller: _namaMetodeController,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: Text(_isLoading ? 'Menambahkan...' : 'Tambahkan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
