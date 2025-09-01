import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/daftar_produk/edit_produk_page.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/daftar_produk/tambah_produk_page.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DaftarProdukPage extends StatefulWidget {
  const DaftarProdukPage({super.key});

  @override
  State<DaftarProdukPage> createState() => _DaftarProdukPageState();
}

class _DaftarProdukPageState extends State<DaftarProdukPage> {
  late Future<List<GetDataProduk>> _productsFuture;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  String selectedCategory = "Semua"; // Default semua kategori
  List<String> categories = ["Semua"]; // List kategori yang tersedia

  @override
  void initState() {
    super.initState();
    _productsFuture = GetDataProduk.getDataProduk();
    _searchController.addListener(_onSearchChanged);
    _loadCategories();
  }

  void _loadCategories() async {
    try {
      final products = await GetDataProduk.getDataProduk();
      final categorySet = products.map((p) => p.kategori_produk).toSet();
      setState(() {
        categories = ["Semua", ...categorySet.toList()];
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
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

    // Filter berdasarkan kategori
    if (selectedCategory != "Semua") {
      filtered =
          filtered.where((p) => p.kategori_produk == selectedCategory).toList();
    }

    // Filter berdasarkan search query
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

  void _refreshProducts() {
    setState(() {
      _productsFuture = GetDataProduk.getDataProduk();
    });
  }

  void _showDeleteConfirmDialog(BuildContext context, GetDataProduk product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus produk "${product.nama_produk}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(product);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(GetDataProduk product) async {
    try {
      await HapusPRodukService.hapusProduk(product.id.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk "${product.nama_produk}" berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      _refreshProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus produk: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> generateAllProductPDF(
    BuildContext context, {
    String? kategori,
  }) async {
    try {
      final pdf = pw.Document();

      // GANTI dengan GetDataProduk untuk mendapatkan kategori
      final allProducts = await GetDataProduk.getDataProduk();
      final produkList = await Produk.getDataSemuaProduk();

      // FILTER BERDASARKAN KATEGORI menggunakan GetDataProduk
      List<String> allowedProductNames = [];
      if (kategori != null && kategori != "Semua") {
        allowedProductNames =
            allProducts
                .where((p) => p.kategori_produk == kategori)
                .map((p) => p.nama_produk)
                .toList();
      }

      // Filter produk detail berdasarkan nama produk yang diizinkan
      List<Produk> filteredProduk = produkList;
      if (kategori != null && kategori != "Semua") {
        filteredProduk =
            produkList
                .where((p) => allowedProductNames.contains(p.namaProduk))
                .toList();
      }

      // Update title berdasarkan kategori
      String title =
          kategori == null || kategori == "Semua"
              ? 'LAPORAN DATA SEMUA PRODUK'
              : 'LAPORAN DATA PRODUK - ${kategori.toUpperCase()}';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            List<pw.Widget> content = [];

            // Header
            content.add(
              pw.Text(
                title,
                style: const pw.TextStyle(fontSize: 20),
                textAlign: pw.TextAlign.center,
              ),
            );
            content.add(pw.SizedBox(height: 20));
            content.add(pw.Divider(thickness: 2));
            content.add(pw.SizedBox(height: 20));

            // Loop untuk setiap produk - GANTI produkList dengan filteredProduk
            for (int i = 0; i < filteredProduk.length; i++) {
              final produk = filteredProduk[i];

              content.add(
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    border: pw.Border.all(color: PdfColors.black),
                  ),
                  child: pw.Text(
                    '${i + 1}. ${produk.namaProduk}',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                ),
              );
              content.add(pw.SizedBox(height: 8));

              content.add(pw.Text('Deskripsi: ${produk.deskripsi}'));
              content.add(pw.SizedBox(height: 4));

              content.add(pw.Text('Harga: ${produk.harga}'));
              content.add(pw.SizedBox(height: 8));

              content.add(
                pw.Text(
                  'Varian Produk:',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              );
              content.add(pw.SizedBox(height: 4));

              // Tabel Varian - code tetap sama
              content.add(
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    // Header tabel
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey100,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Ukuran'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Warna'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Stok'),
                        ),
                      ],
                    ),
                    // Data varian
                    ...produk.varian.map((varian) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(varian.ukuran.toString()),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(varian.warna),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(varian.stok.toString()),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              );

              content.add(pw.SizedBox(height: 20));

              // Divider antar produk
              if (i < filteredProduk.length - 1) {
                content.add(pw.Divider());
                content.add(pw.SizedBox(height: 15));
              }
            }

            // Footer
            content.add(pw.Spacer());
            content.add(pw.Divider());
            content.add(pw.SizedBox(height: 8));
            content.add(
              pw.Text(
                'Dibuat pada: ${DateTime.now().toString().split('.')[0]}',
                style: const pw.TextStyle(fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
            );

            return content;
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat PDF: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Daftar Produk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
                hintText: "Cari produk...",
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

          // TAMBAHKAN DROPDOWN KATEGORI DI SINI
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  'Kategori: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text('Pilih Kategori'),
                      items:
                          categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue ?? "Semua";
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16), // Spacing
          // Products Section Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "DAFTAR PRODUK",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Arahkan ke halaman Tambah Produk
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TambahProdukPage(),
                          ),
                        ).then((_) => _refreshProducts());
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // GUNAKAN selectedCategory yang dipilih dari dropdown
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const AlertDialog(
                              content: Row(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(width: 20),
                                  Text("Membuat PDF..."),
                                ],
                              ),
                            );
                          },
                        );

                        try {
                          // Generate PDF dengan kategori yang dipilih dari dropdown
                          await generateAllProductPDF(
                            context,
                            kategori: selectedCategory,
                          );
                          Navigator.of(context).pop(); // Close loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'PDF kategori $selectedCategory berhasil dibuat!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          Navigator.of(context).pop(); // Close loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal membuat PDF: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: const Text('PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
                      child: Text('Tidak ada produk ditemukan'),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 100,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.55,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCardWithActions(
                        product: product,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => EditProdukPage(product: product),
                            ),
                          ).then((_) => _refreshProducts());
                        },
                        onDelete:
                            () => _showDeleteConfirmDialog(context, product),
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

class ProductCardWithActions extends StatelessWidget {
  final GetDataProduk product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCardWithActions({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final String baseUrl = "http://192.168.1.96:3000/uploads/";

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Image.network(
                  baseUrl + product.link_gambar,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 40),
                      ),
                    );
                  },
                ),
                // Action buttons overlay
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, size: 18),
                          color: Colors.blue,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, size: 18),
                          color: Colors.red,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product Details
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
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
                    const SizedBox(height: 4),
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
    );
  }
}
