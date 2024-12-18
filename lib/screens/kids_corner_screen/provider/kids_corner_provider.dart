import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zaitoon/screens/kids_corner_screen/models/kids_content_model.dart';

const baseUrl = 'https://directus.jihkerala.org/items/zaitoon_kids_submission';
const assetBaseUrl = 'https://directus.jihkerala.org/assets/';

// providers/kids_corner_provider.dart
// import 'package:flutter/foundation.dart';

// import 'dart:convert';

class KidsCornerProvider with ChangeNotifier {
  List<KidsContent> _stories = [];
  List<KidsContent> _poems = [];
  List<KidsContent> _drawings = [];
  List<KidsContent> _highlights = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<KidsContent> get stories => _stories;
  List<KidsContent> get poems => _poems;
  List<KidsContent> get drawings => _drawings;
  List<KidsContent> get highlights => _highlights;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchContent() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await http.get(Uri.parse('$baseUrl?filter[status][_eq]=published'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['data'] ?? [];

        final allContent =
            items.map((item) => KidsContent.fromJson(item)).toList();

        _stories =
            allContent.where((item) => item.contentType == 'story').toList();
        _poems =
            allContent.where((item) => item.contentType == 'poem').toList();
        _drawings =
            allContent.where((item) => item.contentType == 'drawing').toList();
        _highlights = allContent.where((item) => item.highlighted).toList();

        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load content');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  String getAssetUrl(String? assetId) {
    if (assetId == null) return '';
    return '$assetBaseUrl$assetId';
  }
}
