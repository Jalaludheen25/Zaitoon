// ignore_for_file: use_build_context_synchronously

import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/bottom_navigation/provider/bottom_navigation_provider.dart';
import 'package:zaitoon/screens/episode_screen.dart/episode_screen.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/home_screen/components/story_card.dart';
import 'package:zaitoon/screens/language_selection/language_selection.dart';
import 'package:zaitoon/screens/reading_screen/provider/pdf_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';
import 'package:zaitoon/screens/version_check/force_udpate_dialog.dart';
import 'package:zaitoon/screens/version_check/provider/version_check_provider.dart';
import 'package:zaitoon/screens/cbz_viewer/cbz_viewer_screen.dart';

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
                    // Header Section
                    Consumer<UserDataProvider>(
                      builder: (context, data, child) => Row(
                        children: [
                          _buildGreetingSection(data.name ?? ''),
                          _buildActionButtons(context),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 16),
                    // Reading Stats Card
                    // _buildReadingStatsCard(),
                  ],
                ),
              ),
            ),
            // Stories Grid
            Expanded(
              child: _buildStoriesGrid(),
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
                  "Hello, ${name.length > 10 ? '${name.substring(0, 10)}...' : name}", // Add text truncation
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
            "Ready for today's adventure?",
            style: TextStyleClass.poppinsRegular(
              fontSize: 14,
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
        GestureDetector(
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CbzViewerScreen(),
              ),
            );
          },
          child: _buildIconButton(
            icon: Icons.settings,
            onPressed: () => context.read<NavigationProvider>().setIndex(3),
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
            int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: snapshot.storyModel!.data!.length,
              itemBuilder: (context, index) => _buildAnimatedStoryCard(
                index: index,
                snapshot: snapshot,
                pdfSnapshot: pdfSnapshot,
              ),
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
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _fadeController,
        curve: Interval(
          index * 0.1,
          1.0,
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
            index * 0.1,
            1.0,
            curve: Curves.easeOut,
          ),
        )),
        child: StoryCard(
          name: snapshot.selectedLanguage == 'en'
              ? snapshot.storyModel!.data![index].name
              : snapshot.storyModel!.data![index].mlTitle,
          discription: snapshot.selectedLanguage == 'en'
              ? snapshot.storyModel!.data![index].description
              : snapshot.storyModel!.data![index].mlDescription,
          tag: snapshot.storyModel!.data![index].tag,
          imageUrl: ApiUrls.assetBaseUrl +
              snapshot.storyModel!.data![index].coverimage!,
          readTap: () => _handleStoryTap(index, snapshot, pdfSnapshot),
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
        title: snapshot.selectedLanguage == 'en'
            ? snapshot.storyModel!.data![index].name!
            : snapshot.storyModel!.data![index].mlTitle!,
        id: snapshot.storyModel!.data![index].id.toString(),
        imageUrl: ApiUrls.assetBaseUrl +
            snapshot.storyModel!.data![index].coverimage!,
        tag: snapshot.storyModel!.data![index].tag ?? '',
      ),
    );
    pdfSnapshot.setCurrentStory(
      snapshot.storyModel!.data![index].id,
      snapshot.selectedLanguage == 'en'
          ? snapshot.storyModel!.data![index].name
          : snapshot.storyModel!.data![index].mlTitle,
      ApiUrls.assetBaseUrl + snapshot.storyModel!.data![index].coverimage!,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}
