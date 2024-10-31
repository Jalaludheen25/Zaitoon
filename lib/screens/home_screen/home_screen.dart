// ignore_for_file: use_build_context_synchronously

import 'package:d4tales/constants/app_urls.dart';
import 'package:d4tales/helper/navigation_helper.dart';
import 'package:d4tales/screens/home_screen/provider/home_provider.dart';
import 'package:d4tales/screens/home_screen/story_reading_screen.dart';
import 'package:d4tales/screens/language_selection/language_selection.dart';
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
  final categories = [
    {'name': 'Bedtime', 'color': Colors.indigo[400]},
    {'name': 'Adventure', 'color': Colors.orange[400]},
    {'name': 'Animals', 'color': Colors.green[400]},
    {'name': 'Fantasy', 'color': Colors.purple[400]},
    {'name': 'Educational', 'color': Colors.blue[400]},
    {'name': 'Fairy Tales', 'color': Colors.pink[400]},
    {'name': 'Friendship', 'color': Colors.teal[400]},
    {'name': 'Mystery', 'color': Colors.amber[400]},
  ];

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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with Emoji
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'A story earns a goodnight kiss',
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
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Free Story Section
                    const Text(
                      'Free Story of the Day',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              right: 8.0,
                              left: index == 0 ? 0 : 0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: categories[index]['color'] as Color?,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    // Handle category tap
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    child: Center(
                                      child: Text(
                                        categories[index]['name'] as String,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Main Content
            Expanded(
                flex: 3,
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
                                  snapshot.storyModel!.data.length, (index) {
                                return
                                    // Story Card with Bow
                                    InkWell(
                                  onTap: () {
                                    navigateTo(
                                      context: context,
                                      route: PDFViewerScreen(
                                        pdfUrl: ApiUrls.assetBaseUrl +
                                            snapshot.storyModel!.data[index]
                                                .storyFile,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 24),
                                    height: 300,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF90EE90),
                                      // ignore: prefer_const_constructors
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          ApiUrls.assetBaseUrl +
                                              snapshot.storyModel!.data[index]
                                                  .thumbnail,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Tap and Get Button
                                        Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.7),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: const Text(
                                              'Tap and Read',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                )),
          ],
        ),
      ),
    );
  }
}
