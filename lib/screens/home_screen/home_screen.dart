// ignore_for_file: use_build_context_synchronously, unused_import, unused_element

import 'package:lucide_icons/lucide_icons.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/bookmark_screen/bookmark_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zaitoon/screens/episode_screen.dart/episode_screen.dart';
import 'package:zaitoon/screens/home_screen/models/episode_model.dart';
import 'package:zaitoon/screens/home_screen/models/story_model.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/home_screen/components/story_card.dart';
import 'package:zaitoon/screens/language_selection/language_selection.dart';
import 'package:zaitoon/screens/reading_screen/provider/pdf_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon/screens/search/view/search_screen.dart';
import 'package:zaitoon/screens/search/provider/search_provider.dart';
import 'package:zaitoon/screens/reading_screen/story_reader_page.dart';
import 'package:zaitoon/screens/settings_screen/settings_screen.dart';
import 'package:zaitoon/screens/standalone_stories/models/single_story_model.dart';
// duplicate import removed
import 'package:zaitoon/screens/version_check/force_udpate_dialog.dart';
import 'package:zaitoon/screens/version_check/provider/version_check_provider.dart';
import 'package:zaitoon/screens/home_screen/components/highlighted_cards.dart';
import 'package:zaitoon/screens/registration/widgets/registration_popup.dart';
import 'package:zaitoon/screens/standalone_stories/provider/story_provider.dart';
import 'package:zaitoon/screens/bookmark_screen/provider/bookmark_provider.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/screens/standalone_stories/standalone_story_list_screen.dart'
    show StoriesScreen;
