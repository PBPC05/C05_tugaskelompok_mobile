import 'dart:convert';

class User {
  final int id;
  final String username;
  final String? email;
  final bool isActive;
  final bool isSuperuser;
  final DateTime dateJoined;
  final DateTime? lastLogin;
  final UserProfile? profile;

  User({
    required this.id,
    required this.username,
    this.email,
    required this.isActive,
    required this.isSuperuser,
    required this.dateJoined,
    this.lastLogin,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      isActive: json['is_active'] ?? true,
      isSuperuser: json['is_superuser'] ?? false,
      dateJoined: DateTime.parse(json['date_joined']),
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login']) 
          : null,
      profile: json['profile'] != null 
          ? UserProfile.fromJson(json['profile']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'is_active': isActive,
      'is_superuser': isSuperuser,
      'date_joined': dateJoined.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'profile': profile?.toJson(),
    };
  }
}

class UserProfile {
  final int id;
  final String? phoneNumber;
  final String? address;
  final String? bio;
  final String? nationality;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    this.phoneNumber,
    this.address,
    this.bio,
    this.nationality,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      bio: json['bio'],
      nationality: json['nationality'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'address': address,
      'bio': bio,
      'nationality': nationality,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class UserStats {
  final int threadsCount;
  final int votesCount;
  final int commentsCount;

  UserStats({
    required this.threadsCount,
    required this.votesCount,
    required this.commentsCount,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      threadsCount: json['threads_count'] ?? 0,
      votesCount: json['votes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
    );
  }
}