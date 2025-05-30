import 'package:flutter/material.dart';
import 'package:frontend/models/karyawan_model.dart';
import 'package:toastification/toastification.dart';

class TambahPengajuanIzin extends StatefulWidget {
  const TambahPengajuanIzin({super.key});

  @override
  State<TambahPengajuanIzin> createState() => _TambahPengajuanIzinState();
}

class _TambahPengajuanIzinState extends State<TambahPengajuanIzin> {
  final _formKey = GlobalKey<FormState>();
  final _deskripsiController = TextEditingController();
  final _tanggalMulaiController = TextEditingController();
  final _tanggalSelesaiController = TextEditingController();

  String _selectedTipeIzin = 'izin';
  bool _isLoading = false;

  final List<String> _tipeIzinList = ['izin', 'sakit'];

  @override
  void dispose() {
    _deskripsiController.dispose();
    _tanggalMulaiController.dispose();
    _tanggalSelesaiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}";
      });
    }
  }

  void _showToast(String message, bool isSuccess) {
    toastification.show(
      context: context,
      type: isSuccess ? ToastificationType.success : ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: Text(
        isSuccess ? 'Berhasil' : 'Gagal',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      description: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      primaryColor: isSuccess ? Colors.green : Colors.red,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
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

  bool _validateForm() {
    if (_selectedTipeIzin.isEmpty) {
      _showToast('Pilih tipe izin terlebih dahulu', false);
      return false;
    }
    if (_deskripsiController.text.trim().isEmpty) {
      _showToast('Deskripsi alasan tidak boleh kosong', false);
      return false;
    }
    if (_tanggalMulaiController.text.trim().isEmpty) {
      _showToast('Tanggal mulai harus diisi', false);
      return false;
    }
    if (_tanggalSelesaiController.text.trim().isEmpty) {
      _showToast('Tanggal selesai harus diisi', false);
      return false;
    }
    return true;
  }

  String _formatDateForApi(String displayDate) {
    // Convert from "22 / 03 / 2025" to "2025-03-22"
    final parts = displayDate.split(' / ');
    if (parts.length == 3) {
      return "${parts[2]}-${parts[1]}-${parts[0]}";
    }
    return displayDate;
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await PostPengajuanIzin.kirimIzin(
        tipeIzin: _selectedTipeIzin,
        deskripsi: _deskripsiController.text.trim(),
        tanggalMulai: _formatDateForApi(_tanggalMulaiController.text),
        tanggalAkhir: _formatDateForApi(_tanggalSelesaiController.text),
      );

      _showToast(result.pesan, result.success);

      if (result.success) {
        // Clear form after successful submission
        setState(() {
          _selectedTipeIzin = 'izin';
          _deskripsiController.clear();
          _tanggalMulaiController.clear();
          _tanggalSelesaiController.clear();
        });

        // Navigate back after delay
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _showToast('Terjadi kesalahan: ${e.toString()}', false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
          'Pengajuan Izin',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dropdown Tipe Izin
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTipeIzin,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black,
                      ),
                      items:
                          _tipeIzinList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedTipeIzin = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Text Area Deskripsi
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: _deskripsiController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: 'Deskripsi Alasan',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.all(12),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 20),

                // Tanggal Mulai
                const Text(
                  'Mulai',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextFormField(
                          controller: _tanggalMulaiController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: InputBorder.none,
                            hintText: '22 / 03 / 2025',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap:
                          () => _selectDate(context, _tanggalMulaiController),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Tanggal Selesai
                const Text(
                  'Selesai',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextFormField(
                          controller: _tanggalSelesaiController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: InputBorder.none,
                            hintText: '22 / 04 / 2025',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap:
                          () => _selectDate(context, _tanggalSelesaiController),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Tombol Submit
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'AJUKAN',
                              style: TextStyle(
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
      ),
    );
  }
}
