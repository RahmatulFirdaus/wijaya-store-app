import 'package:flutter/material.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:frontend/pages/pembeli_pages/list_chat_admin.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
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
                            )
                            : Image.network(
                              baseUrl + product.linkGambar,
                              fit: BoxFit.contain,
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
                                border: Border.all(color: Colors.red.shade200),
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
                                                  selectedVariantIndex = index;
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

                const SizedBox(height: 32),

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

                      // Add to Cart Button
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Keranjang',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Buy Now Button
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Beli Sekarang',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
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
    );
  }
}
