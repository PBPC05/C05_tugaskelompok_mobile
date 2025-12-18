import 'dart:convert';
import 'package:pittalk_mobile/features/forums/data/forums_model.dart';
import 'package:pittalk_mobile/features/forums/data/forums_replies_model.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ForumsApiService {
  static const String baseUrl = "https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id"; 

  // Forum List with pagination, search, and filter
  Future<ForumListResponse> getForums({
    required CookieRequest request,
    int page = 1,
    String search = '',
    String filter = 'latest',
    int pageSize = 9,
  }) async {
    try {
      // Build query string manually
      String query = '?page=$page&filter=$filter&page_size=$pageSize';
      if (search.isNotEmpty) {
        query += '&q=${Uri.encodeQueryComponent(search)}';
      }

      final response = await request.get('$baseUrl/forums/api/json/$query');

      if (response != null) {
        return ForumListResponse.fromJson(response);
      } else {
        throw Exception('Failed to load forums');
      }
    } catch (e) {
      throw Exception('Error getting forums: $e');
    }
  }

  // Get single forum
  Future<Forum> getForum({
    required CookieRequest request,
    required String id,
  }) async {
    try {
      final response = await request.get('$baseUrl/forums/api/$id/');

      if (response != null) {
        return Forum.fromJson(response);
      } else {
        throw Exception('Failed to load forum');
      }
    } catch (e) {
      throw Exception('Error getting forum: $e');
    }
  }

  // Create forum (Flutter version)
  Future<Forum> createForum({
    required CookieRequest request,
    required String title,
    required String content,
  }) async {
    try {
      final response = await request.post(
        '$baseUrl/forums/create-forum-flutter/',
        {
          'title': title,
          'content': content,
        },
      );

      if (response != null) {
        if (response['status'] == 'success') {
          return Forum.fromJson(response);
        } else {
          throw Exception(response['message'] ?? 'Failed to create forum');
        }
      } else {
        throw Exception('Failed to create forum');
      }
    } catch (e) {
      throw Exception('Error creating forum: $e');
    }
  }

  // Update forum (Flutter version)
  Future<Forum> updateForum({
    required CookieRequest request,
    required String id,
    required String title,
    required String content,
  }) async {
    try {
      final response = await request.post(
        '$baseUrl/forums/$id/update-forum-flutter/',
        {
          'title': title,
          'content': content,
        },
      );

      if (response != null) {
        if (response['status'] == 'success') {
          return Forum.fromJson(response);
        } else {
          throw Exception(response['message'] ?? 'Failed to update forum');
        }
      } else {
        throw Exception('Failed to update forum');
      }
    } catch (e) {
      throw Exception('Error updating forum: $e');
    }
  }

  // Delete forum (Flutter version)
  Future<bool> deleteForum({
    required CookieRequest request,
    required String id,
  }) async {
    try {
      final response = await request.post(
        '$baseUrl/forums/$id/delete-forum-flutter/',
        {},
      );

      if (response != null) {
        return response['status'] == 'success';
      } else {
        throw Exception('Failed to delete forum');
      }
    } catch (e) {
      throw Exception('Error deleting forum: $e');
    }
  }

  // Like/Unlike forum (Flutter version)
  Future<Map<String, dynamic>> toggleForumLike({
    required CookieRequest request,
    required String id,
  }) async {
    try {
      final response = await request.post(
        '$baseUrl/forums/$id/like-forum-flutter/',
        {},
      );

      if (response != null) {
        if (response['status'] == 'success') {
          return response;
        } else {
          throw Exception(response['message'] ?? 'Failed to toggle like');
        }
      } else {
        throw Exception('Failed to toggle like');
      }
    } catch (e) {
      throw Exception('Error toggling forum like: $e');
    }
  }

  // Get replies for a forum
  Future<List<ForumReply>> getForumReplies({
    required CookieRequest request,
    required String forumId,
  }) async {
    try {
      final response = await request.get('$baseUrl/forums/api/$forumId/replies/');

      if (response != null) {
        final List<dynamic> data = response is List ? response : [response];
        return data.map((item) => ForumReply.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load replies');
      }
    } catch (e) {
      throw Exception('Error getting replies: $e');
    }
  }

  // Create reply (Flutter version)
  Future<ForumReply> createReply({
    required CookieRequest request,
    required String forumId,
    required String content,
  }) async {
    try {
      final response = await request.post(
        '$baseUrl/forums/$forumId/create-reply-flutter/',
        {
          'content': content,
        },
      );

      if (response != null) {
        if (response['status'] == 'success') {
          return ForumReply.fromJson(response);
        } else {
          throw Exception(response['message'] ?? 'Failed to create reply');
        }
      } else {
        throw Exception('Failed to create reply');
      }
    } catch (e) {
      throw Exception('Error creating reply: $e');
    }
  }

  // Delete reply (Flutter version)
  Future<bool> deleteReply({
    required CookieRequest request,
    required int replyId,
  }) async {
    try {
      final response = await request.post(
        '$baseUrl/forums/reply/$replyId/delete-flutter/',
        {},
      );

      if (response != null) {
        return response['status'] == 'success';
      } else {
        throw Exception('Failed to delete reply');
      }
    } catch (e) {
      throw Exception('Error deleting reply: $e');
    }
  }

  // Like/Unlike reply (Flutter version)
  Future<Map<String, dynamic>> toggleReplyLike({
    required CookieRequest request,
    required int replyId,
  }) async {
    try {
      final response = await request.post(
        '$baseUrl/forums/reply/$replyId/like-flutter/',
        {},
      );

      if (response != null) {
        if (response['status'] == 'success') {
          return response;
        } else {
          throw Exception(response['message'] ?? 'Failed to toggle reply like');
        }
      } else {
        throw Exception('Failed to toggle reply like');
      }
    } catch (e) {
      throw Exception('Error toggling reply like: $e');
    }
  }

  Future<List<ForumReply>> loadMoreReplies({
    required CookieRequest request,
    required String forumId,
    required int offset,
  }) async {
    try {
      final response = await request.post(
        '$baseUrl/forums/$forumId/replies/load-more-flutter/',
        {
          'offset': offset,
          'limit': 5,
        },
      );
  
      if (response != null && response['status'] == 'success') {
        final List<dynamic> repliesData = response['replies'] ?? [];
        return repliesData.map((item) => ForumReply.fromJson(item)).toList();
      } else {
        throw Exception(response?['message'] ?? 'Failed to load more replies');
      }
    } catch (e) {
      throw Exception('Error loading more replies: $e');
    }
  }

  // Toggle hot status (admin only) - Flutter version
  Future<Map<String, dynamic>> toggleHotStatus({
    required CookieRequest request,
    required String forumId,
  }) async {
    try {
      final response = await request.post(
        '$baseUrl/forums/$forumId/toggle-hot-flutter/',
        {},
      );

      if (response != null) {
        if (response['status'] == 'success') {
          return response;
        } else {
          throw Exception(response['message'] ?? 'Failed to toggle hot status');
        }
      } else {
        throw Exception('Failed to toggle hot status');
      }
    } catch (e) {
      throw Exception('Error toggling hot status: $e');
    }
  }

  // Check if user is admin
  Future<Map<String, dynamic>> checkAdmin({
    required CookieRequest request,
  }) async {
    try {
      final response = await request.get('$baseUrl/forums/api/check-admin/');
      
      if (response != null) {
        return response;
      } else {
        throw Exception('Failed to check admin status');
      }
    } catch (e) {
      throw Exception('Error checking admin status: $e');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile({
    required CookieRequest request,
  }) async {
    try {
      final response = await request.get('$baseUrl/forums/api/user/profile/');
      
      if (response != null) {
        return response;
      } else {
        throw Exception('Failed to get user profile');
      }
    } catch (e) {
      throw Exception('Error getting user profile: $e');
    }
  }
  
}


