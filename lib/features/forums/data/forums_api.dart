import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pittalk_mobile/features/forums/data/forums_model.dart';
import 'package:pittalk_mobile/features/forums/data/forums_replies_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ForumsApiService {
  static const String baseUrl = "https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id"; 

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  // Forum List with pagination, search, and filter
  Future<ForumListResponse> getForums({
    int page = 1,
    String search = '',
    String filter = 'latest',
    int pageSize = 9,
  }) async {
    final headers = await _getHeaders();
    final params = {
      'page': page.toString(),
      'filter': filter,
      'page_size': pageSize.toString(),
      if (search.isNotEmpty) 'q': search,
    };

    final uri = Uri.parse('$baseUrl/forums/api/json/').replace(queryParameters: params);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return ForumListResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load forums');
    }
  }

  // Get single forum
  Future<Forum> getForum(String id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/forums/api/$id/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Forum.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load forum');
    }
  }

  // Create forum
  Future<Forum> createForum(String title, String content) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/forums/create/'),
      headers: headers,
      body: json.encode({'title': title, 'content': content}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Forum.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create forum');
    }
  }

  // Update forum
  Future<Forum> updateForum(String id, String title, String content) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/forums/$id/edit/'),
      headers: headers,
      body: json.encode({'title': title, 'content': content}),
    );

    if (response.statusCode == 200) {
      return Forum.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update forum');
    }
  }

  // Delete forum
  Future<void> deleteForum(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/forums/$id/delete/'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete forum');
    }
  }

  // Like/Unlike forum
  Future<Map<String, dynamic>> toggleForumLike(String id) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/forums/$id/like/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to toggle like');
    }
  }

  // Create reply
  Future<ForumReply> createReply(String forumId, String content) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/forums/$forumId/reply/create/'),
      headers: headers,
      body: json.encode({'replies_content': content}),
    );

    if (response.statusCode == 200) {
      return ForumReply.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create reply');
    }
  }

  // Like/Unlike reply
  Future<Map<String, dynamic>> toggleReplyLike(int replyId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/forums/reply/$replyId/like/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to toggle reply like');
    }
  }

  // Delete reply
  Future<void> deleteReply(int replyId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/forums/reply/$replyId/delete/'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete reply');
    }
  }

    // Get replies
  Future<ForumReply> getReplies(String id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/forums/api/$id/replies/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = ForumReply.fromJson(json.decode(response.body));
      return ForumReply.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load forum');
    }
  }

  // Load more replies
  Future<List<ForumReply>> loadMoreReplies(String forumId, int offset) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/forums/$forumId/replies/load-more/'),
      headers: headers,
      body: json.encode({'offset': offset, 'limit': 5}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['replies'] as List)
          .map((item) => ForumReply.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load more replies');
    }
  }

  // Toggle hot status (admin only)
  Future<Map<String, dynamic>> toggleHotStatus(String forumId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/forums/$forumId/hot-toggle/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to toggle hot status');
    }
  }
}