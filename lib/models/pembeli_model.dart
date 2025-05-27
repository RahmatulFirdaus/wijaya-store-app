import 'dart:convert';
import 'dart:ffi';

import 'package:dio/dio.dart';
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
      Uri.parse('http://192.168.1.96:3000/api/login'),
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

        // Ambil id dan nama dari response
        final String id =
            data['data']['id'].toString(); // Ubah ke String jika perlu
        final String nama = data['data']['nama'];

        // Simpan token, id, dan nama ke storage
        await storage.write(key: 'token', value: token);
        await storage.write(key: 'id', value: id);
        await storage.write(key: 'nama', value: nama);

        print("token login: $token");
        print("id user: $id");
        print("nama user: $nama");

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
  int harga;
  int harga_awal;
  String link_gambar;
  String stok;
  String kategori_produk;

  GetDataProduk({
    required this.id,
    required this.nama_produk,
    required this.deskripsi,
    required this.harga,
    required this.harga_awal,
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
                id: item['id'].toString(),
                nama_produk: item['nama_produk'].toString(),
                deskripsi: item['deskripsi_produk'].toString(),
                harga: int.tryParse(item['harga_produk'].toString()) ?? 0,
                harga_awal: int.tryParse(item['harga_awal'].toString()) ?? 0,
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
  final String idVarian; // Sesuai dengan API response 'id_varian'
  final String warna; // Sesuai dengan API response 'warna'
  final int ukuran; // Sesuai dengan API response 'ukuran'
  final int stok; // Sesuai dengan API response 'stok'
  final String
  linkGambarVarian; // Sesuai dengan API response 'link_gambar_varian'

  Varian({
    required this.idVarian,
    required this.warna,
    required this.ukuran,
    required this.stok,
    required this.linkGambarVarian,
  });

  factory Varian.fromJson(Map<String, dynamic> json) {
    return Varian(
      idVarian: json['id_varian'].toString(),
      warna: json['warna'],
      ukuran: int.parse(json['ukuran'].toString()),
      stok: int.parse(json['stok'].toString()),
      linkGambarVarian: json['link_gambar_varian'],
    );
  }
}

// Class GetDataDetailProduk - setelah class Varian
class GetDataDetailProduk {
  final String id;
  final String namaProduk;
  final String deskripsi;
  final String hargaAwal;
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
    required this.hargaAwal,
  });

  factory GetDataDetailProduk.fromJson(Map<String, dynamic> json) {
    return GetDataDetailProduk(
      id: json['id'].toString(),
      namaProduk: json['nama'],
      hargaAwal: json['harga_awal'],
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

//fungsi untuk menampilkan ulasan produk
class GetDataUlasan {
  String id;
  String id_produk;
  String id_pembeli;
  String nama_pembeli;
  String ulasan;
  String rating;
  String tanggal;

  GetDataUlasan({
    required this.id,
    required this.id_produk,
    required this.id_pembeli,
    required this.nama_pembeli,
    required this.ulasan,
    required this.rating,
    required this.tanggal,
  });

  static Future<List<GetDataUlasan>> getDataUlasan(String id) async {
    Uri url = Uri.parse("http://192.168.1.96:3000/api/tampilUlasanProduk/$id");

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData["data"];

        // Check if data is null or empty
        if (data == null || data.isEmpty) {
          return []; // Return empty list instead of null
        }

        return List<GetDataUlasan>.from(
          data.map(
            (item) => GetDataUlasan(
              id: item['id'].toString(),
              id_produk: item['id_produk'].toString(),
              id_pembeli: item['id_pembeli'].toString(),
              nama_pembeli: item['nama'].toString(),
              ulasan: item['komentar'].toString(),
              rating: item['rating'].toString(),
              tanggal: item['tanggal_komentar'].toString(),
            ),
          ),
        );
      } else {
        // Return empty list on error instead of error message
        return [];
      }
    } catch (e) {
      // Return empty list on exception instead of error message
      return [];
    }
  }
}

//class untuk menampilkan list data admin untuk pembeli
class GetDataAdmin {
  String id;
  String nama;
  String username;
  String password;
  String email;
  String no_telp;
  String role;

  GetDataAdmin({
    required this.id,
    required this.nama,
    required this.username,
    required this.password,
    required this.email,
    required this.no_telp,
    required this.role,
  });

