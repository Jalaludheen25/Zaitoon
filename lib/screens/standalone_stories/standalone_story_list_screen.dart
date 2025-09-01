// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/episode_screen.dart/episode_screen.dart';
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
      backgroundColor: Colors.black,
      body: Consumer2<StoriesProvider, HomeProvider>(
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
                    style: const TextStyle(color: Colors.white),
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

          final stories =
              (provider.singleStoryModel?.data ?? []).reversed.toList();

          return CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.deepPurpleAccent.withOpacity(0.4),
                          Colors.black,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stories 📚',
                            style: TextStyleClass.poppinsBold(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Discover amazing stories',
                            style: TextStyleClass.poppinsRegular(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Stories Grid
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                              ? ApiUrls.assetBaseUrl + (story.storyFileEn ?? '')
                              : ApiUrls.assetBaseUrl +
                                  (story.storyFileMl ?? ''),
                          duration: '${story.readTime ?? '0'} min',
                          imageUrl:
                              '${ApiUrls.assetBaseUrl}${story.coverImage ?? ''}',
                          description: story.description ?? '',
                        ),
                      );
                    },
                    childCount: stories.length,
                  ),
                ),
              ),
            ],
          );
        },
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
        color: Colors.grey[900],
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
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.error_outline,
                          color: Colors.white,
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
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Category Tag
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
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
                                    color: Colors.white,
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
                            color: Colors.white,
                          )
                        : TextStyleClass.manjariSemiBold(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.clock,
                        color: Colors.grey,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: TextStyleClass.poppinsRegular(
                          fontSize: 12,
                          color: Colors.white,
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
