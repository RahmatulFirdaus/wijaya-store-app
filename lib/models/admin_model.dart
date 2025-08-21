import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:async';

import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardPoint {
  final String ym; // 'YYYY-MM'
  final int? online;
  final int? offline;
  final int total;
  final int? profit;
  final bool forecast;

  DashboardPoint({
    required this.ym,
    required this.total,
    this.online,
    this.offline,
    this.profit,
    this.forecast = false,
  });

  factory DashboardPoint.fromJson(Map<String, dynamic> j) {
    return DashboardPoint(
      ym: j['ym'],
      online: j['online'],
      offline: j['offline'],
      total: j['total'],
      profit: j['profit'],
      forecast: j['forecast'] ?? false,
    );
  }
}

class DashboardSummary {
  final int todayOmzet;
  final int todayProfit;
  final int monthOmzet;
  final int monthProfit;

  DashboardSummary({
    required this.todayOmzet,
    required this.todayProfit,
    required this.monthOmzet,
    required this.monthProfit,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> j) {
    final today = j['today'] ?? {};
    final mon = j['thisMonth'] ?? {};
    return DashboardSummary(
      todayOmzet: today['omzet'] ?? 0,
      todayProfit: today['profit'] ?? 0,
      monthOmzet: mon['omzet'] ?? 0,
      monthProfit: mon['profit'] ?? 0,
    );
  }
}

class DashboardApi {
  static const base = 'http://192.168.1.96:3000/api';

  static Future<DashboardSummary> fetchSummary() async {
    final r = await http.get(Uri.parse('$base/adminDashboardSummary'));
    if (r.statusCode != 200) throw Exception('Summary err ${r.statusCode}');
    final body = jsonDecode(r.body);
    return DashboardSummary.fromJson(body['data']);
  }

  static Future<List<DashboardPoint>> fetchGrafik({
    int yearsBack = 3,
    int yearsForward = 2,
  }) async {
    final r = await http.get(
      Uri.parse(
        '$base/adminGrafikPenjualan?years_back=$yearsBack&years_forward=$yearsForward',
      ),
    );
    if (r.statusCode != 200) {
      throw Exception('Grafik err ${r.statusCode}');
    }
    final body = jsonDecode(r.body);
    final hist =
        (body['data']['historical'] as List)
            .map((e) => DashboardPoint.fromJson(e))
            .toList();
    final fcs =
        (body['data']['forecast'] as List)
            .map((e) => DashboardPoint.fromJson(e))
            .toList();
    return [...hist, ...fcs];
  }
}

class BiayaOperasional {
  final int id;
  final int biayaToko;
  final int bensin;
  final String bulan;

  BiayaOperasional({
    required this.id,
    required this.biayaToko,
    required this.bensin,
    required this.bulan,
  });

  factory BiayaOperasional.fromJson(Map<String, dynamic> json) {
    return BiayaOperasional(
      id: int.tryParse(json['id'].toString()) ?? 0,
      biayaToko: int.tryParse(json['biaya_toko'].toString()) ?? 0,
      bensin: int.tryParse(json['bensin'].toString()) ?? 0,
      bulan: json['bulan'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'biaya_toko': biayaToko, 'bensin': bensin, 'bulan': bulan};
  }

  // Base URL API kamu (ubah sesuai IP / domain backend)
  static const String baseUrl = "http://192.168.1.96:3000/api";

  /// GET semua biaya operasional
  static Future<List<BiayaOperasional>> fetchAll() async {
    final url = Uri.parse('$baseUrl/adminTampilBiayaOperasional');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List dataList = body['data'];
      return dataList.map((e) => BiayaOperasional.fromJson(e)).toList();
    } else {
      throw Exception("Gagal fetch biaya operasional: ${response.statusCode}");
    }
  }

  /// POST tambah biaya operasional
  static Future<bool> tambah(BiayaOperasional biaya) async {
    final url = Uri.parse('$baseUrl/adminTambahBiayaOperasional');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(biaya.toJson()),
    );

    return response.statusCode == 201;
  }

  /// PATCH update biaya operasional
  static Future<bool> update(int id, BiayaOperasional biaya) async {
    final url = Uri.parse('$baseUrl/adminUpdateBiayaOperasional/$id');
    final response = await http.patch(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(biaya.toJson()),
    );

    return response.statusCode == 200;
  }

  /// DELETE biaya operasional
  static Future<bool> delete(int id) async {
    final url = Uri.parse('$baseUrl/adminDeleteBiayaOperasional/$id');
    final response = await http.delete(url);

    return response.statusCode == 200;
  }
}

//CLASS GET
class JumlahVerifikasi {
  final int jumlahPending;

  JumlahVerifikasi({required this.jumlahPending});

  // Factory constructor untuk parsing JSON
  factory JumlahVerifikasi.fromJson(Map<String, dynamic> json) {
    return JumlahVerifikasi(jumlahPending: json['jumlah_pending'] ?? 0);
  }

  // Fungsi untuk ambil data dari API
  static Future<JumlahVerifikasi?> getJumlahPending() async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTampilJumlahVerifikasiAkun',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);

        // Pastikan format data sesuai dan tidak kosong
        if (jsonData['data'] != null && jsonData['data'].isNotEmpty) {
          return JumlahVerifikasi.fromJson(jsonData['data'][0]);
        } else {
          return null;
        }
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}

class IDOrderan {
  final int id;
  final String statusPengiriman;

  IDOrderan({required this.id, required this.statusPengiriman});

  factory IDOrderan.fromJson(Map<String, dynamic> json) {
    return IDOrderan(
      id: json['id'],
      statusPengiriman: json['status_pengiriman'],
    );
  }

  static Future<List<IDOrderan>> fetchIDOrderan() async {
    final url = Uri.parse('http://192.168.1.96:3000/api/getIDOrderan');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List dataList = body['data'];
        return dataList.map((e) => IDOrderan.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Gagal mengambil data ID orderan: $e');
    }
  }
}

class PendingUser {
  final int id;
  final String username;
  final String nama;
  final String email;
  final String nomorTelp;
  final String createdAt;

  PendingUser({
    required this.id,
    required this.username,
    required this.nama,
    required this.email,
    required this.nomorTelp,
    required this.createdAt,
  });

  factory PendingUser.fromJson(Map<String, dynamic> json) {
    return PendingUser(
      id: json['id'],
      username: json['username'],
      nama: json['nama'],
      email: json['email'],
      nomorTelp: json['nomor_telp'],
      createdAt: json['created_at'],
    );
  }

  static Future<List<PendingUser>> fetchPendingUsers() async {
    final url = Uri.parse('http://192.168.1.96:3000/api/admin/pending-users');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List dataList = body['data'];
        return dataList.map((e) => PendingUser.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Gagal mengambil data pengguna pending: $e');
    }
  }
}

