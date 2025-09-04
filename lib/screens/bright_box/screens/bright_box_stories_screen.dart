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
      backgroundColor: ColorClass.black,
      body: SafeArea(
        child: Consumer2<BrightBoxProvider, HomeProvider>(
          builder: (context, brightBoxProvider, homeProvider, child) {
            final subcategoryTitle = _getSubcategoryTitle(widget.subcategory, homeProvider.selectedLanguage);

            return CustomScrollView(
              slivers: [
                _buildAppBar(subcategoryTitle),
                if (brightBoxProvider.isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ColorClass.primaryColor,
                      ),
                    ),
                  )
                else if (brightBoxProvider.error != null)
                  _buildErrorState(brightBoxProvider.error!, brightBoxProvider)
                else
                  _buildStoriesList(brightBoxProvider, homeProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(String subcategoryTitle) {
    return SliverAppBar(
      leading: IconButton(
        icon: const Icon(
          LucideIcons.arrowLeft,
          color: ColorClass.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        subcategoryTitle,
        style: TextStyleClass.poppinsSemiBold(
          fontSize: 20,
          color: ColorClass.white,
        ),
      ),
      backgroundColor: ColorClass.black,
      floating: true,
      pinned: false,
      elevation: 0,
    );
  }

  Widget _buildErrorState(String error, BrightBoxProvider provider) {
    return SliverFillRemaining(
      child: Center(
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
                style: TextStyleClass.poppinsSemiBold(
                  fontSize: 18,
                  color: ColorClass.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: TextStyleClass.poppinsRegular(
                  fontSize: 14,
                  color: ColorClass.white.withOpacity(0.7),
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
      ),
    );
  }

  Widget _buildStoriesList(BrightBoxProvider brightBoxProvider, HomeProvider homeProvider) {
    if (brightBoxProvider.stories.isEmpty) {
      return _buildEmptyState();
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final story = brightBoxProvider.stories[index];
            return _buildStoryCard(story, homeProvider, index);
          },
          childCount: brightBoxProvider.stories.length,
        ),
      ),
    );
  }

  Widget _buildStoryCard(BrightBoxStory story, HomeProvider homeProvider, int index) {
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
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorClass.primaryColor.withOpacity(0.1),
                ColorClass.primaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ColorClass.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: ColorClass.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: story.coverImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: ApiUrls.assetBaseUrl + story.coverImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyleClass.poppinsBold(
                                fontSize: 18,
                                color: ColorClass.primaryColor,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyleClass.poppinsBold(
                                fontSize: 18,
                                color: ColorClass.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyleClass.poppinsBold(
                            fontSize: 18,
                            color: ColorClass.primaryColor,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyleClass.poppinsSemiBold(
                        fontSize: 16,
                        color: ColorClass.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          color: ColorClass.white.withOpacity(0.6),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(story.dateCreated),
                          style: TextStyleClass.poppinsRegular(
                            fontSize: 12,
                            color: ColorClass.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: ColorClass.white.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
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
              style: TextStyleClass.poppinsSemiBold(
                fontSize: 24,
                color: ColorClass.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Exciting new content is on the way!\nStay tuned for amazing stories.',
              style: TextStyleClass.poppinsRegular(
                fontSize: 16,
                color: ColorClass.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  // Helper methods for multi-language support
  String _getSubcategoryTitle(subcategory, String language) {
    switch (language) {
      case 'ml':
        return subcategory.subcatTitleMl ?? subcategory.subcatTitleEn ?? '';
      case 'hi':
        return subcategory.subcatTitleHi ?? subcategory.subcatTitleEn ?? '';
      case 'ur':
        return subcategory.subcatTitleUr ?? subcategory.subcatTitleEn ?? '';
      default: // 'en' or any other language
        return subcategory.subcatTitleEn ?? '';
    }
  }

  String _getStoryTitle(BrightBoxStory story, String language) {
    switch (language) {
      case 'ml':
        return story.storyTitleMl ?? story.storyTitleEn ?? '';
      case 'hi':
        return story.storyTitleHi ?? story.storyTitleEn ?? '';
      case 'ur':
        return story.storyTitleUr ?? story.storyTitleEn ?? '';
      default: // 'en' or any other language
        return story.storyTitleEn ?? '';
    }
  }
}