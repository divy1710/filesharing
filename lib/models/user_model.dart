/// ===================================================================
/// USER MODEL - Represents a registered user
/// ===================================================================
import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password; // In production, use hashing!
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  /// Convert to JSON for Hive storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        password: json['password'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
