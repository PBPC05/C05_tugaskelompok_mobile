import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:pittalk_mobile/features/authentication/data/models/user.dart';

class AuthService {
  final CookieRequest request;
  
  // For local development:
  // - local server: use "http://localhost:8000"
  // - Android Emulator: use "http://10.0.2.2:8000"
  // - iOS Simulator: use "http://127.0.0.1:8000"
  // - Physical device: use your computer's IP (e.g., "http://192.168.1.100:8000")
  // For production: use your deployed URL (e.g., "https://pbp.cs.ui.ac.id/ammar.muhammad41/pittalk")
  static const String baseUrl = "http://localhost:8000"; // Change for production
  
  AuthService(this.request);

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await request.login(
        "$baseUrl/auth/flutter_login/",
        {
          'username': username,
          'password': password,
        },
      );

      if (request.loggedIn) {
        return {
          'status': true,
          'message': response['message'] ?? 'Login successful',
          'username': response['username'],
        };
      } else {
        return {
          'status': false,
          'message': response['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String password1,
    required String password2,
    String? email,
  }) async {
    try {
      final response = await request.postJson(
        "$baseUrl/auth/flutter_register/",
        jsonEncode({
          "username": username,
          "password1": password1,
          "password2": password2,
          if (email != null && email.isNotEmpty) "email": email,
        }),
      );

      return {
        'status': response['status'] == 'success',
        'message': response['message'] ?? 'Registration completed',
        'username': response['username'],
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await request.get("$baseUrl/auth/profile/");
      
      if (response['status'] == true) {
        return {
          'status': true,
          'user': User.fromJson(response['user']),
          'stats': UserStats.fromJson(response['stats']),
        };
      } else {
        return {
          'status': false,
          'message': response['message'] ?? 'Failed to fetch profile',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? email,
    String? phoneNumber,
    String? address,
    String? bio,
    String? nationality,
  }) async {
    try {
      final response = await request.postJson(
        "$baseUrl/auth/profile/edit/",
        jsonEncode({
          if (email != null) 'email': email,
          if (phoneNumber != null) 'phone_number': phoneNumber,
          if (address != null) 'address': address,
          if (bio != null) 'bio': bio,
          if (nationality != null) 'nationality': nationality,
        }),
      );

      return {
        'status': response['status'] == true,
        'message': response['message'] ?? 'Profile updated successfully',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  Future<bool> logout() async {
    try {
      await request.logout("$baseUrl/auth/flutter_logout/");
      return true;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }

  bool isLoggedIn() {
    return request.loggedIn;
  }
}