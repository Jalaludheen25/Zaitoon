import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/episode_screen.dart/episode_screen.dart';
import 'package:zaitoon/screens/home_screen/home_screen.dart';
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
    return Scaffold(
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
                color: Colors.white,
              ),
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all(Colors.black.withOpacity(0.2)),
              ),
              onPressed: () {
                if (pdfProvider.currentStoryId != null) {
                  navigatePRTo(
                      context,
                      EpisodeScreen(
                          id: pdfProvider.currentStoryId.toString(),
                          title: pdfProvider.currentStoryTitle!));
                } else {
                  navigatePRTo(context, const HomeScreen());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
