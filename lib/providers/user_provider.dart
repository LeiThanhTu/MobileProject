import 'package:flutter/foundation.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isLoggedIn = false;

  // FlutterSecureStorage: lưu trữ dữ liệu bảo mật trong thiết bị
  final _secureStorage = const FlutterSecureStorage();
 
  final _prefs = SharedPreferences.getInstance();

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn; //

  UserProvider() {
    checkLoginStatus();
  }

  Future checkLoginStatus() async {
    try {
      final prefs = await _prefs;
      final userId = prefs.getInt('userId');
      final userEmail = prefs.getString('userEmail');
      // Lấy mật khẩu từ FlutterSecureStorage
      final password = await _secureStorage.read(key: 'password');

      if (userId != null && userEmail != null && password != null) {
        User? user = await _dbHelper.getUser(userEmail, password);
        if (user != null) {
          _currentUser = user;
          _isLoggedIn = true;
          notifyListeners(); 
        }
      }
    } catch (e) {
      print('Error checking login status: $e');
      // Xóa thông tin đăng nhập nếu có lỗi
      await logout();
    }
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
      User user = User(username: name, email: email, password: password);
      User createdUser = await _dbHelper.createUser(user);

      if (createdUser.id != null) {
        _currentUser = createdUser;
        _isLoggedIn = true;

        // Lưu thông tin đăng nhập
        final prefs = await _prefs;
        await prefs.setInt('userId', createdUser.id!);
        await prefs.setString('userEmail', email);
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
      await _secureStorage.delete(key: 'password');

      notifyListeners(); 
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
