import 'package:flutter/foundation.dart';
import 'package:zaitoon/screens/ott_watchlist/models/ott_content_model.dart';

class OttWatchlistProvider extends ChangeNotifier {
  List<OttContentModel> _watchlist = [];
  bool _isLoading = false;

  List<OttContentModel> get watchlist => _watchlist;
  bool get isLoading => _isLoading;

  // Load watchlist (for now using mock data, later can be from API/local storage)
  Future<void> loadWatchlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // YouTube videos data
      _watchlist = [
        OttContentModel(
          id: 'qxV1mGgGomo',
          title: 'Kids Educational Video',
          thumbnail: 'https://img.youtube.com/vi/qxV1mGgGomo/maxresdefault.jpg',
          year: '2024',
          genre: 'Educational',
          duration: '15m',
          description:
              'Fun and educational content for kids to learn and enjoy.',
          videoUrl: 'https://www.youtube.com/watch?v=qxV1mGgGomo',
          addedToWatchlist: DateTime.now().subtract(const Duration(days: 2)),
        ),
        OttContentModel(
          id: 'VqA_NHmmmYs',
          title: 'Adventure Story',
          thumbnail: 'https://img.youtube.com/vi/VqA_NHmmmYs/maxresdefault.jpg',
          year: '2024',
          genre: 'Adventure',
          duration: '12m',
          description:
              'An exciting adventure story that will captivate young minds.',
          videoUrl: 'https://youtu.be/VqA_NHmmmYs',
          addedToWatchlist: DateTime.now().subtract(const Duration(days: 1)),
        ),
        OttContentModel(
          id: 'hiElSK3nDWA',
          title: 'Learning Fun',
          thumbnail: 'https://img.youtube.com/vi/hiElSK3nDWA/maxresdefault.jpg',
          year: '2024',
          genre: 'Educational',
          duration: '18m',
          description: 'Interactive learning content designed for children.',
          videoUrl: 'https://youtu.be/hiElSK3nDWA',
          addedToWatchlist: DateTime.now().subtract(const Duration(hours: 18)),
        ),
        OttContentModel(
          id: 'CSz9hbMiva8',
          title: 'Creative Stories',
          thumbnail: 'https://img.youtube.com/vi/CSz9hbMiva8/maxresdefault.jpg',
          year: '2024',
          genre: 'Creative',
          duration: '20m',
          description: 'Imaginative stories that spark creativity and wonder.',
          videoUrl: 'https://youtu.be/CSz9hbMiva8',
          addedToWatchlist: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        OttContentModel(
          id: 'OiHQ_pbQfU8',
          title: 'Music & Songs',
          thumbnail: 'https://img.youtube.com/vi/OiHQ_pbQfU8/maxresdefault.jpg',
          year: '2024',
          genre: 'Music',
          duration: '25m',
          description: 'Catchy songs and music videos for kids to sing along.',
          videoUrl: 'https://youtu.be/OiHQ_pbQfU8',
          addedToWatchlist: DateTime.now().subtract(const Duration(hours: 8)),
        ),
        OttContentModel(
          id: 'z0_3xEpGNnw',
          title: 'Fun Activities',
          thumbnail: 'https://img.youtube.com/vi/z0_3xEpGNnw/maxresdefault.jpg',
          year: '2024',
          genre: 'Activities',
          duration: '16m',
          description: 'Engaging activities and games for children to enjoy.',
          videoUrl: 'https://youtu.be/z0_3xEpGNnw',
          addedToWatchlist: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ];
    } catch (e) {
      debugPrint('Error loading watchlist: $e');
      _watchlist = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add content to watchlist
  Future<bool> addToWatchlist(OttContentModel content) async {
    try {
      if (!_watchlist.any((item) => item.id == content.id)) {
        _watchlist.insert(0, content); // Add to beginning of list
        notifyListeners();

        // TODO: Save to local storage or API
        return true;
      }
      return false; // Already in watchlist
    } catch (e) {
      debugPrint('Error adding to watchlist: $e');
      return false;
    }
  }

  // Remove content from watchlist
  Future<bool> removeFromWatchlist(String contentId) async {
    try {
      final initialLength = _watchlist.length;
      _watchlist.removeWhere((item) => item.id == contentId);

      if (_watchlist.length < initialLength) {
        notifyListeners();

        // TODO: Update local storage or API
        return true;
      }
      return false; // Item not found
    } catch (e) {
      debugPrint('Error removing from watchlist: $e');
      return false;
    }
  }

  // Check if content is in watchlist
  bool isInWatchlist(String contentId) {
    return _watchlist.any((item) => item.id == contentId);
  }

  // Clear entire watchlist
  Future<void> clearWatchlist() async {
    try {
      _watchlist.clear();
      notifyListeners();

      // TODO: Clear from local storage or API
    } catch (e) {
      debugPrint('Error clearing watchlist: $e');
    }
  }

  // Get watchlist count
  int get watchlistCount => _watchlist.length;
}
