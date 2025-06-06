import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:toastification/toastification.dart'; // Tambahkan import

class AdminPengajuanIzinDetailKaryawan extends StatefulWidget {
  final String izinId;

  const AdminPengajuanIzinDetailKaryawan({super.key, required this.izinId});

  @override
  State<AdminPengajuanIzinDetailKaryawan> createState() =>
      _AdminPengajuanIzinDetailKaryawanState();
}

class _AdminPengajuanIzinDetailKaryawanState
    extends State<AdminPengajuanIzinDetailKaryawan> {
  DetailIzinKaryawan? detailIzin;
  bool isLoading = true;
  bool isUpdating = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetailIzin();
  }

  Future<void> _loadDetailIzin() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final detail = await DetailIzinKaryawan.getDetailIzinKaryawan(
        widget.izinId,
      );

      setState(() {
        detailIzin = detail;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'disetujui':
      case 'diterima':
        return Colors.green;
      case 'rejected':
      case 'ditolak':
        return Colors.red;
      case 'pending':
      case 'menunggu':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'disetujui':
      case 'diterima':
        return Icons.check_circle;
      case 'rejected':
      case 'ditolak':
        return Icons.cancel;
      case 'pending':
      case 'menunggu':
        return Icons.access_time;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail Pengajuan Izin',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
              : errorMessage != null
              ? _buildErrorWidget()
              : detailIzin == null
              ? _buildNotFoundWidget()
              : _buildDetailContent(),

          // Overlay loading when updating
          if (isUpdating)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Terjadi Kesalahan',
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
              errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDetailIzin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Data Tidak Ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employee Info Card
          _buildInfoCard(
            title: 'Informasi Karyawan',
            child: Column(
              children: [
                _buildDetailRow(
                  icon: Icons.person,
                  label: 'Nama Karyawan',
                  value: detailIzin!.nama,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Leave Request Info Card
          _buildInfoCard(
            title: 'Detail Pengajuan Izin',
            child: Column(
              children: [
                _buildDetailRow(
                  icon: Icons.category,
                  label: 'Tipe Izin',
                  value: detailIzin!.tipeIzin,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Tanggal Mulai',
                  value: _formatDate(detailIzin!.tanggalMulai),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Tanggal Akhir',
                  value: _formatDate(detailIzin!.tanggalAkhir),
                ),
                const SizedBox(height: 16),
                _buildStatusRow(),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Description Card
          _buildInfoCard(
            title: 'Deskripsi',
            child: Text(
              detailIzin!.deskripsi.isEmpty
                  ? 'Tidak ada deskripsi'
                  : detailIzin!.deskripsi,
              style: TextStyle(
                fontSize: 14,
                color:
                    detailIzin!.deskripsi.isEmpty
                        ? Colors.grey[500]
                        : Colors.black87,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons (if status is pending)
          if (detailIzin!.status.toLowerCase() == 'pending' ||
              detailIzin!.status.toLowerCase() == 'menunggu')
            _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(detailIzin!.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(detailIzin!.status).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(detailIzin!.status),
                      size: 16,
                      color: _getStatusColor(detailIzin!.status),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _capitalizeFirst(detailIzin!.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(detailIzin!.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Approve Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isUpdating ? null : () => _showApproveDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 20),
                SizedBox(width: 8),
                Text(
                  'Setujui Pengajuan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Reject Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: isUpdating ? null : () => _showRejectDialog(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel, size: 20),
                SizedBox(width: 8),
                Text(
                  'Tolak Pengajuan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showApproveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Konfirmasi Persetujuan',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menyetujui pengajuan izin ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _approveRequest();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('Setujui'),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Konfirmasi Penolakan',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menolak pengajuan izin ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _rejectRequest();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('Tolak'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _approveRequest() async {
    setState(() {
      isUpdating = true;
    });

    try {
      final message = await UpdateIzinKaryawanService.updateStatusIzinKaryawan(
        id: widget.izinId,
        status: 'diterima',
      );

      if (mounted) {
        toastification.show(
          context: context,
          title: Text(message),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.bottomCenter,
        );

        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          title: Text('Gagal menyetujui: $e'),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.bottomCenter,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  Future<void> _rejectRequest() async {
    setState(() {
      isUpdating = true;
    });

    try {
      final message = await UpdateIzinKaryawanService.updateStatusIzinKaryawan(
        id: widget.izinId,
        status: 'ditolak',
      );

      if (mounted) {
        toastification.show(
          context: context,
          title: Text(message),
          type: ToastificationType.warning,
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.bottomCenter,
        );

        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          title: Text('Gagal menolak: $e'),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.bottomCenter,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
