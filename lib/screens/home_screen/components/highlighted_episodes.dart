import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/home_screen/models/episode_model.dart';
import 'package:zaitoon/screens/home_screen/models/story_model.dart';

class HighlightedEpisodes extends StatelessWidget {
  final List<EpisodeData> episodes;
  final String selectedLanguage;
  final Function(EpisodeData) onEpisodeTap;
  final StoryModel? storyModel; // Add this parameter

  const HighlightedEpisodes({
    super.key,
    required this.episodes,
    required this.selectedLanguage,
    required this.onEpisodeTap,
    required this.storyModel, // Make it required
  });

  String getStoryName(int? storyId) {
    if (storyModel?.data == null || storyId == null) return '';

    final story = storyModel!.data!.firstWhere(
      (story) => story.id == storyId,
      orElse: () =>
          StoryData(), // Replace with your StoryData default constructor
    );

    return selectedLanguage == 'en' ? story.name ?? '' : story.mlTitle ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (episodes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Featured Episodes',
            style: TextStyleClass.poppinsSemiBold(
              fontSize: 20,
              color: ColorClass.white,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: episodes.length,
            itemBuilder: (context, index) {
              final episode = episodes[index];
              final storyName = getStoryName(episode.story);

              return GestureDetector(
                onTap: () => onEpisodeTap(episode),
                child: Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
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
                                ApiUrls.assetBaseUrl + episode.coverImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
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
                              // Episode Title
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      storyName,
                                      style: TextStyleClass.poppinsSemiBold(
                                        fontSize: 16,
                                        color: ColorClass.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedLanguage == 'en'
                                        ? episode.storyTile ?? ''
                                        : episode.mlTitle ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ColorClass.white70,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(width: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        color: Colors.white70,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${episode.readMinutes} min',
                                        style: TextStyleClass.poppinsRegular(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
