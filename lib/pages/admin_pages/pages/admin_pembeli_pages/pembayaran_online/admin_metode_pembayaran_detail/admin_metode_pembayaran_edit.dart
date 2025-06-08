import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';

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

class _AdminMetodePembayaranEditState extends State<AdminMetodePembayaranEdit> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _deskripsiController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.namaMetode);
    _deskripsiController = TextEditingController(text: widget.deskripsi);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await UpdateMetodePembayaranService.updateMetodePembayaran(
        id: widget.id,
        namaMetode: _namaController.text,
        deskripsi: _deskripsiController.text,
      );

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
      if (result.toLowerCase().contains("berhasil")) {
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Metode'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nama Metode Pembayaran"),
              const SizedBox(height: 4),
              TextFormField(
                controller: _namaController,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Nama metode harus diisi' : null,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Deskripsi"),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black),
                ),
                child: TextFormField(
                  controller: _deskripsiController,
                  maxLines: 5,
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Deskripsi harus diisi' : null,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(width: 1),
                    elevation: 0,
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                            'Ubah',
                            style: TextStyle(color: Colors.black),
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
