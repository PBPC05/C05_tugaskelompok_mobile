import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:pittalk_mobile/features/authentication/data/models/user.dart';
import 'package:pittalk_mobile/features/authentication/data/models/country.dart';

class AuthService {
  final CookieRequest request;
  
  // For local development:
  // - local server: "http://localhost:8000"
  // - Android Emulator: "http://10.0.2.2:8000"
  // - iOS Simulator: "http://127.0.0.1:8000"
  // - Physical device: computer's IP (e.g., "http://192.168.1.100:8000")
  // For production: use deployed URL (e.g., "https://pbp.cs.ui.ac.id/ammar.muhammad41/pittalk")
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
      final response = await request.get("$baseUrl/auth/flutter_profile/");
      
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
  required String email,
  required String phoneNumber,
  required String address,
  required String bio,
  required String? nationality,
  }) async {
      try {
        final response = await request.postJson(
          "$baseUrl/auth/flutter_profile/edit/",
          jsonEncode({
            "email": email,
            "phone_number": phoneNumber,
            "address": address,
            "bio": bio,
            "nationality": nationality ?? "",
          }),
        );

        return {
          "status": response["status"] == true,
          "message": response["message"] ?? "Profile updated successfully",
        };
      } catch (e) {
        return {
          "status": false,
          "message": "Connection error: ${e.toString()}",
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

  Future<List<Country>> getCountries() async {
    try {
      final response = await request.get("$baseUrl/auth/countries/");
      
      if (response['status'] == true) {
        List<Country> countries = (response['countries'] as List)
            .map((country) => Country.fromJson(country))
            .toList();
        
        // Add "Not Set" option at the beginning
        countries.insert(0, Country(code: '', name: 'Not Set'));
        
        return countries;
      } else {
        return [Country(code: '', name: 'Not Set')];
      }
    } catch (e) {
      print('Error fetching countries: $e');
      return [Country(code: '', name: 'Not Set')];
    }
  }
}