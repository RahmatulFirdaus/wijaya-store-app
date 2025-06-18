import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:frontend/pages/admin_pages/pages/admin_pembeli_pages/manajemen_pesanan_produk/admin_lobby_produk.dart';
import 'package:toastification/toastification.dart';

const String baseUrl = "http://192.168.1.96:3000/uploads/";

class ManajemenPesananProduk extends StatefulWidget {
  const ManajemenPesananProduk({super.key});

  @override
  State<ManajemenPesananProduk> createState() => _ManajemenPesananProdukState();
}

class _ManajemenPesananProdukState extends State<ManajemenPesananProduk> {
  List<KeranjangItem> keranjangItems = [];
  List<PenggunaPembeli> penggunaList = [];
  List<PenggunaPembeli> filteredPenggunaList = [];
  bool isLoading = true;
  bool isLoadingPengguna = false;
  double totalHarga = 0.0;
  double totalDiskon = 0.0;
  double totalHargaAwal = 0.0;

  PenggunaPembeli? selectedPengguna;
  TextEditingController searchController = TextEditingController();
  bool showDropdown = false;

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

  // Format double to string and then use formatPrice
  String formatRupiah(double amount) {
    return formatPrice(amount.toStringAsFixed(0));
  }

  @override
  void initState() {
    super.initState();
    loadPenggunaData();
    searchController.addListener(_filterPengguna);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterPengguna() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredPenggunaList =
          penggunaList
              .where((pengguna) => pengguna.nama.toLowerCase().contains(query))
              .toList();
    });
  }

  Future<void> loadPenggunaData() async {
    setState(() {
      isLoadingPengguna = true;
    });

    try {
      List<PenggunaPembeli> data = await PenggunaPembeli.fetchPenggunaPembeli();
      setState(() {
        penggunaList = data;
        filteredPenggunaList = data;
        isLoadingPengguna = false;
      });
    } catch (e) {
      setState(() {
        isLoadingPengguna = false;
      });
      toastification.show(
        context: context,
        title: Text('Error loading users: $e'),
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> loadKeranjangData(String idPengguna) async {
    setState(() {
      isLoading = true;
      keranjangItems = [];
      totalHarga = 0.0;
      totalDiskon = 0.0;
      totalHargaAwal = 0.0;
    });

    try {
      List<KeranjangItem> data = await KeranjangItem.fetchKeranjang(idPengguna);
      setState(() {
        keranjangItems = data;
        isLoading = false;
        calculateTotal();
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      toastification.show(
        context: context,
        title: Text('Error: $e'),
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> showDeleteConfirmation(int index) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Hapus Produk",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          content: const Text(
            "Apakah Anda yakin ingin menghapus produk ini dari keranjang?",
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: Text(
                "Tidak",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Ya, Hapus",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      removeItem(index);
    }
  }

  Future<void> removeItem(int index) async {
    final item = keranjangItems[index];

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        },
      );

      // Call delete API (hanya perlu id)
      await HapusKeranjang.hapusKeranjang(item.idItemOrder);

      // Close loading dialog
      Navigator.of(context).pop();

      // Update UI
      setState(() {
        keranjangItems.removeAt(index);
        calculateTotal();
      });

      // Success toast
      toastification.show(
        context: context,
        title: const Text('Produk berhasil dihapus dari keranjang'),
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 3),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Error toast
      toastification.show(
        context: context,
        title: Text('Gagal menghapus produk: $e'),
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 5),
      );
      print("Error removing item: $e");
    }
  }

  void calculateTotal() {
    double total = 0;
    double totalDiskonAmount = 0;
    double totalHargaAwalAmount = 0;

    for (var item in keranjangItems) {
      double hargaSatuan = item.hargaSatuan.toDouble();
      double hargaAwal = item.hargaAwal.toDouble();
      int jumlah = item.jumlah;

      total += hargaSatuan * jumlah;
      totalHargaAwalAmount += hargaAwal * jumlah;

      // Calculate discount amount per item
      double diskonPerItem = (hargaAwal - hargaSatuan) * jumlah;
      totalDiskonAmount += diskonPerItem;
    }

    setState(() {
      totalHarga = total;
      totalDiskon = totalDiskonAmount;
      totalHargaAwal = totalHargaAwalAmount;
    });
  }

  Widget _buildUserDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pilih Pengguna",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText:
                            selectedPengguna?.nama ??
                            "Cari dan pilih pengguna...",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        suffixIcon:
                            isLoadingPengguna
                                ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                                : IconButton(
                                  icon: Icon(
                                    showDropdown
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      showDropdown = !showDropdown;
                                    });
                                  },
                                ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          showDropdown = true;
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          showDropdown = true;
                        });
                      },
                    ),
                    if (showDropdown && filteredPenggunaList.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredPenggunaList.length,
                          itemBuilder: (context, index) {
                            final pengguna = filteredPenggunaList[index];
                            return ListTile(
                              title: Text(
                                pengguna.nama,
                                style: const TextStyle(fontSize: 14),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedPengguna = pengguna;
                                  searchController.text = pengguna.nama;
                                  showDropdown = false;
                                });
                                loadKeranjangData(pengguna.id.toString());
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manajemen Keranjang",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed:
                selectedPengguna != null
                    ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AdminLobbyProduk(
                                idPengguna: selectedPengguna!.id.toString(),
                              ),
                        ),
                      );
                    }
                    : null, // Disable button if no user is selected
            icon: Icon(Icons.add),
            color: selectedPengguna != null ? Colors.black : Colors.grey,
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildUserDropdown(),
          if (selectedPengguna != null) ...[
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                ),
              )
            else if (keranjangItems.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Keranjang kosong",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Pengguna ${selectedPengguna!.nama} belum memiliki item di keranjang",
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    // Cart Items Count
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      color: Colors.white,
                      child: Text(
                        "${keranjangItems.length} item dalam keranjang ${selectedPengguna!.nama}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          20,
                          20,
                          100,
                        ), // Added bottom padding
                        itemCount: keranjangItems.length,
                        itemBuilder: (context, index) {
                          final item = keranjangItems[index];
                          double hargaSatuan = item.hargaSatuan.toDouble();
                          double hargaAwal = item.hargaAwal.toDouble();
                          int jumlah = item.jumlah;
                          double diskonPersen =
                              hargaAwal > 0
                                  ? ((hargaAwal - hargaSatuan) / hargaAwal) *
                                      100
                                  : 0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  spreadRadius: 0,
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[100],
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      baseUrl + item.linkGambarVarian,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          color: Colors.grey[100],
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            color: Colors.grey[400],
                                            size: 32,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.namaProduk,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                                height: 1.3,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Delete Button
                                          GestureDetector(
                                            onTap:
                                                () => showDeleteConfirmation(
                                                  index,
                                                ),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.red[50],
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Colors.red[200]!,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.delete_outline,
                                                color: Colors.red[600],
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${item.warna} • ${item.ukuran}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              "Qty: $jumlah",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (diskonPersen > 0) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.red[50],
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Colors.red[200]!,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                "-${diskonPersen.toStringAsFixed(0)}%",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red[700],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          if (diskonPersen > 0) ...[
                                            Text(
                                              formatPrice(
                                                hargaAwal.toStringAsFixed(0),
                                              ),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          Text(
                                            formatPrice(
                                              hargaSatuan.toStringAsFixed(0),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
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
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ] else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Pilih pengguna untuk melihat keranjang",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      // Summary in bottom navigation bar
      bottomNavigationBar:
          selectedPengguna != null && keranjangItems.isNotEmpty
              ? Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).padding.bottom + 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Show user info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Colors.grey[600], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Keranjang: ${selectedPengguna!.nama}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Total Harga Awal (show only if there's discount)
                    if (totalDiskon > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Harga Awal",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            formatRupiah(totalHargaAwal),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Total Diskon with percentage
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Diskon",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "-${formatRupiah(totalDiskon)}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[600],
                                ),
                              ),
                              Text(
                                "(${totalHargaAwal > 0 ? ((totalDiskon / totalHargaAwal) * 100).toStringAsFixed(1) : '0'}%)",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Total Pembayaran
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Pembayaran",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          formatRupiah(totalHarga),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 54),
                  ],
                ),
              )
              : null,
    );
  }
}
