import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:frontend/pages/admin_pages/pages/admin_master_pages/manajemen%20akun/admin_edit_akun.dart';
import 'package:frontend/pages/admin_pages/pages/admin_master_pages/manajemen%20akun/admin_tambah_akun.dart';
import 'package:toastification/toastification.dart';

class AkunPage extends StatefulWidget {
  const AkunPage({super.key});

  @override
  State<AkunPage> createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  List<DataAkun> dataAkun = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDataAkun();
  }

  Future<void> _loadDataAkun() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await DataAkun.fetchDataAkun();
      if (mounted) {
        setState(() {
          dataAkun = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAkun(int id) async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Konfirmasi Hapus',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            content: const Text(
              'Apakah Anda yakin ingin menghapus akun ini? Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(color: Colors.black54),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => _performDelete(id),
                style: TextButton.styleFrom(foregroundColor: Colors.red[600]),
                child: const Text(
                  'Hapus',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _performDelete(int id) async {
    // Close confirmation dialog first
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (!mounted) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => WillPopScope(
            onWillPop: () async => false,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.black87),
            ),
          ),
    );

    try {
      final response = await HapusAkunService.hapusAkun(id);

      // Close loading dialog
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showSuccessToast('Akun berhasil dihapus');
        // Refresh data setelah berhasil hapus
        await _loadDataAkun();
      } else {
        String errorMsg = 'Gagal menghapus akun';
        try {
          // Coba parse response body jika ada
          if (response.body.isNotEmpty) {
            errorMsg += ': ${response.body}';
          }
        } catch (e) {
          // Jika gagal parse body, gunakan status code
          errorMsg += ' (Status: ${response.statusCode})';
        }
        _showErrorToast(errorMsg);
      }
    } catch (error) {
      // Close loading dialog if still open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        String errorMessage = 'Kesalahan tidak terduga';
        if (error.toString().contains('SocketException')) {
          errorMessage =
              'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
        } else if (error.toString().contains('TimeoutException')) {
          errorMessage = 'Koneksi timeout. Coba lagi nanti.';
        } else if (error.toString().contains('FormatException')) {
          errorMessage = 'Format respons server tidak valid.';
        } else {
          errorMessage = 'Kesalahan: ${error.toString()}';
        }
        _showErrorToast(errorMessage);
      }
    }
  }

  void _showSuccessToast(String message) {
    if (!mounted) return;

    toastification.show(
      context: context,
      title: Text(message),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      type: ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.bottomCenter,
    );
  }

  void _showErrorToast(String message) {
    if (!mounted) return;

    toastification.show(
      context: context,
      title: Text(message),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      type: ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 4),
      alignment: Alignment.bottomCenter,
    );
  }

  void _editAkun(DataAkun akun) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminEditAkun(akun: akun)),
    ).then((_) {
      // Refresh data setelah kembali dari halaman edit
      if (mounted) {
        _loadDataAkun();
      }
    });
  }

  Widget _buildAkunCard(DataAkun akun) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan nama dan role
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        akun.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        akun.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Informasi akun
            _buildInfoRow(
              Icons.account_circle_outlined,
              'Username',
              akun.username,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.lock_outline,
              'Password',
              '•' * akun.password.length,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.email_outlined, 'Email', akun.email),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone_outlined, 'Nomor Telp', akun.nomorTelp),

            const SizedBox(height: 20),

            // Tombol aksi
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Ubah',
                    Icons.edit_outlined,
                    Colors.black87,
                    () => _editAkun(akun),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Hapus',
                    Icons.delete_outline,
                    Colors.red[600]!,
                    () => _deleteAkun(akun.id),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: color),
        label: Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Manajemen Akun',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminTambahAkun(),
                ),
              ).then((_) {
                if (mounted) {
                  _loadDataAkun();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadDataAkun,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.black87),
              )
              : errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi kesalahan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadDataAkun,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
              : dataAkun.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada data akun',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan akun baru untuk memulai',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadDataAkun,
                color: Colors.black87,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: dataAkun.length,
                  itemBuilder: (context, index) {
                    return _buildAkunCard(dataAkun[index]);
                  },
                ),
              ),
    );
  }
}
