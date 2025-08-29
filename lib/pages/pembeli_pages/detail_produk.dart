import 'package:flutter/material.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:frontend/pages/pembeli_pages/list_chat_admin.dart';
import 'package:frontend/pages/pembeli_pages/tampil_video_produk.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

const String baseUrl = "http://192.168.1.96:3000/uploads/";

class DetailProduk extends StatefulWidget {
  final String productId;

  const DetailProduk({super.key, required this.productId});

  @override
  State<DetailProduk> createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
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

  Future<void> shareToWhatsApp(
    String productName,
    String hargaAwal,
    String hargaDiskon,
  ) async {
    final message =
        "🔥 Promo Spesial Wijaya Store! 🔥\n\n"
        "👟 $productName\n"
        "💸 Dari Rp $hargaAwal ➡️ Rp $hargaDiskon\n\n"
        "🛍️ Promo khusus untuk pembelian via aplikasi Wijaya Store!\n"
        "👉 Download sekarang: https://drive.google.com/file/d/1UJZAekusNhcOBckYBMlsd3TUilEZB-9n/view?usp=sharing";

    // gunakan schema whatsapp
    final url = "whatsapp://send?text=${Uri.encodeComponent(message)}";

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // fallback: buka wa.me lewat browser
      final webUrl = "https://wa.me/?text=${Uri.encodeComponent(message)}";
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }

