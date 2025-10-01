// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/bookmark_screen/provider/bookmark_provider.dart';
import 'package:zaitoon/screens/bright_box/screens/bright_box_home_screen.dart';
import 'package:zaitoon/screens/login_screen/login_screen.dart';
import 'package:zaitoon/screens/login_screen/provider/auth_provider.dart';
import 'package:zaitoon/screens/reading_screen/story_reader_page.dart';
import 'package:zaitoon/utils/cache_manager.dart';

class BookmarkScreen extends StatefulWidget {
  final String? initialCategory;

  const BookmarkScreen({super.key, this.initialCategory});

  // Static variable to remember the desired category when returning from Bright Box
  static String? _returnToCategory;

  // Static method to set the return category
  static void setReturnCategory(String category) {
    _returnToCategory = category;
  }

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final List<String> categories = ["Stories", "Episode", "Bright Box"];
  late String selectedCategory;

  @override
  void initState() {
    // Check if we should return to a specific category (from Bright Box)
    selectedCategory =
        BookmarkScreen._returnToCategory ?? widget.initialCategory ?? "Stories";
    // Clear the return category after using it
    BookmarkScreen._returnToCategory = null;

    Future.microtask(() {
      final bookmarkProvider =
          Provider.of<BookmarkProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isSignedIn) {
        bookmarkProvider.loadBookmarks();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.white,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (!authProvider.isSignedIn) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border_rounded,
                      size: 64,
                      color: ColorClass.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Login Required',
                      style: TextStyleClass.fredoka(
                        fontSize: 18,
                        color: ColorClass.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please login to view your bookmarks',
                      style: TextStyleClass.fredoka(
                        fontSize: 14,
                        color: ColorClass.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ColorClass.grad1,
                            ColorClass.grad2,
                            ColorClass.grad3,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          navigatePR(
                              context: context, screen: const AuthScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyleClass.fredoka(
                            fontSize: 16,
                            color: ColorClass.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          'My Bookmarks',
                          style: TextStyleClass.fredoka(
                            fontSize: 28,
                            color: ColorClass.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your saved stories, ready to explore anytime.',
                        style: TextStyleClass.fredoka(
                          fontSize: 16,
                          color: ColorClass.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Category Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: categories.map((category) {
                          final isSelected = selectedCategory == category;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = category;
                              });
                              // Navigate to Bright Box screen when selected
                              if (category == "Bright Box") {
                                navigatePR(
                                  context: context,
                                  screen: const BrightBoxHomeScreen(),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
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
                                color: isSelected ? null : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: ColorClass.grey.withOpacity(0.3),
                                        width: 1,
                                      ),
                              ),
                              child: Text(
                                category,
                                style: TextStyleClass.fredoka(
                                  fontSize: 14,
                                  color: isSelected
                                      ? ColorClass.white
                                      : ColorClass.grey,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: Consumer<BookmarkProvider>(
                    builder: (context, provider, child) {
                      if (provider.bookmarks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bookmark_border_rounded,
                                size: 64,
                                color: ColorClass.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No bookmarks yet',
                                style: TextStyleClass.fredoka(
                                  fontSize: 18,
                                  color: ColorClass.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your bookmarked stories will appear here',
                                style: TextStyleClass.fredoka(
                                  fontSize: 14,
                                  color: ColorClass.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: provider.bookmarks.length,
                          itemBuilder: (context, index) {
                            final story = provider.bookmarks[index];
                            return GestureDetector(
                              onTap: () {
                                navigatePR(
                                  context: context,
                                  screen: StoryReadingScreen(
                                    id: story.id.toString(),
                                    title: story.title,
                                    thumbnail:
                                        '${ApiUrls.assetBaseUrl}${story.thumbnail}',
                                    tag: story.tag,
                                    pdfUrl: story.fileUrl,
                                  ),
                                );
                              },
                              child: BookmarkCard(
                                id: story.id.toString(),
                                title: story.title,
                                category: story.tag,
                                imageUrl:
                                    '${ApiUrls.assetBaseUrl}${story.thumbnail}',
                                fileUrl: story.fileUrl,
                                onReadStory: () {
                                  navigatePR(
                                    context: context,
                                    screen: StoryReadingScreen(
                                      id: story.id.toString(),
                                      title: story.title,
                                      thumbnail:
                                          '${ApiUrls.assetBaseUrl}${story.thumbnail}',
                                      tag: story.tag,
                                      pdfUrl: story.fileUrl,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
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

class BookmarkCard extends StatelessWidget {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String fileUrl;
  final VoidCallback onReadStory;

  const BookmarkCard({
    super.key,
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.fileUrl,
    required this.onReadStory,
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
            flex: 3,
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
                      placeholder: (context, url) => Container(
                        color: ColorClass.grey400.withOpacity(0.2),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: ColorClass.grey,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: ColorClass.grey400.withOpacity(0.2),
                        child: Icon(
                          Icons.error_outline,
                          color: ColorClass.grey,
                        ),
                      ),
                      cacheManager: CustomCacheManager.instance,
                    ),
                  ),

                  // Category Tag (Top Left)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ColorClass.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: TextStyleClass.fredoka(
                          color: ColorClass.black,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  // Remove Bookmark Button (Top Right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<BookmarkProvider>(
                      builder: (context, provider, child) {
                        return GestureDetector(
                          onTap: () {
                            provider.removeBookmark(context, id);
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bookmark_remove,
                              color: ColorClass.white,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Story Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyleClass.fredoka(
                      fontSize: 16,
                      color: ColorClass.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Read Story Button
                  Container(
                    width: double.infinity,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorClass.grad1,
                          ColorClass.grad2,
                          ColorClass.grad3,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: onReadStory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Read Story',
                        style: TextStyleClass.fredoka(
                          fontSize: 14,
                          color: ColorClass.white,
                        ),
                      ),
                    ),
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
