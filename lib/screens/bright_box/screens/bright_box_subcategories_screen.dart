import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/bright_box/provider/bright_box_provider.dart';
import 'package:zaitoon/screens/bright_box/models/bright_box_models.dart';
import 'package:zaitoon/screens/bright_box/screens/bright_box_stories_screen.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';

class BrightBoxSubcategoriesScreen extends StatefulWidget {
  final BrightBoxCategory category;

  const BrightBoxSubcategoriesScreen({
    super.key,
    required this.category,
  });

  @override
  State<BrightBoxSubcategoriesScreen> createState() =>
      _BrightBoxSubcategoriesScreenState();
}

class _BrightBoxSubcategoriesScreenState
    extends State<BrightBoxSubcategoriesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final provider = context.read<BrightBoxProvider>();
        provider.clearSubcategories();
        provider.loadSubcategories(widget.category.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.white,
      body: SafeArea(
        child: Consumer2<BrightBoxProvider, HomeProvider>(
          builder: (context, brightBoxProvider, homeProvider, child) {
            final categoryTitle = _getCategoryTitle(
                widget.category, homeProvider.selectedLanguage);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Back Button with gradient
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                ColorClass.grad1,
                                ColorClass.grad2,
                                ColorClass.grad3
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: ColorClass.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 4), // Closer gap

                      // Category Title with gradient
                      Expanded(
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
                            categoryTitle,
                            style: TextStyleClass.fredoka(
                              fontSize: 28,
                              color: ColorClass.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Subtitle
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: const Text(
                    'Did you know ?',
                    style: TextStyle(
                      fontSize: 16,
                      color: ColorClass.grey,
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: brightBoxProvider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: ColorClass.primaryColor,
                            ),
                          )
                        : brightBoxProvider.error != null
                            ? _buildErrorState(
                                brightBoxProvider.error!, brightBoxProvider)
                            : RefreshIndicator(
                                onRefresh: () async {
                                  await brightBoxProvider
                                      .loadSubcategories(widget.category.id);
                                },
                                color: ColorClass.primaryColor,
                                child: _buildSubcategoriesGrid(
                                    brightBoxProvider, homeProvider),
                              ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, BrightBoxProvider provider) {
    return Center(
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
              style: TextStyleClass.fredoka(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.loadSubcategories(widget.category.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorClass.primaryColor,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoriesGrid(
      BrightBoxProvider brightBoxProvider, HomeProvider homeProvider) {
    if (brightBoxProvider.subcategories.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: brightBoxProvider.subcategories.length,
      itemBuilder: (context, index) {
        final subcategory = brightBoxProvider.subcategories[index];
        return _buildSubcategoryCard(subcategory, homeProvider);
      },
    );
  }

  Widget _buildSubcategoryCard(
      BrightBoxSubcategory subcategory, HomeProvider homeProvider) {
    final title =
        _getSubcategoryTitle(subcategory, homeProvider.selectedLanguage);
    debugPrint('Subcategory: $title, Cover Image: ${subcategory.coverImage}');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BrightBoxStoriesScreen(
              subcategory: subcategory,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
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
                    // Background Image
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: subcategory.coverImage.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl:
                                  ApiUrls.assetBaseUrl + subcategory.coverImage,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange.withOpacity(0.7),
                                      Colors.white.withOpacity(0.4),
                                      Colors.green.withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                ),
                                child: const Center(
                                  child: Icon(
                                    LucideIcons.flag,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange.withOpacity(0.7),
                                      Colors.white.withOpacity(0.4),
                                      Colors.green.withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                ),
                                child: const Center(
                                  child: Icon(
                                    LucideIcons.flag,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.orange.withOpacity(0.7),
                                    Colors.white.withOpacity(0.4),
                                    Colors.green.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                              ),
                              child: const Center(
                                child: Icon(
                                  LucideIcons.flag,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                    ),

                    // Bookmark Button (Top Right)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.bookmark,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content Section
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyleClass.fredoka(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Episodes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.clock,
            size: 64,
            color: ColorClass.primaryColor.withOpacity(0.6),
          ),
          const SizedBox(height: 24),
          Text(
            'Coming Soon',
            style: TextStyleClass.fredoka(
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Exciting new content is on the way!\nStay tuned for amazing stories.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods for multi-language support
  String _getCategoryTitle(category, String language) {
    switch (language) {
      case 'ml':
        return category.catTitleMl.isNotEmpty
            ? category.catTitleMl
            : category.catTitleEn;
      case 'hi':
        return category.catTitleHi.isNotEmpty
            ? category.catTitleHi
            : category.catTitleEn;
      case 'ur':
        return category.catTitleUr.isNotEmpty
            ? category.catTitleUr
            : category.catTitleEn;
      default: // 'en' or any other language
        return category.catTitleEn;
    }
  }

  String _getSubcategoryTitle(
      BrightBoxSubcategory subcategory, String language) {
    switch (language) {
      case 'ml':
        return subcategory.subcatTitleMl.isNotEmpty
            ? subcategory.subcatTitleMl
            : subcategory.subcatTitleEn;
      case 'hi':
        return subcategory.subcatTitleHi.isNotEmpty
            ? subcategory.subcatTitleHi
            : subcategory.subcatTitleEn;
      case 'ur':
        return subcategory.subcatTitleUr.isNotEmpty
            ? subcategory.subcatTitleUr
            : subcategory.subcatTitleEn;
      default: // 'en' or any other language
        return subcategory.subcatTitleEn;
    }
  }
}
