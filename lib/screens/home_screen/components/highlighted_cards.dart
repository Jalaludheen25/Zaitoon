import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/screens/home_screen/models/episode_model.dart';
import 'package:zaitoon/screens/home_screen/models/story_model.dart';
import 'package:zaitoon/screens/standalone_stories/models/single_story_model.dart';

class HighlightedCards extends StatefulWidget {
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

  @override
  State<HighlightedCards> createState() => _HighlightedCardsState();
}

class _HighlightedCardsState extends State<HighlightedCards> {
  int _currentIndex = 0;

  String getStoryName(int? storyId) {
    if (widget.storyModel?.data == null || storyId == null) return '';

    final story = widget.storyModel!.data!.firstWhere(
      (story) => story.id == storyId,
      orElse: () => StoryData(),
    );

    switch (widget.selectedLanguage) {
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

    if (widget.episodes.isNotEmpty) {
      final sortedEpisodes = List<EpisodeData>.from(widget.episodes);
      sortedEpisodes.sort((a, b) {
        final storyA = widget.storyModel?.data?.firstWhere(
          (story) => story.id == a.story,
          orElse: () => StoryData(),
        );
        final storyB = widget.storyModel?.data?.firstWhere(
          (story) => story.id == b.story,
          orElse: () => StoryData(),
        );

        final priorityA = int.tryParse(storyA?.priority ?? '999') ?? 999;
        final priorityB = int.tryParse(storyB?.priority ?? '999') ?? 999;

        return priorityA.compareTo(priorityB);
      });
      combined.addAll(sortedEpisodes);
    }

    if (widget.singleStoryModel?.data != null) {
      final highlightedStories = widget.singleStoryModel!.data
          .where((story) => story.isHighlighted == true)
          .toList();
      combined.addAll(highlightedStories);
    }

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
          padding: const EdgeInsets.all(0),
        ),
        SizedBox(
          width: 357,
          child: FlutterCarousel(
            items: combinedContent.map((item) {
              return GestureDetector(
                onTap: () {
                  if (item is EpisodeData) {
                    widget.onEpisodeTap(item);
                  } else if (item is Datum) {
                    widget.onStoryTap(item);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.grey[900],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
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
              showIndicator: false,
              enableInfiniteScroll: true,
              autoPlayInterval: const Duration(seconds: 2),
              height: 140,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildPageIndicator(combinedContent.length),
      ],
    );
  }

  String _getItemBanner(dynamic item) {
    if (item is EpisodeData) {
      switch (widget.selectedLanguage) {
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
      switch (widget.selectedLanguage) {
        case 'ml':
          return (item.mlBanner?.toString() ?? '') != ''
              ? item.mlBanner.toString()
              : (item.enBanner?.toString() ?? '');
        case 'hi':
          return item.enBanner?.toString() ?? '';
        case 'ur':
          return item.enBanner?.toString() ?? '';
        default: // 'en' or any other language
          return item.enBanner?.toString() ?? '';
      }
    }
    return '';
  }

  Widget _buildPageIndicator(int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final bool isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: 8.0),
          width: isActive ? 20.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [
                      ColorClass.grad1,
                      ColorClass.grad2,
                      ColorClass.grad3,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isActive
                ? null
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black),
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: ColorClass.grad2.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
