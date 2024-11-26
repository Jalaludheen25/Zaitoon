// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
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
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController.addListener(_checkIfAtBottom);
  }

  @override
  void dispose() {
    _pdfViewerController.removeListener(_checkIfAtBottom);
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _checkIfAtBottom() {
    if (_pdfViewerController.pageNumber == _pdfViewerController.pageCount) {
      if (!_isAtBottom) {
        setState(() => _isAtBottom = true);
      }
    } else if (_isAtBottom) {
      setState(() => _isAtBottom = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PDF Viewer
          SfPdfViewer.network(
            widget.pdfUrl,
            controller: _pdfViewerController,
            enableDoubleTapZooming: false,
            canShowScrollHead: false,
            maxZoomLevel: 1,
            pageLayoutMode: PdfPageLayoutMode.continuous,
            onPageChanged: (PdfPageChangedDetails details) {
              _checkIfAtBottom();
            },
          ),

          // Top Bar with Back and Bookmark buttons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: ColorClass.white,
                          size: 20,
                        ),
                        onPressed: () => navigateBack(context),
                      ),
                    ),

                    // Bookmark Button
                    Consumer<BookmarkProvider>(
                      builder: (context, bookmarkProvider, child) {
                        final isBookmarked =
                            bookmarkProvider.isBookmarked(widget.id);

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              isBookmarked
                                  ? LucideIcons.bookMarked
                                  : LucideIcons.bookmark,
                              color: isBookmarked
                                  ? Colors.greenAccent
                                  : ColorClass.white,
                              size: 20,
                            ),
                            onPressed: () async {
                              if (isBookmarked) {
                                await bookmarkProvider
                                    .removeBookmark(widget.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Removed from bookmarks',
                                        style: TextStyleClass.poppinsSemiBold(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
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
                                    SnackBar(
                                      content: Text('Added to bookmarks',
                                          style: TextStyleClass.poppinsSemiBold(
                                            fontSize: 14,
                                            color: Colors.white,
                                          )),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Read Next Button
          // AnimatedPositioned(
          //   duration: const Duration(milliseconds: 300),
          //   curve: Curves.easeInOut,
          //   bottom: _isAtBottom ? 20 : -80,
          //   left: 20,
          //   right: 20,
          //   child: SafeArea(
          //     child: Container(
          //       height: 56,
          //       decoration: BoxDecoration(
          //         gradient: LinearGradient(
          //           colors: [
          //             Colors.purple.shade600,
          //             Colors.purple.shade400,
          //           ],
          //         ),
          //         borderRadius: BorderRadius.circular(16),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.black.withOpacity(0.2),
          //             blurRadius: 8,
          //             offset: const Offset(0, 4),
          //           ),
          //         ],
          //       ),
          //       child: Material(
          //         color: Colors.transparent,
          //         child: InkWell(
          //           onTap: () {
          //             // Add your navigation logic here
          //             // For example:
          //             // Navigator.push(
          //             //   context,
          //             //   MaterialPageRoute(
          //             //     builder: (context) => NextStoryScreen(),
          //             //   ),
          //             // );
          //           },
          //           borderRadius: BorderRadius.circular(16),
          //           child: const Padding(
          //             padding: EdgeInsets.symmetric(horizontal: 20),
          //             child: Row(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: [
          //                 Text(
          //                   'Read Next Story',
          //                   style: TextStyle(
          //                     color: Colors.white,
          //                     fontSize: 16,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //                 SizedBox(width: 8),
          //                 Icon(
          //                   LucideIcons.moveRight,
          //                   color: Colors.white,
          //                   size: 20,
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
