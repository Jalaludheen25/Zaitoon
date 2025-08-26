import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/home_screen/models/episode_model.dart';
import 'package:zaitoon/screens/home_screen/models/story_model.dart';
import 'package:zaitoon/screens/standalone_stories/models/single_story_model.dart';

class HighlightedCards extends StatelessWidget {
  final List<EpisodeData> episodes;
  final String selectedLanguage;
  final Function(EpisodeData) onEpisodeTap;
  final Function(Datum) onStoryTap;
  final StoryModel? storyModel;
  final SingleStoryModel? singleStoryModel;

  const HighlightedCards({
    super.key,
    required this.episodes,
    required this.selectedLanguage,
    required this.onEpisodeTap,
    required this.onStoryTap,
    required this.storyModel,
    required this.singleStoryModel,
  });

  String getStoryName(int? storyId) {
    if (storyModel?.data == null || storyId == null) return '';

    final story = storyModel!.data!.firstWhere(
      (story) => story.id == storyId,
      orElse: () => StoryData(),
    );

    switch (selectedLanguage) {
      case 'ml':
        return story.mlTitle ?? story.name ?? '';
      case 'hi':
        return story.hinTitle ?? story.name ?? '';
      case 'ur':
        return story.urTitle ?? story.name ?? '';
      default: // 'en' or any other language
        return story.name ?? '';
    }
  }

  List<dynamic> getCombinedHighlightedContent() {
    List<dynamic> combined = [];

    // Add episodes (sorted by priority if available)
    if (episodes.isNotEmpty) {
      // Sort episodes by priority (lower number = higher priority)
      final sortedEpisodes = List<EpisodeData>.from(episodes);
      sortedEpisodes.sort((a, b) {
        // Get priority from the story model based on episode's story ID
        final storyA = storyModel?.data?.firstWhere(
          (story) => story.id == a.story,
          orElse: () => StoryData(),
        );
        final storyB = storyModel?.data?.firstWhere(
          (story) => story.id == b.story,
          orElse: () => StoryData(),
        );

        final priorityA = int.tryParse(storyA?.priority ?? '999') ?? 999;
        final priorityB = int.tryParse(storyB?.priority ?? '999') ?? 999;

        return priorityA.compareTo(priorityB);
      });
      combined.addAll(sortedEpisodes);
    }

    // Add single stories (highlighted ones only)
    if (singleStoryModel?.data != null) {
      final highlightedStories = singleStoryModel!.data
          .where((story) => story.isHighlighted == true)
          .toList();
      combined.addAll(highlightedStories);
    }

    // Don't shuffle if we want to maintain priority order
    // If you want to mix them while respecting priority, you could implement a more complex sorting

    return combined;
  }

  @override
  Widget build(BuildContext context) {
    final combinedContent = getCombinedHighlightedContent();

    if (combinedContent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Featured Content',
            style: TextStyleClass.poppinsSemiBold(
              fontSize: 16,
              color: ColorClass.white,
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: FlutterCarousel(
            items: combinedContent.map((item) {
              return GestureDetector(
                onTap: () {
                  if (item is EpisodeData) {
                    onEpisodeTap(item);
                  } else if (item is Datum) {
                    onStoryTap(item);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[900],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl:
                                ApiUrls.assetBaseUrl + _getItemBanner(item),
                            fit: BoxFit.fill,
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[900],
                              child: const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            options: FlutterCarouselOptions(
              viewportFraction: 0.9,
              enlargeCenterPage: true,
              autoPlay: true,
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              showIndicator: true,
              enableInfiniteScroll: true,
              autoPlayInterval: const Duration(seconds: 2),
              height: 250,
            ),
          ),
        ),
      ],
    );
  }

  String _getItemBanner(dynamic item) {
    if (item is EpisodeData) {
      switch (selectedLanguage) {
        case 'ml':
          return item.mlBanner ?? item.adBanner ?? '';
        case 'hi':
          return item.hinBanner ?? item.adBanner ?? '';
        case 'ur':
          return item.urBanner ?? item.adBanner ?? '';
        default: // 'en' or any other language
          return item.adBanner ?? '';
      }
    } else if (item is Datum) {
      // Handle Datum which might not have all language fields yet
      switch (selectedLanguage) {
        case 'ml':
          return (item.mlBanner?.toString() ?? '') != ''
              ? item.mlBanner.toString()
              : (item.enBanner?.toString() ?? '');
        case 'hi':
          // Datum doesn't have hinBanner yet, fallback to enBanner
          return item.enBanner?.toString() ?? '';
        case 'ur':
          // Datum doesn't have urBanner yet, fallback to enBanner
          return item.enBanner?.toString() ?? '';
        default: // 'en' or any other language
          return item.enBanner?.toString() ?? '';
      }
    }
    return '';
  }
}
