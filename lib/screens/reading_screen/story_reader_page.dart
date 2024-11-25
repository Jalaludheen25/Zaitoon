// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/bottom_navigation/bottom_navigation.dart';
import 'package:zaitoon/screens/episode_screen.dart/episode_screen.dart';
import 'package:zaitoon/screens/reading_screen/provider/story_provider.dart';

class StoryReadingScreen extends StatefulWidget {
  final String pdfUrl;
  const StoryReadingScreen({super.key, required this.pdfUrl});

  @override
  State<StoryReadingScreen> createState() => _StoryReadingScreenState();
}

class _StoryReadingScreenState extends State<StoryReadingScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  @override
  Widget build(BuildContext context) {
    PdfProvider pdfProvider = Provider.of<PdfProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        if (pdfProvider.currentStoryId != null) {
          navigatePR(
            context,
            EpisodeScreen(
              id: pdfProvider.currentStoryId.toString(),
              title: pdfProvider.currentStoryTitle!,
              imageUrl: pdfProvider.currentStoryImage!,
            ),
          );
        } else {
          navigateAndRemove(context, const BottomNavigationScreen());
        }
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            SfPdfViewer.network(
              widget.pdfUrl,
              controller: _pdfViewerController,
              enableDoubleTapZooming: false,
              canShowScrollHead: false,
              maxZoomLevel: 1,
              pageLayoutMode: PdfPageLayoutMode.continuous,
            ),
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: ColorClass.white,
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                      ColorClass.black.withOpacity(0.2)),
                ),
                onPressed: () {
                  navigateBack(
                    context,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