class LaporanHarian {
  final String tanggal;
  final int totalPenjualanOffline;
  final int totalPenjualanOnline;
  final int keuntunganPenjualanOffline;
  final int keuntunganPenjualanOnline;
  final int totalHarian;
  final int totalKeuntunganHarian;
  final int gajiKaryawanHarian;
  final int biayaOperasionalHarian;
  final int keuntunganBersih;

  LaporanHarian({
    required this.tanggal,
    required this.totalPenjualanOffline,
    required this.totalPenjualanOnline,
    required this.keuntunganPenjualanOffline,
    required this.keuntunganPenjualanOnline,
    required this.totalHarian,
    required this.totalKeuntunganHarian,
    required this.gajiKaryawanHarian,
    required this.biayaOperasionalHarian,
    required this.keuntunganBersih,
  });

  factory LaporanHarian.fromJson(Map<String, dynamic> json) {
    return LaporanHarian(
      tanggal: json['tanggal'] ?? '',
      totalPenjualanOffline: json['total_penjualan_offline'] ?? 0,
      totalPenjualanOnline: json['total_penjualan_online'] ?? 0,
      keuntunganPenjualanOffline: json['keuntungan_penjualan_offline'] ?? 0,
      keuntunganPenjualanOnline: json['keuntungan_penjualan_online'] ?? 0,
      totalHarian: json['total_harian'] ?? 0,
      totalKeuntunganHarian: json['total_keuntungan_harian'] ?? 0,
      gajiKaryawanHarian: json['gaji_karyawan_harian'] ?? 0,
      biayaOperasionalHarian: json['biaya_operasional_harian'] ?? 0,
      keuntunganBersih: json['keuntungan_bersih'] ?? 0,
    );
  }

  static Future<List<LaporanHarian>> fetchLaporanHarian() async {
    final url = Uri.parse('http://192.168.1.96:3000/api/adminLaporanHarian');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List dataList = body['data'];
        return dataList.map((e) => LaporanHarian.fromJson(e)).toList();
      } else {
        throw Exception('Gagal fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal mengambil data laporan harian: $e');
    }
  }
}

class ProdukTransaksiOnline {
  final String namaProduk;
  final int jumlahOrder;
  final String hargaSatuan;
  final String warna;
  final int ukuran;
  final String linkGambarVarian;

  ProdukTransaksiOnline({
    required this.namaProduk,
    required this.jumlahOrder,
    required this.hargaSatuan,
    required this.warna,
    required this.ukuran,
    required this.linkGambarVarian,
  });

  factory ProdukTransaksiOnline.fromJson(Map<String, dynamic> json) {
    return ProdukTransaksiOnline(
      namaProduk: json['nama_produk'],
      jumlahOrder: json['jumlah_order'],
      hargaSatuan:
          (json['harga_satuan'] is int)
              ? (json['harga_satuan'] as int).toDouble()
              : json['harga_satuan'],
      warna: json['warna'],
      ukuran: json['ukuran'],
      linkGambarVarian: json['link_gambar_varian'],
    );
  }
}

/// Model transaksi online
class DataTransaksiOnlineFull {
  final int idOrderan;
  final String namaPengguna;
  final String tanggalOrder;
  final String totalHarga;
  final List<ProdukTransaksiOnline> produk;

  DataTransaksiOnlineFull({
    required this.idOrderan,
    required this.namaPengguna,
    required this.tanggalOrder,
    required this.totalHarga,
    required this.produk,
  });

  factory DataTransaksiOnlineFull.fromJson(Map<String, dynamic> json) {
    var list = json['produk'] as List;
    List<ProdukTransaksiOnline> produkList =
        list.map((e) => ProdukTransaksiOnline.fromJson(e)).toList();

    return DataTransaksiOnlineFull(
      idOrderan: json['id_orderan'],
      namaPengguna: json['nama_pengguna'],
      tanggalOrder: json['tanggal_order'],
      totalHarga: json['total_harga'],
      produk: produkList,
    );
  }
}

/// Model transaksi offline
class DataTransaksiOffline {
  final String tanggal;
  final String namaProduk;
  final String harga;
  final String warna;
  final int ukuran;
  final String linkGambarVarian;

  DataTransaksiOffline({
    required this.tanggal,
    required this.namaProduk,
    required this.harga,
    required this.warna,
    required this.ukuran,
    required this.linkGambarVarian,
  });

  factory DataTransaksiOffline.fromJson(Map<String, dynamic> json) {
    return DataTransaksiOffline(
      tanggal: json['tanggal'],
      namaProduk: json['nama_produk'],
      harga: json['harga'],
      warna: json['warna'],
      ukuran: json['ukuran'],
      linkGambarVarian: json['link_gambar_varian'],
    );
  }
}

/// Service untuk fetch data dari API
class TransaksiService {
  static Future<Map<String, dynamic>>
  fetchSemuaHasilTransaksiPenjualanHarian() async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTampilSemuaHasilTransaksiPenjualanHarian',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        final List onlineList = body['data_online'];
        final List offlineList = body['data_offline'];

        final List<DataTransaksiOnlineFull> dataOnline =
            onlineList.map((e) => DataTransaksiOnlineFull.fromJson(e)).toList();

        final List<DataTransaksiOffline> dataOffline =
            offlineList.map((e) => DataTransaksiOffline.fromJson(e)).toList();

        return {'online': dataOnline, 'offline': dataOffline};
      } else {
        throw Exception('Gagal memuat data');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}

class DataProdukEco {
  final int id;
  final String nama;
  final String status;
  final String hargaAsli;

  DataProdukEco({
    required this.id,
    required this.nama,
    required this.status,
    required this.hargaAsli,
  });

  factory DataProdukEco.fromJson(Map<String, dynamic> json) {
    return DataProdukEco(
      id: json['id'],
      nama: json['nama'],
      status: json['status'],
      hargaAsli: json['harga_asli']?.toString() ?? '-',
    );
  }

  static Future<List<DataProdukEco>> fetchDataProdukEco() async {
    final url = Uri.parse('http://192.168.1.96:3000/api/adminTampilProdukEco');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List dataList = body['data'];
        return dataList.map((e) => DataProdukEco.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Gagal mengambil data: $e');
    }
  }
}

class ProdukTransaksi {
  final int jumlahOrder;
  final String namaProduk;
  final String hargaSatuan;
  final String warna;
  final int ukuran;

  ProdukTransaksi({
    required this.jumlahOrder,
    required this.namaProduk,
    required this.hargaSatuan,
    required this.warna,
    required this.ukuran,
  });

  factory ProdukTransaksi.fromJson(Map<String, dynamic> json) {
    return ProdukTransaksi(
      jumlahOrder: json['jumlah_order'],
      namaProduk: json['nama_produk'],
      hargaSatuan: json['harga_satuan'],
      warna: json['warna'],
      ukuran: json['ukuran'],
    );
  }
}

