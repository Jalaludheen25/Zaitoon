// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/bookmark_screen/provider/bookmark_provider.dart';

class StoryReadingScreen extends StatefulWidget {
  final String pdfUrl;
  final String id;
  final String title;
  final String thumbnail;
  final String tag;

  const StoryReadingScreen({
    super.key,
    required this.pdfUrl,
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.tag,
  });

  @override
  State<StoryReadingScreen> createState() => _StoryReadingScreenState();
}

class _StoryReadingScreenState extends State<StoryReadingScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  Widget build(BuildContext context) {
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
          // Top Bar with Back and Bookmark buttons
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: ColorClass.white,
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        ColorClass.black.withOpacity(0.2),
                      ),
                    ),
                    onPressed: () => navigateBack(context),
                  ),
                  // Bookmark Button
                  Consumer<BookmarkProvider>(
                    builder: (context, bookmarkProvider, child) {
                      final isBookmarked =
                          bookmarkProvider.isBookmarked(widget.id);

                      return IconButton(
                        icon: Icon(
                          isBookmarked
                              ? LucideIcons.bookMarked
                              : LucideIcons.bookmark,
                          color: isBookmarked
                              ? Colors.greenAccent
                              : ColorClass.white,
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            ColorClass.black.withOpacity(0.2),
                          ),
                        ),
                        onPressed: () async {
                          if (isBookmarked) {
                            await bookmarkProvider.removeBookmark(widget.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Removed from bookmarks'),
                                  duration: Duration(seconds: 1),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            await bookmarkProvider.addBookmark(
                              id: widget.id,
                              thumbnail: widget.thumbnail,
                              title: widget.title,
                              fileUrl: widget.pdfUrl,
                              tag: widget.tag,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to bookmarks'),
                                  duration: Duration(seconds: 1),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
