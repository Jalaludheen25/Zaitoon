import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/screens/bright_box/provider/bright_box_provider.dart';
import 'package:zaitoon/screens/bright_box/models/bright_box_models.dart';
import 'package:zaitoon/screens/bright_box/screens/bright_box_story_reader_screen.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/bookmark_screen/provider/bookmark_provider.dart';

class BrightBoxStoriesScreen extends StatefulWidget {
  final BrightBoxSubcategory subcategory;

  const BrightBoxStoriesScreen({
    super.key,
    required this.subcategory,
  });

  @override
  State<BrightBoxStoriesScreen> createState() => _BrightBoxStoriesScreenState();
}

class _BrightBoxStoriesScreenState extends State<BrightBoxStoriesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final provider = context.read<BrightBoxProvider>();
        provider.clearStories();
        provider.loadStories(widget.subcategory.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.white,
      body: Consumer2<BrightBoxProvider, HomeProvider>(
        builder: (context, brightBoxProvider, homeProvider, child) {
          final subcategoryTitle = _getSubcategoryTitle(
              widget.subcategory, homeProvider.selectedLanguage);

          if (brightBoxProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: ColorClass.primaryColor,
              ),
            );
          }

          if (brightBoxProvider.error != null) {
            return _buildErrorState(
                brightBoxProvider.error!, brightBoxProvider);
          }

          return Column(
            children: [
              // Hero Image Section
              _buildHeroSection(subcategoryTitle),

              // Content Section
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await brightBoxProvider.loadStories(widget.subcategory.id);
                  },
                  color: ColorClass.primaryColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description Section
                        _buildDescriptionSection(),
                        const SizedBox(height: 24),

                        // Episodes Section
                        _buildEpisodesSection(brightBoxProvider, homeProvider),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(String subcategoryTitle) {
    return Container(
      height: 350, // Increased height to account for status bar
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          // Background Image
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(24)),
            child: widget.subcategory.coverImage.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl:
                        ApiUrls.assetBaseUrl + widget.subcategory.coverImage,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(24)),
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.flag,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(24)),
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.flag,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.flag,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(24)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),

          // Back Button - positioned below status bar
          Positioned(
            top: MediaQuery.of(context).padding.top +
                16, // Account for status bar
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // Title and Episode Count
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subcategoryTitle,
                  style: TextStyleClass.fredoka(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Consumer<BrightBoxProvider>(
                  builder: (context, provider, child) {
                    final episodeCount = provider.stories.length;
                    return Text(
                      '$episodeCount Episodes',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description:',
          style: TextStyleClass.fredoka(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Consumer<HomeProvider>(
          builder: (context, homeProvider, child) {
            final description = _getSubcategoryDescription(
                widget.subcategory, homeProvider.selectedLanguage);
            return Text(
              description.isNotEmpty
                  ? description
                  : 'Discover amazing stories and learn about history through engaging episodes.',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEpisodesSection(
      BrightBoxProvider brightBoxProvider, HomeProvider homeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Episodes:',
          style: TextStyleClass.fredoka(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),

        if (brightBoxProvider.stories.isEmpty)
          _buildEmptyState()
        else
          ...brightBoxProvider.stories.asMap().entries.map((entry) {
            final index = entry.key;
            final story = entry.value;
            return _buildEpisodeCard(story, homeProvider, index);
          }),

        const SizedBox(height: 20),

        // Read First Episode Button
        if (brightBoxProvider.stories.isNotEmpty)
          Container(
            width: double.infinity,
            height: 50,
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
              borderRadius: BorderRadius.circular(25),
            ),
            child: ElevatedButton(
              onPressed: () {
                if (brightBoxProvider.stories.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BrightBoxStoryReaderScreen(
                        story: brightBoxProvider.stories.first,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Read first episode',
                style: TextStyleClass.fredoka(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEpisodeCard(
      BrightBoxStory story, HomeProvider homeProvider, int index) {
    final title = _getStoryTitle(story, homeProvider.selectedLanguage);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BrightBoxStoryReaderScreen(
                story: story,
              ),
            ),
          );
        },
        child: Row(
          children: [
            // Episode Thumbnail
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.withOpacity(0.7),
                    Colors.white.withOpacity(0.4),
                    Colors.green.withOpacity(0.7),
                  ],
                ),
              ),
              child: story.coverImage.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: ApiUrls.assetBaseUrl + story.coverImage,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: Icon(
                            LucideIcons.flag,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            LucideIcons.flag,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        LucideIcons.flag,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
            ),
            const SizedBox(width: 16),

            // Episode Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyleClass.fredoka(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Episode ${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Bookmark Button
            Consumer<BookmarkProvider>(
              builder: (context, bookmarkProvider, child) {
                final storyId = story.id.toString();
                final isBookmarked = bookmarkProvider.isBookmarked(storyId);

                return GestureDetector(
                  onTap: () async {
                    final storyTitle =
                        _getStoryTitle(story, homeProvider.selectedLanguage);
                    final success = await bookmarkProvider.toggleBookmark(
                      context: context,
                      id: storyId,
                      thumbnail: story.coverImage.isNotEmpty
                          ? ApiUrls.assetBaseUrl + story.coverImage
                          : '',
                      title: storyTitle,
                      fileUrl: '', // Bright Box stories don't have file URLs
                      tag: 'Bright Box',
                      contentType: 'bright_box_story',
                      brightBoxContent: jsonEncode(story.toJson()),
                    );

                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isBookmarked
                              ? 'Removed from bookmarks'
                              : 'Added to bookmarks'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isBookmarked
                          ? ColorClass.primaryColor.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isBookmarked
                          ? LucideIcons.bookMarked
                          : LucideIcons.bookmark,
                      color:
                          isBookmarked ? ColorClass.primaryColor : Colors.grey,
                      size: 18,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, BrightBoxProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyleClass.fredoka(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.loadStories(widget.subcategory.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorClass.primaryColor,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.clock,
            size: 64,
            color: ColorClass.primaryColor.withOpacity(0.6),
          ),
          const SizedBox(height: 24),
          Text(
            'Coming Soon',
            style: TextStyleClass.fredoka(
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Exciting new content is on the way!\nStay tuned for amazing stories.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods for multi-language support
  String _getSubcategoryTitle(subcategory, String language) {
    switch (language) {
      case 'ml':
        return subcategory.subcatTitleMl.isNotEmpty
            ? subcategory.subcatTitleMl
            : subcategory.subcatTitleEn;
      case 'hi':
        return subcategory.subcatTitleHi.isNotEmpty
            ? subcategory.subcatTitleHi
            : subcategory.subcatTitleEn;
      case 'ur':
        return subcategory.subcatTitleUr.isNotEmpty
            ? subcategory.subcatTitleUr
            : subcategory.subcatTitleEn;
      default: // 'en' or any other language
        return subcategory.subcatTitleEn;
    }
  }

  String _getStoryTitle(BrightBoxStory story, String language) {
    switch (language) {
      case 'ml':
        return story.storyTitleMl.isNotEmpty
            ? story.storyTitleMl
            : story.storyTitleEn;
      case 'hi':
        return story.storyTitleHi.isNotEmpty
            ? story.storyTitleHi
            : story.storyTitleEn;
      case 'ur':
        return story.storyTitleUr.isNotEmpty
            ? story.storyTitleUr
            : story.storyTitleEn;
      default: // 'en' or any other language
        return story.storyTitleEn;
    }
  }

  String _getSubcategoryDescription(subcategory, String language) {
    // Since description fields don't exist in the model, return a default message
    return 'Discover amazing stories and learn about history through engaging episodes.';
  }
}
