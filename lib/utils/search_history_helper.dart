import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryHelper {
  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 5;

  static Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_searchHistoryKey) ?? [];
    return history;
  }

  static Future<void> addSearchQuery(String query) async {
    if (query.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_searchHistoryKey) ?? [];

    // Xóa query nếu đã tồn tại để tránh trùng lặp
    history.remove(query);

    // Thêm query mới vào đầu danh sách
    history.insert(0, query);

    // Giới hạn số lượng lịch sử
    if (history.length > _maxHistoryItems) {
      history = history.sublist(0, _maxHistoryItems);
    }

    await prefs.setStringList(_searchHistoryKey, history);
  }

  static Future<void> removeSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_searchHistoryKey) ?? [];
    history.remove(query);
    await prefs.setStringList(_searchHistoryKey, history);
  }

  static Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);
  }
}