class DataTransaksiOnline {
  final int idOrderan;
  final String namaPengguna;
  final String status;
  final String tanggalOrder;
  final String totalHarga;
  final List<ProdukTransaksi> produk;

  DataTransaksiOnline({
    required this.idOrderan,
    required this.namaPengguna,
    required this.status,
    required this.tanggalOrder,
    required this.totalHarga,
    required this.produk,
  });

  factory DataTransaksiOnline.fromJson(Map<String, dynamic> json) {
    var list = json['produk'] as List;
    List<ProdukTransaksi> produkList =
        list.map((e) => ProdukTransaksi.fromJson(e)).toList();

    return DataTransaksiOnline(
      idOrderan: json['id_orderan'],
      namaPengguna: json['nama_pengguna'],
      status: json['status'],
      tanggalOrder: json['tanggal_order'],
      totalHarga: json['total_harga'],
      produk: produkList,
    );
  }

  static Future<List<DataTransaksiOnline>> fetchDataTransaksiOnline() async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTampilHasilTransaksiOnline',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List dataList = body['data'];
        return dataList.map((e) => DataTransaksiOnline.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Kesalahan saat mengambil data transaksi online: $e');
    }
  }
}

class VerifikasiPembayaran {
  final int idOrderan;
  final String status;
  final String? catatanAdmin;
  final String namaPengirim;
  final String bankPengirim;
  final String tanggalTransfer;
  final List<String> buktiTransfer;

  VerifikasiPembayaran({
    required this.idOrderan,
    required this.status,
    required this.catatanAdmin,
    required this.namaPengirim,
    required this.bankPengirim,
    required this.tanggalTransfer,
    required this.buktiTransfer,
  });

  factory VerifikasiPembayaran.fromJson(Map<String, dynamic> json) {
    return VerifikasiPembayaran(
      idOrderan: json['id_orderan'],
      status: json['status'],
      catatanAdmin: json['catatan_admin'],
      namaPengirim: json['nama_pengirim'],
      bankPengirim: json['bank_pengirim'],
      tanggalTransfer: json['tanggal_transfer'],
      buktiTransfer: List<String>.from(json['bukti_transfer']),
    );
  }

  static Future<List<VerifikasiPembayaran>>
  getDataVerifikasiPembayaran() async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTampilVerifikasiPembayaran',
    );
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((item) => VerifikasiPembayaran.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Gagal memuat data verifikasi pembayaran: $e');
    }
  }
}

class DataAkun {
  final int id;
  final String username;
  final String password;
  final String nama;
  final String email;
  final String nomorTelp;
  final String role;
  final String createdAt;

  DataAkun({
    required this.id,
    required this.username,
    required this.password,
    required this.nama,
    required this.email,
    required this.nomorTelp,
    required this.role,
    required this.createdAt,
  });

  factory DataAkun.fromJson(Map<String, dynamic> json) {
    return DataAkun(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      nama: json['nama'],
      email: json['email'],
      nomorTelp: json['nomor_telp'],
      role: json['role'],
      createdAt: json['created_at'],
    );
  }

  static Future<List<DataAkun>> fetchDataAkun() async {
    final url = Uri.parse('http://192.168.1.96:3000/api/adminTampilDataAkun');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List akunList = body['data'];
        return akunList.map((e) => DataAkun.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Kesalahan: $e');
    }
  }
}

class PengirimanItem {
  String nama;
  String warna;
  int ukuran;
  String hargaSatuan;
  int jumlahOrder;

  PengirimanItem({
    required this.nama,
    required this.warna,
    required this.ukuran,
    required this.hargaSatuan,
    required this.jumlahOrder,
  });

  factory PengirimanItem.fromJson(Map<String, dynamic> json) {
    return PengirimanItem(
      nama: json['nama'].toString(),
      warna: json['warna'].toString(),
      ukuran: json['ukuran'],
      hargaSatuan: json['harga_satuan'].toString(),
      jumlahOrder: json['jumlah_order'],
    );
  }
}

class DetailPengiriman {
  int idPengiriman;
  String namaPengguna; // ditambahkan
  String alamatPengiriman;
  String statusPengiriman;
  String totalHarga;
  String tanggalPengiriman;
  List<PengirimanItem> items;

  DetailPengiriman({
    required this.idPengiriman,
    required this.namaPengguna,
    required this.alamatPengiriman,
    required this.statusPengiriman,
    required this.totalHarga,
    required this.tanggalPengiriman,
    required this.items,
  });

  factory DetailPengiriman.fromJson(Map<String, dynamic> json) {
    var itemsFromJson = json['items'] as List;
    List<PengirimanItem> listItems =
        itemsFromJson.map((i) => PengirimanItem.fromJson(i)).toList();

    return DetailPengiriman(
      idPengiriman: json['id_pengiriman'],
      namaPengguna: json['nama_pengguna'].toString(),
      alamatPengiriman: json['alamat_pengiriman'].toString(),
      statusPengiriman: json['status_pengiriman'].toString(),
      totalHarga: json['total_harga'].toString(),
      tanggalPengiriman: json['tanggal_pengiriman'].toString(),
      items: listItems,
    );
  }

  static Future<List<DetailPengiriman>?> getPengiriman() async {
    final url = Uri.parse('http://192.168.1.96:3000/api/adminTampilPengiriman');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> dataList = jsonResponse['data'];
        return dataList.map((e) => DetailPengiriman.fromJson(e)).toList();
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Gagal memuat data pengiriman: $e');
    }
  }

  static Future<DetailPengiriman?> getPengirimanDetail(int id) async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTampilPengirimanDetail/$id',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data']; // data langsung objek, bukan list
        return DetailPengiriman.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Gagal memuat detail pengiriman: $e');
    }
  }
}

class ProdukPerluRestok {
  String namaProduk;
  String kategori;
  String linkGambarVarian;
  String warna;
  int ukuran;
  int stok;

  ProdukPerluRestok({
    required this.namaProduk,
    required this.kategori,
    required this.linkGambarVarian,
    required this.warna,
    required this.ukuran,
    required this.stok,
  });

