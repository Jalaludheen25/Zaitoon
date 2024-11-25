// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/bookmark_screen/provider/bookmark_provider.dart';
import 'package:zaitoon/screens/bottom_navigation/bottom_navigation.dart';
import 'package:zaitoon/screens/home_screen/models/episode_model.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/reading_screen/story_reader_page.dart';

class EpisodeScreen extends StatefulWidget {
  const EpisodeScreen({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String imageUrl;

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Consumer<HomeProvider>(
          builder: (context, snapshot, _) => snapshot.episodeModel == null
              ? const Center(child: CupertinoActivityIndicator())
              : CustomScrollView(
                  slivers: [
                    // Custom App Bar (unchanged)
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      expandedHeight: 300,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            snapshot.episodeModel!.data!.isNotEmpty
                                ? Image.network(
                                    widget.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(color: ColorClass.grey);
                                    },
                                  )
                                : Container(color: Colors.grey[900]),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                    Colors.black,
                                  ],
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
                                  Text(
                                    widget.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${snapshot.episodeModel!.data!.length} episodes • ${snapshot.episodeModel!.data!.fold(0, (sum, item) => sum + (int.tryParse(item.readMinutes ?? "0") ?? 0))} minutes',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              Colors.black.withOpacity(0.2)),
                        ),
                        color: Colors.white,
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                const BottomNavigationScreen(),
                          ),
                        ),
                      ),
                    ),

                    // Enhanced Episodes List
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final episode = snapshot.episodeModel!.data![index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _EpisodeTile(
                                episode: episode,
                                index: index,
                                selectedLanguage: snapshot.selectedLanguage,
                                onTap: () => navigatePR(
                                  context,
                                  StoryReadingScreen(
                                    pdfUrl: snapshot.selectedLanguage == 'en'
                                        ? ApiUrls.assetBaseUrl +
                                            episode.storyFile!
                                        : ApiUrls.assetBaseUrl +
                                            episode.mlStoryFile!,
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: snapshot.episodeModel!.data!.length,
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

class _EpisodeTile extends StatelessWidget {
  final EpisodeData episode;
  final int index;
  final String selectedLanguage;
  final VoidCallback onTap;

  const _EpisodeTile({
    required this.episode,
    required this.index,
    required this.selectedLanguage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'episode_${episode.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[900]!,
                  Colors.grey[850]!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Episode Number

                  // Episode Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: ApiUrls.assetBaseUrl + episode.coverImage!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.error_outline,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Episode Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedLanguage == 'en'
                              ? episode.storyTile!
                              : episode.mlTitle!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.white54,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${episode.readMinutes} min',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.white54,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              episode.uploadDate ?? 'N/A',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontFamily: 'Poppins',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Play Button
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chrome_reader_mode_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  BookmarkButton(
                    id: episode.id.toString(),
                    thumbnail: episode.coverImage!,
                    title: selectedLanguage == 'en'
                        ? episode.storyTile!
                        : episode.mlTitle!,
                    fileUrl: selectedLanguage == 'en'
                        ? episode.storyFile!
                        : episode.mlStoryFile!,
                    tag: 'episode_${episode.id}',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BookmarkButton extends StatelessWidget {
  final String id;
  final String thumbnail;
  final String title;
  final String fileUrl;
  final String tag;

  const BookmarkButton({
    super.key,
    required this.id,
    required this.thumbnail,
    required this.title,
    required this.fileUrl,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkProvider>(
      builder: (context, bookmarkProvider, child) {
        final isBookmarked = bookmarkProvider.isBookmarked(id);

        return GestureDetector(
          onTap: () async {
            if (isBookmarked) {
              await bookmarkProvider.removeBookmark(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Removed from bookmarks'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            } else {
              await bookmarkProvider.addBookmark(
                id: id,
                thumbnail: thumbnail,
                title: title,
                fileUrl: fileUrl,
                tag: tag,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to bookmarks'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            }
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isBookmarked ? LucideIcons.bookMarked : LucideIcons.bookmark,
              color: Colors.white,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}
