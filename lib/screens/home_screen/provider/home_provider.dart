import 'dart:developer';

import 'package:d4tales/constants/app_urls.dart';
import 'package:d4tales/screens/home_screen/models/story_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider extends ChangeNotifier {
  StoryModel? _storyModel;
  bool _isLoading = false;

  StoryModel? get storyModel => _storyModel;
  bool get isStoryLoading => _isLoading;

  Future<void> fetchStories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(ApiUrls.stories));

      if (response.statusCode == 200) {
        log("Story data fetched successfully");
        _storyModel = storyModelFromJson(response.body);
      } else {
        throw Exception("Failed to load Story");
      }
    } catch (e) {
      log("Error fetching Story: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // save selected language locally and shared preference
  String selectedLanguage = "en";
  Future<void> saveSelectedLanguage(String language) async {
    // save selected language locally
    selectedLanguage = language;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    notifyListeners();
  }
}
