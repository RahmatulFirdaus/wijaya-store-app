import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Class untuk menampilkan data pengguna
class GetDataPengguna {
  String id;
  String nama;
  String username;
  String password;
  String email;
  String nomorTelp;
  String role;

  GetDataPengguna({
    required this.id,
    required this.nama,
    required this.username,
    required this.password,
    required this.email,
    required this.nomorTelp,
    required this.role,
  });

  static Future<GetDataPengguna> getDataPengguna() async {
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'token');
    Uri url = Uri.parse("http://192.168.1.96:3000/api/pembeliProfile");

    try {
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonData = jsonDecode(response.body);
        var dataList = jsonData['data'] as List;

        if (dataList.isEmpty) {
          throw Exception('User data is empty');
        }

        var data = dataList.first;

        return GetDataPengguna(
          id: data['id'].toString(),
          nama: data['nama'].toString(),
          username: data['username'].toString(),
          password: data['password'].toString(),
          email: data['email'].toString(),
          nomorTelp: data['nomor_telp'].toString(),
          role: data['role'].toString(),
        );
      } else {
        throw Exception(
          'Failed to load user data, status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load user data: $e');
    }
  }
}

class ProfilePembeli extends StatefulWidget {
  const ProfilePembeli({super.key});

  @override
  State<ProfilePembeli> createState() => _ProfilePembeliState();
}

class _ProfilePembeliState extends State<ProfilePembeli> {
  GetDataPengguna? userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await GetDataPengguna.getDataPengguna();
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
    bool isPassword = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black87, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPassword ? '••••••••' : value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.person, size: 50, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Text(
            userData?.nama ?? 'Loading...',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              userData?.role.toUpperCase() ?? 'USER',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              _loadUserData();
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.black87),
              )
              : errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });
                        _loadUserData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildProfileItem(
                            icon: Icons.person_outline,
                            title: 'Full Name',
                            value: userData?.nama ?? '',
                          ),
                          _buildProfileItem(
                            icon: Icons.alternate_email,
                            title: 'Username',
                            value: userData?.username ?? '',
                          ),
                          _buildProfileItem(
                            icon: Icons.email_outlined,
                            title: 'Email Address',
                            value: userData?.email ?? '',
                          ),
                          _buildProfileItem(
                            icon: Icons.phone_outlined,
                            title: 'Phone Number',
                            value: userData?.nomorTelp ?? '',
                          ),
                          _buildProfileItem(
                            icon: Icons.lock_outline,
                            title: 'Password',
                            value: userData?.password ?? '',
                            isPassword: true,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to edit profile
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Edit Profile feature coming soon!',
                                    ),
                                    backgroundColor: Colors.black87,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black87,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_outlined),
                                  SizedBox(width: 8),
                                  Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
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
                ],
              ),
    );
  }
}
