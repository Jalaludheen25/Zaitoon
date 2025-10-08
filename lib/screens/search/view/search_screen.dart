// ignore_for_file: use_build_context_synchronously

import 'dart:math' as math;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/screens/home_screen/models/story_model.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/search/provider/search_provider.dart';
import 'package:zaitoon/screens/standalone_stories/models/single_story_model.dart';
import 'package:zaitoon/screens/reading_screen/story_reader_page.dart';
import 'package:zaitoon/screens/standalone_stories/provider/story_provider.dart';
import 'package:zaitoon/screens/episode_screen.dart/episode_screen.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon/providers/theme_provider.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/constants/color_class.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _animController;
  late final Animation<double> _searchBarSlide;
  late final Animation<double> _searchBarFade;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _searchBarSlide = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );
    _searchBarFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = context.mounted
          ? (context.read<UserDataProvider?>()?.uid ?? 'guest')
          : 'guest';
      await context.read<SearchProvider>().initialize(userId);
      _animController.forward();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
            statusBarBrightness:
                themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness:
                themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
          ),
        );
        return Scaffold(
          backgroundColor:
              themeProvider.isDarkMode ? Colors.black : Colors.white,
          body: SafeArea(
            child: Consumer3<SearchProvider, HomeProvider, StoriesProvider>(
              builder: (context, search, home, storiesProvider, _) {
                final List<StoryData> allStories = home.storyModel?.data ?? [];
                final List<Datum> singleStories =
                    (storiesProvider.singleStoryModel?.data ?? <Datum>[]);

                final String q = search.query.trim();
                final bool hasQuery = q.isNotEmpty;

                final List<StoryData> filteredAll = hasQuery
                    ? allStories.where((s) {
                        final title =
                            _titleForStoryData(s, home.selectedLanguage);
                        return title.toLowerCase().contains(q.toLowerCase());
                      }).toList()
                    : allStories;

                final List<Datum> filteredSingle = hasQuery
                    ? singleStories.where((s) {
                        final title = home.selectedLanguage == 'en'
                            ? (s.storyTitleEn ?? '')
                            : (s.storyTitleMl ?? s.storyTitleEn ?? '');
                        return title.toLowerCase().contains(q.toLowerCase());
                      }).toList()
                    : singleStories;

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    _AnimatedSearchBar(
                      controller: _controller,
                      focusNode: _focusNode,
                      slide: _searchBarSlide,
                      fade: _searchBarFade,
                      themeProvider: themeProvider,
                      onChanged: search.setQuery,
                      onSubmitted: (value) async {
                        // Do not record raw query into history; history tracks selected items only
                      },
                      onBack: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 12),
                    // Recent Searches (only visible when there are items)
                    if (search.recentSearches.isNotEmpty) ...[
                      _SectionTitle(
                          title: 'Recent Searches',
                          themeProvider: themeProvider),
                      const SizedBox(height: 12),
                      _RecentItems(
                        items: search.recentSearches,
                        themeProvider: themeProvider,
                        onTap: (title) {
                          _controller.text = title;
                          search.setQuery(title);
                        },
                        onRemove: search.removeFromHistory,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Single Stories (always visible)
                    _SectionTitle(
                        title: 'Single Stories', themeProvider: themeProvider),
                    const SizedBox(height: 12),
                    _HorizontalCardsSingle(
                      stories: filteredSingle,
                      language: home.selectedLanguage,
                      themeProvider: themeProvider,
                    ),

                    // All Stories (always visible)
                    const SizedBox(height: 30),
                    _SectionTitle(
                        title: 'All Stories', themeProvider: themeProvider),
                    const SizedBox(height: 12),
                    _HorizontalCardsAll(
                      stories: filteredAll,
                      language: home.selectedLanguage,
                      themeProvider: themeProvider,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _titleForStoryData(StoryData story, String language) {
    switch (language) {
      case 'ml':
        return story.mlTitle ?? story.name ?? '';
      case 'hi':
        return story.hinTitle ?? story.name ?? '';
      case 'ur':
        return story.urTitle ?? story.name ?? '';
      default:
        return story.name ?? '';
    }
  }
}

class _AnimatedSearchBar extends StatelessWidget {
  const _AnimatedSearchBar({
    required this.controller,
    required this.focusNode,
    required this.slide,
    required this.fade,
    required this.themeProvider,
    required this.onChanged,
    required this.onSubmitted,
    required this.onBack,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Animation<double> slide;
  final Animation<double> fade;
  final ThemeProvider themeProvider;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: AnimatedBuilder(
        animation: slide,
        builder: (context, child) {
          final double dx = (1 - slide.value) * -20;
          return Transform.translate(
            offset: Offset(dx, 0),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Transform.rotate(
                angle: 2 * math.pi / 180,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  onPressed: onBack,
                ),
              ),
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        width: 0.5,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Color(0x99000000)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Icon(Icons.search,
                          size: 20,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            cursorColor: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              hintText: 'Search for stories...',
                              hintStyle: TextStyleClass.openSans(
                                color: themeProvider.isDarkMode
                                    ? Colors.white.withOpacity(0.7)
                                    : Color(0x4C000000),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                            style: TextStyleClass.openSans(
                                fontSize: 14,
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black),
                            textInputAction: TextInputAction.search,
                            onChanged: onChanged,
                            onSubmitted: onSubmitted,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (controller.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                controller.clear();
                                onChanged('');
                                focusNode.requestFocus();
                              },
                              child: Icon(Icons.close,
                                  size: 16,
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black54),
                            ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              // TODO: integrate voice search here
                            },
                            child: Icon(Icons.mic_none,
                                size: 18,
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.themeProvider});
  final String title;
  final ThemeProvider themeProvider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyleClass.fredoka(
                fontSize: 20,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          // trailing removed
        ],
      ),
    );
  }
}

// _RecentChips removed; replaced by _RecentItems grid with images

class _RecentItems extends StatelessWidget {
  const _RecentItems({
    required this.items,
    required this.themeProvider,
    required this.onTap,
    required this.onRemove,
  });

  final List<Map<String, String>> items;
  final ThemeProvider themeProvider;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = items[index];
          final title = item['title'] ?? '';
          final imageUrl = item['imageUrl'] ?? '';
          return GestureDetector(
            onTap: () => onTap(title),
            child: SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: 86,
                                height: 86,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 86,
                                height: 86,
                                color: themeProvider.isDarkMode
                                    ? ColorClass.black.withOpacity(0.3)
                                    : const Color(0xFFF2F2F2),
                                child: Icon(Icons.image,
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black45),
                              ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => onRemove(title),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(Icons.close,
                                size: 12, color: Colors.black54),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 86,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyleClass.openSans(
                        fontSize: 14,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: items.length,
      ),
    );
  }
}

class _HorizontalCardsSingle extends StatelessWidget {
  const _HorizontalCardsSingle({
    required this.stories,
    required this.language,
    required this.themeProvider,
  });

  final List<Datum> stories;
  final String language;
  final ThemeProvider themeProvider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final story = stories[index];
          final String title = language == 'en'
              ? (story.storyTitleEn ?? 'Untitled')
              : (story.storyTitleMl ?? story.storyTitleEn ?? 'Untitled');
          final String imageUrl =
              ApiUrls.assetBaseUrl + (story.coverImage ?? '');
          final String pdfUrl = language == 'en'
              ? ApiUrls.assetBaseUrl + (story.storyFileEn ?? '')
              : ApiUrls.assetBaseUrl +
                  (story.storyFileMl ?? story.storyFileEn ?? '');
          return _TallCard(
            imageUrl: imageUrl,
            title: title,
            subtitle: '${story.readTime ?? '0'} mnt',
            showClock: true,
            themeProvider: themeProvider,
            onTap: () async {
              await context
                  .read<SearchProvider>()
                  .addStoryToHistory(title: title, imageUrl: imageUrl);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StoryReadingScreen(
                    id: (story.id ?? 0).toString(),
                    title: title,
                    thumbnail: imageUrl,
                    tag: story.tag ?? '',
                    pdfUrl: pdfUrl,
                  ),
                ),
              );
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: stories.length,
      ),
    );
  }
}

class _HorizontalCardsAll extends StatelessWidget {
  const _HorizontalCardsAll({
    required this.stories,
    required this.language,
    required this.themeProvider,
  });

  final List<StoryData> stories;
  final String language;
  final ThemeProvider themeProvider;

  String _title(StoryData story) {
    switch (language) {
      case 'ml':
        return story.mlTitle ?? story.name ?? '';
      case 'hi':
        return story.hinTitle ?? story.name ?? '';
      case 'ur':
        return story.urTitle ?? story.name ?? '';
      default:
        return story.name ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 223,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final story = stories[index];
          final String imageUrl =
              ApiUrls.assetBaseUrl + (story.coverimage ?? '');
          final home = Provider.of<HomeProvider>(context, listen: false);
          String subtitleText = 'Episodes';
          final int storyId = story.id ?? 0;
          if (storyId != 0) {
            final cached = home.getEpisodeCountCached(storyId);
            if (cached != null) {
              subtitleText = '$cached episodes';
            } else {
              // Trigger background fetch
              // ignore: discarded_futures
              home.ensureEpisodeCount(storyId);
            }
          }
          return _TallCard(
            imageUrl: imageUrl,
            title: _title(story),
            subtitle: subtitleText,
            themeProvider: themeProvider,
            onTap: () async {
              final title = _title(story);
              await context
                  .read<SearchProvider>()
                  .addStoryToHistory(title: title, imageUrl: imageUrl);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EpisodeScreen(
                    title: title,
                    id: story.id.toString(),
                    imageUrl: imageUrl,
                    tag: story.tag ?? '',
                  ),
                ),
              );
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: stories.length,
      ),
    );
  }
}

class _TallCard extends StatelessWidget {
  const _TallCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.themeProvider,
    required this.onTap,
    this.showClock = false,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final ThemeProvider themeProvider;
  final VoidCallback onTap;
  final bool showClock;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 169,
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? ColorClass.bg : Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Image.network(
                    imageUrl,
                    width: 169,
                    height: 156,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark_border,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 8),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyleClass.fredokaRegular(
                      fontSize: 16,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (showClock)
                    Row(
                      children: [
                        Icon(
                          LucideIcons.clock,
                          size: 14,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyleClass.openSans(
                              fontSize: 12,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyleClass.openSans(
                        fontSize: 12,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
