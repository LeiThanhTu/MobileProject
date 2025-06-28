import 'package:flutter/foundation.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import '../models/user.dart' as app_user;

class UserProvider with ChangeNotifier {
  app_user.User? _currentUser;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  // FlutterSecureStorage: lưu trữ dữ liệu bảo mật trong thiết bị
  final _secureStorage = const FlutterSecureStorage();

  final _prefs = SharedPreferences.getInstance();

  app_user.User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  UserProvider() {
    checkLoginStatus();
  }

  Future checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await _prefs;
      final userEmail = prefs.getString('userEmail');

      if (userEmail != null) {
        // User is logged in, get details from local DB by email.
        // No password check is needed here; Firebase is the source of truth for auth.
        User? user = await _dbHelper.getUserByEmail(userEmail);

        if (user != null) {
          _currentUser = user;
          _isLoggedIn = true;
          await prefs.setInt('userId', user.id!);
        } else {
          print('User email in prefs, but no user in local DB. Logging out.');
          await logout();
        }
      } else {
        _isLoggedIn = false;
        _currentUser = null;
      }
    } catch (e) {
      print('Error checking login status: $e');
      await logout();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      User? user = await _dbHelper.getUser(email, password);

      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;

        // Lưu thông tin đăng nhập
        final prefs = await _prefs;
        await prefs.setInt('userId', user.id!);
        await prefs.setString('userEmail', user.email);
        await prefs.setString('provider', 'email');
        await _secureStorage.write(key: 'password', value: password);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      User user = User(
        username: name,
        email: email,
        password: password,
        provider: 'email',
      );
      User createdUser = await _dbHelper.createUser(user);

      if (createdUser.id != null) {
        _currentUser = createdUser;
        _isLoggedIn = true;

        // Lưu thông tin đăng nhập
        final prefs = await _prefs;
        await prefs.setInt('userId', createdUser.id!);
        await prefs.setString('userEmail', email);
        await prefs.setString('provider', 'email');
        await _secureStorage.write(key: 'password', value: password);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  Future logout() async {
    try {
      _currentUser = null;
      _isLoggedIn = false;

      // Xóa thông tin đăng nhập
      final prefs = await _prefs;
      await prefs.remove('userId');
      await prefs.remove('userEmail');
      await prefs.remove('provider');
      await _secureStorage.delete(key: 'password');

      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<void> updateUserInfo({
    required String email,
    String? displayName,
    String? photoURL,
    String provider = 'email',
  }) async {
    try {
      print('Updating user info for email: $email');
      final prefs = await _prefs;

      User? localUser;
      User? existingUser = await _dbHelper.getUserByEmail(email);

      if (existingUser != null) {
        // User exists, update them
        User updatedUser = existingUser.copyWith(
          displayName: displayName,
          photoURL: photoURL,
          provider: provider,
        );
        await _dbHelper.updateUser(updatedUser);
        localUser = updatedUser;
        print('Updated existing user in database. ID: ${localUser.id}');
      } else {
        // User doesn't exist, create a new one
        User newUser = User(
          username: displayName ?? email.split('@').first,
          email: email,
          displayName: displayName,
          photoURL: photoURL,
          provider: provider,
          password: null, // We don't store passwords from external providers
        );
        localUser = await _dbHelper.createUser(newUser);
        print('Created new user in database. ID: ${localUser.id}');
      }

      _currentUser = localUser;
      _isLoggedIn = true;

      await prefs.setString('userEmail', email);
      await prefs.setString('provider', provider);
      if (localUser.id != null) {
        await prefs.setInt('userId', localUser.id!);
      }

      notifyListeners();
      print(
          'User info updated and session saved successfully. Current user ID: ${_currentUser?.id}');
    } catch (e) {
      print('Error updating user info: $e');
      throw Exception('Không thể cập nhật thông tin người dùng: $e');
    }
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
