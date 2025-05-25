import 'package:flutter/material.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:toastification/toastification.dart';

const String baseUrl = "http://192.168.1.96:3000/uploads/";

class KeranjangPembeli extends StatefulWidget {
  const KeranjangPembeli({super.key});

  @override
  State<KeranjangPembeli> createState() => _KeranjangPembeliState();
}

class _KeranjangPembeliState extends State<KeranjangPembeli> {
  List<GetDataKeranjang> keranjangItems = [];
  bool isLoading = true;
  double totalHarga = 0.0;
  double totalDiskon = 0.0;
  double totalHargaAwal = 0.0;

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
    loadKeranjangData();
  }

  Future<void> loadKeranjangData() async {
    try {
      List<GetDataKeranjang> data = await GetDataKeranjang.getDataKeranjang();
      setState(() {
        keranjangItems = data;
        isLoading = false;
        calculateTotal();
      });
    } catch (e) {
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

  void calculateTotal() {
    double total = 0;
    double totalDiskonAmount = 0;

    for (var item in keranjangItems) {
      double hargaSatuan = double.tryParse(item.hargaSatuan) ?? 0;
      double hargaAwal = double.tryParse(item.hargaAwal) ?? 0;
      int jumlah = int.tryParse(item.jumlah_order) ?? 0;

      total += hargaSatuan * jumlah;

      // Calculate discount amount per item
      double diskonPerItem = (hargaAwal - hargaSatuan) * jumlah;
      totalDiskonAmount += diskonPerItem;
    }

    setState(() {
      totalHarga = total;
      totalDiskon = totalDiskonAmount;
    });
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

      // Call delete API
      await HapusKeranjang.hapusKeranjang(item.id_varian_produk);

      // Close loading dialog
      Navigator.of(context).pop();

      // Update UI
      setState(() {
        keranjangItems.removeAt(index);
        calculateTotal();
      });

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

      toastification.show(
        context: context,
        title: Text('Gagal menghapus produk: $e'),
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Keranjang",
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
              : keranjangItems.isEmpty
              ? Center(
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
                      "Keranjang Anda kosong",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Yuk mulai belanja sekarang!",
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Cart Items Count
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    color: Colors.grey[50],
                    child: Text(
                      "${keranjangItems.length} item dalam keranjang",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: keranjangItems.length,
                      itemBuilder: (context, index) {
                        final item = keranjangItems[index];
                        double hargaSatuan =
                            double.tryParse(item.hargaSatuan) ?? 0;
                        double hargaAwal = double.tryParse(item.hargaAwal) ?? 0;
                        int jumlah = int.tryParse(item.jumlah_order) ?? 0;
                        double diskonPersen =
                            hargaAwal > 0
                                ? ((hargaAwal - hargaSatuan) / hargaAwal) * 100
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
                                    baseUrl + item.linkGambar,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${item.nama_produk}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                  height: 1.3,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
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
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap:
                                              () =>
                                                  showDeleteConfirmation(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ],
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
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
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
                                            padding: const EdgeInsets.symmetric(
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
                  // Bottom Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (totalDiskon > 0) ...[
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
                              Text(
                                "-${formatRupiah(totalDiskon)}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "(${totalHargaAwal > 0 ? ((totalDiskon / totalHargaAwal) * 100).toStringAsFixed(1) : '0'}%)",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
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
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle checkout
                              toastification.show(
                                context: context,
                                title: Text(
                                  'Checkout dengan total ${formatRupiah(totalHarga)}',
                                ),
                                type: ToastificationType.success,
                                style: ToastificationStyle.fillColored,
                                autoCloseDuration: const Duration(seconds: 3),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Checkout - ${formatRupiah(totalHarga)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
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
  }
}
