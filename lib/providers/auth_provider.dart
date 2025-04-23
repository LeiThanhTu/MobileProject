import 'package:flutter/material.dart';

// quản lý trạng thái đăng nhập (authentication) của người dùng
class AuthProvider extends ChangeNotifier {
  // 	Biến riêng lưu trạng thái đăng nhập
  bool _isAuthenticated = false;
// 	Cho phép các widget bên ngoài đọc trạng thái
  bool get isAuthenticated => _isAuthenticated;
// 	Dùng để thay đổi trạng thái đăng nhập
  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    // Báo cho các widget bên ngoài biết trạng thái đã thay đổi
    notifyListeners();
  }
}
