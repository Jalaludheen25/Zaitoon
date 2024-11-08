// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/home_screen/home_screen.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/reading_screen/story_reader_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EpisodeScreen extends StatefulWidget {
  const EpisodeScreen({super.key, required this.id, required this.title});
  final String id;
  final String title;
  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  @override
  void initState() {
    Future.microtask(() {
      HomeProvider homeProvider =
          Provider.of<HomeProvider>(context, listen: false);
      homeProvider.fetchEpisodes(widget.id);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        navigatePRTo(context, const HomeScreen());
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => navigatePRTo(context, const HomeScreen()),
          ),
          title: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Consumer<HomeProvider>(
            builder: (context, snapshot, _) => snapshot.episodeModel == null
                ? const Center(child: CupertinoActivityIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            _buildFilterChip(
                                'Episodes ${snapshot.episodeModel!.data!.length}',
                                icon: Icons.book_rounded),
                          ],
                        ),
                      ),

                      // Stories List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: snapshot.episodeModel!.data!.length,
                          itemBuilder: (context, index) {
                            final story = snapshot.episodeModel!.data![index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  // Story Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[800],
                                      child: CachedNetworkImage(
                                          imageUrl: ApiUrls.assetBaseUrl +
                                              story.coverImage!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const CupertinoActivityIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Story Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.selectedLanguage == 'en'
                                              ? story.storyTile!
                                              : story.mlTitle!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${story.uploadDate} ',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time,
                                                size: 16,
                                                color: Colors.grey[400]),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${story.readMinutes} min',
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: () {
                                      navigatePRTo(
                                        context,
                                        StoryReadingScreen(
                                          pdfUrl:
                                              snapshot.selectedLanguage == 'en'
                                                  ? ApiUrls.assetBaseUrl +
                                                      snapshot
                                                          .episodeModel!
                                                          .data![index]
                                                          .storyFile!
                                                  : ApiUrls.assetBaseUrl +
                                                      snapshot
                                                          .episodeModel!
                                                          .data![index]
                                                          .mlStoryFile!,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Read',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {IconData? icon}) {
    return FilterChip(
      label: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          icon,
          size: 18,
          color: Colors.white,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ]),
      onSelected: (selected) {},
      backgroundColor: Colors.grey[900],
      selectedColor: Colors.green,
      checkmarkColor: Colors.transparent,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
