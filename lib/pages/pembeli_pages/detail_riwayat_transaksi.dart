import 'package:flutter/material.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:frontend/pages/pembeli_pages/ulasan_invoice_pengiriman/invoice.dart';
import 'package:frontend/pages/pembeli_pages/ulasan_invoice_pengiriman/pengiriman.dart';

class DetailRiwayatTransaksi extends StatefulWidget {
  final String idOrderan;

  const DetailRiwayatTransaksi({super.key, required this.idOrderan});

  @override
  State<DetailRiwayatTransaksi> createState() => _DetailRiwayatTransaksiState();
}

class _DetailRiwayatTransaksiState extends State<DetailRiwayatTransaksi> {
  List<RiwayatTransaksiDetail> produkList = [];
  StatusOrder? statusOrder;
  StatusPengiriman? statusPengiriman;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Load semua data secara paralel
      final results = await Future.wait([
        RiwayatTransaksiDetail.fetchDetail(widget.idOrderan),
        StatusOrder.fetchStatusOrder(widget.idOrderan),
        StatusPengiriman.fetchStatus(widget.idOrderan),
      ]);

      setState(() {
        produkList = results[0] as List<RiwayatTransaksiDetail>;
        statusOrder = results[1] as StatusOrder;
        statusPengiriman = results[2] as StatusPengiriman;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
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
          'Detail Produk',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
              : errorMessage.isNotEmpty
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
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product List
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: produkList.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _buildProductCard(produkList[index]);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom Action Buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Invoice Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _canAccessInvoice()
                                    ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => Invoice(
                                                idOrderan: widget.idOrderan,
                                              ),
                                        ),
                                      );
                                    }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _canAccessInvoice()
                                      ? Colors.black
                                      : Colors.grey[300],
                              foregroundColor:
                                  _canAccessInvoice()
                                      ? Colors.white
                                      : Colors.grey[500],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Invoice',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Bottom Row Buttons
                        Row(
                          children: [
                            // Ulasan Button
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _canGiveReview() ? () {} : null,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color:
                                        _canGiveReview()
                                            ? Colors.black
                                            : Colors.grey[300]!,
                                  ),
                                  foregroundColor:
                                      _canGiveReview()
                                          ? Colors.black
                                          : Colors.grey[500],
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Ulasan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Status Pengiriman Button
                            Expanded(
                              child: OutlinedButton(
                                onPressed:
                                    _canCheckShipping()
                                        ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => Pengiriman(
                                                    orderId: widget.idOrderan,
                                                  ),
                                            ),
                                          );
                                        }
                                        : null,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color:
                                        _canCheckShipping()
                                            ? Colors.black
                                            : Colors.grey[300]!,
                                  ),
                                  foregroundColor:
                                      _canCheckShipping()
                                          ? Colors.black
                                          : Colors.grey[500],
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Status Pengiriman',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildProductCard(RiwayatTransaksiDetail produk) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  produk.linkGambarVarian.isNotEmpty
                      ? Image.network(
                        'http://192.168.1.96:3000/uploads/${produk.linkGambarVarian}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.grey[400],
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      )
                      : Icon(
                        Icons.image_outlined,
                        color: Colors.grey[400],
                        size: 24,
                      ),
            ),
          ),
          const SizedBox(width: 16),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produk.namaProduk,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${produk.warna}, Ukuran ${produk.ukuran}, Jumlah ${produk.jumlah}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  produk.harga,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canAccessInvoice() {
    return statusOrder?.status.toLowerCase() == 'berhasil';
  }

  bool _canCheckShipping() {
    return statusOrder?.status.toLowerCase() == 'berhasil';
  }

  bool _canGiveReview() {
    return statusPengiriman?.status.toLowerCase() == 'diterima';
  }
}
