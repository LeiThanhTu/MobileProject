import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void loginWithoutCredentials() {
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // Implementation
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
