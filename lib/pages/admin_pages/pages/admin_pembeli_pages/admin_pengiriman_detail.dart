import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:toastification/toastification.dart';

class AdminPengirimanDetail extends StatefulWidget {
  final int idPengiriman;

  const AdminPengirimanDetail({super.key, required this.idPengiriman});

  @override
  State<AdminPengirimanDetail> createState() => _AdminPengirimanDetailState();
}

class _AdminPengirimanDetailState extends State<AdminPengirimanDetail> {
  DetailPengiriman? detailPengiriman;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDetailPengiriman();
  }

  Future<void> _loadDetailPengiriman() async {
    try {
      final detail = await DetailPengiriman.getPengirimanDetail(
        widget.idPengiriman,
      );
      setState(() {
        detailPengiriman = detail;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return 'Diproses';
      case 'dikirim':
        return 'Dikirim';
      case 'diterima':
        return 'Diterima';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return Colors.orange;
      case 'dikirim':
        return Colors.blue;
      case 'diterima':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return Icons.hourglass_empty;
      case 'dikirim':
        return Icons.local_shipping;
      case 'diterima':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Detail Pengiriman',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF2E3440),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E3440), Color(0xFF3B4252)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5E81AC)),
                ),
              )
              : error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi Kesalahan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : detailPengiriman == null
              ? const Center(
                child: Text(
                  'Data tidak ditemukan',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Card
                    _buildStatusCard(),
                    const SizedBox(height: 20),

                    // Customer Info Card
                    _buildCustomerInfoCard(),
                    const SizedBox(height: 20),

                    // Product Info Card
                    _buildProductInfoCard(),
                    const SizedBox(height: 20),

                    // Update Status Section
                    _buildUpdateStatusSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildStatusCard() {
    final currentStatus = detailPengiriman!.statusPengiriman;
    final statusColor = _getStatusColor(currentStatus);
    final statusIcon = _getStatusIcon(currentStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Pengiriman',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(currentStatus),
                  style: TextStyle(
                    fontSize: 18,
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E81AC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF5E81AC),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Informasi Pembeli',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E3440),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCustomerInfoRow('Nama', detailPengiriman!.namaPengguna),
          const SizedBox(height: 12),
          _buildCustomerInfoRow('Alamat', detailPengiriman!.alamatPengiriman),
          const SizedBox(height: 12),
          _buildCustomerInfoRow('Tanggal', detailPengiriman!.tanggalPengiriman),
        ],
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD08770).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  color: Color(0xFFD08770),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Informasi Produk',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E3440),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Loop through each product item
          ...detailPengiriman!.items.asMap().entries.map((entry) {
            int index = entry.key;
            var item = entry.value;
            bool isLast = index == detailPengiriman!.items.length - 1;

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product number header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD08770).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Produk ${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD08770),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Product details
                      _buildProductDetailRow('Nama', item.nama),
                      const SizedBox(height: 8),
                      _buildProductDetailRow('Warna', item.warna),
                      const SizedBox(height: 8),
                      _buildProductDetailRow('Ukuran', item.ukuran.toString()),
                      const SizedBox(height: 8),
                      _buildProductDetailRow(
                        'Jumlah',
                        '${item.jumlahOrder} pcs',
                      ),
                      const SizedBox(height: 8),
                      _buildProductDetailRow(
                        'Harga Satuan',
                        'Rp ${item.hargaSatuan}',
                      ),
                      const SizedBox(height: 12),

                      // Subtotal for this item
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD08770).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E3440),
                              ),
                            ),
                            Text(
                              'Rp ${int.parse(item.hargaSatuan.replaceAll(',', '')) * item.jumlahOrder}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD08770),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast) const SizedBox(height: 12),
              ],
            );
          }).toList(),

          const SizedBox(height: 16),

          // Total amount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFA3BE8C).withOpacity(0.1),
                  const Color(0xFFA3BE8C).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFA3BE8C).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA3BE8C).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.calculate,
                        color: Color(0xFFA3BE8C),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Total Harga',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E3440),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Rp ${detailPengiriman!.totalHarga}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFA3BE8C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateStatusSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFBF616A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.update,
                  color: Color(0xFFBF616A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ubah Status Pengiriman',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E3440),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatusButton(
            'Diproses',
            'diproses',
            Icons.hourglass_empty,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildStatusButton(
            'Dikirim',
            'dikirim',
            Icons.local_shipping,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildStatusButton(
            'Diterima',
            'diterima',
            Icons.check_circle,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2E3440),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF2E3440),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(
    String label,
    String statusValue,
    IconData icon,
    Color color,
  ) {
    // Perbaikan: Bandingkan dengan nilai yang akan disimpan
    bool isSelected =
        detailPengiriman!.statusPengiriman.toLowerCase() ==
        statusValue.toLowerCase();

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed:
            isSelected
                ? null
                : () {
                  _updateStatus(statusValue); // Gunakan statusValue yang benar
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? color.withOpacity(0.2) : Colors.white,
          foregroundColor: isSelected ? color : const Color(0xFF2E3440),
          side: BorderSide(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isSelected ? 0 : 2,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isSelected ? color : Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : const Color(0xFF2E3440),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check, size: 16, color: color),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      // Tampilkan loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5E81AC)),
              ),
            ),
      );

      final result = await UpdatePengirimanService.updateStatusPengiriman(
        id: widget.idPengiriman.toString(),
        status: newStatus,
      );

      // Tutup loading indicator
      Navigator.of(context).pop();

      // Update local state jika berhasil
      if (result.contains('berhasil')) {
        setState(() {
          detailPengiriman!.statusPengiriman = newStatus;
        });
      }

      // Tampilkan pesan dari server dengan toastification
      toastification.show(
        context: context,
        title: Text(result),
        type:
            result.contains('berhasil')
                ? ToastificationType.success
                : ToastificationType.info,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.bottomCenter,
        style: ToastificationStyle.fillColored,
      );
    } catch (e) {
      // Tutup loading indicator jika masih terbuka
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      toastification.show(
        context: context,
        title: Text('Error: $e'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 4),
        alignment: Alignment.bottomCenter,
        style: ToastificationStyle.fillColored,
      );
    }
  }
}
