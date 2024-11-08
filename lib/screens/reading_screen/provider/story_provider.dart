// pdf_state.dart
import 'dart:developer';

import 'package:flutter/material.dart';

class PdfProvider extends ChangeNotifier {
  /// current read story
  int? currentStoryId;
  String? currentStoryTitle;
  void setCurrentStory(int? id, String? title) {
    currentStoryId = id;
    currentStoryTitle = title;
    log('currentStoryId: $currentStoryId');
    notifyListeners();
  }

  /// current read story
}
//   bool _isLoading = false;
//   String? _pdfPath;
//   int _currentPage = 0;
//   int _totalPages = 0;
//   bool _hasError = false;
//   String _errorMessage = '';

//   bool get isLoading => _isLoading;
//   String? get pdfPath => _pdfPath;
//   int get currentPage => _currentPage;
//   int get totalPages => _totalPages;
//   bool get hasError => _hasError;
//   String get errorMessage => _errorMessage;

//   void setCurrentPage(int page) {
//     _currentPage = page;
//     notifyListeners();
//   }

//   void setTotalPages(int pages) {
//     _totalPages = pages;
//     notifyListeners();
//   }

//   Future<void> loadPDF(String url) async {
//     try {
//       _isLoading = true;
//       _hasError = false;
//       _errorMessage = '';
//       notifyListeners();

//       // Get temporary directory
//       final dir = await getTemporaryDirectory();
//       final filename = url.split('/').last;
//       final file = File('${dir.path}/$filename');

//       // Download PDF if it doesn't exist
//       if (!file.existsSync()) {
//         final response = await http.get(Uri.parse(url));
//         if (response.statusCode != 200) {
//           throw Exception('Failed to download PDF');
//         }
//         await file.writeAsBytes(response.bodyBytes);
//       }

//       _pdfPath = file.path;
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _hasError = true;
//       _errorMessage = e.toString();
//       notifyListeners();
//     }
//   }

//   @override
//   void dispose() {
//     // Clean up temporary files if needed
//     if (_pdfPath != null) {
//       try {
//         File(_pdfPath!).deleteSync();
//       } catch (e) {
//         log('Error deleting temporary file: $e');
//       }
//     }
//     super.dispose();
//   }
// }