  static Future<Map<String, dynamic>> getDataProdukPerluRestok({
    String kategori = 'all',
  }) async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTampilProdukPerluRestok${kategori != 'all' ? '?kategori=$kategori' : ''}',
    );

    try {
      final hasilResponse = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (hasilResponse.statusCode == 200 || hasilResponse.statusCode == 201) {
        final responseData = jsonDecode(hasilResponse.body);
        final List<dynamic> data = responseData['data'] ?? [];
        final List<dynamic> kategoriList = responseData['kategori'] ?? [];

        List<ProdukPerluRestok> produkList =
            data.map((item) {
              return ProdukPerluRestok(
                namaProduk: item['nama_produk'].toString(),
                kategori: item['kategori'].toString(),
                linkGambarVarian: item['link_gambar_varian'].toString(),
                warna: item['warna'].toString(),
                ukuran:
                    item['ukuran'] is int
                        ? item['ukuran']
                        : int.tryParse(item['ukuran'].toString()) ?? 0,
                stok:
                    item['stok'] is int
                        ? item['stok']
                        : int.tryParse(item['stok'].toString()) ?? 0,
              );
            }).toList();

        List<String> availableKategori =
            kategoriList.map((k) => k['kategori'].toString()).toList();

        return {'produk': produkList, 'kategori': availableKategori};
      } else {
        return {'produk': <ProdukPerluRestok>[], 'kategori': <String>[]};
      }
    } catch (e) {
      throw Exception('Gagal memuat data produk perlu restok: $e');
    }
  }
}

class UlasanProduk {
  int rating;
  String komentar;
  String tanggalKomentar;
  String nama;

  UlasanProduk({
    required this.rating,
    required this.komentar,
    required this.tanggalKomentar,
    required this.nama,
  });

  static Future<List<UlasanProduk>> getDataUlasanProduk(String id) async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTampilUlasanProduk/$id',
    );

    try {
      final hasilResponse = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (hasilResponse.statusCode == 200 || hasilResponse.statusCode == 201) {
        final List<dynamic> data = jsonDecode(hasilResponse.body)['data'];
        return data.map((item) {
          return UlasanProduk(
            rating: item['rating'],
            komentar: item['komentar'].toString(),
            tanggalKomentar: item['tanggal_komentar'].toString(),
            nama: item['nama'].toString(),
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Gagal memuat data ulasan produk: $e');
    }
  }
}

class AbsensiKaryawan {
  String nama;
  String tanggal;
  String absenMasuk;

  AbsensiKaryawan({
    required this.nama,
    required this.tanggal,
    required this.absenMasuk,
  });

  static Future<List<AbsensiKaryawan>> getDataAbsensiKaryawan() async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTampilKaryawanAbsensi',
    );

    try {
      final hasilResponse = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (hasilResponse.statusCode == 200 || hasilResponse.statusCode == 201) {
        final List<dynamic> data = jsonDecode(hasilResponse.body)['data'];
        return data.map((item) {
          return AbsensiKaryawan(
            nama: item['nama'].toString(),
            tanggal: item['tanggal'].toString(),
            absenMasuk: item['absen_masuk'].toString(),
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Gagal memuat data absensi karyawan: $e');
    }
  }
}

//CLASS UNTUK MENAMPILKAN DATA FAKTUR ONLINE
class FakturItem {
  final String namaBarang;
  final String warna;
  final String ukuran;
  final dynamic jumlahOrder;
  final dynamic harga;

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
      jumlahOrder: json['jumlah_order'],
      harga: json['harga'],
    );
  }
}

class Faktur {
  final String nomorFaktur;
  final String tanggalFaktur;
  final String id;
  final String namaPengguna;
  final String alamatPengiriman;
  final String status;
  final List<FakturItem> items;

  Faktur({
    required this.nomorFaktur,
    required this.tanggalFaktur,
    required this.id,
    required this.namaPengguna,
    required this.alamatPengiriman,
    required this.status,
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
      alamatPengiriman: json['alamat_pengiriman']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      items: itemList,
    );
  }
}

class ApiService {
  final String baseUrl = 'http://192.168.1.96:3000/api';

  Future<List<Faktur>> fetchFakturOnlineAdmin() async {
    final response = await http.get(
      Uri.parse('$baseUrl/adminTampilFakturOnline'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData is Map<String, dynamic> && jsonData['data'] is List) {
        List<dynamic> dataList = jsonData['data'];
        return dataList.map((data) => Faktur.fromJson(data)).toList();
      } else {
        throw Exception('Format data tidak valid');
      }
    } else {
      return [];
    }
  }
}

//class untuk menampilkan data pengajuan karyawan
class IzinKaryawan {
  String id;
  String nama;
  String tipeIzin;
  String deskripsi;
  String status;
  String tanggalMulai;
  String tanggalAkhir;

  IzinKaryawan({
    required this.id,
    required this.nama,
    required this.tipeIzin,
    required this.deskripsi,
    required this.status,
    required this.tanggalMulai,
    required this.tanggalAkhir,
  });

  static Future<List<IzinKaryawan>> getDataIzinKaryawan() async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTampilKaryawanIzin',
    );

    try {
      final hasilResponse = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (hasilResponse.statusCode == 200 || hasilResponse.statusCode == 201) {
        final List<dynamic> data = jsonDecode(hasilResponse.body)['data'];
        return data.map((item) {
          return IzinKaryawan(
            id: item['id'].toString(),
            nama: item['nama'].toString(),
            tipeIzin: item['tipe_izin'].toString(),
            deskripsi: item['deskripsi'].toString(),
            status: item['status'].toString(),
            tanggalMulai: item['tanggal_mulai'].toString(),
            tanggalAkhir: item['tanggal_akhir'].toString(),
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Gagal memuat data izin karyawan: $e');
    }
  }
}

//class untuk menampilkan detail izin karyawan
class DetailIzinKaryawan {
  String nama;
  String tipeIzin;
  String deskripsi;
  String status;
  String tanggalMulai;
  String tanggalAkhir;

  DetailIzinKaryawan({
    required this.nama,
    required this.tipeIzin,
    required this.deskripsi,
    required this.status,
    required this.tanggalMulai,
    required this.tanggalAkhir,
  });

  static Future<DetailIzinKaryawan?> getDetailIzinKaryawan(String id) async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTampilKaryawanIzinDetail/$id',
    );

    try {
      final hasilResponse = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (hasilResponse.statusCode == 200 || hasilResponse.statusCode == 201) {
        final data = jsonDecode(hasilResponse.body)['data'][0];
        return DetailIzinKaryawan(
          nama: data['nama'].toString(),
          tipeIzin: data['tipe_izin'].toString(),
          deskripsi: data['deskripsi'].toString(),
          status: data['status'].toString(),
          tanggalMulai: data['tanggal_mulai'].toString(),
          tanggalAkhir: data['tanggal_akhir'].toString(),
        );
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Gagal memuat detail izin karyawan: $e');
    }
  }
}

//CLASS POST
class TambahAkunService {
  static Future<String> tambahAkun({
    required String username,
    required String password,
    required String nama,
    required String email,
    required String nomorTelp,
    required String role,
  }) async {
    final url = Uri.parse('http://192.168.1.96:3000/api/adminTambahAkun');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'nama_lengkap': nama,
          'email': email,
          'nomor_telepon': nomorTelp,
          'role': role,
        }),
      );

      final body = jsonDecode(response.body);
      return body['pesan'] ?? 'Akun berhasil ditambahkan';
    } catch (e) {
      return 'Gagal menambah akun: $e';
    }
  }
}

