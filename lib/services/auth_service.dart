import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/user.dart';
import 'package:test/providers/user_provider.dart';

class AuthService with ChangeNotifier {
  bool _isAuthenticated = false;
  User? _currentUser;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;

  void loginWithoutCredentials() {
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    User? user = await _dbHelper.getUser(email, password);
    if (user != null) {
      _currentUser = user;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> resetPassword(String email) async {
    try {
      // Kiểm tra email có tồn tại trong hệ thống không
      User? user = await _dbHelper.getUserByEmail(email);
      if (user == null) {
        return false;
      }

      // Tạo mật khẩu mới ngẫu nhiên
      String newPassword = DateTime.now().millisecondsSinceEpoch
          .toString()
          .substring(7);

      // Cập nhật mật khẩu mới trong database
      bool success = await _dbHelper.updatePassword(email, newPassword);

      if (success) {
        // TODO: Gửi email chứa mật khẩu mới cho người dùng
        // Trong môi trường thực tế, bạn sẽ cần tích hợp dịch vụ gửi email
        print('New password for $email: $newPassword');
        return true;
      }

      return false;
    } catch (e) {
      print('Error in resetPassword: $e');
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  void initialize(UserProvider userProvider) {}
}
