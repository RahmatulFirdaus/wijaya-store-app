import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:frontend/pages/pembeli_pages/list_chat_admin.dart';
import 'package:frontend/pages/pembeli_pages/tampil_video_produk.dart';
import 'package:toastification/toastification.dart';

const String baseUrl = "http://192.168.1.96:3000/uploads/";

class AdminDetailLobbyProduk extends StatefulWidget {
  final String productId, idPengguna;
  const AdminDetailLobbyProduk({
    super.key,
    required this.productId,
    required this.idPengguna,
  });

  @override
  State<AdminDetailLobbyProduk> createState() => _AdminDetailLobbyProdukState();
}

class _AdminDetailLobbyProdukState extends State<AdminDetailLobbyProduk> {
  TextEditingController jumlahOrderController = TextEditingController();
  TextEditingController hargaKhususController = TextEditingController();
  late Future<GetDataDetailProduk> futureProductDetail;
  late Future<List<GetDataUlasan>> futureUlasan;
  int? selectedVariantIndex;
  int? selectedSize;
  int jumlahOrder = 1; // Add quantity state
  bool isAddingToCart = false; // Loading state for cart button

  @override
  void initState() {
    super.initState();
    futureProductDetail = GetDataDetailProduk.getDataDetailProduk(
      widget.productId,
    );
    futureUlasan = GetDataUlasan.getDataUlasan(widget.productId);
  }

  // Get unique sizes from all variants
  List<int> getUniqueSizes(List<Varian> variants) {
    final Set<int> sizes = {};
    for (var variant in variants) {
      sizes.add(variant.ukuran);
    }
    return sizes.toList()..sort();
  }

  bool hasValidVideo(String? videoUrl) {
    if (videoUrl == null || videoUrl.trim().isEmpty) return false;
    if (videoUrl.trim().toUpperCase() == 'NULL') return false;

    final validExtensions = [
      '.mp4',
      '.mov',
      '.avi',
      '.mkv',
      '.webm',
      '.3gp',
      '.flv',
    ];
    final lowerUrl = videoUrl.toLowerCase();
    return validExtensions.any((ext) => lowerUrl.contains(ext));
  }

  // Format price with Rupiah format
  String formatPrice(String price) {
    try {
      double priceValue = double.parse(price);
      String formatted = priceValue.toStringAsFixed(0);

      // Add thousand separators
      String result = '';
      int count = 0;
      for (int i = formatted.length - 1; i >= 0; i--) {
        if (count == 3) {
          result = '.' + result;
          count = 0;
        }
        result = formatted[i] + result;
        count++;
      }

      return 'Rp $result';
    } catch (e) {
      return price;
    }
  }

  // Calculate discount percentage
  String calculateDiscount(String currentPrice, String originalPrice) {
    try {
      double current = double.parse(currentPrice);
      double original = double.parse(originalPrice);
      double discount = ((original - current) / original) * 100;
      return '${discount.toStringAsFixed(0)}%';
    } catch (e) {
      return '0%';
    }
  }