  static Future<List<GetDataAdmin>> getDataAdmin() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.96:3000/api/chatListAdmin'),
    );
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data
            .map(
              (item) => GetDataAdmin(
                id: item['id'].toString(),
                nama: item['nama'].toString(),
                username: item['username'].toString(),
                password: item['password'].toString(),
                email: item['email'].toString(),
                no_telp: item['no_telp'].toString(),
                role: item['role'].toString(),
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

//class untuk menampilkan list data pembeli untuk admin
class GetDataPembeli {
  String id;
  String nama;
  String username;
  String password;
  String email;
  String no_telp;
  String role;

  GetDataPembeli({
    required this.id,
    required this.nama,
    required this.username,
    required this.password,
    required this.email,
    required this.no_telp,
    required this.role,
  });

  static Future<List<GetDataPembeli>> getDataPembeli() async {
    const storage = FlutterSecureStorage();
    final url = Uri.parse('http://192.168.1.96:3000/api/chatListPembeli');

    var token = await storage.read(key: 'token');

    var hasilResponse = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    try {
      if (hasilResponse.statusCode == 200 || hasilResponse.statusCode == 201) {
        final List<dynamic> data = jsonDecode(hasilResponse.body)['data'];
        return data
            .map(
              (item) => GetDataPembeli(
                id: item['id'].toString(),
                nama: item['nama'].toString(),
                username: item['username'].toString(),
                password: item['password'].toString(),
                email: item['email'].toString(),
                no_telp: item['no_telp'].toString(),
                role: item['role'].toString(),
              ),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to load products, status code: ${hasilResponse.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }
}

//class api untuk menampilkan data chat
class GetChat {
  String id_pengirim;
  String id_penerima;
  String pesan;

  GetChat({
    required this.id_pengirim,
    required this.id_penerima,
    required this.pesan,
  });

  factory GetChat.fromJson(Map<String, dynamic> json) {
    return GetChat(
      id_pengirim: json['id_pengirim'].toString(),
      id_penerima: json['id_penerima'].toString(),
      pesan: json['pesan'].toString(),
    );
  }

  static Future<List<GetChat>> getChat(String id) async {
    const storage = FlutterSecureStorage();
    var url = Uri.parse("http://192.168.1.96:3000/api/chat/$id");
    var token = await storage.read(key: 'token');

    var hasilResponse = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (hasilResponse.statusCode == 200) {
      var jsonData = jsonDecode(hasilResponse.body);
      var dataList = jsonData["data"] as List;

      return dataList.map((item) => GetChat.fromJson(item)).toList();
    } else if (hasilResponse.statusCode == 404) {
      return []; // Return empty list if no chat found
    } else {
      throw Exception("Gagal mengambil data chat");
    }
  }
}

//class api untuk mengirimkan chat
class PostChat {
  String id_pengirim;
  String id_penerima;
  String pesan;

  PostChat({
    required this.id_pengirim,
    required this.id_penerima,
    required this.pesan,
  });

  static Future<PostChat> postChat(
    String id_pengirim,
    String id_penerima,
    String pesan,
  ) async {
    const storage = FlutterSecureStorage();
    Uri url = Uri.parse("http://192.168.1.96:3000/api/chat/send");
    var token = await storage.read(key: 'token');
    print("token: $token");
    var hasilResponse = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'id_pengirim': id_pengirim,
        'id_penerima': id_penerima,
        'pesan': pesan,
      },
    );
    var jsonData = jsonDecode(hasilResponse.body);
    return PostChat(
      id_pengirim: jsonData['id_user'].toString(),
      id_penerima: jsonData['id_penerima'].toString(),
      pesan: jsonData['pesan'].toString(),
    );
  }
}

//class untuk menambahkan ke keranjang
class TambahKeranjang {
  String id_varian_produk;
  String jumlahOrder;

  TambahKeranjang({required this.id_varian_produk, required this.jumlahOrder});

  static Future<String?> addToKeranjang(
    String id_varian_produk,
    String jumlahOrder,
  ) async {
    if (id_varian_produk.isEmpty || jumlahOrder.isEmpty) {
      throw Exception('ID varian produk dan jumlah order wajib diisi.');
    }

    int? jumlahInt = int.tryParse(jumlahOrder);
    if (jumlahInt == null || jumlahInt <= 0) {
      throw Exception('Jumlah order harus berupa angka positif.');
    }

    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'token');

    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login terlebih dahulu.');
    }

    Uri url = Uri.parse("http://192.168.1.96:3000/api/pembeliTambahKeranjang");

    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'id_varian_produk': id_varian_produk, 'jumlah_order': jumlahOrder},
    );

    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonData = jsonDecode(response.body);
        return jsonData['pesan'] ?? 'Berhasil ditambahkan ke keranjang';
      } else {
        var jsonData = jsonDecode(response.body);
        throw Exception(jsonData['pesan'] ?? 'Gagal menambahkan ke keranjang');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Response tidak valid dari server');
      }
      rethrow;
    }
  }
}

