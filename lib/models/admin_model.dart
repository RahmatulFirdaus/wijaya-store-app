import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//CLASS GET

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
  String linkGambarVarian;
  String warna;
  int ukuran;
  int stok;

  ProdukPerluRestok({
    required this.namaProduk,
    required this.linkGambarVarian,
    required this.warna,
    required this.ukuran,
    required this.stok,
  });

  static Future<List<ProdukPerluRestok>> getDataProdukPerluRestok() async {
    final url = Uri.parse(
      'http://192.168.1.96:3000/api/adminTampilProdukPerluRestok',
    );

    try {
      final hasilResponse = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (hasilResponse.statusCode == 200 || hasilResponse.statusCode == 201) {
        final List<dynamic> data = jsonDecode(hasilResponse.body)['data'];
        return data.map((item) {
          return ProdukPerluRestok(
            namaProduk: item['nama_produk'].toString(),
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
      } else {
        return [];
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

//CLASS UPDATE
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




//CLASS DELETE