import 'package:flutter/services.dart' as services;
import 'package:zaitoon/screens/home_screen/models/reading_progress_model.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';
import 'package:zaitoon/screens/student_form/view/student_form.dart';
import 'package:zaitoon/screens/bright_box/provider/bright_box_provider.dart';
import 'package:zaitoon/screens/bright_box/models/bright_box_models.dart';
import 'package:zaitoon/screens/bright_box/screens/bright_box_subcategories_screen.dart';
import 'package:zaitoon/screens/bright_box/screens/bright_box_home_screen.dart';
import 'package:zaitoon/providers/theme_provider.dart';

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
      final userProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      final brightBoxProvider =
          Provider.of<BrightBoxProvider>(context, listen: false);
      final storiesProvider =
          Provider.of<StoriesProvider>(context, listen: false);

      homeProvider.fetchStories().then((value) {
        homeProvider.fetchHighlightedContent();
        checkForUpdates();
        homeProvider.loadReadingProgress(userProvider.uid ?? 'guest');
      });

      brightBoxProvider.loadCategories();
      storiesProvider.fetchStories(); // Initialize standalone stories
    });
  }

  Future<void> _showMalarvadiRegistrationPopup() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const RegistrationPopup(isCompulsory: false),
    );

    if (result == true && mounted) {
      // Registration completed successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Malarvadi membership registration completed successfully!',
            style: TextStyleClass.poppinsRegular(
              fontSize: 14,
              color: ColorClass.white,
            ),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildMalarvadiBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _showMalarvadiRegistrationPopup(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorClass.primaryColor,
                ColorClass.primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ColorClass.primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.card_membership,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JOIN MALARVADI',
                      style: TextStyleClass.poppinsBold(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to register Malarvadi Membership',
                      style: TextStyleClass.poppinsRegular(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
          overlays: [
            SystemUiOverlay.top
          ], // Empty array hides all overlays (both top and bottom)
        );
        return Scaffold(
          backgroundColor:
              themeProvider.isDarkMode ? ColorClass.black : Colors.white,
          body: SafeArea(
            child:
                Consumer3<UserDataProvider, StoriesProvider, BookmarkProvider>(
              builder: (context, user, storiesProvider, bookmarkProvider, _) {
                services.SystemChrome.setSystemUIOverlayStyle(
                    services.SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: themeProvider.isDarkMode
                      ? Brightness.light
                      : Brightness.dark,
                  statusBarBrightness: themeProvider.isDarkMode
                      ? Brightness.dark
                      : Brightness.light,
                  systemNavigationBarColor: themeProvider.isDarkMode
                      ? ColorClass.black
                      : Colors.white,
                  systemNavigationBarIconBrightness: themeProvider.isDarkMode
                      ? Brightness.light
                      : Brightness.dark,
                ));
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: _buildGreetingSection(
                          user.name ?? '', user, themeProvider.isDarkMode),
                    ),
                    const SizedBox(height: 20),
                    Consumer<HomeProvider>(
                      builder: (context, provider, _) {
                        if (provider.isHighlightedLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                color: ColorClass.primaryColor,
                              ),
                            ),
                          );
                        }
                        if (provider.highlightedEpisodes == null &&
                            provider.singleStoryModel == null) {
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
                    const SizedBox(height: 20),
                    Consumer<HomeProvider>(
                      builder: (context, homeProvider, _) {
                        final items = homeProvider.activeReadingProgress;
                        if (items.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Continue Reading',
                                isDarkMode: themeProvider.isDarkMode),
                            const SizedBox(height: 12),
                            _buildContinueReadingList(context, items),
                          ],
                        );
                      },
                    ),
                    Consumer<StoriesProvider>(
                      builder: (context, provider, child) {
                        final singleStories =
                            (provider.singleStoryModel?.data ?? [])
                                .reversed
                                .toList();
                        if (singleStories.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Single Stories',
                                trailing: _buildSeeAll(
                                    context, themeProvider.isDarkMode),
                                isDarkMode: themeProvider.isDarkMode),
                            const SizedBox(height: 12),
                            _buildSingleStoriesList(context, singleStories),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),
                    _buildSectionTitle('Recent Upload videos',
                        isDarkMode: themeProvider.isDarkMode),
                    const SizedBox(height: 12),
                    _buildRecentUploadsList(context),
                    const SizedBox(height: 24),
                    _buildSectionTitle('All Stories',
                        isDarkMode: themeProvider.isDarkMode),
                    const SizedBox(height: 12),
                    _buildAllStoriesHorizontal(context),
                    const SizedBox(height: 24),
                    Consumer2<BrightBoxProvider, HomeProvider>(
                      builder:
                          (context, brightBoxProvider, homeProvider, child) {
                        if (brightBoxProvider.categories.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Bright Box',
                                trailing: _buildBrightBoxSeeAll(
                                    context, themeProvider.isDarkMode),
                                isDarkMode: themeProvider.isDarkMode),
                            const SizedBox(height: 12),
                            _buildBrightBoxCategoriesList(context,
                                brightBoxProvider.categories, homeProvider),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
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

  Widget _buildGreetingSection(
      String name, UserDataProvider user, bool isDarkMode) {
    final String avatarAsset = user.avatar ??
        (user.gender == 'girl' ? ImageClass.avatar2 : ImageClass.avatar1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    'Hello ',
                    style: GoogleFonts.fredoka(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? ColorClass.white : Colors.black,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        ColorClass.grad1,
                        ColorClass.grad2,
                        ColorClass.grad3
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      name.isEmpty ? 'Friend' : name,
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                  // ),
                  Text(' 👋', style: TextStyle(fontSize: 24)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => navigatePR(
                      context: context,
                      screen: const SearchScreen(),
                    ),
                    icon: Icon(LucideIcons.search,
                        color: isDarkMode ? ColorClass.white : Colors.black),
                  ),
                  const SizedBox(width: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      avatarAsset,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Let’s explore magical stories together!',
          style: GoogleFonts.openSans(
            fontSize: 14,
            color:
                isDarkMode ? ColorClass.grey400 : Colors.black.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // Widget _buildHeroBanner(UserDataProvider user) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(24),
  //       child: Container(
  //         height: 180,
  //         width: double.infinity,
  //         decoration: BoxDecoration(
  //           image: DecorationImage(
  //             image: AssetImage(user.gender == 'girl'
  //                 ? ImageClass.avatar2
  //                 : ImageClass.avatar1),
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //         child: Container(color: Colors.black.withOpacity(0.15)),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSectionTitle(String title,
      {Widget? trailing, required bool isDarkMode}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? ColorClass.white : Colors.black,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildSeeAll(BuildContext context, bool isDarkMode) {
    return TextButton(
      onPressed: () => navigatePR(
        context: context,
        screen: const StoriesScreen(),
      ),
      child: Text(
        'See all',
        style: GoogleFonts.openSans(
            color: isDarkMode ? ColorClass.white : Colors.black, fontSize: 14),
      ),
    );
  }

  Widget _buildBrightBoxSeeAll(BuildContext context, bool isDarkMode) {
    return TextButton(
      onPressed: () => navigatePR(
        context: context,
        screen: const BrightBoxHomeScreen(sourceScreen: 'home'),
      ),
      child: Text(
        'See all',
        style: GoogleFonts.openSans(
            color: isDarkMode ? ColorClass.white : Colors.black, fontSize: 14),
      ),
    );
  }

  Widget _buildContinueReadingList(
      BuildContext context, List<ReadingProgressModel> items) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildSmallPoster(
            imageUrl: item.thumbnail,
            title: item.title,
            progress: (item.progressPercentage.clamp(0, 100)) / 100.0,
            onTap: () {
              navigatePR(
                context: context,
                screen: StoryReadingScreen(
                  id: item.id,
                  title: item.title,
                  thumbnail: item.thumbnail,
                  tag: item.tag,
                  pdfUrl: item.fileUrl,
                ),
              );
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: items.length.clamp(0, 10),
      ),
    );
  }

  Widget _buildSingleStoriesList(
      BuildContext context, List<Datum> singleStories) {
    final home = Provider.of<HomeProvider>(context, listen: false);
    return SizedBox(
      height: 230,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final story = singleStories[index];
          return _buildTallCard(
            imageUrl: ApiUrls.assetBaseUrl + (story.coverImage ?? ''),
            title: home.selectedLanguage == 'en'
                ? (story.storyTitleEn ?? 'Untitled')
                : (story.storyTitleMl ?? 'Untitled'),
            subtitle: '${story.readTime ?? '0'} mnt',
            cardType: 'single',
            onTap: () {
              navigatePR(
                context: context,
                screen: StoryReadingScreen(
                  id: (story.id ?? 0).toString(),
                  title: home.selectedLanguage == 'en'
                      ? (story.storyTitleEn ?? 'Untitled')
                      : (story.storyTitleMl ?? 'Untitled'),
                  thumbnail: ApiUrls.assetBaseUrl + (story.coverImage ?? ''),
                  tag: story.tag ?? '',
                  pdfUrl: home.selectedLanguage == 'en'
                      ? ApiUrls.assetBaseUrl + (story.storyFileEn ?? '')
                      : ApiUrls.assetBaseUrl + (story.storyFileMl ?? ''),
                ),
              );
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: singleStories.length,
      ),
    );
  }

  Widget _buildRecentUploadsList(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final stories = provider.storyModel?.data ?? [];
        if (stories.isEmpty) return _buildEmptyState();
        final latest = List<StoryData>.from(stories)
          ..sort((a, b) => (int.tryParse(b.id.toString()) ?? 0)
              .compareTo(int.tryParse(a.id.toString()) ?? 0));
        return SizedBox(
          height: 130,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final s = latest[index];
              return _buildWideThumb(
                imageUrl: ApiUrls.assetBaseUrl + (s.coverimage ?? ''),
                onTap: () {
                  navigatePR(
                    context: context,
                    screen: EpisodeScreen(
                      title: _getStoryModelTitle(s, provider.selectedLanguage),
                      id: s.id.toString(),
                      imageUrl: ApiUrls.assetBaseUrl + (s.coverimage ?? ''),
                      tag: s.tag ?? '',
                    ),
                  );
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: latest.length.clamp(0, 10),
          ),
        );
      },
    );
  }

  Widget _buildAllStoriesHorizontal(BuildContext context) {
    return Consumer2<HomeProvider, PdfProvider>(
      builder: (context, home, pdf, _) {
        if (home.isStoryLoading) return _buildLoadingIndicator();
        final list = home.storyModel?.data ?? [];
        if (list.isEmpty) return _buildEmptyState();
        final sorted = _getSortedStories(list);
        return SizedBox(
          height: 230,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final item = sorted[index];
              return _buildTallCard(
                imageUrl: ApiUrls.assetBaseUrl + (item.coverimage ?? ''),
                title: _getStoryModelTitle(item, home.selectedLanguage),
                subtitle: _episodeCountText(item),
                cardType: 'all',
                onTap: () => _handleStoryTapWithData(item, home, pdf),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemCount: sorted.length,
          ),
        );
      },
    );
  }

  String _episodeCountText(StoryData story) {
    final home = Provider.of<HomeProvider>(context, listen: false);
    final int storyId = story.id ?? 0;
    if (storyId == 0) return 'Episodes';

    final cachedCount = home.getEpisodeCountCached(storyId);
    if (cachedCount != null) {
      return '$cachedCount episodes';
    }

    // Trigger background fetch; UI will rebuild when count arrives
    // ignore: discarded_futures
    home.ensureEpisodeCount(storyId);
    return 'Episodes';
  }

  Widget _buildSmallPoster(
      {required String imageUrl,
      required String title,
      double? progress,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 116,
        height: 159,
        child: Stack(
          children: [
            // Background image with rounded corners
            Container(
              width: 116,
              height: 159,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            // Dark overlay
            Container(
              width: 116,
              height: 159,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: const Color(0x33000000),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            // Progress bar 12px above bottom, 10px horizontal padding
            if (progress != null)
              Positioned(
                left: 10,
                right: 10,
                bottom: 15,
                child: Container(
                  width: 96,
                  height: 6,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: ColorClass.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideThumb(
      {required String imageUrl, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 182,
        height: 126,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          //color: Colors.white,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 182,
                  height: 126,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    color: const Color(0x33000000),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTallCard({
    required String imageUrl,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String cardType =
        'single', // 'single' for single stories, 'all' for all stories
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 169,
        decoration: BoxDecoration(
          color: Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              // borderRadius: BorderRadius.circular(24),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            const SizedBox(height: 8),
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
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      if (cardType == 'single')
                        Icon(
                          LucideIcons.clock,
                          size: 14,
                          color: Colors.black54,
                        ),
                      if (cardType == 'brightbox')
                        Icon(
                          LucideIcons.box,
                          size: 14,
                          color: Colors.black54,
                        ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.openSans(
                              fontSize: 12, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoriesGrid() {
    return Consumer2<HomeProvider, PdfProvider>(
      builder: (context, snapshot, pdfSnapshot, child) {
        if (snapshot.isStoryLoading) {
          return _buildLoadingIndicator();
        }
        if (snapshot.error != null && snapshot.error!.isNotEmpty) {
          return _buildErrorState(snapshot.error!);
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
              color: ColorClass.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading stories',
            style: TextStyleClass.poppinsMedium(
              fontSize: 18,
              color: ColorClass.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyleClass.poppinsRegular(
              fontSize: 14,
              color: ColorClass.black.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Retry loading stories
              final provider =
                  Provider.of<HomeProvider>(context, listen: false);
              provider.fetchStories();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorClass.primaryColor,
              foregroundColor: Colors.black,
            ),
            child: Text(
              'Retry',
              style: TextStyleClass.poppinsMedium(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildBrightBoxCategoriesList(BuildContext context,
      List<BrightBoxCategory> categories, HomeProvider homeProvider) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildTallCard(
            imageUrl: ApiUrls.assetBaseUrl + (category.coverImage),
            title: _getBrightBoxCategoryTitle(
                category, homeProvider.selectedLanguage),
            subtitle: 'Categories',
            cardType: 'brightbox',
            onTap: () {
              navigatePR(
                context: context,
                screen: BrightBoxSubcategoriesScreen(category: category),
              );
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: categories.length,
      ),
    );
  }

  String _getBrightBoxCategoryTitle(
      BrightBoxCategory category, String language) {
    switch (language) {
      case 'ml':
        return category.catTitleMl.isNotEmpty
            ? category.catTitleMl
            : category.catTitleEn;
      case 'hi':
        return category.catTitleHi.isNotEmpty
            ? category.catTitleHi
            : category.catTitleEn;
      case 'ur':
        return category.catTitleUr.isNotEmpty
            ? category.catTitleUr
            : category.catTitleEn;
      default:
        return category.catTitleEn;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}
