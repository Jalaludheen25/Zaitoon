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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';
import 'package:zaitoon/screens/version_check/force_udpate_dialog.dart';
import 'package:zaitoon/screens/version_check/provider/version_check_provider.dart';

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
      homeProvider.fetchStories().then((value) {
        checkForUpdates();
      });
    });
    super.initState();
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
            // Main Content
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with Emoji
                  Consumer<UserDataProvider>(
                    builder: (context, data, child) => Row(
                      children: [
                        Expanded(
                          child: Text(
                              "hello, ${data.name ?? ''} 👋\nLet's read some stories",
                              style: TextStyleClass.poppinsSemiBold(
                                fontSize: 18,
                                color: ColorClass.white,
                              )),
                        ),
                        IconButton(
                          onPressed: () {
                            navigatePR(
                              context: context,
                              screen: const LanguageSelection(),
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
                            context
                                .read<NavigationProvider>()
                                .setIndex(3); // 3 is the index for settings
                          },
                          icon: const Icon(
                            Icons.settings,
                            color: ColorClass.white,
                          ),
                        )
                      ],
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
                              1.2, // Adjust this value to control card height
                        ),
                        itemCount: snapshot.storyModel!.data!.length,
                        itemBuilder: (context, index) {
                          void onTapFunction() {
                            navigatePR(
                              context: context,
                              screen: EpisodeScreen(
                                title: snapshot.selectedLanguage == 'en'
                                    ? snapshot.storyModel!.data![index].name!
                                    : snapshot
                                        .storyModel!.data![index].mlTitle!,
                                id: snapshot.storyModel!.data![index].id
                                    .toString(),
                                imageUrl: ApiUrls.assetBaseUrl +
                                    snapshot
                                        .storyModel!.data![index].coverimage!,
                                tag:
                                    snapshot.storyModel!.data![index].tag ?? '',
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
