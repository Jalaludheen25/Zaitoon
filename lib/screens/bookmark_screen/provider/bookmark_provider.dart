// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/screens/bookmark_screen/hive/bookmark_hive_model.dart';
import 'package:zaitoon/screens/login_screen/login_screen.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/login_screen/provider/auth_provider.dart';

class BookmarkProvider extends ChangeNotifier {
  static const String _boxName = 'bookmarks';
  Box<BookmarkModel>? _bookmarkBox;
  List<BookmarkModel> _bookmarks = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters
  List<BookmarkModel> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Initialize Hive
  Future<void> initHive() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      _bookmarkBox = await Hive.openBox<BookmarkModel>(_boxName);
      _isInitialized = true;
      await loadBookmarks();
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Check login status and show login prompt if needed
  Future<bool> _checkLoginStatus(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkUserStatus();

    if (!authProvider.isSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please login to manage bookmarks'),
          action: SnackBarAction(
            label: 'Login',
            onPressed: () {
              navigateAndRemove(context: context, screen: const AuthScreen());
            },
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  // Load all bookmarks
  Future<void> loadBookmarks() async {
    if (_bookmarkBox == null) {
      debugPrint('Bookmark box not initialized');
      return;
    }

    try {
      _bookmarks = _bookmarkBox!.values.toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
    }
  }

  // Add bookmark with login check
  Future<bool> addBookmark({
    required BuildContext context,
    required String id,
    required String thumbnail,
    required String title,
    required String fileUrl,
    required String tag,
  }) async {
    if (!await _checkLoginStatus(context)) return false;
    if (_bookmarkBox == null) {
      debugPrint('Bookmark box not initialized');
      return false;
    }

    try {
      final bookmark = BookmarkModel(
        id: id,
        thumbnail: thumbnail,
        title: title,
        fileUrl: fileUrl,
        tag: tag,
      );

      await _bookmarkBox!.put(id, bookmark);
      await loadBookmarks();
      return true;
    } catch (e) {
      debugPrint('Error adding bookmark: $e');
      return false;
    }
  }

  // Remove bookmark with login check
  Future<bool> removeBookmark(BuildContext context, String id) async {
    if (!await _checkLoginStatus(context)) return false;
    if (_bookmarkBox == null) {
      debugPrint('Bookmark box not initialized');
      return false;
    }

    try {
      await _bookmarkBox!.delete(id);
      await loadBookmarks();
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Bookmark removed successfully'),
      //     duration: Duration(seconds: 2),
      //   ),
      // );
      return true;
    } catch (e) {
      debugPrint('Error removing bookmark: $e');
      return false;
    }
  }

  // Toggle bookmark status
  Future<bool> toggleBookmark({
    required BuildContext context,
    required String id,
    required String thumbnail,
    required String title,
    required String fileUrl,
    required String tag,
  }) async {
    if (!await _checkLoginStatus(context)) return false;

    if (isBookmarked(id)) {
      return await removeBookmark(context, id);
    } else {
      return await addBookmark(
        context: context,
        id: id,
        thumbnail: thumbnail,
        title: title,
        fileUrl: fileUrl,
        tag: tag,
      );
    }
  }

  // Check if story is bookmarked
  bool isBookmarked(String id) {
    if (_bookmarkBox == null) return false;
    return _bookmarkBox!.containsKey(id);
  }

  // Clear all bookmarks with login check
  Future<bool> clearAllBookmarks(BuildContext context) async {
    if (!await _checkLoginStatus(context)) return false;
    if (_bookmarkBox == null) {
      debugPrint('Bookmark box not initialized');
      return false;
    }

    try {
      await _bookmarkBox!.clear();
      await loadBookmarks();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All bookmarks cleared successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Error clearing bookmarks: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _bookmarkBox?.compact();
    _bookmarkBox?.close();
    super.dispose();
  }
}
