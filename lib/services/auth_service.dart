import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/user.dart';
import 'package:test/providers/user_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/encryption_helper.dart';

class AuthService with ChangeNotifier {
  bool _isAuthenticated = false;
  User? _currentUser;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _storage = const FlutterSecureStorage();

  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;

  void initialize(UserProvider userProvider) {
    // Khởi tạo các giá trị mặc định
    _isAuthenticated = false;
    _currentUser = null;
  }

  Future<void> login(String username, String password) async {
    try {
      // Hash mật khẩu trước khi kiểm tra
      final hashedPassword = EncryptionHelper.hashPassword(password);

      // Kiểm tra trong database
      final user = await _dbHelper.getUser(username, hashedPassword);

      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;

        // Lưu thông tin đăng nhập
        await _saveCredentials(username, hashedPassword);

        notifyListeners();
      } else {
        throw Exception('Tên đăng nhập hoặc mật khẩu không đúng');
      }
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      throw Exception('Không thể đăng nhập');
    }
  }
// Sử dụng repository để thao tác với cơ sở dữ liệu 
  Future<void> register(String username, String password, String email) async {
    try {
      // Hash mật khẩu trước khi lưu
      final hashedPassword = EncryptionHelper.hashPassword(password);

      // Tạo user mới
      final user = User(
        username: username,
        email: email,
        password: hashedPassword,
      );

      // Lưu vào database
      final createdUser = await _dbHelper.createUser(user);

      if (createdUser.id != null) {
        // Đăng ký thành công, tự động đăng nhập
        await login(username, password);
      } else {
        throw Exception('Đăng ký thất bại');
      }
    } catch (e) {
      print('Lỗi đăng ký: $e');
      throw Exception('Không thể đăng ký');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      // Kiểm tra email có tồn tại không
      final user = await _dbHelper.getUserByEmail(email);
      if (user == null) {
        throw Exception('Email không tồn tại');
      }

      // Tạo mật khẩu mới
      final newPassword =
          DateTime.now().millisecondsSinceEpoch.toString().substring(7);
      final hashedPassword = EncryptionHelper.hashPassword(newPassword);

      // Cập nhật mật khẩu mới
      final success = await _dbHelper.updatePassword(email, hashedPassword);

      if (success) {
        print('Mật khẩu mới cho $email: $newPassword');
      } else {
        throw Exception('Không thể đặt lại mật khẩu');
      }
    } catch (e) {
      print('Lỗi đặt lại mật khẩu: $e');
      throw Exception('Không thể đặt lại mật khẩu');
    }
  }

  Future<void> _saveCredentials(String username, String hashedPassword) async {
    try {
      await _storage.write(key: 'username', value: username);
      await _storage.write(key: 'password', value: hashedPassword);
    } catch (e) {
      print('Lỗi khi lưu thông tin đăng nhập: $e');
      throw Exception('Không thể lưu thông tin đăng nhập');
    }
  }

  Future<Map<String, String>?> _getSavedCredentials() async {
    try {
      final username = await _storage.read(key: 'username');
      final hashedPassword = await _storage.read(key: 'password');

      if (username == null || hashedPassword == null) {
        return null;
      }

      return {
        'username': username,
        'password': hashedPassword,
      };
    } catch (e) {
      print('Lỗi khi đọc thông tin đăng nhập: $e');
      return null;
    }
  }

  Future<void> autoLogin() async {
    try {
      final credentials = await _getSavedCredentials();
      if (credentials != null) {
        await login(credentials['username']!, credentials['password']!);
      }
    } catch (e) {
      print('Lỗi tự động đăng nhập: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'username');
      await _storage.delete(key: 'password');
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      print('Lỗi đăng xuất: $e');
      throw Exception('Không thể đăng xuất');
    }
  }
}
