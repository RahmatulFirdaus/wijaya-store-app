import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//class untuk mengirim absensi karyawan
class PostAbsensi {
  final String pesan;
  final bool success;
  final Map<String, dynamic>? data;

  PostAbsensi({required this.pesan, this.success = true, this.data});

  /// Mengirim absensi ke server dan mengembalikan respon [PostAbsensi].
  static Future<PostAbsensi> kirimAbsensi() async {
    const storage = FlutterSecureStorage();

    try {
      // Validasi token
      final token = await storage.read(key: 'token');
      if (token == null || token.isEmpty) {
        return PostAbsensi(
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
          success: false,
        );
      }

      final url = Uri.parse(
        'http://192.168.1.96:3000/api/karyawanTambahAbsensi',
      );

      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Koneksi timeout. Periksa koneksi internet Anda.',
              );
            },
          );

      // Validasi response body
      if (response.body.isEmpty) {
        return PostAbsensi(
          pesan: 'Server mengembalikan respon kosong.',
          success: false,
        );
      }

      final data = jsonDecode(response.body);

      // Validasi status code dan response
      if (response.statusCode == 201) {
        return PostAbsensi(
          pesan: data['pesan'] ?? 'Absensi berhasil dikirim!',
          success: true,
          data: data,
        );
      } else if (response.statusCode == 401) {
        return PostAbsensi(
          pesan: 'Token tidak valid. Silakan login kembali.',
          success: false,
        );
      } else if (response.statusCode == 400) {
        return PostAbsensi(
          pesan: data['pesan'] ?? 'Data absensi tidak valid.',
          success: false,
        );
      } else if (response.statusCode == 409) {
        return PostAbsensi(
          pesan: data['pesan'] ?? 'Anda sudah melakukan absensi hari ini.',
          success: false,
        );
      } else if (response.statusCode >= 500) {
        return PostAbsensi(
          pesan: 'Server sedang bermasalah. Coba lagi nanti.',
          success: false,
        );
      } else {
        return PostAbsensi(
          pesan:
              data['pesan'] ??
              'Gagal mengirim absensi. Kode: ${response.statusCode}',
          success: false,
        );
      }
    } on FormatException {
      return PostAbsensi(
        pesan: 'Format respon server tidak valid.',
        success: false,
      );
    } on http.ClientException {
      return PostAbsensi(
        pesan: 'Tidak dapat terhubung ke server. Periksa koneksi internet.',
        success: false,
      );
    } catch (e) {
      String errorMessage = 'Terjadi kesalahan tidak terduga.';

      if (e.toString().contains('SocketException')) {
        errorMessage =
            'Tidak dapat terhubung ke server. Periksa koneksi internet.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Koneksi timeout. Coba lagi nanti.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Format data tidak valid.';
      }

      return PostAbsensi(pesan: errorMessage, success: false);
    }
  }
}

//class untuk mengambil data pengajuan izin karyawan
class DataPengajuanIzinKaryawan {
  String id;
  String tipeIzin;
  String deskripsi;
  String tanggalMulai;
  String tanggalSelesai;
  String status;
  String namaKaryawan;

  DataPengajuanIzinKaryawan({
    required this.id,
    required this.tipeIzin,
    required this.deskripsi,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.status,
    required this.namaKaryawan,
  });

  static Future<List<DataPengajuanIzinKaryawan>> getDataIzinKaryawan() async {
    const storage = FlutterSecureStorage();
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/karyawanTampilPengajuanIzin',
    );

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
        return data.map((item) {
          return DataPengajuanIzinKaryawan(
            id: item['id'].toString(),
            tipeIzin: item['tipe_izin'].toString(),
            deskripsi: item['deskripsi'].toString(),
            tanggalMulai: item['tanggal_mulai'].toString(),
            tanggalSelesai: item['tanggal_akhir'].toString(),
            status: item['status'].toString(),
            namaKaryawan: item['nama'].toString(),
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load izin data: $e');
    }
  }
}

//class untuk mengirim pengajuan izin karyawan
class PostPengajuanIzin {
  final String pesan;
  final bool success;

