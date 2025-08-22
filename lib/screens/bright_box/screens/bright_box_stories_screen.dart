import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/bright_box/provider/bright_box_provider.dart';
import 'package:zaitoon/screens/bright_box/models/bright_box_models.dart';
import 'package:zaitoon/screens/reading_screen/story_reader_page.dart';
import 'package:zaitoon/constants/app_urls.dart';

class BrightBoxStoriesScreen extends StatefulWidget {
  final BrightBoxSubcategory subcategory;

  const BrightBoxStoriesScreen({
    super.key,
    required this.subcategory,
  });

  @override
  State<BrightBoxStoriesScreen> createState() => _BrightBoxStoriesScreenState();
}

class _BrightBoxStoriesScreenState extends State<BrightBoxStoriesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<BrightBoxProvider>();
      provider.clearStories();
      provider.loadStories(widget.subcategory.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.black,
      body: SafeArea(
        child: Consumer<BrightBoxProvider>(
          builder: (context, provider, child) {
            final subcategoryTitle = provider.currentLanguage == 'en' 
                ? widget.subcategory.subcatTitleEn 
                : widget.subcategory.subcatTitleMl;

            return CustomScrollView(
              slivers: [
                _buildAppBar(subcategoryTitle),
                if (provider.isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ColorClass.primaryColor,
                      ),
                    ),
                  )
                else if (provider.error != null)
                  _buildErrorState(provider.error!, provider)
                else
                  _buildStoriesList(provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(String subcategoryTitle) {
    return SliverAppBar(
      leading: IconButton(
        icon: const Icon(
          LucideIcons.arrowLeft,
          color: ColorClass.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        subcategoryTitle,
        style: TextStyleClass.poppinsSemiBold(
          fontSize: 20,
          color: ColorClass.white,
        ),
      ),
      backgroundColor: ColorClass.black,
      floating: true,
      pinned: false,
      elevation: 0,
    );
  }

  Widget _buildErrorState(String error, BrightBoxProvider provider) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.alertCircle,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: TextStyleClass.poppinsSemiBold(
                  fontSize: 18,
                  color: ColorClass.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: TextStyleClass.poppinsRegular(
                  fontSize: 14,
                  color: ColorClass.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => provider.loadStories(widget.subcategory.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorClass.primaryColor,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesList(BrightBoxProvider provider) {
    if (provider.stories.isEmpty) {
      return _buildEmptyState();
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final story = provider.stories[index];
            return _buildStoryCard(story, provider, index);
          },
          childCount: provider.stories.length,
        ),
      ),
    );
  }

  Widget _buildStoryCard(BrightBoxStory story, BrightBoxProvider provider, int index) {
    final title = provider.currentLanguage == 'en' 
        ? story.storyTitleEn 
        : story.storyTitleMl;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          // Get the story file URL based on current language
          final storyFileId = provider.currentLanguage == 'en' 
              ? story.storyEn 
              : story.storyMl;
          
          // Construct the PDF URL
          final pdfUrl = '${ApiUrls.assetBaseUrl}$storyFileId';
          
          // Get the story title based on current language
          final storyTitle = provider.currentLanguage == 'en' 
              ? story.storyTitleEn 
              : story.storyTitleMl;
          
          // Navigate to PDF reader
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoryReadingScreen(
                pdfUrl: pdfUrl,
                id: story.id.toString(),
                title: storyTitle,
                thumbnail: '', // No thumbnail for Bright Box stories
                tag: 'bright_box',
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorClass.primaryColor.withOpacity(0.1),
                ColorClass.primaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ColorClass.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorClass.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyleClass.poppinsBold(
                    fontSize: 18,
                    color: ColorClass.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyleClass.poppinsSemiBold(
                        fontSize: 16,
                        color: ColorClass.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          color: ColorClass.white.withOpacity(0.6),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(story.dateCreated),
                          style: TextStyleClass.poppinsRegular(
                            fontSize: 12,
                            color: ColorClass.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: ColorClass.white.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.bookOpen,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No stories available',
              style: TextStyleClass.poppinsMedium(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new stories!',
              style: TextStyleClass.poppinsRegular(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown date';
    }
  }
}