  void refreshProductData() {
    setState(() {
      futureProductDetail = GetDataDetailProduk.getDataDetailProduk(
        widget.productId,
      );
      futureUlasan = GetDataUlasan.getDataUlasan(widget.productId);
      // Reset selection
      selectedVariantIndex = null;
      selectedSize = null;
      jumlahOrder = 1;
    });
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
      final result = await TambahKeranjang.addToKeranjang(
        selectedVariant.idVarian.toString(), // Gunakan idVarian, bukan id
        jumlahOrder.toString(),
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: FutureBuilder<GetDataDetailProduk>(
          future: futureProductDetail,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Tidak ada data yang ditemukan'));
            }

            final product = snapshot.data!;
            final uniqueSizes = getUniqueSizes(product.varian);

            // If no variant is selected yet, select the first one
            if (selectedVariantIndex == null && product.varian.isNotEmpty) {
              selectedVariantIndex = 0;
              selectedSize = product.varian[0].ukuran;
            }

            // Get current variant stock
            int currentStock =
                selectedVariantIndex != null
                    ? product.varian[selectedVariantIndex!].stok
                    : 0;

            // Ensure jumlahOrder doesn't exceed stock
            if (jumlahOrder > currentStock) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  jumlahOrder = currentStock > 0 ? 1 : 0;
                });
              });
            }

            // Get unique color variants for the thumbnail selection
            final Map<String, Varian> uniqueColorVariants = {};
            for (var variant in product.varian) {
              uniqueColorVariants[variant.warna] = variant;
            }

            final List<Varian> colorVariants =
                uniqueColorVariants.values.toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    height: 320,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child:
                          selectedVariantIndex != null
                              ? Image.network(
                                baseUrl +
                                    product
                                        .varian[selectedVariantIndex!]
                                        .linkGambarVarian,
                                fit: BoxFit.contain,
                                // ✅ TAMBAHKAN ERROR HANDLING
                                errorBuilder: (context, error, stackTrace) {
                                  print("Error loading variant image: $error");
                                  return Container(
                                    color: Colors.grey.shade100,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported,
                                          size: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Gambar tidak tersedia',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                // ✅ TAMBAHKAN LOADING BUILDER
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey.shade100,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
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
                              : Image.network(
                                baseUrl + product.linkGambar,
                                fit: BoxFit.contain,
                                // ✅ TAMBAHKAN ERROR HANDLING UNTUK GAMBAR UTAMA
                                errorBuilder: (context, error, stackTrace) {
                                  print(
                                    "Error loading main product image: $error",
                                  );
                                  return Container(
                                    color: Colors.grey.shade100,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported,
                                          size: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Gambar tidak tersedia',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey.shade100,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ),

                  // Color Variants
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Warna',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                colorVariants.map((variant) {
                                  bool isSelected =
                                      selectedVariantIndex != null &&
                                      product
                                              .varian[selectedVariantIndex!]
                                              .warna ==
                                          variant.warna;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedVariantIndex = product.varian
                                            .indexWhere(
                                              (v) => v.warna == variant.warna,
                                            );
                                        selectedSize =
                                            product
                                                .varian[selectedVariantIndex!]
                                                .ukuran;
                                        // Reset quantity when variant changes
                                        jumlahOrder = 1;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? Colors.black
                                                  : Colors.grey.shade300,
                                          width: isSelected ? 2 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey.shade100,
                                          child: Image.network(
                                            baseUrl + variant.linkGambarVarian,
                                            fit: BoxFit.cover,
                                            // ✅ TAMBAHKAN ERROR HANDLING UNTUK THUMBNAIL VARIAN
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              print(
                                                "Error loading variant thumbnail: $error",
                                              );
                                              return Container(
                                                color: Colors.grey.shade200,
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  size: 24,
                                                  color: Colors.grey.shade400,
                                                ),
                                              );
                                            },
                                            // ✅ TAMBAHKAN LOADING BUILDER UNTUK THUMBNAIL
                                            loadingBuilder: (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Container(
                                                color: Colors.grey.shade200,
                                                child: const Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
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
                  ),

                  // Product Info
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.namaProduk,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Updated Rating and Reviews section with proper empty handling
                        FutureBuilder<List<GetDataUlasan>>(
                          future: futureUlasan,
                          builder: (context, ulasanSnapshot) {
                            if (ulasanSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Memuat ulasan...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                            }

                            if (ulasanSnapshot.hasError) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Tidak ada ulasan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                            }

                            if (ulasanSnapshot.hasData) {
                              final reviews = ulasanSnapshot.data!;

                              // Check if reviews list is empty
                              if (reviews.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    'Belum ada ulasan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                );
                              }

                              double averageRating = 0;
                              double totalRating = 0;
                              for (var review in reviews) {
                                totalRating +=
                                    double.tryParse(review.rating) ?? 0;
                              }
                              averageRating = totalRating / reviews.length;

                              return GestureDetector(
                                onTap: () => showReviewsPopup(context, reviews),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      buildRatingStars(averageRating),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${averageRating.toStringAsFixed(1)} (${reviews.length}) · ${reviews.length} ulasan',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.chevron_right,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Tidak ada ulasan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Price with discount
                        Row(
                          children: [
                            Text(
                              formatPrice(product.harga),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (product.hargaAwal != product.harga) ...[
                              Text(
                                formatPrice(product.hargaAwal),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade500,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
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
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Size Selection
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pilih Ukuran',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                // Tombol Video Produk - PERBAIKAN
                                if (hasValidVideo(product.videoDemo)) ...[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => TampilVideoProduk(
                                                videoUrl:
                                                    product
                                                        .videoDemo!, // Pass video URL
                                                productName:
                                                    product
                                                        .namaProduk, // Pass product name
                                              ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Video Produk',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Text(' • '),
                                ],
                                // Tombol Deskripsi Produk
                                TextButton(
                                  onPressed: () {
                                    showDescriptionPopup(
                                      context,
                                      product.deskripsi,
                                      product.namaProduk,
                                    );
                                  },
                                  child: const Text(
                                    'Deskripsi Produk',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                uniqueSizes.map((size) {
                                  bool isSelected = selectedSize == size;

                                  // Check if there's stock for this size in the current color
                                  bool hasStock = false;
                                  if (selectedVariantIndex != null) {
                                    String currentColor =
                                        product
                                            .varian[selectedVariantIndex!]
                                            .warna;
                                    hasStock = product.varian.any(
                                      (v) =>
                                          v.ukuran == size &&
                                          v.warna == currentColor &&
                                          v.stok > 0,
                                    );
                                  }

                                  return GestureDetector(
                                    onTap:
                                        hasStock
                                            ? () {
                                              setState(() {
                                                selectedSize = size;
                                                if (selectedVariantIndex !=
                                                    null) {
                                                  String currentColor =
                                                      product
                                                          .varian[selectedVariantIndex!]
                                                          .warna;
                                                  int index = product.varian
                                                      .indexWhere(
                                                        (v) =>
                                                            v.ukuran == size &&
                                                            v.warna ==
                                                                currentColor,
                                                      );
                                                  if (index != -1) {
                                                    selectedVariantIndex =
                                                        index;
                                                    // Reset quantity when size changes
                                                    jumlahOrder = 1;
                                                  }
                                                }
                                              });
                                            }
                                            : null,
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? Colors.black
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              hasStock
                                                  ? (isSelected
                                                      ? Colors.black
                                                      : Colors.grey.shade300)
                                                  : Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          size.toString(),
                                          style: TextStyle(
                                            color:
                                                isSelected
                                                    ? Colors.white
                                                    : (hasStock
                                                        ? Colors.black
                                                        : Colors.grey.shade400),
                                            fontWeight: FontWeight.bold,
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
                  ),

                  const SizedBox(height: 24),

                  // Quantity Selector
                  if (currentStock > 0) ...[
                    buildQuantitySelector(currentStock),
                    const SizedBox(height: 24),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: Colors.red.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Stok habis untuk varian ini',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Chat Button
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              showChatWithAdmin(context);
                            },
                            icon: Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              shareToWhatsApp(
                                product.namaProduk,
                                formatPrice(product.hargaAwal),
                                formatPrice(product.harga),
                              );
                            },
                            icon: const Icon(Icons.share, color: Colors.green),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Add to Cart Button
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed:
                                  currentStock > 0 && !isAddingToCart
                                      ? handleAddToCart
                                      : null,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color:
                                      currentStock > 0
                                          ? Colors.black
                                          : Colors.grey.shade300,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor:
                                    currentStock > 0
                                        ? Colors.white
                                        : Colors.grey.shade100,
                              ),
                              child:
                                  isAddingToCart
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.black,
                                        ),
                                      )
                                      : Text(
                                        currentStock > 0
                                            ? 'Tambah ke Keranjang'
                                            : 'Stok Habis',
                                        style: TextStyle(
                                          color:
                                              currentStock > 0
                                                  ? Colors.black
                                                  : Colors.grey.shade500,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
