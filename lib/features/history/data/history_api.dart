import 'dart:convert';
import 'package:http/http.dart' as http;

// Driver & Winner model
import 'models/driver_model.dart';
import 'models/winner_model.dart';

/// API Service untuk Flutter (Driver + Winner)
class HistoryApi {
  // === Base URL ===
  // --- Pakai localhost ntar dihanti pakai pws aja biar bisa akses Django --- 
  // Localhost: "http://localhost:8000/history";
  final String baseUrl = "https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/history";


  // === DRIVER API ===
  // --- GET Drivers ---
  Future<List<Driver>> fetchDrivers() async {
    final res = await http.get(Uri.parse("$baseUrl/api/drivers/"));

    if (res.statusCode != 200) {
      throw Exception("Gagal mengambil data driver");
    }

    final List raw = jsonDecode(res.body);

    // Convert ke Driver model
    final List<Driver> drivers =
        raw.map((json) => Driver.fromJson(json)).toList();

    // Sorting sesuai yg ada di website
    drivers.sort((a, b) {
      final ay = a.year;
      final by = b.year;
      if (ay != by) return ay.compareTo(by);
      return b.points.compareTo(a.points);
    });

    return drivers;
  }

  // --- ADD Driver ---
  Future<bool> addDriver(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/driver/add/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return res.statusCode == 200;
  }

  // --- EDIT Driver ---
  Future<bool> editDriver(int id, Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/driver/edit/$id/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return res.statusCode == 200;
  }

  // --- DELETE Driver ---
  Future<bool> deleteDriver(int id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/driver/delete/$id/"),
    );

    return res.statusCode == 200;
  }

  // === IMAGE PROXY ===
  String proxyImage(String? url) {
    if (url == null || url.isEmpty) return "";
    return "$baseUrl/proxy-image/?url=$url";
  }

  // alias
  String proxiedImage(String? url) {
    if (url == null || url.isEmpty) return "";
    return "$baseUrl/proxy-image/?url=$url";
  }

  // === WINNER API ===
  // --- GET Winners ---
  Future<List<Winner>> fetchWinners() async {
    final res = await http.get(Uri.parse("$baseUrl/api/winners/"));

    if (res.statusCode != 200) {
      throw Exception("Gagal mengambil data winner");
    }

    final List raw = jsonDecode(res.body);

    // Convert ke Winner model
    return raw.map((json) => Winner.fromJson(json)).toList();
  }

  // --- ADD Winner ---
  Future<bool> addWinner(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/winner/add/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return res.statusCode == 200;
  }

  // --- EDIT Winner ---
  Future<bool> editWinner(int id, Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/winner/edit/$id/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return res.statusCode == 200;
  }

  // --- DELETE Winner ---
  Future<bool> deleteWinner(int id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/winner/delete/$id/"),
    );

    return res.statusCode == 200;
  }
}
