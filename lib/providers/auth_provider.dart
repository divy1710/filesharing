

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser; // Currently logged-in user
  final Uuid _uuid = const Uuid();

  // Hive box names
  static const String _usersBox = 'users_box';
  static const String _sessionBox = 'session_box';

  // ---- Getters ----
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String get userName => _currentUser?.name ?? 'Guest';

  // ---- Initialize: check if user has an active session ----
  Future<void> checkSession() async {
    try {
      final sessionBox = await Hive.openBox(_sessionBox);
      final userId = sessionBox.get('current_user_id');
      if (userId != null) {
        // User was previously logged in — restore session
        final usersBox = await Hive.openBox(_usersBox);
        final usersJson = usersBox.get('users_list');
        if (usersJson != null) {
          final List<dynamic> users = jsonDecode(usersJson);
          final userData = users.firstWhere(
            (u) => u['id'] == userId,
            orElse: () => null,
          );
          if (userData != null) {
            _currentUser = UserModel.fromJson(userData);
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking session: $e');
    }
    notifyListeners();
  }

  // ---- Sign Up ----
  /// Register a new user. Returns error string or null on success.
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // Validation
    if (name.trim().isEmpty) return 'Name is required';
    if (email.trim().isEmpty) return 'Email is required';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Please enter a valid email';
    }
    if (password.length < 6) return 'Password must be at least 6 characters';

    try {
      final usersBox = await Hive.openBox(_usersBox);
      final usersJson = usersBox.get('users_list');
      List<dynamic> users = [];

      if (usersJson != null) {
        users = jsonDecode(usersJson);
        // Check if email already exists
        final exists = users.any(
          (u) => u['email'].toString().toLowerCase() == email.trim().toLowerCase(),
        );
        if (exists) return 'An account with this email already exists';
      }

      // Create new user
      final newUser = UserModel(
        id: _uuid.v4(),
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password, // In production, hash the password!
        createdAt: DateTime.now(),
      );

      users.add(newUser.toJson());
      await usersBox.put('users_list', jsonEncode(users));

      // Auto-login after signup
      _currentUser = newUser;
      final sessionBox = await Hive.openBox(_sessionBox);
      await sessionBox.put('current_user_id', newUser.id);

      notifyListeners();
      return null; // Success
    } catch (e) {
      return 'Signup failed: $e';
    }
  }

  // ---- Login ----
  /// Login with email and password. Returns error string or null on success.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    // Validation
    if (email.trim().isEmpty) return 'Email is required';
    if (password.isEmpty) return 'Password is required';

    try {
      final usersBox = await Hive.openBox(_usersBox);
      final usersJson = usersBox.get('users_list');

      if (usersJson == null) return 'No accounts found. Please sign up first.';

      final List<dynamic> users = jsonDecode(usersJson);
      final userData = users.firstWhere(
        (u) =>
            u['email'].toString().toLowerCase() == email.trim().toLowerCase() &&
            u['password'] == password,
        orElse: () => null,
      );

      if (userData == null) return 'Invalid email or password';

      // Login successful
      _currentUser = UserModel.fromJson(userData);
      final sessionBox = await Hive.openBox(_sessionBox);
      await sessionBox.put('current_user_id', _currentUser!.id);

      notifyListeners();
      return null; // Success
    } catch (e) {
      return 'Login failed: $e';
    }
  }

  // ---- Logout ----
  Future<void> logout() async {
    _currentUser = null;
    try {
      final sessionBox = await Hive.openBox(_sessionBox);
      await sessionBox.delete('current_user_id');
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
    notifyListeners();
  }
}