//class untuk menampilkan data keranjang pembeli
class GetDataKeranjang {
  String id;
  String id_varian_produk;
  String hargaAwal;
  String jumlah_order;
  String nama_produk;
  String warna;
  String ukuran;
  String hargaSatuan;
  String linkGambar;

  GetDataKeranjang({
    required this.id,
    required this.id_varian_produk,
    required this.jumlah_order,
    required this.nama_produk,
    required this.warna,
    required this.ukuran,
    required this.hargaAwal,
    required this.hargaSatuan,
    required this.linkGambar,
  });

  static Future<List<GetDataKeranjang>> getDataKeranjang() async {
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'token');

    Uri url = Uri.parse("http://192.168.1.96:3000/api/pembeliTampilKeranjang");

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
        var data = jsonData['data'] as List;

        return data.map((item) {
          return GetDataKeranjang(
            id: item['id_item_order'].toString(),
            id_varian_produk: item['id_varian_produk'].toString(),
            jumlah_order: item['jumlah'].toString(),
            nama_produk: item['nama_produk'].toString(),
            warna: item['warna'].toString(),
            ukuran: item['ukuran'].toString(),
            hargaAwal: item['harga_awal'].toString(),
            hargaSatuan: item['harga_satuan'].toString(),
            linkGambar: item['link_gambar_varian'].toString(),
          );
        }).toList();
      } else if (response.statusCode == 404) {
        // Tangani keranjang kosong secara khusus
        return [];
      } else {
        throw Exception(
          'Gagal mengambil data keranjang (${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Gagal mengambil data keranjang: $e');
    }
  }
}

//class untuk menghapus data keranjang pembeli
class HapusKeranjang {
  final String id;

  HapusKeranjang({required this.id});

  static Future<HapusKeranjang> hapusKeranjang(String id) async {
    final Uri url = Uri.parse(
      "http://192.168.1.96:3000/api/pembeliDeleteKeranjang/$id",
    );

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      // Tidak perlu ambil 'id' dari response karena backend tidak mengirimkannya
      return HapusKeranjang(id: id);
    } else {
      final jsonData = jsonDecode(response.body);
      final pesan = jsonData['pesan'] ?? 'Terjadi kesalahan';
      throw Exception('Gagal menghapus keranjang: $pesan');
    }
  }
}

//class untuk mendapatkan data metode pembayaran
class GetDataMetodePembayaran {
  String id;
  String nama_metode;
  String deskripsi;

  GetDataMetodePembayaran({
    required this.id,
    required this.nama_metode,
    required this.deskripsi,
  });

  static Future<List<GetDataMetodePembayaran>> getDataMetodePembayaran() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.96:3000/api/adminTampilMetodePembayaran'),
    );
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data
            .map(
              (item) => GetDataMetodePembayaran(
                id: item['id'].toString(),
                nama_metode: item['nama_metode'].toString(),
                deskripsi: item['deskripsi'].toString(),
              ),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to load payment methods, status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load payment methods: $e');
    }
  }
}

//class untuk menambahkan data pembayaran pembeli
class TambahPembayaran {
  String id_metode_pembayaran;
  String total_harga;
  String nama_pengirim;
  String bank_pengirim;
  String alamat_pengiriman;
  String bukti_pembayaran;

  TambahPembayaran({
    required this.id_metode_pembayaran,
    required this.total_harga,
    required this.nama_pengirim,
    required this.bank_pengirim,
    required this.alamat_pengiriman,
    required this.bukti_pembayaran,
  });

  /// Method untuk mengirim data pembayaran ke server
  static Future<String?> addPembayaran({
    required String id_metode_pembayaran,
    required String total_harga,
    required String nama_pengirim,
    required String bank_pengirim,
    required String alamat_pengiriman,
    required String bukti_pembayaran,
  }) async {
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'token');

    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login terlebih dahulu.');
    }

    Uri url = Uri.parse("http://192.168.1.96:3000/api/upload");

    var request =
        http.MultipartRequest('POST', url)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['id_metode_pembayaran'] = id_metode_pembayaran
          ..fields['total_harga'] = total_harga
          ..fields['nama_pengirim'] = nama_pengirim
          ..fields['bank_pengirim'] = bank_pengirim
          ..fields['alamat_pengiriman'] = alamat_pengiriman
          ..files.add(
            await http.MultipartFile.fromPath(
              'bukti_transfer', // sesuaikan dengan nama field di backend
              bukti_pembayaran,
            ),
          );

    try {
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      var jsonData = jsonDecode(responseData.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonData['pesan'] ?? 'Pembayaran berhasil ditambahkan';
      } else {
        throw Exception(jsonData['pesan'] ?? 'Gagal menambahkan pembayaran');
      }
    } catch (e) {
      throw Exception('Gagal mengunggah bukti pembayaran: $e');
    }
  }
}
