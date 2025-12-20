import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:pittalk_mobile/features/authentication/data/models/user.dart';

class AdminService {
  final CookieRequest request;
  static const String baseUrl = "https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/"; // Change this for production
  
  AdminService(this.request);

  Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final response = await request.get("$baseUrl/auth/flutter_admin/users/");
      
      if (response['status'] == true) {
        List<User> users = (response['users'] as List)
            .map((userData) => User.fromJson(userData))
            .toList();
        
        return {
          'status': true,
          'users': users,
          'total_users': response['total_users'],
          'active_users': response['active_users'],
          'banned_users': response['banned_users'],
        };
      } else {
        return {
          'status': false,
          'message': response['message'] ?? 'Failed to fetch users',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getUserById(int userId) async {
    try {
      final response = await request.get("$baseUrl/auth/flutter_admin/user/$userId/");
      
      if (response['status'] == true) {
        return {
          'status': true,
          'user': User.fromJson(response['user']),
        };
      } else {
        return {
          'status': false,
          'message': response['message'] ?? 'Failed to fetch user',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateUser({
    required int userId,
    required String username,
    String? email,
    required bool isActive,
    String? phoneNumber,
    String? address,
    String? bio,
    String? nationality,
  }) async {
    try {
      final response = await request.postJson(
        "$baseUrl/auth/flutter_admin/user/$userId/edit/",
        jsonEncode({
          'username': username,
          'email': email ?? '',
          'is_active': isActive,
          'phone_number': phoneNumber ?? '',
          'address': address ?? '',
          'bio': bio ?? '',
          'nationality': nationality ?? '',
        }),
      );

      return {
        'status': response['status'] == true,
        'message': response['message'] ?? 'User updated successfully',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> banUser(int userId) async {
    try {
      final response = await request.post(
        "$baseUrl/auth/flutter_admin/user/$userId/ban/",
        {},
      );

      return {
        'status': response['status'] == true,
        'message': response['message'] ?? 'User ban status updated',
        'is_active': response['is_active'],
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final response = await request.post(
        "$baseUrl/auth/flutter_admin/user/$userId/delete/",
        {},
      );

      return {
        'status': response['status'] == true,
        'message': response['message'] ?? 'User deleted successfully',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<bool> isAdmin() async {
    try {
      final response = await request.get("$baseUrl/auth/flutter_admin/check/");
      return response['is_admin'] == true;
    } catch (e) {
      return false;
    }
  }
}