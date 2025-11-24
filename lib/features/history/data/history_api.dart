import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/driver_model.dart';

/// API Service untuk Flutter
class HistoryApi {
  // --- Pakai localhost ntar dihanti pakai pws aja biar bisa akses Django ---
  final String baseUrl = "http://localhost:8000/history";

  // ============================================================
  // GET DRIVERS
  // ============================================================
  Future<List<Driver>> fetchDrivers() async {
    final res = await http.get(Uri.parse("$baseUrl/api/drivers/"));

    if (res.statusCode != 200) {
      throw Exception("Gagal mengambil data driver");
    }

    final List raw = jsonDecode(res.body);

    // Convert ke Driver model
    final List<Driver> drivers =
        raw.map((json) => Driver.fromJson(json)).toList();

    // --- Sorting sesuai web (year asc → points desc) ---
    drivers.sort((a, b) {
      final ay = a.year;
      final by = b.year;
      if (ay != by) return ay.compareTo(by);
      return b.points.compareTo(a.points);
    });

    return drivers;
  }

  // ============================================================
  // ADD DRIVER
  // ============================================================
  Future<bool> addDriver(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/driver/add/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return res.statusCode == 200;
  }

  // ============================================================
  // EDIT DRIVER
  // ============================================================
  Future<bool> editDriver(int id, Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/driver/edit/$id/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return res.statusCode == 200;
  }

  // ============================================================
  // DELETE DRIVER
  // ============================================================
  Future<bool> deleteDriver(int id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/driver/delete/$id/"),
    );

    return res.statusCode == 200;
  }

  // ============================================================
  // IMAGE PROXY (supaya Flutter Web/Android bisa load gambar)
  // ============================================================
  String proxyImage(String? url) {
    if (url == null || url.isEmpty) return "";
    return "$baseUrl/proxy-image/?url=$url";
  }

  // ==== IMAGE PROXY ====
  String proxiedImage(String? url) {
    if (url == null || url.isEmpty) return "";
    return "$baseUrl/proxy-image/?url=$url";
  }
}
