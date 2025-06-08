import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:toastification/toastification.dart';

class AdminVerifikasiPembayaranEdit extends StatefulWidget {
  final VerifikasiPembayaran pembayaran;

  const AdminVerifikasiPembayaranEdit({super.key, required this.pembayaran});

  @override
  State<AdminVerifikasiPembayaranEdit> createState() =>
      _AdminVerifikasiPembayaranEditState();
}

class _AdminVerifikasiPembayaranEditState
    extends State<AdminVerifikasiPembayaranEdit> {
  late String status;
  late TextEditingController _catatanController;
  bool _isLoading = false;

  final String baseUrl = "http://192.168.1.96:3000/uploads/";

  @override
  void initState() {
    super.initState();
    status = widget.pembayaran.status;
    _catatanController = TextEditingController(
      text: widget.pembayaran.catatanAdmin ?? '',
    );
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _simpanPerubahan() async {
    setState(() => _isLoading = true);

    try {
      final result =
          await UpdateVerifikasiPembayaranService.updateStatusVerifikasiPembayaran(
            id: widget.pembayaran.idOrderan.toString(),
            status: status,
            catatanAdmin: _catatanController.text.trim(),
          );

      if (mounted) {
        toastification.show(
          context: context,
          title: const Text('Status pembayaran berhasil diperbarui'),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.bottomCenter,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          title: Text('Gagal memperbarui status: ${e.toString()}'),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 4),
          alignment: Alignment.bottomCenter,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Pembayaran',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tampilkan semua gambar bukti transfer
                Column(
                  children:
                      widget.pembayaran.buktiTransfer.map((imageName) {
                        final imageUrl = baseUrl + imageName;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 64,
                                            color: Colors.grey,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 24),

                // Tombol status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _statusButton("berhasil", Colors.green)),
                    const SizedBox(width: 16),
                    Expanded(child: _statusButton("gagal", Colors.red)),
                  ],
                ),
                const SizedBox(height: 24),

                // Catatan admin
                TextField(
                  controller: _catatanController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Catatan Admin (boleh dikosongkan)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol simpan
                ElevatedButton(
                  onPressed: _isLoading ? null : _simpanPerubahan,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Simpan Perubahan',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _statusButton(String value, Color color) {
    final isSelected = status == value;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: isSelected ? color : Colors.grey[300]!),
        ),
      ),
      onPressed: _isLoading ? null : () => setState(() => status = value),
      child: Text(
        value[0].toUpperCase() + value.substring(1),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