class TambahMetodePembayaranService {
  static Future<String> tambahMetodePembayaran({
    required String namaMetode,
    required String deskripsi,
  }) async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTambahMetodePembayaran',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nama_metode': namaMetode, 'deskripsi': deskripsi}),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return body['pesan'] ?? 'Metode pembayaran berhasil ditambahkan';
      } else {
        return body['pesan'] ?? 'Gagal menambahkan metode pembayaran';
      }
    } catch (e) {
      return 'Gagal menghubungi server: $e';
    }
  }
}

//CLASS UPDATE
class UpdateUserStatusService {
  static Future<String> updateUserStatus({
    required String id,
    required String status,
  }) async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/admin/update-user-status',
    );

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status, 'id': id}),
      );

      final body = jsonDecode(response.body);
      return body['pesan'] ?? 'Status pengguna berhasil diperbarui';
    } catch (e) {
      return 'Gagal update status pengguna: $e';
    }
  }
}

class UpdateAkunService {
  static Future<String> updateAkun({
    required String id,
    required String username,
    required String password,
    required String namaLengkap,
    required String email,
    required String nomorTelp,
    required String role,
  }) async {
    final url = Uri.parse('http://192.168.1.96:3000/api/adminUpdateAkun/$id');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'username': username,
          'password': password,
          'nama_lengkap': namaLengkap,
          'email': email,
          'nomor_telepon': nomorTelp,
          'role': role,
        }),
      );

      final body = jsonDecode(response.body);
      return body['pesan'] ?? 'Akun berhasil diperbarui';
    } catch (e) {
      return 'Gagal update akun: $e';
    }
  }
}

class UpdateIzinKaryawanService {
  static Future<String> updateStatusIzinKaryawan({
    required String id,
    required String status,
  }) async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminUpdateKaryawanIzin/$id',
    );

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return body['pesan'] ?? 'Status berhasil diupdate';
      } else {
        return body['pesan'] ?? 'Gagal update status';
      }
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }
}

class UpdatePengirimanService {
  static Future<String> updateStatusPengiriman({
    required String id,
    required String status,
  }) async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminUpdatePengiriman/$id',
    );

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status_pengiriman': status}),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return body['pesan'] ?? 'Status pengiriman berhasil diupdate';
      } else {
        return body['pesan'] ?? 'Gagal update status pengiriman';
      }
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }
}

class UpdateMetodePembayaranService {
  static Future<String> updateMetodePembayaran({
    required String id,
    required String namaMetode,
    required String deskripsi,
  }) async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminUpdateMetodePembayaran/$id',
    );

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nama_metode': namaMetode, 'deskripsi': deskripsi}),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return body['pesan'] ?? 'Metode pembayaran berhasil diupdate';
      } else {
        return body['pesan'] ?? 'Gagal update metode pembayaran';
      }
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }
}

class UpdateVerifikasiPembayaranService {
  static Future<String> updateStatusVerifikasiPembayaran({
    required String id,
    required String status,
    String? catatanAdmin,
  }) async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminUpdateVerifikasiPembayaran/$id',
    );

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status': status,
          if (catatanAdmin != null) 'catatan_admin': catatanAdmin,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return body['pesan'] ??
            'Status verifikasi pembayaran berhasil diupdate';
      } else {
        return body['pesan'] ?? 'Gagal update status verifikasi pembayaran';
      }
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }
}

class UpdateHargaProdukEcoService {
  static Future<String> updateHargaProdukEco({
    required String idProduk,
    required String hargaAsli,
  }) async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminUpdateHargaProdukEco/$idProduk',
    );

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'harga_asli': hargaAsli}),
      );

      final body = jsonDecode(response.body);
      return body['pesan'] ?? 'Harga produk berhasil diperbarui';
    } catch (e) {
      return 'Gagal update harga produk: $e';
    }
  }
}

//CLASS DELETE
class HapusAkunService {
  static Future<http.Response> hapusAkun(int id) async {
    final url = Uri.parse('http://192.168.1.96:3000/api/adminDeleteAkun/$id');

    try {
      final response = await http.delete(url);
      return response;
    } catch (e) {
      // Tetap lempar Exception agar bisa ditangani di _performDelete()
      throw Exception('Gagal menghapus akun: $e');
    }
  }
}

class HapusPRodukService {
  static Future<String> hapusProduk(String id) async {
    final url = Uri.parse('http://192.168.1.96:3000/api/adminDeleteProduk/$id');

    try {
      final response = await http.delete(url);

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return body['pesan'] ?? 'Produk berhasil dihapus';
      } else {
        return body['pesan'] ?? 'Gagal menghapus produk';
      }
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }
}

class HapusMetodePembayaranService {
  static Future<String> hapusMetodePembayaran(String id) async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminDeleteMetodePembayaran/$id',
    );

    try {
      final response = await http.delete(url);

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return body['pesan'] ?? 'Metode pembayaran berhasil dihapus';
      } else {
        return body['pesan'] ?? 'Gagal menghapus metode pembayaran';
      }
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }
}

class AdminHapusVarianProduk {
  static Future<String> hapusVarianProduk(String id) async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminDeleteVarianProduk/$id',
    );

    try {
      final response = await http.delete(url);

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return body['pesan'] ?? 'Varian produk berhasil dihapus';
      } else {
        return body['pesan'] ?? 'Gagal menghapus varian produk';
      }
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }
}

//KHUSUS TAMBAH PRODUK
class PostTambahProduk {
  final String pesan;
  final bool success;

  PostTambahProduk({required this.pesan, this.success = true});

