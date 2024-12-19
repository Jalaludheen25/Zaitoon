import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
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

  Future<String?> _uploadImage(File imageFile) async {
    try {
      var uri = Uri.parse('https://directus.jihkerala.org/files');
      var request = http.MultipartRequest('POST', uri);

      // Get the file extension and mime type
      final mimeType = lookupMimeType(imageFile.path);
      final fileName = path.basename(imageFile.path);

      // Add file metadata
      request.fields['title'] = fileName;

      // Create multipart file with correct filename
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: fileName,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      );

      request.files.add(multipartFile);

      // Add required headers for Directus
      request.headers.addAll({
        'Accept': 'application/json',
      });

      log('Uploading file: ${imageFile.path}');
      log('File exists: ${await imageFile.exists()}');
      log('File size: ${await imageFile.length()} bytes');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      log('File upload response status: ${response.statusCode}');
      log('File upload response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] != null &&
            jsonResponse['data']['id'] != null) {
          return jsonResponse['data']['id'];
        } else {
          log('Invalid response format: $jsonResponse');
          return null;
        }
      } else {
        log('Failed to upload image. Status code: ${response.statusCode}');
        log('Response body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      log('Error uploading image: $e');
      log('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<bool> submitContent({
    required String title,
    required String contentType,
    required String storyOrPoem,
    required String kidName,
    required int kidAge,
    required String schoolName,
    String? parentName,
    String? parentPhoneNumber,
    File? kidPhoto,
    File? drawings,
    String? descriptionForDrawings,
  }) async {
    try {
      String? kidPhotoId;
      String? drawingsId;

      // Upload kid's photo
      if (kidPhoto != null) {
        log('Uploading kid photo...');
        kidPhotoId = await _uploadImage(kidPhoto);
        if (kidPhotoId == null) {
          throw Exception('Failed to upload kid photo');
        }
        log('Kid photo uploaded successfully. ID: $kidPhotoId');
      }

      // Upload drawing if content type is drawing
      if (drawings != null && contentType == 'drawing') {
        log('Uploading drawing...');
        drawingsId = await _uploadImage(drawings);
        if (drawingsId == null) {
          throw Exception('Failed to upload drawing');
        }
        log('Drawing uploaded successfully. ID: $drawingsId');
      }

      // Prepare the request body
      final Map<String, dynamic> body = {
        "status": "pending",
        "date_created": DateTime.now().toUtc().toIso8601String(),
        "content_type": contentType,
        "title": title,
        "story_or_poem": contentType == 'drawing' ? null : storyOrPoem,
        "drawings": drawingsId,
        "kid_name": kidName,
        "kid_age": kidAge,
        "school_name": schoolName,
        "parent_name": parentName?.isEmpty ?? true ? null : parentName,
        "parent_phone_number":
            parentPhoneNumber?.isEmpty ?? true ? null : parentPhoneNumber,
        "kid_photo": kidPhotoId,
        "cover_image_for_poem_and_story": null,
        "description_for_drawings":
            contentType == 'drawing' ? descriptionForDrawings : null,
        "Highlighted": false
      };

      log('Submitting content with body: $body');

      // Submit content
      final response = await http.post(
        Uri.parse(
            'https://directus.jihkerala.org/items/zaitoon_kids_submission'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      log('Content submission response status: ${response.statusCode}');
      log('Content submission response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchContent();
        return true;
      } else {
        _error = 'Failed to submit content: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      log('Error in submitContent: $e');
      log('Stack trace: $stackTrace');
      _error = 'Error submitting content: $e';
      notifyListeners();
      return false;
    }
  }

  String getAssetUrl(String? assetId) {
    if (assetId == null) return '';
    return '$assetBaseUrl$assetId';
  }
}
