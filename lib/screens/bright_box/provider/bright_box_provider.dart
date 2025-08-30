import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/screens/bright_box/models/bright_box_models.dart';

class BrightBoxProvider extends ChangeNotifier {
  List<BrightBoxCategory> _categories = [];
  List<BrightBoxSubcategory> _subcategories = [];
  List<BrightBoxStory> _stories = [];
  
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BrightBoxCategory> get categories => _categories;
  List<BrightBoxSubcategory> get subcategories => _subcategories;
  List<BrightBoxStory> get stories => _stories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load categories
  Future<void> loadCategories() async {
    try {
      _setLoading(true);
      _clearError();

      debugPrint('Loading Bright Box categories...');
      final response = await http.get(Uri.parse(ApiUrls.brightBoxCategories));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Categories API Response: $data');
        final List<dynamic> categoriesData = data['data'] ?? [];
        
        _categories = categoriesData
            .map((json) {
              debugPrint('Category JSON: $json');
              return BrightBoxCategory.fromJson(json);
            })
            .toList();
        
        debugPrint('Loaded ${_categories.length} categories');
        for (var category in _categories) {
          debugPrint('Category: ${category.catTitleEn}, Cover Image: ${category.coverImage}');
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      _setError('Failed to load categories: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load subcategories for a category
  Future<void> loadSubcategories(int categoryId) async {
    try {
      _setLoading(true);
      _clearError();

      debugPrint('Loading subcategories for category $categoryId...');
      final response = await http.get(
        Uri.parse(ApiUrls.getBrightBoxSubcategories(categoryId))
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> subcategoriesData = data['data'] ?? [];
        
        _subcategories = subcategoriesData
            .map((json) => BrightBoxSubcategory.fromJson(json))
            .toList();
        
        debugPrint('Loaded ${_subcategories.length} subcategories');
      } else {
        throw Exception('Failed to load subcategories: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading subcategories: $e');
      _setError('Failed to load subcategories: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load stories for a subcategory
  Future<void> loadStories(int subcategoryId) async {
    try {
      _setLoading(true);
      _clearError();

      debugPrint('Loading stories for subcategory $subcategoryId...');
      final response = await http.get(
        Uri.parse(ApiUrls.getBrightBoxStories(subcategoryId))
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> storiesData = data['data'] ?? [];
        
        _stories = storiesData
            .map((json) => BrightBoxStory.fromJson(json))
            .toList();
        
        debugPrint('Loaded ${_stories.length} stories');
      } else {
        throw Exception('Failed to load stories: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading stories: $e');
      _setError('Failed to load stories: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Clear data when navigating back
  void clearSubcategories() {
    _subcategories.clear();
    notifyListeners();
  }

  void clearStories() {
    _stories.clear();
    notifyListeners();
  }
}