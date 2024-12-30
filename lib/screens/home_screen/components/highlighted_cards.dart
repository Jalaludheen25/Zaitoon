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

    return selectedLanguage == 'en' ? story.name ?? '' : story.mlTitle ?? '';
  }

  List<dynamic> getCombinedHighlightedContent() {
    List<dynamic> combined = [];

    // Add episodes
    if (episodes.isNotEmpty) {
      combined.addAll(episodes);
    }

    // Add single stories
    if (singleStoryModel?.data != null) {
      combined.addAll(
          singleStoryModel!.data.where((story) => story.isHighlighted == true));
    }

    // Shuffle the combined list to mix stories and episodes
    combined.shuffle();

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
      return selectedLanguage == 'ml'
          ? item.mlBanner ?? item.adBanner
          : item.adBanner ?? '';
    } else if (item is Datum) {
      return selectedLanguage == 'ml'
          ? item.mlBanner ?? item.enBanner
          : item.enBanner ?? '';
    }
    return '';
  }
}
