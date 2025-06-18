import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';

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
  String nilaiRating;

  GetDataProduk({
    required this.id,
    required this.nama_produk,
    required this.deskripsi,
    required this.harga,
    required this.harga_awal,
    required this.link_gambar,
    required this.stok,
    required this.kategori_produk,
    required this.nilaiRating,
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
                nilaiRating: item['rating'].toString(),
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
  final String videoDemo;
  final String linkGambar;
  final String kategoriProduk;
  final List<Varian> varian;

  GetDataDetailProduk({
    required this.id,
    required this.namaProduk,
    required this.deskripsi,
    required this.harga,
    required this.linkGambar,
    required this.videoDemo,
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
      videoDemo: json['video_demo'].toString(),
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
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load payment methods: $e');
    }
  }
}

//class untuk menambahkan data pembayaran pembeli
class TambahPembayaran {
  static Future<String?> addPembayaran({
    required String id_metode_pembayaran,
    required String total_harga,
    required String nama_pengirim,
    required String bank_pengirim,
    required String alamat_pengiriman,
    required List<String> bukti_transfer_paths, // ubah jadi list
  }) async {
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'token');

    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    var uri = Uri.parse('http://192.168.1.96:3000/api/pembayaran/upload');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['id_metode_pembayaran'] = id_metode_pembayaran;
    request.fields['total_harga'] = total_harga;
    request.fields['nama_pengirim'] = nama_pengirim;
    request.fields['bank_pengirim'] = bank_pengirim;
    request.fields['alamat_pengiriman'] = alamat_pengiriman;

    // Loop untuk menambahkan banyak gambar
    for (String path in bukti_transfer_paths) {
      String ext = path.split('.').last.toLowerCase();
      String mimeType =
          (ext == 'png')
              ? 'png'
              : (ext == 'jpg' || ext == 'jpeg')
              ? 'jpeg'
              : 'jpeg';

      request.files.add(
        await http.MultipartFile.fromPath(
          'bukti_transfer', // gunakan key yang sama
          path,
          contentType: MediaType('image', mimeType),
        ),
      );
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Response: ${response.statusCode} - ${response.body}');

      var data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data['message'];
      } else {
        String errorMessage =
            data['message'] ?? 'Terjadi kesalahan saat mengunggah.';
        return errorMessage;
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Gagal mengunggah bukti pembayaran: $e');
    }
  }
}

//class untuk menampilkan riwayat transaksi pembeli
class GetRiwayatTransaksi {
  String namaPengirim;
  String bankPengirim;
  String tanggalTransfer;
  String status;
  String? catatanAdmin;
  String idOrderan;

  GetRiwayatTransaksi({
    required this.namaPengirim,
    required this.bankPengirim,
    required this.tanggalTransfer,
    required this.status,
    this.catatanAdmin,
    required this.idOrderan,
  });

  static Future<List<GetRiwayatTransaksi>> getRiwayatTransaksi() async {
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'token');

    Uri url = Uri.parse("http://192.168.1.96:3000/api/pembeliRiwayatTransaksi");
    try {
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data
            .map(
              (item) => GetRiwayatTransaksi(
                namaPengirim: item['nama_pengirim'] ?? '',
                bankPengirim: item['bank_pengirim'] ?? '',
                tanggalTransfer: item['tanggal_transfer'] ?? '',
                status: item['status'] ?? '',
                catatanAdmin: item['catatan_admin'],
                idOrderan: item['id_orderan'].toString(),
              ),
            )
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load transaction history: $e');
    }
  }
}

//class untuk menampilkan data pengguna
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

//class untuk memperbarui profil pengguna
class UpdateProfileService {
  final String baseUrl = 'http://192.168.1.96:3000/api';
  final String token; // JWT Token untuk autentikasi

  UpdateProfileService({required this.token});

