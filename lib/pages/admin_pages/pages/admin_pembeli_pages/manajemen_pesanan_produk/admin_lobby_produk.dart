import 'package:flutter/material.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/manajemen_pesanan_produk/admin_detail_lobby_produk.dart';

class AdminLobbyProduk extends StatefulWidget {
  final String idPengguna;
  const AdminLobbyProduk({super.key, required this.idPengguna});

  @override
  State<AdminLobbyProduk> createState() => _AdminLobbyProdukState();
}

class _AdminLobbyProdukState extends State<AdminLobbyProduk> {
  late Future<List<GetDataProduk>> _productsFuture;
  final TextEditingController _searchController = TextEditingController();

  // Categories
  List<String> categories = [
    "All",
    "Running Shoes",
    "Premium Shoes",
    "Sports",
    "Casual",
  ];

  // Sort options
  List<String> sortOptions = [
    "Default",
    "Harga: Terendah - Tertinggi",
    "Harga: Tertinggi - Terendah",
    "Rating: Terendah - Tertinggi",
    "Rating: Tertinggi - Terendah",
  ];

  String selectedCategory = "All";
  String selectedSort = "Default";
  String searchQuery = "";
  bool showFilters = false;

  @override
  void initState() {
    super.initState();
    _productsFuture = GetDataProduk.getDataProduk();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<GetDataProduk> _filterAndSortProducts(List<GetDataProduk> products) {
    List<GetDataProduk> filtered = products;

    // Filter by category
    if (selectedCategory != "All") {
      filtered =
          filtered
              .where(
                (p) =>
                    p.kategori_produk?.toLowerCase() ==
                    selectedCategory.toLowerCase(),
              )
              .toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (p) => p.nama_produk.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
              )
              .toList();
    }

    // Sort products
    switch (selectedSort) {
      case "Harga: Terendah - Tertinggi":
        filtered.sort((a, b) => a.harga.compareTo(b.harga));
        break;
      case "Harga: Tertinggi - Terendah":
        filtered.sort((a, b) => b.harga.compareTo(a.harga));
        break;
      case "Rating: Terendah - Tertinggi":
        filtered.sort((a, b) {
          double ratingA = double.tryParse(a.nilaiRating) ?? 0.0;
          double ratingB = double.tryParse(b.nilaiRating) ?? 0.0;
          return ratingA.compareTo(ratingB);
        });
        break;
      case "Rating: Tertinggi - Terendah":
        filtered.sort((a, b) {
          double ratingA = double.tryParse(a.nilaiRating) ?? 0.0;
          double ratingB = double.tryParse(b.nilaiRating) ?? 0.0;
          return ratingB.compareTo(ratingA);
        });
        break;
      default:
        // Keep original order
        break;
    }

    return filtered;
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue[800] : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
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
        title: const Text(
          "WIJAYA STORE",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(
              showFilters ? Icons.filter_list : Icons.filter_list_outlined,
              color: showFilters ? Colors.blue : Colors.grey[600],
            ),
            onPressed: () {
              setState(() {
                showFilters = !showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Apa yang kamu cari?",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Products Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "PRODUCTS",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (selectedSort != "Default")
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      selectedSort,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Categories Filter
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildFilterChip(
                  categories[index],
                  selectedCategory == categories[index],
                  () {
                    setState(() {
                      selectedCategory = categories[index];
                    });
                  },
                );
              },
            ),
          ),

          // Sort Filter (when filter button is pressed)
          if (showFilters) ...[
            const SizedBox(height: 12),
            Container(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: sortOptions.length,
                itemBuilder: (context, index) {
                  return _buildFilterChip(
                    sortOptions[index],
                    selectedSort == sortOptions[index],
                    () {
                      setState(() {
                        selectedSort = sortOptions[index];
                      });
                    },
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Product Grid
          Expanded(
            child: FutureBuilder<List<GetDataProduk>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 40,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 10),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _productsFuture = GetDataProduk.getDataProduk();
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada produk tersedia'));
                } else {
                  final filteredProducts = _filterAndSortProducts(
                    snapshot.data!,
                  );
                  if (filteredProducts.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada produk tersedia'),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 0,
                      bottom: 100,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.58,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        idPengguna:
                            widget.idPengguna, // Pass the idPengguna here
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final GetDataProduk product;
  final String idPengguna; // Add this parameter

  const ProductCard({
    super.key,
    required this.product,
    required this.idPengguna, // Add this parameter
  });

  final String baseUrl = "http://192.168.1.96:3000/uploads/";

  Widget _buildRatingWidget() {
    double? rating = double.tryParse(product.nilaiRating);

    if (rating == null || rating == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'No rating',
          style: TextStyle(fontSize: 9, color: Colors.grey),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 10, color: Colors.orange[600]),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 9,
              color: Colors.orange[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => AdminDetailLobbyProduk(
                  productId: product.id,
                  idPengguna:
                      idPengguna, // Now correctly using the passed parameter
                ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    child: Image.network(
                      baseUrl + product.link_gambar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 30),
                          ),
                        );
                      },
                    ),
                  ),
                  // Discount badge
                  if (product.harga_awal != null &&
                      product.harga_awal > product.harga)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${(((product.harga_awal - product.harga) / product.harga_awal) * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product Details
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name and Rating
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.nama_produk,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        _buildRatingWidget(),
                      ],
                    ),

                    // Price and Stock
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price
                        if (product.harga_awal != null &&
                            product.harga_awal > product.harga)
                          Text(
                            'Rp ${product.harga_awal}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          'Rp ${product.harga}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Stock
                        Text(
                          'Stok: ${product.stok}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
