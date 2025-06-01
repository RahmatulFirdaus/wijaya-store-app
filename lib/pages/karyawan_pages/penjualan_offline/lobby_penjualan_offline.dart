import 'package:flutter/material.dart';
import 'package:frontend/models/karyawan_model.dart';
import 'package:frontend/pages/karyawan_pages/penjualan_offline/main_tambah_penjualan_offline.dart';
import 'package:toastification/toastification.dart';

class LobbyPenjualanOffline extends StatefulWidget {
  const LobbyPenjualanOffline({super.key});

  @override
  State<LobbyPenjualanOffline> createState() => _LobbyPenjualanOfflineState();
}

class _LobbyPenjualanOfflineState extends State<LobbyPenjualanOffline>
    with TickerProviderStateMixin {
  final String baseUrl = "http://192.168.1.96:3000/uploads/";
  List<PenjualanOfflineKaryawan> penjualanList = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedDateFilter = 'all'; // all, today, week, month, custom
  DateTimeRange? customDateRange;
  final TextEditingController searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    loadData();
  }

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final data = await PenjualanOfflineKaryawan.getDataPenjualanOffline();
      setState(() {
        penjualanList = data;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error loading data: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  DateTime _parseDate(String dateString) {
    try {
      // Assuming the date format is DD/MM/YYYY or similar
      final parts = dateString.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      }
      // If parsing fails, return current date
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  List<PenjualanOfflineKaryawan> get filteredPenjualanList {
    List<PenjualanOfflineKaryawan> filtered = penjualanList;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered.where((item) {
            return item.namaProduk.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                item.namaKaryawan.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                item.warnaProduk.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                item.ukuranProduk.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
          }).toList();
    }

    // Apply date filter
    final now = DateTime.now();
    filtered =
        filtered.where((item) {
          final itemDate = _parseDate(item.tanggalPenjualan);

          switch (selectedDateFilter) {
            case 'today':
              return itemDate.year == now.year &&
                  itemDate.month == now.month &&
                  itemDate.day == now.day;
            case 'week':
              final weekStart = now.subtract(Duration(days: now.weekday - 1));
              final weekEnd = weekStart.add(const Duration(days: 6));
              return itemDate.isAfter(
                    weekStart.subtract(const Duration(days: 1)),
                  ) &&
                  itemDate.isBefore(weekEnd.add(const Duration(days: 1)));
            case 'month':
              return itemDate.year == now.year && itemDate.month == now.month;
            case 'custom':
              if (customDateRange != null) {
                return itemDate.isAfter(
                      customDateRange!.start.subtract(const Duration(days: 1)),
                    ) &&
                    itemDate.isBefore(
                      customDateRange!.end.add(const Duration(days: 1)),
                    );
              }
              return true;
            default:
              return true;
          }
        }).toList();

    return filtered;
  }

  Map<String, List<PenjualanOfflineKaryawan>> get groupedByDate {
    final filtered = filteredPenjualanList;
    final Map<String, List<PenjualanOfflineKaryawan>> grouped = {};

    for (final item in filtered) {
      if (grouped[item.tanggalPenjualan] == null) {
        grouped[item.tanggalPenjualan] = [];
      }
      grouped[item.tanggalPenjualan]!.add(item);
    }

    // Sort by date (most recent first)
    final sortedKeys =
        grouped.keys.toList()..sort((a, b) {
          final dateA = _parseDate(a);
          final dateB = _parseDate(b);
          return dateB.compareTo(dateA);
        });

    final Map<String, List<PenjualanOfflineKaryawan>> sortedGrouped = {};
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  int _calculateTotalForDate(List<PenjualanOfflineKaryawan> items) {
    return items.fold(0, (total, item) {
      try {
        final price = int.parse(item.hargaProduk);
        final quantity = int.parse(item.jumlahProduk);
        return total + (price * quantity);
      } catch (e) {
        return total;
      }
    });
  }

  void _showDateFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.date_range,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Filter Tanggal',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDateFilterOption('Semua Tanggal', 'all'),
              _buildDateFilterOption('Hari Ini', 'today'),
              _buildDateFilterOption('Minggu Ini', 'week'),
              _buildDateFilterOption('Bulan Ini', 'month'),
              _buildDateFilterOption('Rentang Kustom', 'custom'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Tutup',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateFilterOption(String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight:
              selectedDateFilter == value ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      leading: Radio<String>(
        value: value,
        groupValue: selectedDateFilter,
        onChanged: (String? newValue) async {
          if (newValue == 'custom') {
            Navigator.of(context).pop();
            final DateTimeRange? picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDateRange: customDateRange,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(
                      context,
                    ).colorScheme.copyWith(primary: Colors.black),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                customDateRange = picked;
                selectedDateFilter = 'custom';
              });
            }
          } else {
            setState(() {
              selectedDateFilter = newValue!;
            });
            Navigator.of(context).pop();
          }
        },
        activeColor: Colors.black,
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning_amber,
                  color: Colors.red.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Konfirmasi Hapus',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus item ini? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(fontSize: 16, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  penjualanList.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Item berhasil dihapus'),
                      ],
                    ),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _getDateFilterLabel() {
    switch (selectedDateFilter) {
      case 'today':
        return 'Hari Ini';
      case 'week':
        return 'Minggu Ini';
      case 'month':
        return 'Bulan Ini';
      case 'custom':
        if (customDateRange != null) {
          return '${customDateRange!.start.day}/${customDateRange!.start.month}/${customDateRange!.start.year} - ${customDateRange!.end.day}/${customDateRange!.end.month}/${customDateRange!.end.year}';
        }
        return 'Rentang Kustom';
      default:
        return 'Semua';
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = groupedByDate;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 18,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Penjualan Offline',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.black, Color(0xFF333333)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainTambahPenjualanOffline(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced Search Bar
          Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Cari produk, karyawan, atau varian...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
                suffixIcon:
                    searchQuery.isNotEmpty
                        ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              searchQuery = '';
                            });
                          },
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),

          // Date Filter Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _showDateFilterDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              selectedDateFilter != 'all'
                                  ? Colors.black
                                  : Colors.grey.shade300,
                          width: selectedDateFilter != 'all' ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            color:
                                selectedDateFilter != 'all'
                                    ? Colors.black
                                    : Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getDateFilterLabel(),
                              style: TextStyle(
                                color:
                                    selectedDateFilter != 'all'
                                        ? Colors.black
                                        : Colors.grey.shade600,
                                fontWeight:
                                    selectedDateFilter != 'all'
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color:
                                selectedDateFilter != 'all'
                                    ? Colors.black
                                    : Colors.grey.shade600,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results Counter
          if (filteredPenjualanList.isNotEmpty && !isLoading)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${filteredPenjualanList.length} item${filteredPenjualanList.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (searchQuery.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      'untuk "${searchQuery}"',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Content
          Expanded(
            child:
                isLoading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Memuat data penjualan...',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : groupedData.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              searchQuery.isNotEmpty ||
                                      selectedDateFilter != 'all'
                                  ? Icons.search_off
                                  : Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            searchQuery.isNotEmpty ||
                                    selectedDateFilter != 'all'
                                ? 'Tidak ada hasil untuk filter ini'
                                : 'Belum ada data penjualan offline',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            searchQuery.isNotEmpty ||
                                    selectedDateFilter != 'all'
                                ? 'Coba ubah filter atau kata kunci pencarian'
                                : 'Data akan muncul setelah ada transaksi',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                    : FadeTransition(
                      opacity: _fadeAnimation,
                      child: RefreshIndicator(
                        onRefresh: loadData,
                        color: Colors.black,
                        backgroundColor: Colors.white,
                        strokeWidth: 3,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          itemCount: groupedData.length,
                          itemBuilder: (context, dateIndex) {
                            final date = groupedData.keys.elementAt(dateIndex);
                            final items = groupedData[date]!;
                            final totalAmount = _calculateTotalForDate(items);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date Header with Total
                                Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 12,
                                    top: 16,
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.black, Color(0xFF333333)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            date,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${items.length} item${items.length > 1 ? 's' : ''}',
                                            style: TextStyle(
                                              color: Colors.grey.shade300,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            _formatCurrency(totalAmount),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Items for this date
                                ...items.asMap().entries.map((entry) {
                                  final itemIndex = entry.key;
                                  final item = entry.value;
                                  final globalIndex = penjualanList.indexOf(
                                    item,
                                  );

                                  return AnimatedContainer(
                                    duration: Duration(
                                      milliseconds: 300 + (itemIndex * 50),
                                    ),
                                    curve: Curves.easeOutQuart,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.06,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Enhanced Product Image
                                            Hero(
                                              tag: 'product_${globalIndex}',
                                              child: Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.grey.shade50,
                                                      Colors.grey.shade100,
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: Colors.grey.shade200,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  child:
                                                      item
                                                              .gambarProduk
                                                              .isNotEmpty
                                                          ? Image.network(
                                                            baseUrl +
                                                                item.gambarProduk,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Container(
                                                                decoration: BoxDecoration(
                                                                  gradient: LinearGradient(
                                                                    colors: [
                                                                      Colors
                                                                          .grey
                                                                          .shade100,
                                                                      Colors
                                                                          .grey
                                                                          .shade200,
                                                                    ],
                                                                    begin:
                                                                        Alignment
                                                                            .topLeft,
                                                                    end:
                                                                        Alignment
                                                                            .bottomRight,
                                                                  ),
                                                                ),
                                                                child: Icon(
                                                                  Icons
                                                                      .image_not_supported_outlined,
                                                                  color:
                                                                      Colors
                                                                          .grey
                                                                          .shade500,
                                                                  size: 32,
                                                                ),
                                                              );
                                                            },
                                                            loadingBuilder: (
                                                              context,
                                                              child,
                                                              loadingProgress,
                                                            ) {
                                                              if (loadingProgress ==
                                                                  null)
                                                                return child;
                                                              return Container(
                                                                decoration: BoxDecoration(
                                                                  gradient: LinearGradient(
                                                                    colors: [
                                                                      Colors
                                                                          .grey
                                                                          .shade100,
                                                                      Colors
                                                                          .grey
                                                                          .shade200,
                                                                    ],
                                                                    begin:
                                                                        Alignment
                                                                            .topLeft,
                                                                    end:
                                                                        Alignment
                                                                            .bottomRight,
                                                                  ),
                                                                ),
                                                                child: Center(
                                                                  child: SizedBox(
                                                                    width: 24,
                                                                    height: 24,
                                                                    child: CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
                                                                      valueColor: AlwaysStoppedAnimation<
                                                                        Color
                                                                      >(
                                                                        Colors
                                                                            .grey
                                                                            .shade400,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          )
                                                          : Container(
                                                            decoration: BoxDecoration(
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  Colors
                                                                      .grey
                                                                      .shade100,
                                                                  Colors
                                                                      .grey
                                                                      .shade200,
                                                                ],
                                                                begin:
                                                                    Alignment
                                                                        .topLeft,
                                                                end:
                                                                    Alignment
                                                                        .bottomRight,
                                                              ),
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .image_not_supported_outlined,
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade500,
                                                              size: 32,
                                                            ),
                                                          ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 16),

                                            // Enhanced Product Details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  _buildDetailRow(
                                                    'Nama Produk',
                                                    item.namaProduk,
                                                    Icons.local_offer_outlined,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _buildDetailRow(
                                                    'Spesifikasi',
                                                    '${item.warnaProduk} • ${item.ukuranProduk} • ${item.jumlahProduk} pcs',
                                                    Icons.tune_outlined,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _buildDetailRow(
                                                    'Harga',
                                                    _formatCurrency(
                                                      int.parse(
                                                        item.hargaProduk,
                                                      ),
                                                    ),
                                                    Icons.attach_money_outlined,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _buildDetailRow(
                                                    'Karyawan',
                                                    item.namaKaryawan,
                                                    Icons.person_outline,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _buildDetailRow(
                                                    'Subtotal',
                                                    _formatCurrency(
                                                      int.parse(
                                                            item.hargaProduk,
                                                          ) *
                                                          int.parse(
                                                            item.jumlahProduk,
                                                          ),
                                                    ),
                                                    Icons.receipt_outlined,
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(width: 12),

                                            // Enhanced Delete Button
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFFF4757),
                                                    Color(0xFFFF3742),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFFFF4757,
                                                    ).withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                            'Hapus Item',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          content: const Text(
                                                            'Apakah Anda yakin ingin menghapus item ini?',
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                  context,
                                                                ).pop();
                                                              },
                                                              child: const Text(
                                                                'Batal',
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () async {
                                                                try {
                                                                  await HapusProdukPenjualanOffline.hapusProdukPenjualanOffline(
                                                                    item.idPenjualanOffline,
                                                                  );

                                                                  toastification.show(
                                                                    context:
                                                                        context,
                                                                    title: const Text(
                                                                      'Produk berhasil dihapus',
                                                                    ),
                                                                    type:
                                                                        ToastificationType
                                                                            .success,
                                                                    style:
                                                                        ToastificationStyle
                                                                            .flat,
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomCenter,
                                                                    autoCloseDuration:
                                                                        const Duration(
                                                                          seconds:
                                                                              3,
                                                                        ),
                                                                  );

                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();

                                                                  // Refresh the data after deletion
                                                                  await loadData();
                                                                } catch (e) {
                                                                  toastification.show(
                                                                    context:
                                                                        context,
                                                                    title: Text(
                                                                      e.toString().replaceFirst(
                                                                        'Exception: ',
                                                                        '',
                                                                      ),
                                                                    ),
                                                                    type:
                                                                        ToastificationType
                                                                            .error,
                                                                    style:
                                                                        ToastificationStyle
                                                                            .flat,
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomCenter,
                                                                    autoCloseDuration:
                                                                        const Duration(
                                                                          seconds:
                                                                              4,
                                                                        ),
                                                                  );
                                                                }
                                                              },
                                                              child: const Text(
                                                                'Hapus',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },

                                                  child: Container(
                                                    width: 44,
                                                    height: 44,
                                                    alignment: Alignment.center,
                                                    child: const Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
