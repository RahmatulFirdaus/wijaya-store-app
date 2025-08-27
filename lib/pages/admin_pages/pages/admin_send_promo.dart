import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminSendPromoPage extends StatefulWidget {
  const AdminSendPromoPage({super.key});

  @override
  State<AdminSendPromoPage> createState() => _AdminSendPromoPageState();
}

class _AdminSendPromoPageState extends State<AdminSendPromoPage> {
  final _judulController = TextEditingController();
  final _pesanController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendPromo() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token'); // JWT admin

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token admin tidak ditemukan, login dulu'),
        ),
      );
      return;
    }

    if (_judulController.text.isEmpty || _pesanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan pesan wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse('http://192.168.1.96:3000/api/notifications/promosi');
    final body = {
      "judul": _judulController.text,
      "pesan": _pesanController.text,
      "target_role": "pembeli", // bisa diganti role lain
      "created_by": 9, // ID admin login
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Promosi berhasil dikirim')),
        );
        _judulController.clear();
        _pesanController.clear();
      } else {
        final msg = response.body.isNotEmpty ? response.body : 'Gagal';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $msg')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kirim Promosi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _judulController,
              decoration: const InputDecoration(labelText: 'Judul Promosi'),
            ),
            TextField(
              controller: _pesanController,
              decoration: const InputDecoration(labelText: 'Pesan Promosi'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendPromo,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Kirim Promosi'),
            ),
          ],
        ),
      ),
    );
  }
}