  static Future<PostTambahProduk> kirimProduk({
    required String namaProduk,
    required String deskripsi,
    required String hargaProduk,
    required String hargaAwal,
    required String hargaModal,
    required String kategori,
    required List<File> gambarList, // gambarUtama + gambar varian
    required List<VarianProduk> varianList,
    File? videoDemo, // TAMBAHAN: Video demo (opsional)
  }) async {
    final url = Uri.parse('http://192.168.1.96:3000/api/adminTambahProduk');

    try {
      final request = http.MultipartRequest('POST', url);

      // Form fields
      request.fields['nama_produk'] = namaProduk;
      request.fields['deskripsi'] = deskripsi;
      request.fields['harga_produk'] = hargaProduk;
      request.fields['harga_awal'] = hargaAwal;
      request.fields['harga_modal'] = hargaModal;
      request.fields['kategori'] = kategori;

      // Konversi list varian ke JSON string
      List<Map<String, dynamic>> varianJsonList =
          varianList.map((e) => e.toJson()).toList();
      request.fields['varian'] = jsonEncode(varianJsonList);

      // Upload semua gambar
      for (File file in gambarList) {
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final multipartFile = await http.MultipartFile.fromPath(
          'files', // UBAH: sesuai dengan backend yang baru (upload.array('files'))
          file.path,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      // TAMBAHAN: Upload video demo jika ada
      if (videoDemo != null) {
        final mimeType = lookupMimeType(videoDemo.path) ?? 'video/mp4';
        final videoFile = await http.MultipartFile.fromPath(
          'files', // Menggunakan field yang sama dengan gambar
          videoDemo.path,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(videoFile);
      }

      final response = await request.send().timeout(
        const Duration(seconds: 30), // UBAH: Naikkan timeout untuk video
        onTimeout: () {
          throw Exception('Koneksi timeout. Periksa koneksi internet Anda.');
        },
      );

      final responseBody = await response.stream.bytesToString();

      if (responseBody.isEmpty) {
        return PostTambahProduk(
          pesan: 'Server mengembalikan respon kosong.',
          success: false,
        );
      }

      final data = jsonDecode(responseBody);

      if (response.statusCode == 201) {
        return PostTambahProduk(
          pesan: data['pesan'] ?? 'Produk berhasil ditambahkan.',
          success: true,
        );
      } else {
        return PostTambahProduk(
          pesan: data['pesan'] ?? 'Gagal menambahkan produk.',
          success: false,
        );
      }
    } on FormatException {
      return PostTambahProduk(
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
      }

      return PostTambahProduk(pesan: errorMessage, success: false);
    }
  }
}

class VarianProduk {
  final String warna;
  final List<UkuranVarian> ukuranList;
  final File? gambarVarian;

  VarianProduk({
    required this.warna,
    required this.ukuranList,
    this.gambarVarian,
  });

  Map<String, dynamic> toJson() {
    return {
      'warna': warna,
      'ukuran': ukuranList.map((e) => e.toJson()).toList(),
    };
  }
}

class UkuranVarian {
  final String ukuran;
  final int stok;

  UkuranVarian({required this.ukuran, required this.stok});

  Map<String, dynamic> toJson() => {'ukuran': ukuran, 'stok': stok};
}

//KHUSUS MENAMPILKAN DATA UNTUK UPDATE PRODUK
class DataVarianProduk {
  final int id;
  final int idProduk;
  final String warna;
  final int ukuran;
  final int stok;
  final String linkGambarVarian;

  DataVarianProduk({
    required this.id,
    required this.idProduk,
    required this.warna,
    required this.ukuran,
    required this.stok,
    required this.linkGambarVarian,
  });

  factory DataVarianProduk.fromJson(Map<String, dynamic> json) {
    return DataVarianProduk(
      id: json['id'],
      idProduk: json['id_produk'],
      warna: json['warna'],
      ukuran: json['ukuran'],
      stok: json['stok'],
      linkGambarVarian: json['link_gambar_varian'],
    );
  }
}

class DataDetailProduk {
  final int id;
  final String nama;
  final String deskripsi;
  final String harga;
  final String hargaAwal;
  final String linkGambar;
  final String kategori;
  final String? videoDemo; // TAMBAHAN: Field untuk video demo
  final List varian;

  DataDetailProduk({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.hargaAwal,
    required this.linkGambar,
    required this.kategori,
    this.videoDemo, // TAMBAHAN: Video demo bersifat opsional
    required this.varian,
  });

  factory DataDetailProduk.fromJson(Map json) {
    final produk = json['produk'];
    final List varianList = json['varian'] ?? [];

    return DataDetailProduk(
      id: produk['id'],
      nama: produk['nama'],
      deskripsi: produk['deskripsi'],
      harga: produk['harga'],
      hargaAwal: produk['harga_awal'],
      linkGambar: produk['link_gambar'],
      kategori: produk['kategori'],
      videoDemo:
          produk['video_demo'], // TAMBAHAN: Ambil video demo dari response
      varian: varianList.map((v) => DataVarianProduk.fromJson(v)).toList(),
    );
  }

  static Future fetchDataDetailProduk(String id) async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTampilUpdateProduk/$id',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        return DataDetailProduk.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Gagal mengambil detail produk: $e');
    }
  }
}

//KHUSUS UPDATE PRODUK
class PostUpdateProduk {
  final String pesan;
  final bool success;
  final Map<String, dynamic>? data;

  PostUpdateProduk({required this.pesan, this.success = true, this.data});

