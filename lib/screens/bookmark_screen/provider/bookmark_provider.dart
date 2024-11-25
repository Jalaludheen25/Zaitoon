import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zaitoon/screens/bookmark_screen/hive/bookmark_hive_model.dart';

class BookmarkProvider extends ChangeNotifier {
  static const String _boxName = 'bookmarks';
  Box<BookmarkModel>? _bookmarkBox; // Make nullable
  List<BookmarkModel> _bookmarks = [];
  bool _isLoading = false;
  bool _isInitialized = false; // Track initialization state

  // Getters
  List<BookmarkModel> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Initialize Hive
  Future<void> initHive() async {
    if (_isInitialized) return; // Prevent multiple initializations

    _isLoading = true;
    notifyListeners();

    try {
      _bookmarkBox = await Hive.openBox<BookmarkModel>(_boxName);
      _isInitialized = true;
      await loadBookmarks(); // Load bookmarks after initialization
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
    }

    _isLoading = false;
    notifyListeners();
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

  // Add bookmark
  Future<void> addBookmark({
    required String id,
    required String thumbnail,
    required String title,
    required String fileUrl,
    required String tag,
  }) async {
    if (_bookmarkBox == null) {
      debugPrint('Bookmark box not initialized');
      return;
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
    } catch (e) {
      debugPrint('Error adding bookmark: $e');
    }
  }

  // Remove bookmark
  Future<void> removeBookmark(String id) async {
    if (_bookmarkBox == null) {
      debugPrint('Bookmark box not initialized');
      return;
    }

    try {
      await _bookmarkBox!.delete(id);
      await loadBookmarks();
    } catch (e) {
      debugPrint('Error removing bookmark: $e');
    }
  }

  // Check if story is bookmarked
  bool isBookmarked(String id) {
    if (_bookmarkBox == null) return false;
    return _bookmarkBox!.containsKey(id);
  }

  // Clear all bookmarks
  Future<void> clearAllBookmarks() async {
    if (_bookmarkBox == null) {
      debugPrint('Bookmark box not initialized');
      return;
    }

    try {
      await _bookmarkBox!.clear();
      await loadBookmarks();
    } catch (e) {
      debugPrint('Error clearing bookmarks: $e');
    }
  }

  @override
  void dispose() {
    _bookmarkBox?.compact();
    _bookmarkBox?.close();
    super.dispose();
  }
}
