// ignore_for_file: use_build_context_synchronously

import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/bookmark_screen/bookmark_screen.dart';

import 'package:zaitoon/screens/episode_screen.dart/episode_screen.dart';
import 'package:zaitoon/screens/home_screen/models/episode_model.dart';
import 'package:zaitoon/screens/home_screen/models/story_model.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/home_screen/components/story_card.dart';
import 'package:zaitoon/screens/language_selection/language_selection.dart';
import 'package:zaitoon/screens/reading_screen/provider/pdf_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/screens/reading_screen/story_reader_page.dart';
import 'package:zaitoon/screens/settings_screen/settings_screen.dart';
import 'package:zaitoon/screens/standalone_stories/models/single_story_model.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';
import 'package:zaitoon/screens/version_check/force_udpate_dialog.dart';
import 'package:zaitoon/screens/version_check/provider/version_check_provider.dart';
import 'package:zaitoon/screens/home_screen/components/highlighted_cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    Future.microtask(() {
      HomeProvider homeProvider =
          Provider.of<HomeProvider>(context, listen: false);
      homeProvider.fetchStories().then((value) {
        homeProvider.fetchHighlightedContent();
        checkForUpdates();
      });
    });
  }

  void checkForUpdates() async {
    final provider = Provider.of<VersionCheckProvider>(context, listen: false);
    await provider.checkVersion();

    if (provider.needsUpdate) {
      showDialog(
        context: context,
        barrierDismissible: !provider.forceUpdate,
        builder: (context) => FadeTransition(
          opacity: CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.easeOut,
          ),
          child: const UpdateDialog(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.black,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ColorClass.primaryColor.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    Consumer<UserDataProvider>(
                      builder: (context, data, child) => Row(
                        children: [
                          _buildGreetingSection(data.name ?? ''),
                          _buildActionButtons(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  Consumer<HomeProvider>(
                    builder: (context, provider, _) {
                      if (provider.isHighlightedLoading ||
                          (provider.highlightedEpisodes == null &&
                              provider.singleStoryModel == null)) {
                        return const SizedBox.shrink();
                      }
                      return HighlightedCards(
                        storyModel: provider.storyModel,
                        singleStoryModel: provider.singleStoryModel,
                        episodes: provider.highlightedEpisodes?.data ?? [],
                        selectedLanguage: provider.selectedLanguage,
                        onEpisodeTap: (episode) {
                          navigatePR(
                            context: context,
                            screen: StoryReadingScreen(
                              id: episode.id.toString(),
                              title: _getEpisodeTitle(
                                  episode, provider.selectedLanguage),
                              thumbnail:
                                  ApiUrls.assetBaseUrl + episode.coverImage!,
                              tag: '',
                              pdfUrl: ApiUrls.assetBaseUrl +
                                  _getEpisodeFile(
                                      episode, provider.selectedLanguage),
                            ),
                          );
                        },
                        onStoryTap: (story) {
                          navigatePR(
                            context: context,
                            screen: StoryReadingScreen(
                              id: story.id.toString(),
                              title: _getStoryTitle(
                                  story, provider.selectedLanguage),
                              thumbnail:
                                  ApiUrls.assetBaseUrl + story.coverImage!,
                              tag: story.tag!,
                              pdfUrl: ApiUrls.assetBaseUrl +
                                  _getStoryFile(
                                      story, provider.selectedLanguage),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'All Stories',
                      style: TextStyleClass.poppinsSemiBold(
                        fontSize: 16,
                        color: ColorClass.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildStoriesGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection(String name) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Add this
        children: [
          FittedBox(
            // Wrap the row in FittedBox
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  "Hello", // Add text truncation
                  style: TextStyleClass.poppinsSemiBold(
                    fontSize: 20,
                    color: ColorClass.white,
                  ),
                  maxLines: 1, // Limit to single line
                  overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                ),
                const Text(" 👋", style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyleClass.poppinsRegular(
              fontSize: 16,
              color: ColorClass.white.withOpacity(0.7),
            ),
            maxLines: 1, // Limit to single line
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _buildIconButton(
          icon: 'assets/icons/language.png',
          onPressed: () => navigatePR(
            context: context,
            screen: const LanguageSelection(),
          ),
        ),
        _buildIconButton(
          icon: Icons.bookmark_outline_outlined,
          onPressed: () => navigatePR(
            context: context,
            screen: const BookmarkScreen(),
          ),
        ),
        _buildIconButton(
          icon: Icons.settings,
          onPressed: () => navigatePR(
            context: context,
            screen: const SettingsScreen(),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({dynamic icon, required VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: ColorClass.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: icon is String
            ? Image.asset(icon, color: ColorClass.white, height: 24)
            : Icon(icon as IconData, color: ColorClass.white),
      ),
    );
  }

  Widget _buildStoriesGrid() {
    return Consumer2<HomeProvider, PdfProvider>(
      builder: (context, snapshot, pdfSnapshot, child) {
        if (snapshot.isStoryLoading) {
          return _buildLoadingIndicator();
        }
        if (snapshot.storyModel == null) {
          return _buildEmptyState();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _getSortedStories(snapshot.storyModel!.data!).length,
              itemBuilder: (context, index) {
                final sortedStories =
                    _getSortedStories(snapshot.storyModel!.data!);
                final originalIndex =
                    snapshot.storyModel!.data!.indexOf(sortedStories[index]);
                return _buildAnimatedStoryCard(
                  index: originalIndex,
                  snapshot: snapshot,
                  pdfSnapshot: pdfSnapshot,
                  storyData: sortedStories[index],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedStoryCard({
    required int index,
    required HomeProvider snapshot,
    required PdfProvider pdfSnapshot,
    required StoryData storyData,
  }) {
    // Clamp the animation start time to prevent exceeding 1.0
    final double animationStart = (index * 0.05).clamp(0.0, 0.8);
    final double animationEnd = (animationStart + 0.2).clamp(0.2, 1.0);

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _fadeController,
        curve: Interval(
          animationStart,
          animationEnd,
          curve: Curves.easeOut,
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _fadeController,
          curve: Interval(
            animationStart,
            animationEnd,
            curve: Curves.easeOut,
          ),
        )),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ColorClass.primaryColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: StoryCard(
            name: _getStoryModelTitle(storyData, snapshot.selectedLanguage),
            imageUrl: ApiUrls.assetBaseUrl + storyData.coverimage!,
            readTap: () =>
                _handleStoryTapWithData(storyData, snapshot, pdfSnapshot),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: ColorClass.primaryColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '📚',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'No stories found',
            style: TextStyleClass.poppinsMedium(
              fontSize: 18,
              color: ColorClass.white,
            ),
          ),
        ],
      ),
    );
  }

  void _handleStoryTap(
    int index,
    HomeProvider snapshot,
    PdfProvider pdfSnapshot,
  ) {
    navigatePR(
      context: context,
      screen: EpisodeScreen(
        title: _getStoryModelTitle(
            snapshot.storyModel!.data![index], snapshot.selectedLanguage),
        id: snapshot.storyModel!.data![index].id.toString(),
        imageUrl: ApiUrls.assetBaseUrl +
            snapshot.storyModel!.data![index].coverimage!,
        tag: snapshot.storyModel!.data![index].tag ?? '',
      ),
    );
    pdfSnapshot.setCurrentStory(
      snapshot.storyModel!.data![index].id,
      _getStoryModelTitle(
          snapshot.storyModel!.data![index], snapshot.selectedLanguage),
      ApiUrls.assetBaseUrl + snapshot.storyModel!.data![index].coverimage!,
    );
  }

  // Helper methods for multi-language support
  String _getEpisodeTitle(EpisodeData episode, String language) {
    switch (language) {
      case 'ml':
        return episode.mlTitle ?? episode.storyTile ?? '';
      case 'hi':
        return episode.hinTitle ?? episode.storyTile ?? '';
      case 'ur':
        return episode.urTitle ?? episode.storyTile ?? '';
      default: // 'en' or any other language
        return episode.storyTile ?? '';
    }
  }

  String _getEpisodeFile(EpisodeData episode, String language) {
    switch (language) {
      case 'ml':
        return episode.mlStoryFile ?? episode.storyFile ?? '';
      case 'hi':
        return episode.hinStoryFile ?? episode.storyFile ?? '';
      case 'ur':
        return episode.urStoryFile ?? episode.storyFile ?? '';
      default: // 'en' or any other language
        return episode.storyFile ?? '';
    }
  }

  String _getStoryTitle(Datum story, String language) {
    switch (language) {
      case 'ml':
        return story.storyTitleMl!;
      case 'hi':
        return story.storyTitleEn!; // Fallback to English for now
      case 'ur':
        return story.storyTitleEn!; // Fallback to English for now
      default: // 'en' or any other language
        return story.storyTitleEn!;
    }
  }

  String _getStoryFile(Datum story, String language) {
    switch (language) {
      case 'ml':
        return story.storyFileMl!;
      case 'hi':
        return story.storyFileEn!; // Fallback to English for now
      case 'ur':
        return story.storyFileEn!; // Fallback to English for now
      default: // 'en' or any other language
        return story.storyFileEn!;
    }
  }

  String _getStoryModelTitle(StoryData story, String language) {
    switch (language) {
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

  // Sort stories by priority (lower number = higher priority)
  List<StoryData> _getSortedStories(List<StoryData> stories) {
    final sortedStories = List<StoryData>.from(stories);
    sortedStories.sort((a, b) {
      final priorityA = int.tryParse(a.priority ?? '999') ?? 999;
      final priorityB = int.tryParse(b.priority ?? '999') ?? 999;
      return priorityA.compareTo(priorityB);
    });
    return sortedStories;
  }

  void _handleStoryTapWithData(
    StoryData storyData,
    HomeProvider snapshot,
    PdfProvider pdfSnapshot,
  ) {
    navigatePR(
      context: context,
      screen: EpisodeScreen(
        title: _getStoryModelTitle(storyData, snapshot.selectedLanguage),
        id: storyData.id.toString(),
        imageUrl: ApiUrls.assetBaseUrl + storyData.coverimage!,
        tag: storyData.tag ?? '',
      ),
    );
    pdfSnapshot.setCurrentStory(
      storyData.id,
      _getStoryModelTitle(storyData, snapshot.selectedLanguage),
      ApiUrls.assetBaseUrl + storyData.coverimage!,
    );
  }



  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}