  PostPengajuanIzin({required this.pesan, this.success = true});

  static Future<PostPengajuanIzin> kirimIzin({
    required String tipeIzin,
    required String deskripsi,
    required String tanggalMulai,
    required String tanggalAkhir,
  }) async {
    const storage = FlutterSecureStorage();

    try {
      final token = await storage.read(key: 'token');

      if (token == null || token.isEmpty) {
        return PostPengajuanIzin(
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
          success: false,
        );
      }

      final url = Uri.parse(
        'http://192.168.1.96:3000/api/karyawanTambahPengajuanIzin',
      );

      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {
              'tipe_izin': tipeIzin,
              'deskripsi': deskripsi,
              'tanggal_mulai': tanggalMulai,
              'tanggal_akhir': tanggalAkhir,
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Koneksi timeout. Periksa koneksi internet Anda.',
              );
            },
          );

      if (response.body.isEmpty) {
        return PostPengajuanIzin(
          pesan: 'Server mengembalikan respon kosong.',
          success: false,
        );
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return PostPengajuanIzin(
          pesan: data['pesan'] ?? 'Pengajuan izin berhasil dikirim.',
          success: true,
        );
      } else if (response.statusCode == 400) {
        return PostPengajuanIzin(
          pesan: data['pesan'] ?? 'Harap mengisi semua data dengan lengkap.',
          success: false,
        );
      } else if (response.statusCode == 401) {
        return PostPengajuanIzin(
          pesan: 'Token tidak valid. Silakan login kembali.',
          success: false,
        );
      } else {
        return PostPengajuanIzin(
          pesan:
              data['pesan'] ??
              'Gagal mengajukan izin. Kode: ${response.statusCode}',
          success: false,
        );
      }
    } on FormatException {
      return PostPengajuanIzin(
        pesan: 'Format respon server tidak valid.',
        success: false,
      );
    } catch (e) {
      String errorMessage = 'Terjadi kesalahan tidak terduga.';
      if (e.toString().contains('SocketException')) {
        errorMessage =
            'Tidak dapat terhubung ke server. Periksa koneksi internet.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Koneksi timeout. Coba lagi nanti.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Format data tidak valid.';
      }

      return PostPengajuanIzin(pesan: errorMessage, success: false);
    }
  }
}

//class untuk menghapus pengajuan izin karyawan
class HapusPengajuanIzin {
  final String id;

  HapusPengajuanIzin({required this.id});

  static Future<HapusPengajuanIzin> hapusPengajuanIzin(String id) async {
    final Uri url = Uri.parse(
      "http://192.168.1.96:3000/api/karyawanDeletePengajuanIzin/$id",
    );

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        // Sukses hapus, return objek dengan ID
        return HapusPengajuanIzin(id: id);
      } else {
        final jsonData = jsonDecode(response.body);
        final pesan = jsonData['pesan'] ?? 'Terjadi kesalahan';
        throw Exception('Gagal menghapus pengajuan izin: $pesan');
      }
    } catch (e) {
      // Tangkap error umum seperti jaringan dll
      throw Exception('Terjadi kesalahan saat menghapus pengajuan izin: $e');
    }
  }
}

//class untuk menampilkan data penjualan offline karyawan
class PenjualanOfflineKaryawan {
  String idPenjualanOffline;
  String namaProduk;
  String hargaProduk;
  String warnaProduk;
  String ukuranProduk;
  String namaKaryawan;
  String tanggalPenjualan;
  String jumlahProduk;
  String gambarProduk;

  PenjualanOfflineKaryawan({
    required this.idPenjualanOffline,
    required this.namaProduk,
    required this.hargaProduk,
    required this.warnaProduk,
    required this.ukuranProduk,
    required this.namaKaryawan,
    required this.tanggalPenjualan,
    required this.jumlahProduk,
    required this.gambarProduk,
  });