  static Future<PostUpdateProduk> kirimUpdateProduk({
    required String id,
    required String namaProduk,
    required String deskripsi,
    required String hargaProduk,
    required String hargaAwal,
    required List<File> fileList, // Ubah dari gambarList ke fileList
    required List<Map<String, dynamic>> varianList,
    bool adaGambarUtamaBaru = false,
    bool adaVideoDemoBaru = false, // Parameter baru untuk video
  }) async {
    final url = Uri.parse('http://192.168.1.96:3000/api/adminUpdateProduk/$id');

    try {
      final request = http.MultipartRequest('PATCH', url);

      // Set fields
      request.fields['nama_produk'] = namaProduk;
      request.fields['deskripsi'] = deskripsi;
      request.fields['harga_produk'] = hargaProduk;
      request.fields['harga_awal'] = hargaAwal;
      request.fields['ada_gambar_utama_baru'] = adaGambarUtamaBaru.toString();
      request.fields['ada_video_demo_baru'] = adaVideoDemoBaru.toString();
      request.fields['varian'] = jsonEncode(varianList);

      print("🟡 Kirim field:");
      print("nama_produk: $namaProduk");
      print("deskripsi: $deskripsi");
      print("harga_produk: $hargaProduk");
      print("harga_awal: $hargaAwal");
      print("ada_gambar_utama_baru: $adaGambarUtamaBaru");
      print("ada_video_demo_baru: $adaVideoDemoBaru");
      print("varianList (encoded): ${jsonEncode(varianList)}");

      // Pisahkan file berdasarkan tipe
      List<File> imageFiles = [];
      List<File> videoFiles = [];

      for (var file in fileList) {
        final mimeType = lookupMimeType(file.path) ?? '';
        if (mimeType.startsWith('image/')) {
          imageFiles.add(file);
        } else if (mimeType.startsWith('video/')) {
          videoFiles.add(file);
        }
      }

      print("📊 Analisis Files:");
      print("Total files: ${fileList.length}");
      print("Image files: ${imageFiles.length}");
      print("Video files: ${videoFiles.length}");

      // Upload semua files dengan field name 'files' (sesuai backend)
      int fileIndex = 0;

      // Upload gambar utama jika ada
      if (adaGambarUtamaBaru && imageFiles.isNotEmpty) {
        var file = imageFiles[0];
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final multipartFile = await http.MultipartFile.fromPath(
          'files', // Ubah field name sesuai backend
          file.path,
          contentType: MediaType.parse(mimeType),
          filename: file.path.split('/').last,
        );

        print(
          "🟢 Upload [GAMBAR UTAMA] index $fileIndex: ${file.path.split('/').last}",
        );
        request.files.add(multipartFile);
        fileIndex++;
      }

      // Upload gambar varian
      int varianImageIndex = adaGambarUtamaBaru ? 1 : 0;
      int varianImageCount = 0;

      // Hitung berapa gambar varian yang dibutuhkan
      for (var varian in varianList) {
        if (varian['has_new_image'] == true) {
          varianImageCount++;
        }
      }

      // Upload gambar varian sesuai kebutuhan
      for (
        int i = 0;
        i < varianImageCount && varianImageIndex < imageFiles.length;
        i++
      ) {
        var file = imageFiles[varianImageIndex];
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final multipartFile = await http.MultipartFile.fromPath(
          'files', // Ubah field name sesuai backend
          file.path,
          contentType: MediaType.parse(mimeType),
          filename: file.path.split('/').last,
        );

        print(
          "🟢 Upload [GAMBAR VARIAN ${i + 1}] index $fileIndex: ${file.path.split('/').last}",
        );
        request.files.add(multipartFile);
        fileIndex++;
        varianImageIndex++;
      }

      // Upload video demo jika ada
      if (adaVideoDemoBaru && videoFiles.isNotEmpty) {
        var file = videoFiles[0];
        final mimeType = lookupMimeType(file.path) ?? 'video/mp4';
        final multipartFile = await http.MultipartFile.fromPath(
          'files', // Ubah field name sesuai backend
          file.path,
          contentType: MediaType.parse(mimeType),
          filename: file.path.split('/').last,
        );

        print(
          "🟢 Upload [VIDEO DEMO] index $fileIndex: ${file.path.split('/').last}",
        );
        request.files.add(multipartFile);
        fileIndex++;
      }

      print("📤 Total files yang diupload: ${request.files.length}");

      final response = await request.send().timeout(
        const Duration(seconds: 60), // Extend timeout untuk video
        onTimeout: () {
          throw Exception('Koneksi timeout. Periksa koneksi internet Anda.');
        },
      );

      final responseBody = await response.stream.bytesToString();

      print("📥 Status code: ${response.statusCode}");
      print("📥 Response body: $responseBody");

      if (responseBody.isEmpty) {
        return PostUpdateProduk(
          pesan: 'Server mengembalikan respon kosong.',
          success: false,
        );
      }

      final data = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        print("✅ Berhasil update produk.");
        return PostUpdateProduk(
          pesan: data['pesan'] ?? 'Produk berhasil diperbarui.',
          success: true,
          data: data['data'],
        );
      } else {
        print("❌ Gagal update. Pesan: ${data['pesan']}");
        return PostUpdateProduk(
          pesan: data['pesan'] ?? 'Gagal memperbarui produk.',
          success: false,
        );
      }
    } on FormatException catch (e) {
      print("❌ FormatException: $e");
      return PostUpdateProduk(
        pesan: 'Format respon server tidak valid.',
        success: false,
      );
    } catch (e) {
      print("❌ Exception saat kirimUpdateProduk: $e");
      String errorMessage = 'Terjadi kesalahan tidak terduga.';

      if (e.toString().contains('SocketException')) {
        errorMessage =
            'Tidak dapat terhubung ke server. Periksa koneksi internet.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Koneksi timeout. Coba lagi nanti.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Format data tidak valid.';
      } else if (e.toString().contains('ClientException')) {
        errorMessage = 'Kesalahan koneksi ke server.';
      }

      return PostUpdateProduk(pesan: errorMessage, success: false);
    }
  }

  // Helper method untuk validasi file
  static bool isValidImageFile(File file) {
    final mimeType = lookupMimeType(file.path) ?? '';
    return mimeType.startsWith('image/') &&
        (mimeType.contains('jpeg') || mimeType.contains('png'));
  }

  static bool isValidVideoFile(File file) {
    final mimeType = lookupMimeType(file.path) ?? '';
    return mimeType.startsWith('video/') &&
        (mimeType.contains('mp4') ||
            mimeType.contains('quicktime') ||
            mimeType.contains('x-msvideo'));
  }

  // Helper method untuk mendapatkan ukuran file dalam MB
  static double getFileSizeInMB(File file) {
    int bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  // Method untuk validasi sebelum upload
  static Map<String, dynamic> validateFiles(List<File> fileList) {
    List<String> errors = [];
    double totalSize = 0;

    for (var file in fileList) {
      double fileSizeInMB = getFileSizeInMB(file);
      totalSize += fileSizeInMB;

      // Validasi tipe file
      if (!isValidImageFile(file) && !isValidVideoFile(file)) {
        errors.add(
          'File ${file.path.split('/').last} tidak didukung. Hanya JPEG, PNG, MP4, MOV, AVI yang diizinkan.',
        );
      }

      // Validasi ukuran file
      if (fileSizeInMB > 50) {
        errors.add(
          'File ${file.path.split('/').last} terlalu besar (${fileSizeInMB.toStringAsFixed(1)}MB). Maksimal 50MB.',
        );
      }
    }

    // Validasi total ukuran
    if (totalSize > 200) {
      errors.add(
        'Total ukuran file terlalu besar (${totalSize.toStringAsFixed(1)}MB). Maksimal 200MB.',
      );
    }

    return {
      'valid': errors.isEmpty,
      'errors': errors,
      'totalSizeMB': totalSize,
    };
  }
}

// Extension untuk kemudahan penggunaan
extension PostUpdateProdukExtension on PostUpdateProduk {
  bool get isSuccess => success;
  bool get isFailure => !success;

  String get message => pesan;

  Map<String, dynamic>? get responseData => data;
}

//khusus gaji karyawan
class GajiKaryawan {
  final int id;
  final int idPengguna;
  final int jumlahGaji;

  GajiKaryawan({
    required this.id,
    required this.idPengguna,
    required this.jumlahGaji,
  });

  factory GajiKaryawan.fromJson(Map<String, dynamic> json) {
    return GajiKaryawan(
      id: json['id'] ?? 0,
      idPengguna: json['id_pengguna'] ?? 0,
      jumlahGaji: json['jumlah_gaji'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': idPengguna, // backend expects 'id' not 'id_pengguna'
      'jumlah_gaji': jumlahGaji,
    };
  }
}

// Response wrapper untuk operasi CRUD
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;

  ApiResponse({required this.success, this.data, required this.message});
}

class GajiKaryawanService {
  static const String baseUrl = 'http://192.168.1.96:3000/api';