  // Build rating stars
  Widget buildRatingStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 16));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 16));
      } else {
        stars.add(
          Icon(Icons.star_border, color: Colors.grey.shade400, size: 16),
        );
      }
    }

    return Row(children: stars);
  }

  // Show description popup
  void showDescriptionPopup(
    BuildContext context,
    String description,
    String productName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.8,
            minChildSize: 0.4,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Deskripsi Produk',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      // Description content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                description.isNotEmpty
                                    ? description
                                    : 'Tidak ada deskripsi tersedia untuk produk ini.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  // Show chat with admin
  void showChatWithAdmin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminListPage()),
    );
  }

  // Updated show reviews popup with empty state handling
  void showReviewsPopup(BuildContext context, List<GetDataUlasan> reviews) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ulasan Produk',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      // Reviews list or empty state
                      Expanded(
                        child:
                            reviews.isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.rate_review_outlined,
                                        size: 80,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Belum ada ulasan',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Jadilah yang pertama memberikan ulasan\nuntuk produk ini',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : ListView.builder(
                                  controller: scrollController,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  itemCount: reviews.length,
                                  itemBuilder: (context, index) {
                                    final review = reviews[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                review.nama_pembeli,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                review.tanggal,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          buildRatingStars(
                                            double.tryParse(review.rating) ?? 0,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            review.ulasan,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Future<void> handleAddToCart() async {
    if (selectedVariantIndex == null) {
      toastification.show(
        context: context,
        title: Text('Pilih varian produk terlebih dahulu'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    setState(() {
      isAddingToCart = true;
    });

    try {
      // Get the product data that's already loaded
      final product = await futureProductDetail;

      // Get the selected variant using the index
      final selectedVariant = product.varian[selectedVariantIndex!];

      // Use the correct field name for variant ID
      final result = await TambahKeranjangAdmin.addToKeranjang(
        widget.idPengguna,
        selectedVariant.idVarian.toString(), // Gunakan idVarian, bukan id
        jumlahOrder.toString(),
        hargaKhusus: hargaKhususController.text,
      );

      if (result != null) {
        toastification.show(
          context: context,
          title: Text(result),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 3),
        );

        // Refresh halaman
        setState(() {
          futureProductDetail = GetDataDetailProduk.getDataDetailProduk(
            widget.productId,
          );
          futureUlasan = GetDataUlasan.getDataUlasan(widget.productId);
        });
      }
    } catch (e) {
      toastification.show(
        context: context,
        title: Text('Gagal menambahkan ke keranjang: $e'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );
    } finally {
      setState(() {
        isAddingToCart = false;
      });
    }
  }

  // Build quantity selector
  Widget buildQuantitySelector(int maxStock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jumlah',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed:
                          jumlahOrder > 1
                              ? () {
                                setState(() {
                                  jumlahOrder--;
                                });
                              }
                              : null,
                      icon: const Icon(Icons.remove),
                      iconSize: 20,
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        jumlahOrder.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          jumlahOrder < maxStock
                              ? () {
                                setState(() {
                                  jumlahOrder++;
                                });
                              }
                              : null,
                      icon: const Icon(Icons.add),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Stok tersedia: $maxStock',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _buildAppBar(context),
        body: FutureBuilder<GetDataDetailProduk>(
          future: futureProductDetail,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            } else if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            } else if (!snapshot.hasData) {
              return _buildEmptyState();
            }

            final product = snapshot.data!;
            return _buildProductContent(product);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      shadowColor: Colors.grey.shade200,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.black87),
          onPressed: () {
            // Implementasi share functionality
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.black87),
          onPressed: () {
            // Implementasi wishlist functionality
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.black87, strokeWidth: 2),
          SizedBox(height: 16),
          Text(
            'Memuat detail produk...',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Produk Tidak Ditemukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data produk tidak tersedia saat ini',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductContent(GetDataDetailProduk product) {
    final uniqueSizes = getUniqueSizes(product.varian);

    // Initialize selection if needed
    if (selectedVariantIndex == null && product.varian.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedVariantIndex = 0;
          selectedSize = product.varian[0].ukuran;
        });
      });
    }

    final currentStock =
        selectedVariantIndex != null
            ? product.varian[selectedVariantIndex!].stok
            : 0;

    // Validate quantity against stock
    if (jumlahOrder > currentStock) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          jumlahOrder = currentStock > 0 ? 1 : 0;
        });
      });
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProductImage(product),
          _buildProductInfo(product),
          _buildColorVariants(product),
          _buildSizeSelection(product, uniqueSizes),
          _buildQuantitySection(currentStock),
          _buildActionButtons(product, currentStock),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProductImage(GetDataDetailProduk product) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 360,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child:
              selectedVariantIndex != null
                  ? Image.network(
                    baseUrl +
                        product.varian[selectedVariantIndex!].linkGambarVarian,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                              progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                          color: Colors.black87,
                          strokeWidth: 2,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade100,
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                      );
                    },
                  )
                  : Image.network(
                    baseUrl + product.linkGambar,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                              progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                          color: Colors.black87,
                          strokeWidth: 2,
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(GetDataDetailProduk product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.namaProduk,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildRatingSection(),
          const SizedBox(height: 20),
          _buildPriceSection(product),
          const SizedBox(height: 16),
          _buildProductActions(product),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return FutureBuilder<List<GetDataUlasan>>(
      future: futureUlasan,
      builder: (context, ulasanSnapshot) {
        if (ulasanSnapshot.connectionState == ConnectionState.waiting) {
          return _buildRatingPlaceholder('Memuat ulasan...');
        }

        if (ulasanSnapshot.hasError ||
            !ulasanSnapshot.hasData ||
            ulasanSnapshot.data!.isEmpty) {
          return _buildRatingPlaceholder('Belum ada ulasan');
        }

        final reviews = ulasanSnapshot.data!;
        final averageRating =
            reviews.fold<double>(
              0,
              (sum, review) => sum + (double.tryParse(review.rating) ?? 0),
            ) /
            reviews.length;

        return GestureDetector(
          onTap: () => showReviewsPopup(context, reviews),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildRatingStars(averageRating),
                const SizedBox(width: 12),
                Text(
                  '${averageRating.toStringAsFixed(1)} (${reviews.length} ulasan)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingPlaceholder(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildPriceSection(GetDataDetailProduk product) {
    final hasDiscount = product.hargaAwal != product.harga;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          formatPrice(product.harga),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatPrice(product.hargaAwal),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '-${calculateDiscount(product.harga, product.hargaAwal)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProductActions(GetDataDetailProduk product) {
    return Row(
      children: [
        if (hasValidVideo(product.videoDemo)) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _navigateToVideo(product),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Video'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
                side: BorderSide(color: Colors.blue.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showDescription(product),
            icon: const Icon(Icons.description_outlined),
            label: const Text('Deskripsi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorVariants(GetDataDetailProduk product) {
    final uniqueColorVariants = <String, Varian>{};
    for (var variant in product.varian) {
      uniqueColorVariants[variant.warna] = variant;
    }
    final colorVariants = uniqueColorVariants.values.toList();

    if (colorVariants.length <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Warna',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  colorVariants.map((variant) {
                    final isSelected =
                        selectedVariantIndex != null &&
                        product.varian[selectedVariantIndex!].warna ==
                            variant.warna;

                    return GestureDetector(
                      onTap: () => _selectColorVariant(product, variant),
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.black87
                                    : Colors.grey.shade300,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade50,
                            child: Image.network(
                              baseUrl + variant.linkGambarVarian,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey.shade400,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSelection(
    GetDataDetailProduk product,
    List<dynamic> uniqueSizes,
  ) {
    if (uniqueSizes.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Ukuran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                uniqueSizes.map((size) {
                  final isSelected = selectedSize == size;
                  final hasStock = _checkSizeStock(product, size);

                  return GestureDetector(
                    onTap: hasStock ? () => _selectSize(product, size) : null,
                    child: Container(
                      width: 60,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black87 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              hasStock
                                  ? (isSelected
                                      ? Colors.black87
                                      : Colors.grey.shade300)
                                  : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          size.toString(),
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : (hasStock
                                        ? Colors.black87
                                        : Colors.grey.shade400),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection(int currentStock) {
    if (currentStock <= 0) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stok Habis',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Varian ini sedang tidak tersedia',
                    style: TextStyle(color: Colors.red.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jumlah',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Stok: $currentStock',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildQuantitySelector(currentStock),
          const SizedBox(height: 20),
          TextField(
            controller: hargaKhususController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Harga Khusus (Opsional)',
              hintText: 'Masukkan harga khusus jika ada',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black87, width: 2),
              ),
              prefixIcon: Icon(Icons.attach_money, color: Colors.grey.shade600),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(GetDataDetailProduk product, int currentStock) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Container(
          //   width: 56,
          //   height: 56,
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(16),
          //     border: Border.all(color: Colors.grey.shade300),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.grey.shade200,
          //         blurRadius: 6,
          //         offset: const Offset(0, 2),
          //       ),
          //     ],
          //   ),
          //   child: IconButton(
          //     onPressed: () => showChatWithAdmin(context),
          //     icon: Icon(
          //       Icons.chat_bubble_outline,
          //       color: Colors.grey.shade700,
          //     ),
          //   ),
          // ),
          // const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed:
                    currentStock > 0 && !isAddingToCart
                        ? handleAddToCart
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      currentStock > 0 ? Colors.black87 : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: currentStock > 0 ? 4 : 0,
                  shadowColor: Colors.black.withOpacity(0.2),
                ),
                child:
                    isAddingToCart
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_outlined),
                            const SizedBox(width: 8),
                            Text(
                              currentStock > 0
                                  ? 'Tambah ke Keranjang'
                                  : 'Stok Habis',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  void _selectColorVariant(GetDataDetailProduk product, Varian variant) {
    setState(() {
      selectedVariantIndex = product.varian.indexWhere(
        (v) => v.warna == variant.warna,
      );
      selectedSize = product.varian[selectedVariantIndex!].ukuran;
      jumlahOrder = 1;
    });
  }

  void _selectSize(GetDataDetailProduk product, dynamic size) {
    if (selectedVariantIndex != null) {
      final currentColor = product.varian[selectedVariantIndex!].warna;
      final index = product.varian.indexWhere(
        (v) => v.ukuran == size && v.warna == currentColor,
      );
      if (index != -1) {
        setState(() {
          selectedSize = size;
          selectedVariantIndex = index;
          jumlahOrder = 1;
        });
      }
    }
  }

  bool _checkSizeStock(GetDataDetailProduk product, dynamic size) {
    if (selectedVariantIndex == null) return false;
    final currentColor = product.varian[selectedVariantIndex!].warna;
    return product.varian.any(
      (v) => v.ukuran == size && v.warna == currentColor && v.stok > 0,
    );
  }

  void _navigateToVideo(GetDataDetailProduk product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TampilVideoProduk(
              videoUrl: product.videoDemo!,
              productName: product.namaProduk,
            ),
      ),
    );
  }

  void _showDescription(GetDataDetailProduk product) {
    showDescriptionPopup(context, product.deskripsi, product.namaProduk);
  }
}
