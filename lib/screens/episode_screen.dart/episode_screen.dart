// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/bookmark_screen/bookmark_screen.dart';
import 'package:zaitoon/screens/bookmark_screen/provider/bookmark_provider.dart';
import 'package:zaitoon/screens/bottom_navigation/bottom_navigation.dart';
import 'package:zaitoon/screens/home_screen/models/episode_model.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/reading_screen/story_reader_page.dart';
import 'package:zaitoon/utils/cache_manager.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Consumer<HomeProvider>(
          builder: (context, snapshot, _) => snapshot.episodeModel == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 16,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading episodes...',
                        style: TextStyleClass.poppinsRegular(
                          fontSize: 14,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // Custom App Bar (unchanged)
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      expandedHeight: 300,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            snapshot.episodeModel!.data!.isNotEmpty
                                ? CachedNetworkImage(
                                    cacheManager: CustomCacheManager.instance,
                                    imageUrl: widget.imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Container(color: ColorClass.grey),
                                    errorWidget: (context, url, error) =>
                                        Container(color: ColorClass.grey),
                                  )
                                : Container(color: Colors.grey[900]),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                    Colors.black,
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: snapshot.selectedLanguage == 'en'
                                        ? TextStyleClass.poppinsSemiBold(
                                            fontSize: 24,
                                            color: Colors.white,
                                          )
                                        : TextStyleClass.manjariSemiBold(
                                            fontSize: 24,
                                            color: Colors.white,
                                          ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${snapshot.episodeModel!.data!.length} episodes • ${snapshot.episodeModel!.data!.fold(0, (sum, item) => sum + (int.tryParse(item.readMinutes ?? "0") ?? 0))} minutes read',
                                    style: TextStyleClass.poppinsRegular(
                                      fontSize: 14,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              Colors.black.withOpacity(0.2)),
                        ),
                        color: Colors.white,
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                const BottomNavigationScreen(),
                          ),
                        ),
                      ),
                    ),

                    // Enhanced Episodes List
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // Reverse the index to show latest episodes first
                            final reversedIndex =
                                snapshot.episodeModel!.data!.length - 1 - index;
                            final episode =
                                snapshot.episodeModel!.data![reversedIndex];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _EpisodeTile(
                                seriesTitle: widget.title,
                                tag: widget.tag,
                                episode: episode,
                                index: reversedIndex,
                                selectedLanguage: snapshot.selectedLanguage,
                                onTap: () => navigatePR(
                                  context: context,
                                  screen: StoryReadingScreen(
                                    id: episode.id.toString(),
                                    title: snapshot.selectedLanguage == 'en'
                                        ? "${widget.title}: ${episode.storyTile!}"
                                        : "${widget.title}: ${episode.mlTitle!}",
                                    thumbnail:
                                        '${ApiUrls.assetBaseUrl}${episode.coverImage}',
                                    tag: widget.tag,
                                    pdfUrl: snapshot.selectedLanguage == 'en'
                                        ? ApiUrls.assetBaseUrl +
                                            episode.storyFile!
                                        : ApiUrls.assetBaseUrl +
                                            episode.mlStoryFile!,
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: snapshot.episodeModel!.data!.length,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  final String seriesTitle;
  final EpisodeData episode;
  final int index;
  final String selectedLanguage;
  final VoidCallback onTap;
  final String tag;

  const _EpisodeTile({
    required this.episode,
    required this.index,
    required this.selectedLanguage,
    required this.onTap,
    required this.seriesTitle,
    required this.tag,
  });

  Future<void> _shareEpisode(BuildContext context) async {
    const String appStoreLink =
        'https://apps.apple.com/in/app/zai-toon-kids/id6737912105';
    const String playStoreLink =
        'https://play.google.com/store/apps/details?id=co.d4dx.zaitoon';

    String textToShare = '''📚 Check out this amazing story on Zai Toon Kids!

"$seriesTitle"
Episode: ${selectedLanguage == 'en' ? episode.storyTile! : episode.mlTitle!}

🌟 Download Zai Toon Kids to start reading:
📱 iOS: $appStoreLink
📱 Android: $playStoreLink

Join thousands of families making reading time special! 🎉
#ZaiToonKids #ChildrenStories #InteractiveReading''';

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
  Widget build(BuildContext context) {
    return Hero(
      tag: 'episode_${episode.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[900]!,
                  Colors.grey[850]!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Episode Number

                  // Episode Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: ApiUrls.assetBaseUrl + episode.coverImage!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.error_outline,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Episode Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedLanguage == 'en'
                              ? episode.storyTile!
                              : episode.mlTitle!,
                          style: selectedLanguage == 'en'
                              ? TextStyleClass.poppinsSemiBold(
                                  fontSize: 16,
                                  color: Colors.white,
                                )
                              : TextStyleClass.manjariSemiBold(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.white54,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${episode.readMinutes} min',
                              style: TextStyleClass.poppinsRegular(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.white54,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              episode.uploadDate ?? 'N/A',
                              style: TextStyleClass.poppinsRegular(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Play Button
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chrome_reader_mode_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.share_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => _shareEpisode(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  BookmarkButton(
                    id: episode.id.toString(),
                    thumbnail: ApiUrls.assetBaseUrl + episode.coverImage!,
                    title: selectedLanguage == 'en'
                        ? "$seriesTitle: ${episode.storyTile!}"
                        : "$seriesTitle: ${episode.mlTitle!}",
                    fileUrl: selectedLanguage == 'en'
                        ? episode.storyFile ?? ''
                        : episode.mlStoryFile!,
                    tag: tag,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
                    content: const Text(
                      'Added to bookmarks',
                      style: TextStyle(color: Colors.white),
                    ),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'View',
                      backgroundColor: Colors.white,
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
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
                      isBookmarked
                          ? LucideIcons.bookMarked
                          : LucideIcons.bookmark,
                      key: ValueKey<bool>(isBookmarked),
                      color: isBookmarked ? Colors.greenAccent : Colors.white,
                      size: 24,
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
