import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/user.dart' as app_user;
import 'package:test/providers/user_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/encryption_helper.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService with ChangeNotifier {
  bool _isAuthenticated = false;
  app_user.User? _currentUser;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _storage = const FlutterSecureStorage();
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  UserProvider? _userProvider;

  bool get isAuthenticated => _isAuthenticated;
  app_user.User? get currentUser => _currentUser;

  void initialize(UserProvider userProvider) {
    _isAuthenticated = false;
    _currentUser = null;
    _userProvider = userProvider;
  }

  Future<bool> login(String email, String password) async {
    try {
      print('AuthService: Bắt đầu đăng nhập với email: $email');

      final firebase_auth.UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print(
          'AuthService: Đăng nhập Firebase thành công: ${userCredential.user?.uid}');

      if (userCredential.user != null) {
        print('AuthService: Cập nhật thông tin người dùng');
        await _userProvider?.updateUserInfo(
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName ?? '',
          photoURL: userCredential.user!.photoURL,
        );

        _currentUser = app_user.User(
          username: email,
          email: email,
        //  password: '',
        );
        _isAuthenticated = true;
        await _saveCredentials(email, '');
        notifyListeners();
        print('AuthService: Đăng nhập thành công');
        return true;
      }
      print('AuthService: Đăng nhập thất bại - không có user');
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('AuthService: Firebase Auth Error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('AuthService: Lỗi không xác định: $e');
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      print('AuthService: Bắt đầu đăng nhập Google');

      // Đăng xuất trước để tránh lỗi
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('AuthService: Người dùng hủy đăng nhập Google');
        return false;
      }

      print('AuthService: Đã lấy được thông tin Google: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('AuthService: Đang xác thực với Firebase');
      final firebase_auth.UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        print(
            'AuthService: Đăng nhập Firebase thành công với Google: ${userCredential.user?.uid}');

        await _userProvider?.updateUserInfo(
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName ?? '',
          photoURL: userCredential.user!.photoURL,
        );

        _currentUser = app_user.User(
          username: userCredential.user!.email!,
          email: userCredential.user!.email!,
        //  password: '',
        );
        _isAuthenticated = true;
        await _saveCredentials(userCredential.user!.email!, '');
        notifyListeners();
        print('AuthService: Đăng nhập Google thành công');
        return true;
      }
      print('AuthService: Đăng nhập Google thất bại - không có user');
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('AuthService: Firebase Auth Error: ${e.code} - ${e.message}');
      if (e.code == 'account-exists-with-different-credential') {
        print(
            'AuthService: Tài khoản đã tồn tại với phương thức đăng nhập khác');
      }
      return false;
    } catch (e) {
      print('AuthService: Google Sign In Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _userProvider?.clearUser();
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'password');
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<String?> register(
      String email, String password, String displayName) async {
    try {
      final firebase_auth.UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);

        await _userProvider?.updateUserInfo(
          email: userCredential.user!.email!,
          displayName: displayName,
          photoURL: userCredential.user!.photoURL,
        );
        await login(email, password);
        return null; // null nghĩa là thành công
      }
      return 'Đăng ký thất bại';
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email đã tồn tại';
      }
      return 'Lỗi: ${e.message}';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.message}');
      rethrow;
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
}
