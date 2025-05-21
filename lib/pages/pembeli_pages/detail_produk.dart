import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:http/http.dart' as http;

const String baseUrl = "http://192.168.1.96:3000/uploads/";

class DetailProduk extends StatefulWidget {
  final String productId;

  const DetailProduk({super.key, required this.productId});

  @override
  State<DetailProduk> createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
  late Future<GetDataDetailProduk> futureProductDetail;
  int? selectedVariantIndex;
  int? selectedSize;

  @override
  void initState() {
    super.initState();
    futureProductDetail = GetDataDetailProduk.getDataDetailProduk(
      widget.productId,
    );
  }

  // Get unique sizes from all variants
  List<int> getUniqueSizes(List<Varian> variants) {
    final Set<int> sizes = {};
    for (var variant in variants) {
      sizes.add(variant.ukuran);
    }
    return sizes.toList()..sort();
  }

  // Format price with separator
  String formatPrice(String price) {
    try {
      double priceValue = double.parse(price);
      return '\$${priceValue.toStringAsFixed(2)}';
    } catch (e) {
      return price;
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<GetDataDetailProduk>(
        future: futureProductDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
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

          // Calculate discount
          final originalPrice = '\$254.00'; // Hardcoded for the example

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white),
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
                // Color Variants
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children:
                        colorVariants.map((variant) {
                          bool isSelected =
                              selectedVariantIndex != null &&
                              product.varian[selectedVariantIndex!].warna ==
                                  variant.warna;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                // Find the first variant with this color
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
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Colors.orange
                                          : Colors.grey.shade300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  color: Colors.black,
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

                // Product Info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.namaProduk,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            ' 4.8 (335) · 212 reviews',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            formatPrice(product.harga),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            originalPrice,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
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
                            'Select Size',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Chart',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                                              // Find variant with selected color and size
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
                                    margin: const EdgeInsets.only(right: 10),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? Colors.orange
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color:
                                            hasStock
                                                ? (isSelected
                                                    ? Colors.orange
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
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
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
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Add to Cart Button
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Add to Cart',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Buy Now Button
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Buy Now',
                              style: TextStyle(fontWeight: FontWeight.bold),
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
