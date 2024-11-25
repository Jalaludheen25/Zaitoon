// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/screens/bookmark_screen/provider/bookmark_provider.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  @override
  void initState() {
    Future.microtask(() {
      final bookmarkProvider =
          Provider.of<BookmarkProvider>(context, listen: false);
      bookmarkProvider.loadBookmarks();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bookmarks',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: ColorClass.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer<BookmarkProvider>(
                    builder: (context, provider, child) {
                      return Text(
                        '${provider.bookmarks.length} saved stories',
                        style: const TextStyle(
                          fontSize: 16,
                          color: ColorClass.grey,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: Consumer<BookmarkProvider>(
                builder: (context, provider, child) {
                  if (provider.bookmarks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border_rounded,
                            size: 64,
                            color: ColorClass.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No bookmarks yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: ColorClass.grey.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your bookmarked stories will appear here',
                            style: TextStyle(
                              fontSize: 14,
                              color: ColorClass.grey.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.bookmarks.length,
                    itemBuilder: (context, index) {
                      final story = provider.bookmarks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: ColorClass.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Story Image
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              child: Image.network(
                                story.thumbnail,
                                width: 120,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Story Details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Tag
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        story.tag,
                                        style: const TextStyle(
                                          color: Colors.purple,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Title
                                    Text(
                                      story.title,
                                      style: const TextStyle(
                                        color: ColorClass.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Description
                                    // Text(
                                    //   story.description,
                                    //   maxLines: 2,
                                    //   overflow: TextOverflow.ellipsis,
                                    //   style: TextStyle(
                                    //     color: ColorClass.grey.withOpacity(0.8),
                                    //     fontSize: 14,
                                    //   ),
                                    // ),
                                    // const SizedBox(height: 12),
                                    // Action Buttons
                                    Row(
                                      children: [
                                        // Continue Reading Button
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              // Implement continue reading
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.purple,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text('Continue'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Remove Bookmark Button
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              provider.removeBookmark(story.id);
                                            },
                                            icon: const Icon(
                                              Icons.bookmark_remove,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
