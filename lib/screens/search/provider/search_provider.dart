import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchProvider extends ChangeNotifier {
  static const String _prefsKeyPrefix = 'recent_searches_';
  static const String _oldGlobalKey = 'recent_searches';

  // Each entry: { 'title': String, 'imageUrl': String }
  final List<Map<String, String>> _recentSearches = <Map<String, String>>[];
  String _query = '';
  String _userId = 'guest';

  List<Map<String, String>> get recentSearches =>
      List.unmodifiable(_recentSearches);
  String get query => _query;

  Future<void> initialize(String userId) async {
    _userId = (userId.isEmpty) ? 'guest' : userId;
    await _loadRecentSearches();
    await _migrateOldGlobalHistoryIfAny();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String raw = prefs.getString(_prefsKeyPrefix + _userId) ?? '[]';
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _recentSearches.clear();
      for (final dynamic e in decoded) {
        if (e is Map<String, dynamic>) {
          _recentSearches.add({
            'title': (e['title'] ?? '').toString(),
            'imageUrl': (e['imageUrl'] ?? '').toString(),
          });
        } else if (e is String) {
          // Backward compatibility
          _recentSearches.add({'title': e, 'imageUrl': ''});
        }
      }
      notifyListeners();
    } catch (_) {
      // ignore parse/load errors silently
    }
  }

  Future<void> _persistRecentSearches() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKeyPrefix + _userId, jsonEncode(_recentSearches));
  }

  Future<void> _migrateOldGlobalHistoryIfAny() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(_oldGlobalKey)) return;
      final String raw = prefs.getString(_oldGlobalKey) ?? '[]';
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      if (decoded.isEmpty) return;
      final List<Map<String, String>> merged = [
        ..._recentSearches,
        ...decoded.map((e) => {
              'title': e.toString(),
              'imageUrl': '',
            }),
      ];
      // Deduplicate by title (case-insensitive)
      final Set<String> seen = {};
      final List<Map<String, String>> deduped = [];
      for (final item in merged) {
        final key = (item['title'] ?? '').toLowerCase();
        if (key.isEmpty || seen.contains(key)) continue;
        seen.add(key);
        deduped.add(item);
      }
      _recentSearches
        ..clear()
        ..addAll(deduped.take(12));
      await _persistRecentSearches();
      // Optionally clear old global store
      // await prefs.remove(_oldGlobalKey);
      notifyListeners();
    } catch (_) {}
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  Future<void> addStoryToHistory({
    required String title,
    required String imageUrl,
  }) async {
    final String normalized = title.trim();
    if (normalized.isEmpty) return;
    _recentSearches.removeWhere(
        (t) => (t['title'] ?? '').toLowerCase() == normalized.toLowerCase());
    _recentSearches.insert(0, {
      'title': normalized,
      'imageUrl': imageUrl,
    });
    if (_recentSearches.length > 12) {
      _recentSearches.removeRange(12, _recentSearches.length);
    }
    await _persistRecentSearches();
    notifyListeners();
  }

  Future<void> removeFromHistory(String term) async {
    _recentSearches.removeWhere((t) => (t['title'] ?? '') == term);
    await _persistRecentSearches();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _recentSearches.clear();
    await _persistRecentSearches();
    notifyListeners();
  }
}
