import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../providers/database_helper.dart';

/// Authentication service managing user sessions
class AuthService {
  static final AuthService instance = AuthService._init();
  AuthService._init();

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserPoints = 'user_points';

  UserModel? _currentUser;

  /// Get current logged-in user
  UserModel? get currentUser => _currentUser;

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Initialize and load user session
  Future<void> init() async {
    if (await isLoggedIn()) {
      await _loadUserFromPrefs();
    }
  }

  /// Load user data from SharedPreferences
  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getInt(_keyUserId);
    final userName = prefs.getString(_keyUserName);
    final userEmail = prefs.getString(_keyUserEmail);
    final userRole = prefs.getString(_keyUserRole);
    final userPoints = prefs.getInt(_keyUserPoints);

    if (userId != null &&
        userName != null &&
        userEmail != null &&
        userRole != null) {
      _currentUser = UserModel(
        userId: userId,
        name: userName,
        email: userEmail,
        password: '',
        role: userRole,
        points: userPoints ?? 0,
      );
    }
  }

  /// Save user session to SharedPreferences
  Future<void> _saveUserToPrefs(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setInt(_keyUserId, user.userId!);
    await prefs.setString(_keyUserName, user.name);
    await prefs.setString(_keyUserEmail, user.email);
    await prefs.setString(_keyUserRole, user.role);
    await prefs.setInt(_keyUserPoints, user.points);
  }

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Register new user
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Check if email already exists
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existing.isNotEmpty) {
        throw Exception('email_already_exists');
      }

      // Hash password
      final hashedPassword = _hashPassword(password);

      // Create user
      final userId = await db.insert('users', {
        'name': name,
        'email': email,
        'password': hashedPassword,
        'role': role,
        'points': 0,
      });

      // Create default settings
      await db.insert('settings', {
        'user_id': userId,
        'language': 'ar',
        'theme': 'light',
        'notifications_enabled': 1,
      });

      final user = UserModel(
        userId: userId,
        name: name,
        email: email,
        password: hashedPassword,
        role: role,
        points: 0,
      );

      // Save session
      _currentUser = user;
      await _saveUserToPrefs(user);

      return user;
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  /// Login user
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Hash password
      final hashedPassword = _hashPassword(password);

      // Find user
      final results = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, hashedPassword],
      );

      if (results.isEmpty) {
        throw Exception('invalid_credentials');
      }

      final user = UserModel.fromMap(results.first);

      // Save session
      _currentUser = user;
      await _saveUserToPrefs(user);

      return user;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
  }

  /// Update user points
  Future<void> updatePoints(int points) async {
    if (_currentUser == null) return;

    try {
      final db = await DatabaseHelper.instance.database;

      await db.update(
        'users',
        {'points': points},
        where: 'user_id = ?',
        whereArgs: [_currentUser!.userId],
      );

      _currentUser = _currentUser!.copyWith(points: points);
      await _saveUserToPrefs(_currentUser!);
    } catch (e) {
      debugPrint('Update points error: $e');
    }
  }

  /// Get user by ID
  Future<UserModel?> getUserById(int userId) async {
    try {
      final db = await DatabaseHelper.instance.database;

      final results = await db.query(
        'users',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (results.isEmpty) return null;

      return UserModel.fromMap(results.first);
    } catch (e) {
      debugPrint('Get user error: $e');
      return null;
    }
  }

  /// Get all students (for teachers)
  Future<List<UserModel>> getAllStudents() async {
    try {
      final db = await DatabaseHelper.instance.database;

      final results = await db.query(
        'users',
        where: 'role = ?',
        whereArgs: ['student'],
        orderBy: 'name ASC',
      );

      return results.map((map) => UserModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Get students error: $e');
      return [];
    }
  }
}
