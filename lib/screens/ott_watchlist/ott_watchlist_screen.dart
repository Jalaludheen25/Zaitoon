// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/ott_watchlist/provider/ott_watchlist_provider.dart';
import 'package:zaitoon/screens/ott_watchlist/models/ott_content_model.dart';
import 'package:zaitoon/utils/cache_manager.dart';

class OttWatchlistScreen extends StatefulWidget {
  const OttWatchlistScreen({super.key});

  @override
  State<OttWatchlistScreen> createState() => _OttWatchlistScreenState();
}

class _OttWatchlistScreenState extends State<OttWatchlistScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<OttWatchlistProvider>().loadWatchlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    ColorClass.grad1,
                    ColorClass.grad2,
                    ColorClass.grad3,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'Watchlist',
                  style: TextStyleClass.fredoka(
                    fontSize: 24,
                    color: ColorClass.white,
                  ),
                ),
              ),
            ),

            // Watchlist Content
            Expanded(
              child: Consumer<OttWatchlistProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ColorClass.primaryColor,
                      ),
                    );
                  }

                  if (provider.watchlist.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.tv,
                            size: 64,
                            color: ColorClass.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your watchlist is empty',
                            style: TextStyleClass.fredoka(
                              fontSize: 18,
                              color: ColorClass.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add movies and shows to watch later',
                            style: TextStyleClass.fredoka(
                              fontSize: 14,
                              color: ColorClass.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 16,
                        childAspectRatio:
                            1.6, // Wider aspect ratio for the cards
                      ),
                      itemCount: provider.watchlist.length,
                      itemBuilder: (context, index) {
                        final content = provider.watchlist[index];
                        return OttContentCard(
                          content: content,
                          onTap: () => _playContent(content),
                          onRemove: () => _removeFromWatchlist(content),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playContent(OttContentModel content) async {
    try {
      final Uri youtubeUrl = Uri.parse(content.videoUrl);

      // Try to launch the YouTube URL
      if (await canLaunchUrl(youtubeUrl)) {
        await launchUrl(
          youtubeUrl,
          mode: LaunchMode
              .externalApplication, // This will open in YouTube app if available
        );
      } else {
        // Fallback: show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open ${content.title}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Handle any errors
      debugPrint('Error launching YouTube URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening video: ${content.title}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeFromWatchlist(OttContentModel content) {
    context.read<OttWatchlistProvider>().removeFromWatchlist(content.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${content.title}" from watchlist'),
        backgroundColor: Colors.red.withOpacity(0.8),
      ),
    );
  }
}

class OttContentCard extends StatelessWidget {
  final OttContentModel content;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const OttContentCard({
    super.key,
    required this.content,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: ColorClass.white,
          boxShadow: [
            BoxShadow(
              color: ColorClass.grey400.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    // Main Image
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: CachedNetworkImage(
                        imageUrl: content.thumbnail,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => Container(
                          color: ColorClass.grey400.withOpacity(0.2),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: ColorClass.grey,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: ColorClass.grey400.withOpacity(0.2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                color: ColorClass.grey,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Video Thumbnail',
                                style: TextStyleClass.poppinsRegular(
                                  fontSize: 12,
                                  color: ColorClass.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        cacheManager: CustomCacheManager.instance,
                      ),
                    ),

                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ColorClass.transparent,
                            ColorClass.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),

                    // Play button in center
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: ColorClass.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: ColorClass.black.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: ColorClass.black,
                          size: 36,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Details Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: ColorClass.white,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    content.title,
                    style: TextStyleClass.poppinsSemiBold(
                      fontSize: 18,
                      color: ColorClass.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${content.year} • ${content.genre} • ${content.duration}',
                    style: TextStyleClass.poppinsRegular(
                      fontSize: 14,
                      color: ColorClass.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
