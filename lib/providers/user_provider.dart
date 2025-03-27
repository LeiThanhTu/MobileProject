import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  DatabaseHelper _dbHelper = DatabaseHelper();
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
    
    if (userId != null && userEmail != null) {
      User? user = await _dbHelper.getUserByEmail(userEmail);
      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;
        notifyListeners();
      }
    }
  }

  Future login(String email, String password) async {
    bool isValid = await _dbHelper.validateUser(email, password);
    
    if (isValid) {
      User? user = await _dbHelper.getUserByEmail(email);
      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;
        
        // Save login status to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('userId', user.id!);
        prefs.setString('userEmail', user.email);
        
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future register(String name, String email, String password) async {
    try {
      User user = User(
        name: name,
        email: email,
        password: password,
      );
      
      int userId = await _dbHelper.insertUser(user);
      if (userId > 0) {
        user = User(
          id: userId,
          name: name,
          email: email,
          password: password,
        );
        
        _currentUser = user;
        _isLoggedIn = true;
        
        // Save login status to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('userId', userId);
        prefs.setString('userEmail', email);
        
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
    
    notifyListeners();
  }
}