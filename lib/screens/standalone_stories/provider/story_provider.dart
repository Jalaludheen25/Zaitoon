import 'package:flutter/material.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/screens/standalone_stories/models/single_story_model.dart';
import 'package:http/http.dart' as http;

class StoriesProvider extends ChangeNotifier {
  SingleStoryModel? _singleStoryModel;
  bool _isLoading = false;
  String _error = '';
  bool _isBookmarkLoading = false;

  // Getters
  SingleStoryModel? get singleStoryModel => _singleStoryModel;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isBookmarkLoading => _isBookmarkLoading;

  Future<void> fetchStories() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      debugPrint('🔄 Fetching stories from: ${ApiUrls.baseUrl}/items/zaitoon_single_story');
      final response = await http
          .get(Uri.parse('${ApiUrls.baseUrl}/items/zaitoon_single_story'));

      debugPrint('📡 Stories API Response Status: ${response.statusCode}');
      debugPrint('📄 Stories API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ Starting to parse stories...');
        _singleStoryModel = singleStoryModelFromJson(response.body);
        debugPrint('✅ Successfully parsed ${_singleStoryModel?.data.length ?? 0} stories');
        
        // Log each story's fields to identify null values
        if (_singleStoryModel?.data != null) {
          for (int i = 0; i < _singleStoryModel!.data.length; i++) {
            final story = _singleStoryModel!.data[i];
            debugPrint('📖 Story $i: ${story.storyTitleEn ?? 'No Title'}');
            // debugPrint('   - ID: ${story.id}');
            // debugPrint('   - Cover Image: ${story.coverImage}');
            // debugPrint('   - Description: ${story.description}');
            // debugPrint('   - Read Time: ${story.readTime}');
            // debugPrint('   - Story File EN: ${story.storyFileEn}');
            // debugPrint('   - Story File ML: ${story.storyFileMl}');
            // debugPrint('   - Story Title EN: ${story.storyTitleEn}');
            // debugPrint('   - Story Title ML: ${story.storyTitleMl}');
            // debugPrint('   - Tag: ${story.tag}');
            // debugPrint('   - Is Highlighted: ${story.isHighlighted}');
            // debugPrint('   - EN Banner: ${story.enBanner}');
            // debugPrint('   - ML Banner: ${story.mlBanner}');
          }
        }
      } else {
        _error = 'Failed to load stories';
        debugPrint('❌ Stories API Error: Status ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('💥 Stories API Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setBookmarkLoading(bool value) {
    _isBookmarkLoading = value;
    notifyListeners();
  }
}
