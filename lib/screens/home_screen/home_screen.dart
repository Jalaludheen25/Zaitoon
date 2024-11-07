// ignore_for_file: use_build_context_synchronously

import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/episode_screen.dart/episode_screen.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/reading_screen/story_card.dart';
import 'package:zaitoon/screens/language_selection/language_selection.dart';
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
  // List of categories with their colors

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
      backgroundColor: Colors.black,
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
                          'Zai Toon: Read, Dream, Explore',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            navigateTo(
                                context: context,
                                route: const LanguageSelection());
                          },
                          icon: Image.asset(
                            'assets/icons/language.png',
                            color: Colors.white,
                            height: 32,
                          )),
                      const SizedBox(
                        width: 5,
                      ),
                      IconButton(
                        onPressed: () {
                          navigatePRTo(context, const SettingsScreen());
                        },
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
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
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            // Main Content
            Expanded(
                flex: 2,
                child: Consumer<HomeProvider>(
                  builder: (context, snapshot, child) => snapshot.isStoryLoading
                      ? const Center(
                          child: CupertinoActivityIndicator(),
                        )
                      : snapshot.storyModel == null
                          ? const Center(
                              child: Text('No Data Found'),
                            )
                          : ListView(
                              padding: const EdgeInsets.all(16),
                              children: List.generate(
                                  snapshot.storyModel!.data!.length, (index) {
                                void onTapFunction() {
                                  navigateTo(
                                      context: context,
                                      route: EpisodeScreen(
                                        title: snapshot.selectedLanguage == 'en'
                                            ? snapshot
                                                .storyModel!.data![index].name!
                                            : snapshot.storyModel!.data![index]
                                                .mlTitle!,
                                        id: snapshot.storyModel!.data![index].id
                                            .toString(),
                                      )
                                      // PDFViewerScreen(
                                      //   pdfUrl: ApiUrls.assetBaseUrl +
                                      //       snapshot.storyModel!.data[index]
                                      //           .storyFile,
                                      // ),
                                      );
                                }

                                return
                                    // Story Card with Bow
                                    StoryCard(
                                        name: snapshot.selectedLanguage == 'en'
                                            ? snapshot
                                                .storyModel!.data![index].name
                                            : snapshot.storyModel!.data![index]
                                                .mlTitle,
                                        discription:
                                            snapshot.selectedLanguage == 'en'
                                                ? snapshot.storyModel!
                                                    .data![index].description
                                                : snapshot.storyModel!
                                                    .data![index].mlDescription,
                                        tag: snapshot
                                            .storyModel!.data![index].tag,
                                        imageUrl: ApiUrls.assetBaseUrl +
                                            snapshot.storyModel!.data![index]
                                                .coverimage!,
                                        readTap: onTapFunction);
                              }),
                            ),
                )),
          ],
        ),
      ),
    );
  }
}