  Future<String?> _patchProfileData(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Sertakan token di header
        },
        body: jsonEncode(data),
      );

      final jsonData = jsonDecode(response.body);
      return jsonData['pesan'];
    } catch (e) {
      print('Error: $e');
      return 'Terjadi kesalahan';
    }
  }

  Future<String?> updatePassword(String password) {
    return _patchProfileData('pembeliUpdateProfilePassword', {
      'password': password,
    });
  }

  Future<String?> updateNama(String nama) {
    return _patchProfileData('pembeliUpdateProfileNama', {'nama': nama});
  }

  Future<String?> updateNomorTelepon(String nomorTelp) {
    return _patchProfileData('pembeliUpdateProfileNomorTelepon', {
      'nomor_telp': nomorTelp,
    });
  }

  Future<String?> updateEmail(String email) {
    return _patchProfileData('pembeliUpdateProfileEmail', {'email': email});
  }
}

//class untuk mengecek status orderan berdasarkan id_orderan
class StatusOrder {
  final String status;

  StatusOrder({required this.status});

  factory StatusOrder.fromJson(Map<String, dynamic> json) {
    return StatusOrder(status: json['status'].toString());
  }

  static Future<StatusOrder> fetchStatusOrder(String id) async {
    final url = Uri.parse('http://192.168.1.96:3000/api/pembeliCekStatus/$id');

    final response = await http.get(url);

    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];

        if (data is List && data.isNotEmpty) {
          return StatusOrder.fromJson(data[0]);
        } else {
          throw Exception('Data status kosong');
        }
      } else {
        throw Exception('Gagal mengambil status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil status: $e');
    }
  }
}

//class untuk menampilkan detail riwayat transaksi pembeli
class RiwayatTransaksiDetail {
  final String idProduk;
  final String idVarianProduk;
  final String namaProduk;
  final String warna;
  final int ukuran;
  final int jumlah;
  final String harga;
  final String linkGambarVarian;

  RiwayatTransaksiDetail({
    required this.idProduk,
    required this.idVarianProduk,
    required this.namaProduk,
    required this.warna,
    required this.ukuran,
    required this.jumlah,
    required this.harga,
    required this.linkGambarVarian,
  });

  factory RiwayatTransaksiDetail.fromJson(Map<String, dynamic> json) {
    return RiwayatTransaksiDetail(
      idProduk: json['id_produk'].toString(),
      idVarianProduk: json['id_varian_produk'].toString(),
      namaProduk: json['nama_produk'] ?? '',
      warna: json['warna'] ?? '',
      ukuran: int.tryParse(json['ukuran'].toString()) ?? 0,
      jumlah: int.tryParse(json['jumlah'].toString()) ?? 0,
      harga: json['harga']?.toString() ?? '0',
      linkGambarVarian: json['link_gambar_varian'] ?? '',
    );
  }

  static Future<List<RiwayatTransaksiDetail>> fetchDetail(String id) async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.1.96:3000/api/pembeliRiwayatTransaksiDetail/$id',
        ),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['data'] != null) {
          final List<dynamic> data = responseBody['data'];
          return data
              .map((item) => RiwayatTransaksiDetail.fromJson(item))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}

//class untuk mengecek status pengiriman berdasarkan id_orderan
class StatusPengiriman {
  final String status;

  StatusPengiriman({required this.status});

  factory StatusPengiriman.fromJson(Map<String, dynamic> json) {
    return StatusPengiriman(status: json['status'] ?? '');
  }

  static Future<StatusPengiriman> fetchStatus(String id) async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/pembeliCekPengiriman/$id',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];

