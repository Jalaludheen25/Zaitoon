// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/bookmark_screen/bookmark_screen.dart';
import 'package:zaitoon/screens/bookmark_screen/provider/bookmark_provider.dart';
import 'package:zaitoon/screens/bright_box/models/bright_box_models.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class BrightBoxStoryReaderScreen extends StatefulWidget {
  final BrightBoxStory story;

  const BrightBoxStoryReaderScreen({
    super.key,
    required this.story,
  });

  @override
  State<BrightBoxStoryReaderScreen> createState() => _BrightBoxStoryReaderScreenState();
}

class _BrightBoxStoryReaderScreenState extends State<BrightBoxStoryReaderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  bool _isAtBottom = false;
  bool _isLoading = true;
  String? _localPdfPath;
  int _totalPages = 0;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      // Get the current language from HomeProvider
      final homeProvider = context.read<HomeProvider>();
      final currentLanguage = homeProvider.selectedLanguage;
      
      // Get the appropriate PDF file ID based on language
      final pdfFileId = currentLanguage == 'en' ? widget.story.storyEn : widget.story.storyMl;
      
      if (pdfFileId.isEmpty) {
        throw Exception('PDF file not available for selected language');
      }
      
      // Construct the PDF URL using the asset base URL
      final pdfUrl = '${ApiUrls.assetBaseUrl}$pdfFileId';
      
      debugPrint('Loading PDF from: $pdfUrl');
      
      final response = await http.get(Uri.parse(pdfUrl));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
      
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/bright_box_story_${widget.story.id}_$currentLanguage.pdf');
      await file.writeAsBytes(response.bodyBytes);
      
      setState(() {
        _localPdfPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading PDF: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _checkIfAtBottom() {
    if (_currentPage == _totalPages) {
      if (!_isAtBottom) {
        setState(() => _isAtBottom = true);
      }
    } else if (_isAtBottom) {
      setState(() => _isAtBottom = false);
    }
  }

  String get _currentTitle {
    final homeProvider = context.read<HomeProvider>();
    final currentLanguage = homeProvider.selectedLanguage;
    return currentLanguage == 'en' ? widget.story.storyTitleEn : widget.story.storyTitleMl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Progress Indicator
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _totalPages == 0 ? 0 : _currentPage / _totalPages,
              backgroundColor: ColorClass.primaryColor.withOpacity(0.1),
              color: ColorClass.primaryColor,
              minHeight: 3,
            ),
          ),
          // PDF Viewer
          if (_localPdfPath != null && !_isLoading)
            PDFView(
              filePath: _localPdfPath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: false,
              pageFling: false,
              pageSnap: true,
              defaultPage: 0,
              fitPolicy: FitPolicy.WIDTH,
              preventLinkNavigation: false,
              onRender: (pages) {
                setState(() {
                  _totalPages = pages!;
                });
              },
              onPageChanged: (int? page, int? total) {
                if (page != null) {
                  setState(() {
                    _currentPage = page + 1;
                  });
                  _checkIfAtBottom();
                }
              },
              onError: (error) {
                debugPrint('PDF View Error: $error');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PDF Error: ${error.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),

          // Error state when PDF fails to load
          if (!_isLoading && _localPdfPath == null)
            _buildErrorState(),

          // Loading Overlay
          if (_isLoading) _buildLoadingOverlay(),

          // Top Bar
          _buildTopBar(),

          // Reading Helper
          if (_isAtBottom) _buildReadingCompleteBadge(),

          // Reading Guide Mascot
          if (!_isLoading && !_isAtBottom && _localPdfPath != null) _buildReadingGuide(),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorClass.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Story Not Available',
              style: TextStyleClass.poppinsSemiBold(
                fontSize: 18,
                color: ColorClass.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This story is not available in the selected language or there was an error loading it.',
              style: TextStyleClass.poppinsRegular(
                fontSize: 14,
                color: ColorClass.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _loadPdf();
              },
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorClass.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  icon: Icons.arrow_back_ios_new,
                  onPressed: () => navigateBack(context),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _currentTitle,
                      style: TextStyleClass.poppinsSemiBold(
                        fontSize: 16,
                        color: ColorClass.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  onPressed: _shareStory,
                ),
                const SizedBox(width: 8),
                _buildBookmarkButton(),
              ],
            ),
            if (_totalPages > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Page $_currentPage of $_totalPages',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 12,
                  color: ColorClass.white.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReadingGuide() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -_bounceAnimation.value),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorClass.primaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: ColorClass.primaryColor.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('📖', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    'Keep Reading!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: ColorClass.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder(
                    duration: const Duration(seconds: 2),
                    tween: Tween(begin: 0.0, end: 2.0 * 3.14159),
                    builder: (context, double value, child) {
                      return Transform.rotate(
                        angle: value,
                        child: const Icon(
                          Icons.auto_stories,
                          size: 40,
                          color: ColorClass.primaryColor,
                        ),
                      );
                    },
                  ),
                  TweenAnimationBuilder(
                    duration: const Duration(seconds: 1),
                    tween: Tween(begin: 0.8, end: 1.2),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ColorClass.primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const DefaultTextStyle(
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              child: LoadingText(),
            ),
            const SizedBox(height: 16),
            Container(
              width: 200,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: ColorClass.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorClass.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorClass.primaryColor.withOpacity(0.3),
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: ColorClass.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildBookmarkButton() {
    return Consumer<BookmarkProvider>(
      builder: (context, bookmarkProvider, child) {
        final bookmarkId = 'bright_box_${widget.story.id}';
        final isBookmarked = bookmarkProvider.isBookmarked(bookmarkId);
        return Container(
          decoration: BoxDecoration(
            color: ColorClass.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorClass.primaryColor.withOpacity(0.3),
            ),
          ),
          child: IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isBookmarked ? LucideIcons.bookMarked : LucideIcons.bookmark,
                key: ValueKey(isBookmarked),
                color:
                    isBookmarked ? ColorClass.primaryColor : ColorClass.white,
                size: 20,
              ),
            ),
            onPressed: () => _handleBookmark(bookmarkProvider, isBookmarked),
          ),
        );
      },
    );
  }

  Widget _buildReadingCompleteBadge() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorClass.primaryColor,
                ColorClass.primaryColor.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ColorClass.primaryColor.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => navigateBack(context),
                child: Text(
                  'Great job! You finished the story!',
                  style: TextStyleClass.poppinsSemiBold(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBookmark(BookmarkProvider provider, bool isBookmarked) async {
    final bookmarkId = 'bright_box_${widget.story.id}';
    
    if (isBookmarked) {
      await provider.removeBookmark(context, bookmarkId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Removed from bookmarks',
              style: TextStyle(color: Colors.white),
            ),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // For Bright Box stories, we'll use a placeholder thumbnail since it's not provided
      final success = await provider.addBookmark(
        context: context,
        id: bookmarkId,
        thumbnail: '', // No thumbnail available for Bright Box stories
        title: _currentTitle,
        fileUrl: _localPdfPath ?? '',
        tag: 'Bright Box',
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Added to bookmarks',
              style: TextStyle(color: Colors.white),
            ),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'View',
              backgroundColor: Colors.white,
              onPressed: () {
                navigatePR(context: context, screen: const BookmarkScreen());
              },
            ),
            backgroundColor: Colors.greenAccent.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _shareStory() async {
    const String appStoreLink =
        'https://apps.apple.com/in/app/zai-toon-kids/id6737912105';
    const String playStoreLink =
        'https://play.google.com/store/apps/details?id=co.d4dx.zaitoon';

    String textToShare = '''📚 Check out this amazing story on Zai Toon Kids!

"$_currentTitle"

🌟 Download Zai Toon Kids to start reading:
📱 iOS: $appStoreLink

📱 Android: $playStoreLink

Join thousands of families making reading time special! 🎉
#ZaiToonKids #BrightBox #ChildrenStories #InteractiveReading''';

    try {
      await Share.share(
        textToShare,
        subject: '📚 Check out this story on Zai Toon Kids!',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share story'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class LoadingText extends StatefulWidget {
  const LoadingText({super.key});

  @override
  State<LoadingText> createState() => _LoadingTextState();
}

class _LoadingTextState extends State<LoadingText> {
  final List<String> _loadingTexts = [
    'Preparing your story...',
    'Getting everything ready...',
    'Almost there...',
    'Loading magical pages...',
  ];
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _loadingTexts.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Text(
        _loadingTexts[_currentIndex],
        key: ValueKey(_currentIndex),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}