  static Future<List<PenjualanOfflineKaryawan>>
  getDataPenjualanOffline() async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/karyawanTampilTambahProdukPenjualanOffline',
    );

    try {
      final hasilResponse = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (hasilResponse.statusCode == 200 || hasilResponse.statusCode == 201) {
        final List<dynamic> data = jsonDecode(hasilResponse.body)['data'];
        return data.map((item) {
          return PenjualanOfflineKaryawan(
            idPenjualanOffline: item['id'].toString(),
            namaProduk: item['nama_produk'].toString(),
            hargaProduk: item['harga'].toString(),
            warnaProduk: item['warna'].toString(),
            ukuranProduk: item['ukuran'].toString(),
            namaKaryawan: item['nama'].toString(),
            tanggalPenjualan: item['tanggal'].toString(),
            jumlahProduk: item['jumlah'].toString(),
            gambarProduk: item['link_gambar_varian'].toString(),
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load penjualan offline data: $e');
    }
  }
}

//class untuk karyawan menambahkan penjualan offline
class PostKaryawanPenjualanOffline {
  final String pesan;
  final bool success;

  PostKaryawanPenjualanOffline({required this.pesan, this.success = true});

  static Future<PostKaryawanPenjualanOffline> kirimPenjualan({
    required String idVarianProduk,
    required String jumlah,
  }) async {
    const storage = FlutterSecureStorage();

    try {
      final token = await storage.read(key: 'token');

      if (token == null || token.isEmpty) {
        return PostKaryawanPenjualanOffline(
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
          success: false,
        );
      }

      final url = Uri.parse(
        'http://192.168.1.96:3000/api/karyawanTambahPenjualanOffline',
      );

      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {'id_varian_produk': idVarianProduk, 'jumlah': jumlah},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Koneksi timeout. Periksa koneksi internet Anda.',
              );
            },
          );

      if (response.body.isEmpty) {
        return PostKaryawanPenjualanOffline(
          pesan: 'Server mengembalikan respon kosong.',
          success: false,
        );
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return PostKaryawanPenjualanOffline(
          pesan: data['pesan'] ?? 'Penjualan offline berhasil.',
          success: true,
        );
      } else if (response.statusCode == 400) {
        return PostKaryawanPenjualanOffline(
          pesan: data['pesan'] ?? 'Harap mengisi semua data dengan lengkap.',
          success: false,
        );
      } else if (response.statusCode == 401) {
        return PostKaryawanPenjualanOffline(
          pesan: 'Token tidak valid. Silakan login kembali.',
          success: false,
        );
      } else {
        return PostKaryawanPenjualanOffline(
          pesan: data['pesan'] ?? 'Gagal menambahkan penjualan.',
          success: false,
        );
      }
    } on FormatException {
      return PostKaryawanPenjualanOffline(
        pesan: 'Format respon server tidak valid.',
        success: false,
      );
    } catch (e) {
      String errorMessage = 'Terjadi kesalahan tidak terduga.';
      if (e.toString().contains('SocketException')) {
        errorMessage =
            'Tidak dapat terhubung ke server. Periksa koneksi internet.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Koneksi timeout. Coba lagi nanti.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Format data tidak valid.';
      }

      return PostKaryawanPenjualanOffline(pesan: errorMessage, success: false);
    }
  }
}

////class untuk menghapus penjualan offline karyawan
class HapusProdukPenjualanOffline {
  final String id;

  HapusProdukPenjualanOffline({required this.id});

  static Future<HapusProdukPenjualanOffline> hapusProdukPenjualanOffline(
    String id,
  ) async {
    final Uri url = Uri.parse(
      "http://192.168.1.96:3000/api/karyawanDeleteProdukPenjualanOffline/$id",
    );

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return HapusProdukPenjualanOffline(id: id);
      } else {
        final jsonData = jsonDecode(response.body);
        final pesan = jsonData['pesan'] ?? 'Terjadi kesalahan';
        throw Exception('Gagal menghapus produk penjualan offline: $pesan');
      }
    } catch (e) {
      throw Exception(
        'Terjadi kesalahan saat menghapus produk penjualan offline: $e',
      );
    }
  }
}