        if (data is List && data.isNotEmpty) {
          return StatusPengiriman.fromJson(data[0]);
        } else {
          throw Exception('Data pengiriman kosong');
        }
      } else {
        throw Exception(
          'Gagal mengambil status pengiriman: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}

class FakturItem {
  final String namaBarang;
  final String warna;
  final String ukuran;
  final dynamic jumlahOrder; // Changed to dynamic to handle both int and string
  final dynamic harga; // Changed to dynamic to handle both int and string

  FakturItem({
    required this.namaBarang,
    required this.warna,
    required this.ukuran,
    required this.jumlahOrder,
    required this.harga,
  });

  factory FakturItem.fromJson(Map<String, dynamic> json) {
    return FakturItem(
      namaBarang: json['nama_barang']?.toString() ?? '',
      warna: json['warna']?.toString() ?? '',
      ukuran: json['ukuran']?.toString() ?? '',
      jumlahOrder: json['jumlah_order'], // Keep as dynamic
      harga: json['harga'], // Keep as dynamic
    );
  }
}

class Faktur {
  final String nomorFaktur;
  final String tanggalFaktur;
  final String id;
  final String namaPengguna;
  final List<FakturItem> items;

  Faktur({
    required this.nomorFaktur,
    required this.tanggalFaktur,
    required this.id,
    required this.namaPengguna,
    required this.items,
  });

  factory Faktur.fromJson(Map<String, dynamic> json) {
    var itemsJson = json['items'] as List? ?? [];
    List<FakturItem> itemList =
        itemsJson.map((item) => FakturItem.fromJson(item)).toList();

    return Faktur(
      nomorFaktur: json['nomor_faktur']?.toString() ?? '',
      tanggalFaktur: json['tanggal_faktur']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      namaPengguna: json['nama_pengguna']?.toString() ?? '',
      items: itemList,
    );
  }
}

class ApiService {
  final String baseUrl = 'http://192.168.1.96:3000/api';

  Future<Faktur> fetchFaktur(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/pembeliFaktur/$id'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // Handle different possible response structures
      Map<String, dynamic> data;
      if (jsonData is Map<String, dynamic>) {
        data = jsonData['data'] ?? jsonData;
      } else {
        throw Exception('Format response tidak valid');
      }

      return Faktur.fromJson(data);
    } else {
      throw Exception('Gagal memuat data faktur: ${response.statusCode}');
    }
  }
}

//class untuk menambahkan ulasan produk
class PostKomentar {
  final String pesan;

  PostKomentar({required this.pesan});

  static Future<PostKomentar> kirimKomentar({
    required String idProduk,
    required String idVarianProduk,
    required String rating,
    required String komentar,
  }) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    final url = Uri.parse('http://192.168.1.96:3000/api/pembeliTambahKomentar');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'id_produk': idProduk,
        'id_varian_produk': idVarianProduk,
        'rating': rating,
        'komentar': komentar,
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return PostKomentar(pesan: data['pesan']);
    } else {
      throw Exception(data['pesan'] ?? 'Gagal mengirim komentar');
    }
  }
}

//class untuk mengecek apakah pembeli sudah mengirimkan ulasan
class KomentarModel {
  final int id;
  final int idPengguna;
  final int idProduk;
  final int rating;
  final String komentar;
  final DateTime tanggalKomentar;

  KomentarModel({
    required this.id,
    required this.idPengguna,
    required this.idProduk,
    required this.rating,
    required this.komentar,
    required this.tanggalKomentar,
  });

  factory KomentarModel.fromJson(Map<String, dynamic> json) {
    return KomentarModel(
      id: json['id'],
      idPengguna: json['id_pengguna'],
      idProduk: json['id_produk'],
      rating: json['rating'],
      komentar: json['komentar'],
      tanggalKomentar: DateTime.parse(json['tanggal_komentar']),
    );
  }
}

class CekKomentarService {
  static Future<KomentarModel?> fetchKomentar(int idVarianProduk) async {
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'token');

    Uri url = Uri.parse(
      "http://192.168.1.96:3000/api/pembeliCekKomentar/$idVarianProduk",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final komentar = data['data'][0]; // karena data dalam bentuk list
        return KomentarModel.fromJson(komentar);
      } else if (response.statusCode == 404) {
        return null; // tidak ada komentar
      } else {
        throw Exception(
          'Failed to load komentar (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error while fetching komentar: $e');
    }
  }
}
