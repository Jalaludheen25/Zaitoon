import 'package:flutter/material.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/screens/standalone_stories/models/single_story_model.dart';
import 'package:http/http.dart' as http;

class StoriesProvider extends ChangeNotifier {
  SingleStoryModel? _singleStoryModel;
  bool _isLoading = false;
  String _error = '';

  // Getters
  SingleStoryModel? get singleStoryModel => _singleStoryModel;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchStories() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('${ApiUrls.baseUrl}/items/zaitoon_single_story'));

      if (response.statusCode == 200) {
        _singleStoryModel = singleStoryModelFromJson(response.body);
      } else {
        _error = 'Failed to load stories';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
