import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pittalk_mobile/features/news/data/news_model.dart';
import 'package:pittalk_mobile/features/forums/data/forums_model.dart';

class ApiService {
  static const baseUrl = "https://your-django-domain.com"; //wait

  static Future<List<News>> fetchNews() async {
    final resp = await http.get(Uri.parse('$baseUrl/news/json/'));
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.map((e) => News.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<ForumsEntry>> fetchForums() async {
    final resp = await http.get(Uri.parse('$baseUrl/forums/api/json/'));
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.map((e) => ForumsEntry.fromJson(e)).toList();
    }
    return [];
  }
}
