// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:zaitoon/constants/app_constants.dart';
import 'package:zaitoon/constants/app_urls.dart';

class VersionCheckProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _newVersion;
  bool _forceUpdate = false;
  String? _changes;
  bool _needsUpdate = false;

  bool get isLoading => _isLoading;
  bool get needsUpdate => _needsUpdate;
  String? get newVersion => _newVersion;
  bool get forceUpdate => _forceUpdate;
  String? get changes => _changes;

  Future<void> checkVersion() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get current installed version
      const currentVersion = ApiContants.appVersion;

      // Fetch version info from API
      final response = await http
          .get(Uri.parse('${ApiUrls.baseUrl}/items/zaitoon_force_update'));
      if (response.statusCode == 200) {
        log('Version check response: ${response.body}');

        final data = json.decode(response.body)['data'];

        _newVersion = data['new_version'];
        _forceUpdate = data['force'];
        _changes = data['changes'];

        // Compare versions (ignoring build number after +)
        final currentVersionNumber = currentVersion.split('+')[0];
        final newVersionNumber = _newVersion!.split('+')[0];

        // Compare version numbers
        _needsUpdate = _compareVersions(currentVersionNumber, newVersionNumber);

        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error checking version: $e');
    }
  }

  bool _compareVersions(String current, String new_) {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> newParts = new_.split('.').map(int.parse).toList();

    for (int i = 0; i < currentParts.length; i++) {
      if (newParts[i] > currentParts[i]) return true;
      if (newParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  void launchAppStore({required BuildContext context}) async {
    // Replace these URLs with your actual app store URLs
    const String androidUrl = 'market://details?id=net.thafheem.app';
    const String iOSUrl =
        'https://apps.apple.com/in/app/thafheemul-quran/id1292572556';

    if (Theme.of(context).platform == TargetPlatform.android) {
      if (!await launchUrl(Uri.parse(androidUrl))) {
        // If market:// scheme fails, try https:// scheme
        await launchUrl(Uri.parse(
            'https://play.google.com/store/apps/details?id=net.thafheem.app'));
      }
    } else {
      await launchUrl(Uri.parse(iOSUrl));
    }
  }
}
