// ignore_for_file: use_build_context_synchronously

import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/episode_screen.dart/episode_screen.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/home_screen/components/story_card.dart';
import 'package:zaitoon/screens/language_selection/language_selection.dart';
import 'package:zaitoon/screens/reading_screen/provider/story_provider.dart';
import 'package:zaitoon/screens/settings_screen/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    Future.microtask(() {
      HomeProvider homeProvider =
          Provider.of<HomeProvider>(context, listen: false);
      homeProvider.fetchStories();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.black,
      body: SafeArea(
        child: Column(
          children: [
            // Main Content
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with Emoji
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Zai Toon',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: ColorClass.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          navigateTo(
                            context: context,
                            route: const LanguageSelection(),
                          );
                        },
                        icon: Image.asset(
                          'assets/icons/language.png',
                          color: ColorClass.white,
                          height: 32,
                        ),
                      ),
                      const SizedBox(width: 5),
                      IconButton(
                        onPressed: () {
                          navigateTo(
                              context: context, route: const SettingsScreen());
                        },
                        icon: const Icon(
                          Icons.settings,
                          color: ColorClass.white,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Free Story Section
                  const Text(
                    'Read, imagine, and explore stories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorClass.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            // Main Content
            Expanded(
              flex: 2,
              child: Consumer2<HomeProvider, PdfProvider>(
                builder: (context, snapshot, pdfSnapshot, child) {
                  if (snapshot.isStoryLoading) {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }
                  if (snapshot.storyModel == null) {
                    return const Center(
                      child: Text('No Data Found'),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Determine number of columns based on screen width
                      int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio:
                              1.4, // Adjust this value to control card height
                        ),
                        itemCount: snapshot.storyModel!.data!.length,
                        itemBuilder: (context, index) {
                          void onTapFunction() {
                            navigateTo(
                              context: context,
                              route: EpisodeScreen(
                                title: snapshot.selectedLanguage == 'en'
                                    ? snapshot.storyModel!.data![index].name!
                                    : snapshot
                                        .storyModel!.data![index].mlTitle!,
                                id: snapshot.storyModel!.data![index].id
                                    .toString(),
                                imageUrl: ApiUrls.assetBaseUrl +
                                    snapshot
                                        .storyModel!.data![index].coverimage!,
                              ),
                            );
                            pdfSnapshot.setCurrentStory(
                              snapshot.storyModel!.data![index].id,
                              snapshot.selectedLanguage == 'en'
                                  ? snapshot.storyModel!.data![index].name
                                  : snapshot.storyModel!.data![index].mlTitle,
                              ApiUrls.assetBaseUrl +
                                  snapshot.storyModel!.data![index].coverimage!,
                            );
                          }

                          return StoryCard(
                            name: snapshot.selectedLanguage == 'en'
                                ? snapshot.storyModel!.data![index].name
                                : snapshot.storyModel!.data![index].mlTitle,
                            discription: snapshot.selectedLanguage == 'en'
                                ? snapshot.storyModel!.data![index].description
                                : snapshot
                                    .storyModel!.data![index].mlDescription,
                            tag: snapshot.storyModel!.data![index].tag,
                            imageUrl: ApiUrls.assetBaseUrl +
                                snapshot.storyModel!.data![index].coverimage!,
                            readTap: onTapFunction,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
