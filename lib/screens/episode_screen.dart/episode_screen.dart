// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/bookmark_screen/bookmark_screen.dart';
import 'package:zaitoon/screens/bookmark_screen/provider/bookmark_provider.dart';
import 'package:zaitoon/screens/bottom_navigation/bottom_navigation.dart';
import 'package:zaitoon/screens/home_screen/models/episode_model.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/reading_screen/story_reader_page.dart';
import 'package:zaitoon/utils/cache_manager.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon/providers/theme_provider.dart';

class EpisodeScreen extends StatefulWidget {
  const EpisodeScreen({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.tag,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String tag;
  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  @override
  void initState() {
    Future.microtask(() {
      HomeProvider homeProvider =
          Provider.of<HomeProvider>(context, listen: false);
      homeProvider.fetchEpisodes(widget.id);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Hide system UI at bottom, keep top (status bar)
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
          overlays: [SystemUiOverlay.top], // Only show top overlay (status bar)
        );
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
            statusBarBrightness:
                themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness:
                themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
          ),
        );

        return Scaffold(
          backgroundColor:
              themeProvider.isDarkMode ? Colors.black : Colors.white,
          body: SafeArea(
            child: Consumer<HomeProvider>(
              builder: (context, snapshot, _) => snapshot.episodeModel == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoActivityIndicator(
                            color: themeProvider.isDarkMode
                                ? ColorClass.violet30
                                : Colors.black,
                            radius: 16,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading episodes...',
                            style: TextStyleClass.poppinsRegular(
                              fontSize: 14,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        color: themeProvider.isDarkMode
                            ? ColorClass.black
                            : Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Section with Stack for overlay elements
                            Container(
                              margin: const EdgeInsets.all(18),
                              child: Stack(
                                children: [
                                  // Header Image
                                  Container(
                                    width: double.infinity,
                                    height: 244,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          widget.imageUrl,
                                          cacheManager:
                                              CustomCacheManager.instance,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        color: themeProvider.isDarkMode
                                            ? Colors.black.withOpacity(0.5)
                                            : Color(0x3F000000),
                                      ),
                                    ),
                                  ),

                                  // Back Button
                                  Positioned(
                                    left: 10,
                                    top: 10,
                                    child: GestureDetector(
                                      onTap: () =>
                                          Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const BottomNavigationScreen(),
                                        ),
                                      ),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0x3FFFFFFF),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_back_ios_new,
                                          color: Colors.black,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Tag Badge
                                  Positioned(
                                    right: 10,
                                    top: 15,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0x3EFFFFFF),
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      child: Text(
                                        widget.tag,
                                        style: TextStyleClass.fredoka(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Series Title
                                  Positioned(
                                    left: 17,
                                    bottom: 30,
                                    right: 27,
                                    child: Text(
                                      widget.title,
                                      style: _getLanguageTextStyle(
                                          snapshot.selectedLanguage),
                                    ),
                                  ),

                                  // Episode Count
                                  Positioned(
                                    left: 17,
                                    bottom: 8,
                                    child: Text(
                                      '${snapshot.episodeModel!.data!.length} Episodes',
                                      style: TextStyleClass.openSansSemiBold(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Description Section
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 17),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Description:',
                                    style: TextStyleClass.fredoka(
                                      color: themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    // snapshot.episodeModel!.data!.isNotEmpty &&
                                    //         snapshot.episodeModel!.data![0]
                                    //                 .adBanner !=
                                    //             null
                                    //     ? snapshot.episodeModel!.data![0].adBanner!
                                    //     :
                                    'Discover amazing stories filled with adventure, friendship, and fun! Each episode brings new characters and exciting journeys that will spark your imagination.',
                                    style: TextStyleClass.openSans(
                                      color: themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Episodes Section
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 17),
                              child: Text(
                                'Episodes:',
                                style: TextStyleClass.fredoka(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Episodes List
                            ...List.generate(
                              snapshot.episodeModel!.data!.length,
                              (index) {
                                final episode =
                                    snapshot.episodeModel!.data![index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 8),
                                  child: _buildEpisodeCard(
                                    episode: episode,
                                    index: index + 1,
                                    selectedLanguage: snapshot.selectedLanguage,
                                    themeProvider: themeProvider,
                                    onTap: () => navigatePR(
                                      context: context,
                                      screen: StoryReadingScreen(
                                        id: episode.id.toString(),
                                        title:
                                            "${widget.title}: ${_getEpisodeTitle(episode, snapshot.selectedLanguage)}",
                                        thumbnail:
                                            '${ApiUrls.assetBaseUrl}${episode.coverImage}',
                                        tag: widget.tag,
                                        pdfUrl: ApiUrls.assetBaseUrl +
                                            _getEpisodeFile(episode,
                                                snapshot.selectedLanguage),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Add bottom padding to account for floating button
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          // Floating Action Button for "Read first episode"
          floatingActionButton: Consumer<HomeProvider>(
            builder: (context, snapshot, _) {
              if (snapshot.episodeModel == null ||
                  snapshot.episodeModel!.data!.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFAC28DC),
                      Color(0xFF7E1EB7),
                      Color(0xFF501392)
                    ],
                    stops: [0, 0.50, 1],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFAC28DC).withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    final firstEpisode = snapshot.episodeModel!.data![0];
                    navigatePR(
                      context: context,
                      screen: StoryReadingScreen(
                        id: firstEpisode.id.toString(),
                        title:
                            "${widget.title}: ${_getEpisodeTitle(firstEpisode, snapshot.selectedLanguage)}",
                        thumbnail:
                            '${ApiUrls.assetBaseUrl}${firstEpisode.coverImage}',
                        tag: widget.tag,
                        pdfUrl: ApiUrls.assetBaseUrl +
                            _getEpisodeFile(
                                firstEpisode, snapshot.selectedLanguage),
                      ),
                    );
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  label: Text(
                    'Read first episode',
                    style: TextStyleClass.fredoka(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  // Helper methods for multi-language support
  String _getEpisodeTitle(EpisodeData episode, String language) {
    switch (language) {
      case 'ml':
        return episode.mlTitle ?? episode.storyTile ?? '';
      case 'hi':
        return episode.hinTitle ?? episode.storyTile ?? '';
      case 'ur':
        return episode.urTitle ?? episode.storyTile ?? '';
      default: // 'en' or any other language
        return episode.storyTile ?? '';
    }
  }

  String _getEpisodeFile(EpisodeData episode, String language) {
    switch (language) {
      case 'ml':
        return episode.mlStoryFile ?? episode.storyFile ?? '';
      case 'hi':
        return episode.hinStoryFile ?? episode.storyFile ?? '';
      case 'ur':
        return episode.urStoryFile ?? episode.storyFile ?? '';
      default: // 'en' or any other language
        return episode.storyFile ?? '';
    }
  }

  Widget _buildEpisodeCard({
    required EpisodeData episode,
    required int index,
    required String selectedLanguage,
    required ThemeProvider themeProvider,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 106,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? ColorClass.bg : Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Main content
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // Episode Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: ApiUrls.assetBaseUrl + episode.coverImage!,
                      width: 86,
                      height: 86,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: themeProvider.isDarkMode
                            ? ColorClass.black.withOpacity(0.3)
                            : Colors.grey[300],
                        child: const Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: themeProvider.isDarkMode
                            ? ColorClass.black.withOpacity(0.3)
                            : Colors.grey[300],
                        child: Icon(
                          Icons.error_outline,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Episode Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getEpisodeTitle(episode, selectedLanguage),
                          style: TextStyleClass.fredoka(
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Episode: $index',
                          style: TextStyleClass.openSans(
                            color: themeProvider.isDarkMode
                                ? Colors.white.withOpacity(0.7)
                                : Color(0x7F000000),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bookmark Button
          Positioned(
            top: 10,
            right: 10,
            child: BookmarkButton(
              id: episode.id.toString(),
              thumbnail: ApiUrls.assetBaseUrl + episode.coverImage!,
              title:
                  "${widget.title}: ${_getEpisodeTitle(episode, selectedLanguage)}",
              fileUrl: _getEpisodeFile(episode, selectedLanguage),
              tag: widget.tag,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _getLanguageTextStyle(String language) {
    switch (language) {
      case 'ml':
        return TextStyleClass.fredoka(
          fontSize: 24,
          color: Colors.white,
        );
      case 'hi':
        return TextStyleClass.fredoka(
          fontSize: 24,
          color: Colors.white,
        );
      case 'ur':
        return TextStyleClass.fredoka(
          fontSize: 24,
          color: Colors.white,
        );
      default: // 'en' or any other language
        return TextStyleClass.fredoka(
          fontSize: 24,
          color: Colors.white,
        );
    }
  }
}

class BookmarkButton extends StatefulWidget {
  final String id;
  final String thumbnail;
  final String title;
  final String fileUrl;
  final String tag;

  const BookmarkButton({
    super.key,
    required this.id,
    required this.thumbnail,
    required this.title,
    required this.fileUrl,
    required this.tag,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.2),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playAnimation() async {
    await _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkProvider>(
      builder: (context, bookmarkProvider, child) {
        final isBookmarked = bookmarkProvider.isBookmarked(widget.id);

        return GestureDetector(
          onTap: () async {
            _playAnimation();
            if (isBookmarked) {
              await bookmarkProvider.removeBookmark(context, widget.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Removed from bookmarks',
                      style: TextStyleClass.openSans(
                          color: Colors.white, fontSize: 12),
                    ),
                    duration: const Duration(seconds: 1),
                    backgroundColor: Colors.red.withOpacity(0.8),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } else {
              final success = await bookmarkProvider.addBookmark(
                context: context,
                id: widget.id,
                thumbnail: widget.thumbnail,
                title: widget.title,
                fileUrl: widget.fileUrl,
                tag: widget.tag,
              );

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added to bookmarks',
                      style: TextStyleClass.openSans(
                          color: Colors.white, fontSize: 12),
                    ),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'View',
                      backgroundColor: Colors.black,
                      onPressed: () {
                        navigatePR(
                            context: context, screen: const BookmarkScreen());
                      },
                    ),
                    backgroundColor: Colors.greenAccent.withOpacity(0.8),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      key: ValueKey<bool>(isBookmarked),
                      color:
                          isBookmarked ? ColorClass.coquelicot : Colors.black,
                      size: 18,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
