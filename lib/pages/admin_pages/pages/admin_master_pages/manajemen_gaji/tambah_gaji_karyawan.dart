import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/admin_model.dart';

class TambahGajiKaryawan extends StatefulWidget {
  const TambahGajiKaryawan({super.key});

  @override
  State<TambahGajiKaryawan> createState() => _TambahGajiKaryawanState();
}

class _TambahGajiKaryawanState extends State<TambahGajiKaryawan>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _jumlahGajiController = TextEditingController();
  final _searchController = TextEditingController();

  bool isLoading = false;
  bool isLoadingKaryawan = false;
  List<PenggunaKaryawan> karyawanList = [];
  List<PenggunaKaryawan> filteredKaryawanList = [];
  PenggunaKaryawan? selectedKaryawan;
  bool showDropdown = false;

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    loadKaryawan();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _jumlahGajiController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadKaryawan() async {
    setState(() {
      isLoadingKaryawan = true;
    });

    try {
      final karyawan = await PenggunaKaryawan.fetchPenggunaKaryawan();
      setState(() {
        karyawanList = karyawan;
        filteredKaryawanList = karyawan;
        isLoadingKaryawan = false;
      });
    } catch (e) {
      setState(() {
        isLoadingKaryawan = false;
      });
      _showSnackBar(
        'Gagal memuat data karyawan: ${e.toString()}',
        isError: true,
      );
    }
  }

  void filterKaryawan(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredKaryawanList = karyawanList;
      } else {
        filteredKaryawanList =
            karyawanList
                .where(
                  (karyawan) =>
                      karyawan.nama.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      karyawan.id.toString().contains(query),
                )
                .toList();
      }
    });
  }

  void selectKaryawan(PenggunaKaryawan karyawan) {
    setState(() {
      selectedKaryawan = karyawan;
      _searchController.text = '${karyawan.nama} (ID: ${karyawan.id})';
      showDropdown = false;
    });
  }

  String formatCurrency(String value) {
    if (value.isEmpty) return '';
    String digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return '';
    String formatted = digits.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return 'Rp $formatted';
  }

  int parseCurrency(String value) {
    return int.tryParse(value.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[800] : Colors.green[800],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
    );
  }

  Future<void> simpanGaji() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedKaryawan == null) {
      _showSnackBar('Pilih karyawan terlebih dahulu', isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final gaji = GajiKaryawan(
        id: 0,
        idPengguna: selectedKaryawan!.id,
        jumlahGaji: parseCurrency(_jumlahGajiController.text),
      );

      final response = await GajiKaryawanService.tambahGajiKaryawan(gaji);

      if (response.success) {
        _showSnackBar(response.message);
        Navigator.of(context).pop(true);
      } else {
        _showSnackBar(response.message, isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            setState(() {
              showDropdown = false;
            });
            // Hide keyboard
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              // Fixed Header
              _buildHeader(),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - _slideAnimation.value)),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildMainCard(),
                                  const SizedBox(height: 20),
                                  _buildSaveButton(),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 18,
              ),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Gaji',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[900],
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Karyawan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[900],
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.payments_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Form Gaji',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[900],
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Tambahkan gaji untuk karyawan',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Pilih Karyawan Section
            _buildSectionTitle('Pilih Karyawan'),
            const SizedBox(height: 10),
            _buildKaryawanSelector(),
            const SizedBox(height: 24),

            // Jumlah Gaji Section
            _buildSectionTitle('Jumlah Gaji'),
            const SizedBox(height: 10),
            _buildGajiInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
        letterSpacing: -0.1,
      ),
    );
  }

  Widget _buildKaryawanSelector() {
    return Column(
      children: [
        // Main Input
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: showDropdown ? Colors.grey[900]! : Colors.grey[300]!,
              width: showDropdown ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            onTap:
                isLoadingKaryawan
                    ? null
                    : () {
                      setState(() {
                        showDropdown = !showDropdown;
                      });
                    },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.person_search_outlined,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedKaryawan != null
                          ? '${selectedKaryawan!.nama} (ID: ${selectedKaryawan!.id})'
                          : isLoadingKaryawan
                          ? 'Memuat data karyawan...'
                          : 'Pilih karyawan...',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            selectedKaryawan != null
                                ? FontWeight.w500
                                : FontWeight.w400,
                        color:
                            selectedKaryawan != null
                                ? Colors.grey[900]
                                : Colors.grey[500],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AnimatedRotation(
                    turns: showDropdown ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Dropdown
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: showDropdown && !isLoadingKaryawan ? 240 : 0,
          child: ClipRect(
            child:
                showDropdown && !isLoadingKaryawan
                    ? Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Search Field
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[200]!),
                              ),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Cari karyawan...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  size: 18,
                                  color: Colors.grey[600],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[700]!,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                isDense: true,
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              onChanged: filterKaryawan,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),

                          // List
                          Expanded(
                            child:
                                filteredKaryawanList.isEmpty
                                    ? Center(
                                      child: Text(
                                        'Tidak ada karyawan ditemukan',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                    : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      itemCount: filteredKaryawanList.length,
                                      itemBuilder: (context, index) {
                                        final karyawan =
                                            filteredKaryawanList[index];
                                        final isSelected =
                                            selectedKaryawan?.id == karyawan.id;

                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? Colors.grey[900]
                                                    : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: ListTile(
                                            dense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 4,
                                                ),
                                            leading: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color:
                                                    isSelected
                                                        ? Colors.white
                                                        : Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  karyawan.nama.isNotEmpty
                                                      ? karyawan.nama[0]
                                                          .toUpperCase()
                                                      : 'K',
                                                  style: TextStyle(
                                                    color:
                                                        isSelected
                                                            ? Colors.grey[900]
                                                            : Colors.grey[700],
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              karyawan.nama,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    isSelected
                                                        ? Colors.white
                                                        : Colors.grey[900],
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: Text(
                                              'ID: ${karyawan.id}',
                                              style: TextStyle(
                                                color:
                                                    isSelected
                                                        ? Colors.grey[300]
                                                        : Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                            onTap:
                                                () => selectKaryawan(karyawan),
                                          ),
                                        );
                                      },
                                    ),
                          ),
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ),

        // Validation Error
        if (selectedKaryawan == null)
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              'Pilih karyawan terlebih dahulu',
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGajiInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: _jumlahGajiController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Masukkan jumlah gaji',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(16),
            child: Icon(Icons.attach_money, color: Colors.grey[600], size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: (value) {
          String formatted = formatCurrency(value);
          if (formatted != _jumlahGajiController.text) {
            _jumlahGajiController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Jumlah gaji tidak boleh kosong';
          }
          int amount = parseCurrency(value);
          if (amount <= 0) {
            return 'Jumlah gaji harus lebih dari 0';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors:
              (isLoading || isLoadingKaryawan)
                  ? [Colors.grey[400]!, Colors.grey[400]!]
                  : [Colors.grey[900]!, Colors.grey[800]!],
        ),
        boxShadow:
            (isLoading || isLoadingKaryawan)
                ? []
                : [
                  BoxShadow(
                    color: Colors.grey[900]!.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
      ),
      child: ElevatedButton(
        onPressed: (isLoading || isLoadingKaryawan) ? null : simpanGaji,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
                  'Simpan Data',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.1,
                  ),
                ),
      ),
    );
  }
}
