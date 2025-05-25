import 'package:flutter/material.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:frontend/pages/pembeli_pages/detail_produk.dart';

class HomePembeli extends StatefulWidget {
  const HomePembeli({super.key});

  @override
  State<HomePembeli> createState() => _HomePembeliState();
}

class _HomePembeliState extends State<HomePembeli> {
  late Future<List<GetDataProduk>> _productsFuture;
  final TextEditingController _searchController = TextEditingController();
  List<String> categories = [
    "All",
    "Running Shoes",
    "Premium Shoes",
    "Sports",
    "Casual",
  ];
  String selectedCategory = "All";
  String searchQuery = "";

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

  List<GetDataProduk> _filterProducts(List<GetDataProduk> products) {
    List<GetDataProduk> filtered = products;
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
    return filtered;
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
        centerTitle: true, // Center the title
        backgroundColor: Colors.white,
        elevation: 0.5,
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

          // Featured Product Banner (bisa kamu update nanti)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        "assets/images/shoe.png",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 40),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Dapatkan tawaran menarik",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            "Murah dan berkualitas",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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

          // New Arrival Section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "PRODUCTS",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Categories
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(categories[index]),
                    selected: selectedCategory == categories[index],
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = categories[index];
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.blue[100],
                  ),
                );
              },
            ),
          ),

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
                  final filteredProducts = _filterProducts(snapshot.data!);
                  if (filteredProducts.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada produk tersedia'),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.6, // Diperbesar agar lebih tinggi
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(product: product);
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
  const ProductCard({super.key, required this.product});
  final String baseUrl = "http://192.168.1.96:3000/uploads/";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailProduk(productId: product.id),
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
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                baseUrl + product.link_gambar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 40),
                    ),
                  );
                },
              ),
            ),
            // Expanded section to prevent overflow
            Expanded(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.nama_produk,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            'Rp ${product.harga}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (product.harga_awal != null &&
                              product.harga_awal > product.harga)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-${(((product.harga_awal - product.harga) / product.harga_awal) * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        'Stok: ${product.stok}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
