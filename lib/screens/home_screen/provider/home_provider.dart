import 'dart:developer';
import 'dart:io';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/screens/home_screen/models/episode_model.dart';
import 'package:zaitoon/screens/home_screen/models/story_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaitoon/screens/standalone_stories/models/single_story_model.dart';

class HomeProvider extends ChangeNotifier {
  StoryModel? _storyModel;
  EpisodeModel? _episodeModel;
  SingleStoryModel? _singleStoryModel;
  bool _isLoading = false;
  String? _error;
  EpisodeModel? _highlightedEpisodes;
  bool _isHighlightedLoading = false;
  // Cache of episode counts per story to avoid fetching on every render
  final Map<int, int> _episodeCountByStoryId = {};
  final Map<int, bool> _isEpisodeCountLoading = {};

  StoryModel? get storyModel => _storyModel;
  bool get isStoryLoading => _isLoading;
  EpisodeModel? get episodeModel => _episodeModel;
  SingleStoryModel? get singleStoryModel => _singleStoryModel;
  bool get isepisodeLoading => _isLoading;
  String? get error => _error;
  EpisodeModel? get highlightedEpisodes => _highlightedEpisodes;
  bool get isHighlightedLoading => _isHighlightedLoading;

  // Returns cached episode count if known; otherwise null
  int? getEpisodeCountCached(int storyId) => _episodeCountByStoryId[storyId];

  // Ensure episode count for a story is fetched and cached
  Future<void> ensureEpisodeCount(int storyId) async {
    if (_episodeCountByStoryId.containsKey(storyId)) return;
    if (_isEpisodeCountLoading[storyId] == true) return;
    _isEpisodeCountLoading[storyId] = true;
    try {
      final response = await http
          .get(Uri.parse(ApiUrls.getEpisode(storyId.toString())))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final model = episodeModelFromJson(response.body);
        _episodeCountByStoryId[storyId] = (model.data ?? []).length;
      }
    } catch (_) {
      // Silently ignore; we will keep showing fallback text
    } finally {
      _isEpisodeCountLoading[storyId] = false;
      notifyListeners();
    }
  }

  Future<void> fetchStories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Add timeout to the request
      final response = await http
          .get(Uri.parse(ApiUrls.stories))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        log("Story data fetched successfully");
        _storyModel = storyModelFromJson(response.body);
        _error = null;
      } else {
        _error = "Failed to load stories: ${response.statusCode}";
        log(_error!);
      }
    } on SocketException catch (e) {
      _error = "No internet connection. Please check your network.";
      log("Network error: $e");
    } on HttpException catch (e) {
      _error = "Couldn't reach the server.";
      log("HTTP error: $e");
    } on FormatException catch (e) {
      _error = "Invalid response format.";
      log("Format error: $e");
    } catch (e) {
      _error = "Something went wrong. Please try again.";
      log("Error fetching Story: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // save selected language locally and shared preference
  String selectedLanguage = "en";
  Future<void> saveSelectedLanguage(String language) async {
    try {
      selectedLanguage = language;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', language);
      notifyListeners();
    } catch (e) {
      log("Error saving language preference: $e");
    }
  }

  Future<void> loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedLanguage = prefs.getString('language') ?? "en"; // Default to "en"
    notifyListeners();
  }

  // Function to set onboarding as completed
  Future<void> setOnboardingCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);
  }

  // Function to check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboardingCompleted') ?? false;
  }

  Future<void> fetchEpisodes(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Add timeout to the request
      final response = await http
          .get(Uri.parse(ApiUrls.getEpisode(id)))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        log("Episode data fetched successfully");
        _episodeModel = episodeModelFromJson(response.body);
        _error = null;
      } else {
        _error = "Failed to load episode: ${response.statusCode}";
        log(_error!);
      }
    } on SocketException catch (e) {
      _error = "No internet connection. Please check your network.";
      log("Network error: $e");
    } on HttpException catch (e) {
      _error = "Couldn't reach the server.";
      log("HTTP error: $e");
    } on FormatException catch (e) {
      _error = "Invalid response format.";
      log("Format error: $e");
    } catch (e) {
      _error = "Something went wrong. Please try again.";
      log("Error fetching Story: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Function to set onboarding as completed
  int _currentPage = 0;

  int get currentPage => _currentPage;

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void nextPage() {
    _currentPage++;
    notifyListeners();
  }

  Future<void> fetchHighlightedContent() async {
    _isHighlightedLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch both highlighted episodes and stories in parallel
      final results = await Future.wait([
        http
            .get(Uri.parse(ApiUrls.highlightedEpisodes))
            .timeout(const Duration(seconds: 15)),
        http
            .get(Uri.parse(ApiUrls.highlightedStories))
            .timeout(const Duration(seconds: 15)),
      ]);

      if (results[0].statusCode == 200) {
        _highlightedEpisodes = episodeModelFromJson(results[0].body);
      }

      if (results[1].statusCode == 200) {
        _singleStoryModel = singleStoryModelFromJson(results[1].body);
      }

      _error = null;
    } catch (e) {
      _error = "Something went wrong. Please try again.";
      log("Error fetching highlighted content: $e");
    } finally {
      _isHighlightedLoading = false;
      notifyListeners();
    }
  }
}
