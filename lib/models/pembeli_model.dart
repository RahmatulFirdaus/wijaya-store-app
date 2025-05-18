import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginAkunPembeli {
  static Future<String?> loginAkunPembeli(String email, String password) async {
    const storage = FlutterSecureStorage();
    final response = await http.post(
      Uri.parse(
        'https://localhost:3000/api/login',
      ), // Replace with your API URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: '{"email": "$email", "password": "$password"}',
    );
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['data']['token'];
        final String role = data['data']['role'];

        // Simpan token ke storage
        await storage.write(key: 'token', value: token);

        return role;
      } else {
        final errorMessage = jsonDecode(response.body)['pesan'];
        return errorMessage;
      }
    } catch (e) {
      final errorMessage = jsonDecode(response.body)['pesan'];
      return errorMessage;
    }
  }
}
