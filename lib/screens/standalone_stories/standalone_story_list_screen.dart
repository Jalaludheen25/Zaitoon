// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/bookmark_screen/bookmark_screen.dart';
import 'package:zaitoon/screens/bookmark_screen/provider/bookmark_provider.dart';
import 'package:zaitoon/screens/home_screen/home_screen.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/reading_screen/story_reader_page.dart';
import 'package:zaitoon/screens/standalone_stories/provider/story_provider.dart';
import 'package:zaitoon/utils/cache_manager.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final List<String> categories = [
    "Fun",
    "Kids",
    "Bed time stories",
    "Children"
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<StoriesProvider>().fetchStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.white,
      body: SafeArea(
        child: Consumer2<StoriesProvider, HomeProvider>(
          builder: (context, provider, homeProvider, child) {
            if (provider.isLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (provider.error.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.error,
                      style: TextStyle(color: ColorClass.black),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchStories(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final stories = provider.filteredStories.reversed.toList();

            return Column(
              children: [
                // Custom Header with back button, title and search in same row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Back Button with gradient
                      GestureDetector(
                        onTap: () {
                          navigatePR(
                            context: context,
                            screen: const HomeScreen(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                ColorClass.grad1,
                                ColorClass.grad2,
                                ColorClass.grad3
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: ColorClass.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 4), // Closer gap

                      // Stories Title with gradient
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            ColorClass.grad1,
                            ColorClass.grad2,
                            ColorClass.grad3,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'Stories',
                          style: TextStyleClass.fredoka(
                            fontSize: 30,
                            color: ColorClass.white,
                          ),
                        ),
                      ),

                      const Spacer(), // Push search button to the right

                      // Search Button with circular background
                      GestureDetector(
                        onTap: () {
                          // Add search functionality here
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ColorClass.containerBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.search,
                            color: ColorClass.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Category Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: categories.map((category) {
                      final isSelected = provider.selectedCategory == category;
                      return GestureDetector(
                        onTap: () {
                          provider.setSelectedCategory(category);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      ColorClass.grad1,
                                      ColorClass.grad2,
                                      ColorClass.grad3,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected ? null : ColorClass.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: TextStyleClass.fredoka(
                              fontSize: 13,
                              color: isSelected
                                  ? ColorClass.white
                                  : ColorClass.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Stories Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: stories.length,
                      itemBuilder: (context, index) {
                        final story = stories[index];
                        return GestureDetector(
                          onTap: () {
                            navigatePR(
                              context: context,
                              screen: StoryReadingScreen(
                                id: (story.id ?? 0).toString(),
                                title: homeProvider.selectedLanguage == 'en'
                                    ? (story.storyTitleEn ?? 'Untitled')
                                    : (story.storyTitleMl ?? 'Untitled'),
                                thumbnail:
                                    '${ApiUrls.assetBaseUrl}${story.coverImage ?? ''}',
                                tag: story.tag ?? '',
                                pdfUrl: homeProvider.selectedLanguage == 'en'
                                    ? ApiUrls.assetBaseUrl +
                                        (story.storyFileEn ?? '')
                                    : ApiUrls.assetBaseUrl +
                                        (story.storyFileMl ?? ''),
                              ),
                            );
                          },
                          child: StoryCard(
                            id: (story.id ?? 0).toString(),
                            title: homeProvider.selectedLanguage == 'en'
                                ? (story.storyTitleEn ?? 'Untitled')
                                : (story.storyTitleMl ?? 'Untitled'),
                            category: story.tag ?? 'Story',
                            fileUrl: homeProvider.selectedLanguage == 'en'
                                ? ApiUrls.assetBaseUrl +
                                    (story.storyFileEn ?? '')
                                : ApiUrls.assetBaseUrl +
                                    (story.storyFileMl ?? ''),
                            duration: '${story.readTime ?? '0'} min',
                            imageUrl:
                                '${ApiUrls.assetBaseUrl}${story.coverImage ?? ''}',
                            description: story.description ?? '',
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class StoryCard extends StatelessWidget {
  final String id;
  final String title;
  final String category;
  final String duration;
  final String imageUrl;
  final String description;
  final String fileUrl;

  const StoryCard({
    super.key,
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.imageUrl,
    required this.description,
    required this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: ColorClass.white,
        boxShadow: [
          BoxShadow(
            color: ColorClass.grey400.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Story Image
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  // CachedNetworkImage
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => const Center(
                        child: CupertinoActivityIndicator(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: ColorClass.grey400,
                        child: Icon(
                          Icons.error_outline,
                          color: ColorClass.grey,
                        ),
                      ),
                      cacheManager: CustomCacheManager.instance,
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ColorClass.transparent,
                          ColorClass.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),

                  // Bookmark Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<StoriesProvider>(
                      builder: (context, provider, child) =>
                          provider.isBookmarkLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: ColorClass.white,
                                  ),
                                )
                              : BookmarkButton(
                                  id: id,
                                  thumbnail: imageUrl,
                                  title: title,
                                  fileUrl: fileUrl,
                                  tag: category,
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Story Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Consumer<HomeProvider>(
              builder: (context, data, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: data.selectedLanguage == 'en'
                        ? TextStyleClass.poppinsSemiBold(
                            fontSize: 16,
                            color: ColorClass.black,
                          )
                        : TextStyleClass.manjariSemiBold(
                            fontSize: 16,
                            color: ColorClass.black,
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        color: ColorClass.grey,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: TextStyleClass.poppinsRegular(
                          fontSize: 12,
                          color: ColorClass.grey,
                        ),
                      ),
                    ],
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
                      style: TextStyle(color: ColorClass.white),
                    ),
                    duration: const Duration(seconds: 1),
                    backgroundColor: ColorClass.secondaryColor.withOpacity(0.8),
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
                      style: TextStyle(color: ColorClass.white),
                    ),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'View',
                      backgroundColor: ColorClass.white,
                      onPressed: () {
                        navigatePR(
                            context: context, screen: const BookmarkScreen());
                      },
                    ),
                    backgroundColor: ColorClass.primaryColor.withOpacity(0.8),
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
                    color: ColorClass.white.withOpacity(0.1),
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
                      color: isBookmarked
                          ? ColorClass.primaryColor
                          : ColorClass.white,
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
