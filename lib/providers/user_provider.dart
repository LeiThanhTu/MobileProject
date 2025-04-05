import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  UserProvider() {
    checkLoginStatus();
  }

  Future checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    String? userEmail = prefs.getString('userEmail');
    String? password = prefs.getString('password');
    if (userId != null && userEmail != null && password != null) {
      User? user = await _dbHelper.getUser(userEmail, password);
      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    User? user = await _dbHelper.getUser(email, password);

    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;

      // Save login status to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('userId', user.id!);
      prefs.setString('userEmail', user.email);
      prefs.setString('password', user.password);

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      User user = User(username: name, email: email, password: password);

      User createdUser = await _dbHelper.createUser(user);
      if (createdUser.id != null) {
        _currentUser = createdUser;
        _isLoggedIn = true;

        // Save login status to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('userId', createdUser.id!);
        prefs.setString('userEmail', email);
        prefs.setString('password', password);

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
    _currentUser = null;
    _isLoggedIn = false;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
    prefs.remove('userEmail');
    prefs.remove('password');

    notifyListeners();
  }
}
