import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//class LoginAkunPembeli
class LoginAkunPembeli {
  static Future<String?> loginAkunPembeli(
    String username,
    String password,
  ) async {
    const storage = FlutterSecureStorage();
    final response = await http.post(
      Uri.parse(
        'http://192.168.1.96:3000/api/login',
      ), // Replace with your API URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: '{"username": "$username", "password": "$password"}',
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

//class pembeli daftar akun
class PembeliDaftarAkun {
  static Future<String?> daftarAkunPembeli(
    String username,
    String password,
    String nama,
    String email,
    String confirmPassword,
    String nohp,
  ) async {
    final response = await http.post(
      Uri.parse(
        'http://192.168.1.96:3000/api/daftar',
      ), // Replace with your API URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
        'nama': nama,
        'email': email,
        'confirmPassword': confirmPassword,
        'no_telp': nohp,
      }),
    );
    try {
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['pesan'];
      } else {
        return data['pesan'];
      }
    } catch (e) {
      final errorMessage = jsonDecode(response.body)['pesan'];
      return errorMessage;
    }
  }
}

//class untuk menampilkan data produk
class GetDataProduk {
  String id;
  String nama_produk;
  String deskripsi;
  String harga;
  String link_gambar;
  String stok;
  String kategori_produk;

  GetDataProduk({
    required this.id,
    required this.nama_produk,
    required this.deskripsi,
    required this.harga,
    required this.link_gambar,
    required this.stok,
    required this.kategori_produk,
  });

  static Future<List<GetDataProduk>> getDataProduk() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.96:3000/api/tampilProduk'),
    );

    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data
            .map(
              (item) => GetDataProduk(
                id: item['id'].toString(), // id angka di-parse ke string
                nama_produk: item['nama_produk'].toString(),
                deskripsi: item['deskripsi_produk'].toString(),
                harga: item['harga_produk'].toString(),
                link_gambar: item['link_gambar_produk'].toString(),
                stok: item['total_stok_produk'].toString(),
                kategori_produk: item['kategori'].toString(),
              ),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to load products, status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }
}

//class untuk menampilkan data detail produk
class Varian {
  final int idVarian;
  final String warna;
  final int ukuran;
  final int stok;
  final String linkGambarVarian;

  Varian({
    required this.idVarian,
    required this.warna,
    required this.ukuran,
    required this.stok,
    required this.linkGambarVarian,
  });

  factory Varian.fromJson(Map<String, dynamic> json) {
    return Varian(
      idVarian: json['id_varian'],
      warna: json['warna'],
      ukuran: json['ukuran'],
      stok: json['stok'],
      linkGambarVarian: json['link_gambar_varian'],
    );
  }
}

class GetDataDetailProduk {
  final String id;
  final String namaProduk;
  final String deskripsi;
  final String harga;
  final String linkGambar;
  final String kategoriProduk;
  final List<Varian> varian;

  GetDataDetailProduk({
    required this.id,
    required this.namaProduk,
    required this.deskripsi,
    required this.harga,
    required this.linkGambar,
    required this.kategoriProduk,
    required this.varian,
  });

  factory GetDataDetailProduk.fromJson(Map<String, dynamic> json) {
    return GetDataDetailProduk(
      id: json['id'].toString(),
      namaProduk: json['nama'],
      deskripsi: json['deskripsi'],
      harga: json['harga'],
      linkGambar: json['link_gambar'],
      kategoriProduk: json['kategori'],
      varian: (json['varian'] as List).map((v) => Varian.fromJson(v)).toList(),
    );
  }

  static Future<GetDataDetailProduk> getDataDetailProduk(String id) async {
    Uri url = Uri.parse("http://192.168.1.96:3000/api/tampilProdukDetail/$id");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData["data"];
      return GetDataDetailProduk.fromJson(data);
    } else {
      throw Exception("Gagal mengambil data produk");
    }
  }
}
