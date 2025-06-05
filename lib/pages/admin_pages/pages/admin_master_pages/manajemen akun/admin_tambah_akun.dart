import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';

class AdminTambahAkun extends StatefulWidget {
  const AdminTambahAkun({super.key});

  @override
  State<AdminTambahAkun> createState() => _AdminTambahAkunState();
}

class _AdminTambahAkunState extends State<AdminTambahAkun> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _nomorTelpController = TextEditingController();

  String _selectedRole = 'Karyawan';
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _nomorTelpController.dispose();
    super.dispose();
  }

  Future<void> _tambahAkun() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await TambahAkunService.tambahAkun(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        nama: _namaController.text.trim(),
        email: _emailController.text.trim(),
        nomorTelp: _nomorTelpController.text.trim(),
        role: _selectedRole,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor:
                result.contains('Gagal') ? Colors.red : Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        if (!result.contains('Gagal')) {
          // Clear form on success
          _usernameController.clear();
          _passwordController.clear();
          _namaController.clear();
          _emailController.clear();
          _nomorTelpController.clear();
          setState(() {
            _selectedRole = 'Karyawan';
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Validasi username
  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username tidak boleh kosong';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 3) {
      return 'Username minimal 3 karakter';
    }

    if (trimmedValue.length > 20) {
      return 'Username maksimal 20 karakter';
    }

    // Cek apakah ada spasi
    if (trimmedValue.contains(' ')) {
      return 'Username tidak boleh mengandung spasi';
    }

    // Cek karakter yang diizinkan (huruf, angka, underscore, dash)
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(trimmedValue)) {
      return 'Username hanya boleh huruf, angka, underscore (_), dan dash (-)';
    }

    // Username harus dimulai dengan huruf
    if (!RegExp(r'^[a-zA-Z]').hasMatch(trimmedValue)) {
      return 'Username harus dimulai dengan huruf';
    }

    return null;
  }

  // Validasi password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }

    if (value.length > 50) {
      return 'Password maksimal 50 karakter';
    }

    // Cek apakah mengandung huruf besar
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 huruf besar';
    }

    // Cek apakah mengandung huruf kecil
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 huruf kecil';
    }

    // Cek apakah mengandung angka
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 angka';
    }

    // Cek apakah mengandung karakter khusus
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 karakter khusus';
    }

    return null;
  }

  // Validasi nama
  String? _validateNama(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'Nama minimal 2 karakter';
    }

    if (trimmedValue.length > 50) {
      return 'Nama maksimal 50 karakter';
    }

    // Cek apakah hanya mengandung huruf dan spasi
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmedValue)) {
      return 'Nama hanya boleh mengandung huruf dan spasi';
    }

    // Cek apakah tidak dimulai atau diakhiri dengan spasi
    if (trimmedValue != value) {
      return 'Nama tidak boleh dimulai atau diakhiri dengan spasi';
    }

    return null;
  }

  // Validasi email
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }

    final trimmedValue = value.trim();

    // Validasi format email yang lebih ketat
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(trimmedValue)) {
      return 'Format email tidak valid';
    }

    // Cek panjang email
    if (trimmedValue.length > 100) {
      return 'Email maksimal 100 karakter';
    }

    // Cek apakah domain email valid
    final parts = trimmedValue.split('@');
    if (parts.length != 2) {
      return 'Format email tidak valid';
    }

    final localPart = parts[0];
    final domainPart = parts[1];

    if (localPart.isEmpty || domainPart.isEmpty) {
      return 'Format email tidak valid';
    }

    if (localPart.length > 64) {
      return 'Bagian sebelum @ terlalu panjang';
    }

    return null;
  }

  // Validasi nomor telepon
  String? _validateNomorTelp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }

    final trimmedValue = value.trim();

    // Hapus semua karakter non-digit untuk validasi
    final digitsOnly = trimmedValue.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10) {
      return 'Nomor telepon minimal 10 digit';
    }

    if (digitsOnly.length > 15) {
      return 'Nomor telepon maksimal 15 digit';
    }

    // Cek format nomor telepon Indonesia
    if (!RegExp(r'^(\+62|62|0)[0-9\s\-\(\)]+$').hasMatch(trimmedValue)) {
      return 'Format nomor telepon tidak valid';
    }

    // Validasi awalan nomor Indonesia
    if (digitsOnly.startsWith('62')) {
      if (digitsOnly.length < 11) {
        return 'Nomor telepon Indonesia tidak valid';
      }
    } else if (digitsOnly.startsWith('0')) {
      if (digitsOnly.length < 10) {
        return 'Nomor telepon Indonesia tidak valid';
      }
    }

    return null;
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? helperText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Masukkan $label',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              helperText: helperText,
              helperStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black87, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Role',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = 'Karyawan'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color:
                          _selectedRole == 'Karyawan'
                              ? Colors.black87
                              : Colors.grey.shade50,
                      border: Border.all(
                        color:
                            _selectedRole == 'Karyawan'
                                ? Colors.black87
                                : Colors.grey.shade300,
                        width: _selectedRole == 'Karyawan' ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Karyawan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            _selectedRole == 'Karyawan'
                                ? Colors.white
                                : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = 'Admin'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color:
                          _selectedRole == 'Admin'
                              ? Colors.black87
                              : Colors.grey.shade50,
                      border: Border.all(
                        color:
                            _selectedRole == 'Admin'
                                ? Colors.black87
                                : Colors.grey.shade300,
                        width: _selectedRole == 'Admin' ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Admin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            _selectedRole == 'Admin'
                                ? Colors.white
                                : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tambah Akun',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _buildTextField(
                label: 'Username',
                controller: _usernameController,
                validator: _validateUsername,
                helperText:
                    'Huruf, angka, underscore (_), dash (-). Dimulai dengan huruf.',
              ),
              _buildTextField(
                label: 'Password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                helperText:
                    'Min 8 karakter, huruf besar, huruf kecil, angka, karakter khusus',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade600,
                  ),
                  onPressed:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: _validatePassword,
              ),
              _buildTextField(
                label: 'Nama',
                controller: _namaController,
                validator: _validateNama,
                helperText: 'Nama lengkap (hanya huruf dan spasi)',
              ),
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                helperText: 'Contoh: user@example.com',
              ),
              _buildTextField(
                label: 'Nomor Telepon',
                controller: _nomorTelpController,
                keyboardType: TextInputType.phone,
                validator: _validateNomorTelp,
                helperText: 'Format: +62xxx, 08xxx, atau 62xxx',
              ),
              _buildRoleSelector(),
              const SizedBox(height: 20),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _tambahAkun,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey.shade400,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Tambah',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
