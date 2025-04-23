import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  static final _key = _generateKey();
  static final _iv = _generateIV();

  // Tạo key từ một chuỗi cố định và hash nó
  static encrypt.Key _generateKey() {
    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return encrypt.Key(Uint8List.fromList(keyBytes));
  }

  // Tạo IV (Initialization Vector)
  static encrypt.IV _generateIV() {
    final random = Random.secure();
    final ivBytes = List<int>.generate(16, (i) => random.nextInt(256));
    return encrypt.IV(Uint8List.fromList(ivBytes));
  }

  // Mã hóa mật khẩu
  static String encryptPassword(String password) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(password, iv: _iv);
    return encrypted.base64;
  }

  // Giải mã mật khẩu
  static String decryptPassword(String encryptedPassword) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final decrypted = encrypter.decrypt64(encryptedPassword, iv: _iv);
    return decrypted;
  }

  // Hash mật khẩu với salt
  static String hashPassword(String password) {
    final salt = _generateSalt();
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return '$salt:${digest.toString()}';
  }

  // Tạo salt ngẫu nhiên
  static String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(saltBytes);
  }

  // Kiểm tra mật khẩu có khớp với hash không
  static bool verifyPassword(String password, String hashedPassword) {
    final parts = hashedPassword.split(':');
    if (parts.length != 2) return false;

    final salt = parts[0];
    final storedHash = parts[1];

    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);

    return digest.toString() == storedHash;
  }
}
