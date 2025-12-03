import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pittalk_mobile/features/forums/data/forums_model.dart';

class ForumsApi {
  static const baseUrl = "https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id";

  static Future<List<ForumResult>> fetchForums({int page = 1}) async {
    final url = Uri.parse('$baseUrl/forums/api/json/?page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final ForumsEntry entry = ForumsEntry.fromJson(decoded);

      return entry.results;
    }

    return [];
  }

  static Future<List<ReplyResult>> fetchReplies(String forumId, {int page = 1}) async {
    final url = Uri.parse('$baseUrl/forums/$forumId/replies/json/?page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final RepliesEntry entry = RepliesEntry.fromJson(decoded);

      return entry.results;
    }

    return [];
  }
}
