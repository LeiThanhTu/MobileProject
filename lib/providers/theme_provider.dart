import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
// Lớp ThemeProvider giúp ứng dụng lưu trữ và thay đổi giữa chế độ sáng (light) và tối (dark).
// Sử dụng SharedPreferences để lưu trạng thái theme (sáng/tối) vào bộ nhớ thiết bị, đảm bảo theme được giữ nguyên khi mở lại ứng dụng.
// Kế thừa ChangeNotifier để thông báo cho giao diện cập nhật khi theme thay đổi. 
class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';  // _themeKey: Một chuỗi định danh ('theme_mode') để lưu trạng thái theme trong SharedPreferences.
  //Biến boolean lưu trạng thái theme (true = dark, false = light).
  bool _isDarkMode = false;
  late SharedPreferences _prefs; // Đối tượng SharedPreferences để lưu trữ dữ liệu lâu dài

// Hàm khởi tạo (constructor) của lớp ThemeProvider.
  ThemeProvider() {
    _loadThemeMode(); // Gọi phương thức _loadThemeMode() để tải trạng thái theme từ SharedPreferences.
  }

  bool get isDarkMode => _isDarkMode;
// Phương thức get themeMode trả về chế độ theme hiện tại.
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

// Phương thức _loadThemeMode() tải trạng thái theme từ SharedPreferences.
  Future<void> _loadThemeMode() async {
    // await: đợi cho đến khi SharedPreferences được khởi tạo
    // SharedPreferences.getInstance(): trả về một đối tượng SharedPreferences để lưu trữ và truy xuất dữ liệu lâu dài.
    _prefs = await SharedPreferences.getInstance();

    _isDarkMode = _prefs.getBool(_themeKey) ?? false;
    notifyListeners(); 
  }
// Phương thức toggleTheme đổi trạng thái theme và lưu vào SharedPreferences.
  Future<void> toggleTheme() async {
    // !: đảm bảo _isDarkMode là true
    _isDarkMode = !_isDarkMode;
// await: đợi cho đến khi SharedPreferences được khởi tạo
// Lưu trạng thái mới vào SharedPreferences với _themeKey.
    await _prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
}
