import 'dart:developer';
import 'dart:io';
import 'package:d4tales/constants/app_urls.dart';
import 'package:d4tales/screens/home_screen/models/story_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider extends ChangeNotifier {
  StoryModel? _storyModel;
  bool _isLoading = false;
  String? _error;

  StoryModel? get storyModel => _storyModel;
  bool get isStoryLoading => _isLoading;
  String? get error => _error;

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
}