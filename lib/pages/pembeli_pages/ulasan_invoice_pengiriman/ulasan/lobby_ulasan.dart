import 'package:flutter/material.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:frontend/pages/pembeli_pages/ulasan_invoice_pengiriman/ulasan/tambah_ulasan.dart';

class LobbyUlasan extends StatefulWidget {
  final String transactionId;

  const LobbyUlasan({super.key, required this.transactionId});

  @override
  State<LobbyUlasan> createState() => _LobbyUlasanState();
}

class _LobbyUlasanState extends State<LobbyUlasan> {
  List<RiwayatTransaksiDetail> products = [];
  Map<String, KomentarModel?> komentarMap =
      {}; // Menyimpan status komentar per produk varian
  Map<String, bool> komentarLoadingMap = {}; // Status loading per produk varian
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final fetchedProducts = await RiwayatTransaksiDetail.fetchDetail(
        widget.transactionId,
      );

      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });

      // Setelah produk berhasil dimuat, cek komentar untuk setiap produk varian
      await _loadKomentarForAllProducts();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadKomentarForAllProducts() async {
    for (var product in products) {
      await _loadKomentarForProduct(product.idVarianProduk);
    }
  }

  Future<void> _loadKomentarForProduct(String idVarianProduk) async {
    setState(() {
      komentarLoadingMap[idVarianProduk] = true;
    });

    try {
      final komentar = await CekKomentarService.fetchKomentar(
        int.parse(idVarianProduk),
      );

      setState(() {
        komentarMap[idVarianProduk] = komentar;
        komentarLoadingMap[idVarianProduk] = false;
      });
    } catch (e) {
      setState(() {
        komentarMap[idVarianProduk] = null;
        komentarLoadingMap[idVarianProduk] = false;
      });
      print('Error loading komentar for product variant $idVarianProduk: $e');
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
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Produk Ulasan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Terjadi kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
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

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada produk',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada produk untuk diulas',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildProductCard(products[index]);
        },
      ),
    );
  }

  Widget _buildProductCard(RiwayatTransaksiDetail product) {
    final bool hasKomentar = komentarMap[product.idVarianProduk] != null;
    final bool isKomentarLoading =
        komentarLoadingMap[product.idVarianProduk] ?? false;
    final komentar = komentarMap[product.idVarianProduk];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    product.linkGambarVarian.isNotEmpty
                        ? Image.network(
                          'http://192.168.1.96:3000/uploads/${product.linkGambarVarian}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.grey[400],
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              ),
                            );
                          },
                        )
                        : _buildPlaceholderImage(),
              ),
            ),
            const SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.namaProduk,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Product Details (Color, Size, Quantity, Price)
                  _buildDetailRow('Warna', product.warna),
                  _buildDetailRow('Ukuran', product.ukuran.toString()),
                  _buildDetailRow('Jumlah', '${product.jumlah} pcs'),
                  _buildDetailRow('Harga', 'Rp ${_formatPrice(product.harga)}'),

                  const SizedBox(height: 16),

                  // Status Ulasan (jika sudah ada ulasan)
                  if (hasKomentar && komentar != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[600],
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Ulasan Sudah Diberikan',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Rating: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[600],
                                ),
                              ),
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < komentar.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 14,
                                );
                              }),
                            ],
                          ),
                          if (komentar.komentar.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              '"${komentar.komentar}"',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[600],
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ] else if (isKomentarLoading) ...[
                    // Loading state untuk cek komentar
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Memeriksa status ulasan...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Tombol tambah ulasan (aktif jika belum ada ulasan)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => TambahUlasan(
                                    idProduk: product.idProduk,
                                    idVarianProduk: product.idVarianProduk,
                                  ),
                            ),
                          );

                          // Refresh komentar setelah kembali dari halaman tambah ulasan
                          if (result == true) {
                            await _loadKomentarForProduct(
                              product.idVarianProduk,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'TAMBAHKAN ULASAN',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image_outlined, size: 32, color: Colors.grey[400]),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(String price) {
    try {
      final numPrice = int.parse(price);
      return numPrice.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]}.',
      );
    } catch (e) {
      return price;
    }
  }
}