  // Helper method untuk handle response error
  static String _getErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? body['error'] ?? 'Terjadi kesalahan';
    } catch (e) {
      switch (response.statusCode) {
        case 400:
          return 'Data yang dikirim tidak valid';
        case 401:
          return 'Tidak memiliki akses';
        case 403:
          return 'Akses ditolak';
        case 404:
          return 'Data tidak ditemukan';
        case 500:
          return 'Terjadi kesalahan pada server';
        default:
          return 'Terjadi kesalahan (${response.statusCode})';
      }
    }
  }

  // Helper method untuk handle network error
  static String _handleNetworkError(dynamic error) {
    if (error is SocketException) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    } else if (error is TimeoutException) {
      return 'Koneksi timeout. Coba lagi nanti.';
    } else {
      return 'Terjadi kesalahan jaringan: ${error.toString()}';
    }
  }

  // POST: Menambahkan data gaji karyawan
  static Future<ApiResponse<bool>> tambahGajiKaryawan(GajiKaryawan gaji) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/adminTambahGajiKaryawan'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(gaji.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          data: true,
          message: 'Data gaji berhasil ditambahkan',
        );
      } else {
        return ApiResponse(
          success: false,
          data: false,
          message: _getErrorMessage(response),
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        data: false,
        message: _handleNetworkError(e),
      );
    }
  }

  // PATCH: Update data gaji karyawan
  static Future<ApiResponse<bool>> updateGajiKaryawan(
    int id,
    int jumlahGaji,
  ) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/adminUpdateGajiKaryawan/$id'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'jumlah_gaji': jumlahGaji}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: true,
          message: 'Data gaji berhasil diperbarui',
        );
      } else {
        return ApiResponse(
          success: false,
          data: false,
          message: _getErrorMessage(response),
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        data: false,
        message: _handleNetworkError(e),
      );
    }
  }

  // DELETE: Hapus data gaji karyawan
  static Future<ApiResponse<bool>> deleteGajiKaryawan(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/adminDeleteGajiKaryawan/$id'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: true,
          message: 'Data gaji berhasil dihapus',
        );
      } else {
        return ApiResponse(
          success: false,
          data: false,
          message: _getErrorMessage(response),
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        data: false,
        message: _handleNetworkError(e),
      );
    }
  }
}

class PenggunaKaryawan {
  final int id;
  final String nama;

  PenggunaKaryawan({required this.id, required this.nama});

  factory PenggunaKaryawan.fromJson(Map<String, dynamic> json) {
    return PenggunaKaryawan(id: json['id'], nama: json['nama']);
  }

  static Future<List<PenggunaKaryawan>> fetchPenggunaKaryawan() async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTampilDataPenggunaKaryawan',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List dataList = body['data'];
        return dataList.map((e) => PenggunaKaryawan.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Gagal mengambil data pengguna karyawan: $e');
    }
  }
}

class TampilGajiKaryawan {
  final int id;
  final String nama;
  final String gaji;

  TampilGajiKaryawan({
    required this.id,
    required this.nama,
    required this.gaji,
  });

  factory TampilGajiKaryawan.fromJson(Map<String, dynamic> json) {
    return TampilGajiKaryawan(
      id: json['id'],
      nama: json['nama'],
      gaji: json['gaji'],
    );
  }

  static Future<List<TampilGajiKaryawan>> fetchGajiKaryawan() async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTampilGajiKaryawan',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List dataList = body['data'];
        return dataList.map((e) => TampilGajiKaryawan.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Gagal mengambil data gaji karyawan: $e');
    }
  }
}

//Khusus keranjang admin
class KeranjangItem {
  final String idItemOrder; // Tetap String karena digunakan untuk API call
  final int idVarianProduk;
  final String linkGambarVarian;
  final int hargaAwal;
  final String namaProduk;
  final String warna;
  final String ukuran;
  final int jumlah;
  final int hargaSatuan;

  KeranjangItem({
    required this.idItemOrder,
    required this.idVarianProduk,
    required this.linkGambarVarian,
    required this.hargaAwal,
    required this.namaProduk,
    required this.warna,
    required this.ukuran,
    required this.jumlah,
    required this.hargaSatuan,
  });

  factory KeranjangItem.fromJson(Map<String, dynamic> json) {
    return KeranjangItem(
      // Konversi id_item_order ke String
      idItemOrder: json['id_item_order']?.toString() ?? '0',
      idVarianProduk: json['id_varian_produk'] ?? 0,
      linkGambarVarian: json['link_gambar_varian']?.toString() ?? '',
      hargaAwal: _parseToInt(json['harga_awal']),
      namaProduk: json['nama_produk']?.toString() ?? '',
      warna: json['warna']?.toString() ?? '',
      ukuran: json['ukuran']?.toString() ?? '',
      jumlah: _parseToInt(json['jumlah']),
      hargaSatuan: _parseToInt(json['harga_satuan']),
    );
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static Future<List<KeranjangItem>> fetchKeranjang(String idPengguna) async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTampilKeranjang/$idPengguna',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Handle different response structures
        List dataList;
        if (responseBody is List) {
          dataList = responseBody;
        } else if (responseBody is Map && responseBody.containsKey('data')) {
          dataList = responseBody['data'];
        } else {
          dataList = [];
        }

        return dataList
            .map((e) => KeranjangItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Gagal mengambil data keranjang: $e');
    }
  }
}

//KHUSUS MENGAMBIL DATA PENGGUNA PEMBELI
class PenggunaPembeli {
  final int id;
  final String nama;

  PenggunaPembeli({required this.id, required this.nama});

  factory PenggunaPembeli.fromJson(Map<String, dynamic> json) {
    return PenggunaPembeli(id: json['id'], nama: json['nama']);
  }

  static Future<List<PenggunaPembeli>> fetchPenggunaPembeli() async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTampilDataPenggunaPembeli',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List dataList = body['data'];
        return dataList.map((e) => PenggunaPembeli.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Gagal mengambil data pengguna pembeli: $e');
    }
  }
}

//Khusus tambah keranjang admin
class TambahKeranjangAdmin {
  String idVarianProduk;
  String jumlahOrder;
  String? hargaKhusus; // opsional

  TambahKeranjangAdmin({
    required this.idVarianProduk,
    required this.jumlahOrder,
    this.hargaKhusus,
  });

  static Future<String?> addToKeranjang(
    String idPengguna,
    String idVarianProduk,
    String jumlahOrder, {
    String? hargaKhusus,
  }) async {
    if (idVarianProduk.isEmpty || jumlahOrder.isEmpty) {
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

    Uri url = Uri.parse(
      "http://192.168.1.96:3000/api/adminTambahKeranjang/$idPengguna",
    );

    // body dinamis
    final body = {
      'id_varian_produk': idVarianProduk,
      'jumlah_order': jumlahOrder,
    };
    if (hargaKhusus != null && hargaKhusus.isNotEmpty) {
      body['harga_khusus'] = hargaKhusus;
    }

    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
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
