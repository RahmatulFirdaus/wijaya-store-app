import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/admin_model.dart';

class AdminEditAkun extends StatefulWidget {
  final DataAkun akun;

  const AdminEditAkun({super.key, required this.akun});

  @override
  State<AdminEditAkun> createState() => _AdminEditAkunState();
}

class _AdminEditAkunState extends State<AdminEditAkun> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _namaLengkapController = TextEditingController();
  final _emailController = TextEditingController();
  final _nomorTelpController = TextEditingController();

  String _selectedRole = 'karyawan';
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Focus nodes for better form navigation
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _namaLengkapFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _nomorTelpFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Populate form with existing data
    _usernameController.text = widget.akun.username;
    _namaLengkapController.text = widget.akun.nama;
    _passwordController.text = widget.akun.password;
    _emailController.text = widget.akun.email;
    _nomorTelpController.text = widget.akun.nomorTelp;
    _selectedRole = widget.akun.role;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _namaLengkapController.dispose();
    _emailController.dispose();
    _nomorTelpController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _namaLengkapFocus.dispose();
    _emailFocus.dispose();
    _nomorTelpFocus.dispose();
    super.dispose();
  }

  // Enhanced validation methods
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

    // Check for valid characters (alphanumeric and underscore only)
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmedValue)) {
      return 'Username hanya boleh mengandung huruf, angka, dan underscore';
    }

    // Username cannot start with number
    if (RegExp(r'^[0-9]').hasMatch(trimmedValue)) {
      return 'Username tidak boleh dimulai dengan angka';
    }

    return null;
  }

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
    if (value.contains(' ')) {
      return 'Username tidak boleh mengandung spasi';
    }

    // Check for common weak passwords
    List<String> commonPasswords = [
      'password',
      '12345678',
      'qwerty123',
      'admin123',
      'password123',
    ];

    if (commonPasswords.contains(value.toLowerCase())) {
      return 'Password terlalu umum, gunakan password yang lebih kuat';
    }

    return null;
  }

  String? _validateNamaLengkap(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap tidak boleh kosong';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'Nama lengkap minimal 2 karakter';
    }

    if (trimmedValue.length > 50) {
      return 'Nama lengkap maksimal 50 karakter';
    }

    // Check for valid characters (letters, spaces, apostrophes, hyphens)
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(trimmedValue)) {
      return 'Nama lengkap hanya boleh mengandung huruf, spasi, tanda kutip, dan tanda hubung';
    }

    // Check for consecutive spaces
    if (RegExp(r'\s{2,}').hasMatch(trimmedValue)) {
      return 'Nama lengkap tidak boleh mengandung spasi berturut-turut';
    }

    // Check if name starts or ends with space
    if (trimmedValue != value.trim()) {
      return 'Nama lengkap tidak boleh dimulai atau diakhiri dengan spasi';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }

    final trimmedValue = value.trim().toLowerCase();

    // Enhanced email regex pattern
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(trimmedValue)) {
      return 'Format email tidak valid';
    }

    if (trimmedValue.length > 254) {
      return 'Email terlalu panjang (maksimal 254 karakter)';
    }

    // Check for local part length (before @)
    String localPart = trimmedValue.split('@')[0];
    if (localPart.length > 64) {
      return 'Bagian email sebelum @ terlalu panjang (maksimal 64 karakter)';
    }

    // Check for consecutive dots
    if (RegExp(r'\.{2,}').hasMatch(trimmedValue)) {
      return 'Email tidak boleh mengandung titik berturut-turut';
    }

    // Check if email starts or ends with dot
    if (localPart.startsWith('.') || localPart.endsWith('.')) {
      return 'Email tidak boleh dimulai atau diakhiri dengan titik';
    }

    return null;
  }

  String? _validateNomorTelp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }

    final trimmedValue = value.trim();

    // Remove any non-digit characters for validation
    String digitsOnly = trimmedValue.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10) {
      return 'Nomor telepon minimal 10 digit';
    }

    if (digitsOnly.length > 15) {
      return 'Nomor telepon maksimal 15 digit';
    }

    // Check for valid Indonesian phone number formats
    if (!RegExp(r'^(\+62|62|0)?[8][1-9][0-9]{7,11}$').hasMatch(digitsOnly)) {
      // If it doesn't match Indonesian format, check for general international format
      if (!RegExp(
        r'^[\+]?[0-9]{10,15}$',
      ).hasMatch(trimmedValue.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
        return 'Format nomor telepon tidak valid';
      }
    }

    // Check for obviously invalid patterns
    if (RegExp(r'^(.)\1{9,}$').hasMatch(digitsOnly)) {
      return 'Nomor telepon tidak boleh berupa angka yang sama berulang';
    }

    return null;
  }

  Future<void> _updateAkun() async {
    // Remove focus from current field
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mohon periksa kembali data yang diinput'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await UpdateAkunService.updateAkun(
        id: widget.akun.id.toString(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        namaLengkap: _namaLengkapController.text.trim(),
        nomorTelp: _nomorTelpController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
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
          // Navigate back on success
          Navigator.pop(
            context,
            true,
          ); // Return true to indicate successful update
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    VoidCallback? onEditingComplete,
    List<TextInputFormatter>? inputFormatters,
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
            focusNode: focusNode,
            textInputAction: textInputAction,
            onEditingComplete: onEditingComplete,
            inputFormatters: inputFormatters,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Masukkan $label',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
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
                  onTap: () => setState(() => _selectedRole = 'karyawan'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color:
                          _selectedRole == 'karyawan'
                              ? Colors.black87
                              : Colors.grey.shade50,
                      border: Border.all(
                        color:
                            _selectedRole == 'karyawan'
                                ? Colors.black87
                                : Colors.grey.shade300,
                        width: _selectedRole == 'karyawan' ? 2 : 1,
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
                            _selectedRole == 'karyawan'
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
                  onTap: () => setState(() => _selectedRole = 'admin'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color:
                          _selectedRole == 'admin'
                              ? Colors.black87
                              : Colors.grey.shade50,
                      border: Border.all(
                        color:
                            _selectedRole == 'admin'
                                ? Colors.black87
                                : Colors.grey.shade300,
                        width: _selectedRole == 'admin' ? 2 : 1,
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
                            _selectedRole == 'admin'
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
          'Edit Akun',
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
                focusNode: _usernameFocus,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => _passwordFocus.requestFocus(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                  LengthLimitingTextInputFormatter(20),
                ],
              ),
              _buildTextField(
                label: 'Password',
                controller: _passwordController,
                validator: _validatePassword,
                obscureText: _obscurePassword,
                focusNode: _passwordFocus,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => _namaLengkapFocus.requestFocus(),
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade600,
                  ),
                  onPressed:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              _buildTextField(
                label: 'Nama Lengkap',
                controller: _namaLengkapController,
                validator: _validateNamaLengkap,
                keyboardType: TextInputType.name,
                focusNode: _namaLengkapFocus,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => _emailFocus.requestFocus(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'-]")),
                  LengthLimitingTextInputFormatter(50),
                ],
              ),
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
                focusNode: _emailFocus,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => _nomorTelpFocus.requestFocus(),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  LengthLimitingTextInputFormatter(254),
                ],
              ),
              _buildTextField(
                label: 'Nomor Telepon',
                controller: _nomorTelpController,
                validator: _validateNomorTelp,
                keyboardType: TextInputType.phone,
                focusNode: _nomorTelpFocus,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
                  LengthLimitingTextInputFormatter(20),
                ],
              ),
              _buildRoleSelector(),
              const SizedBox(height: 20),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateAkun,
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
                            'Update',
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
