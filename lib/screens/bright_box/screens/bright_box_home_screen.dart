import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/screens/bright_box/provider/bright_box_provider.dart';
import 'package:zaitoon/screens/bright_box/screens/bright_box_subcategories_screen.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/bottom_navigation/bottom_navigation.dart';

import 'package:zaitoon/screens/bookmark_screen/bookmark_screen.dart';
import 'package:zaitoon/providers/theme_provider.dart';

class BrightBoxHomeScreen extends StatefulWidget {
  final String? sourceScreen; // 'home' or 'bookmark'

  const BrightBoxHomeScreen({super.key, this.sourceScreen});

  @override
  State<BrightBoxHomeScreen> createState() => _BrightBoxHomeScreenState();
}

class _BrightBoxHomeScreenState extends State<BrightBoxHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final provider = context.read<BrightBoxProvider>();
        provider.loadCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor:
              themeProvider.isDarkMode ? ColorClass.black : ColorClass.white,
          body: SafeArea(
            child: Consumer2<BrightBoxProvider, HomeProvider>(
              builder: (context, brightBoxProvider, homeProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // Back Button with gradient
                          GestureDetector(
                            onTap: () {
                              if (widget.sourceScreen == 'bookmark') {
                                // Set the return category to "Stories" before navigating back
                                BookmarkScreen.setReturnCategory("Stories");
                                // Navigate back to bottom navigation with bookmark tab selected (index 3)
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BottomNavigationScreen(
                                            currentIndex: 3),
                                  ),
                                );
                              } else {
                                // Navigate back to home screen (index 0)
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BottomNavigationScreen(
                                            currentIndex: 0),
                                  ),
                                );
                              }
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

                          // Bright Box Title with gradient
                          ShaderMask(
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
                              'Bright Box',
                              style: TextStyleClass.fredoka(
                                fontSize: 30,
                                color: ColorClass.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16),
                      child: Text(
                        'Step Into the Past, Learn for the Future',
                        style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.isDarkMode
                              ? ColorClass.grey400
                              : ColorClass.grey,
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
                                ? _buildErrorState(brightBoxProvider.error!,
                                    brightBoxProvider, themeProvider.isDarkMode)
                                : RefreshIndicator(
                                    onRefresh: () async {
                                      await brightBoxProvider.loadCategories();
                                    },
                                    color: ColorClass.primaryColor,
                                    child: _buildCategoriesList(
                                        brightBoxProvider,
                                        homeProvider,
                                        themeProvider.isDarkMode),
                                  ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(
      String error, BrightBoxProvider provider, bool isDarkMode) {
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
                color: isDarkMode ? ColorClass.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? ColorClass.grey400 : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                provider.loadCategories();
              },
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

  Widget _buildCategoriesList(BrightBoxProvider brightBoxProvider,
      HomeProvider homeProvider, bool isDarkMode) {
    if (brightBoxProvider.categories.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return ListView.builder(
      itemCount: brightBoxProvider.categories.length,
      itemBuilder: (context, index) {
        final category = brightBoxProvider.categories[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCategoryCard(category, homeProvider, isDarkMode),
        );
      },
    );
  }

  Widget _buildCategoryCard(
      category, HomeProvider homeProvider, bool isDarkMode) {
    final title = _getCategoryTitle(category, homeProvider.selectedLanguage);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BrightBoxSubcategoriesScreen(category: category),
          ),
        );
      },
      child: Container(
        height: 200,
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
        child: Stack(
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: category.coverImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: ApiUrls.assetBaseUrl + category.coverImage,
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
                              ColorClass.primaryColor.withOpacity(0.3),
                              ColorClass.primaryColor.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.box,
                            color: ColorClass.primaryColor,
                            size: 48,
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
                              ColorClass.primaryColor.withOpacity(0.3),
                              ColorClass.primaryColor.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.box,
                            color: ColorClass.primaryColor,
                            size: 48,
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
                            ColorClass.primaryColor.withOpacity(0.3),
                            ColorClass.primaryColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.box,
                          color: ColorClass.primaryColor,
                          size: 48,
                        ),
                      ),
                    ),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(16)),
                  color: isDarkMode
                      ? ColorClass.bg.withOpacity(0.5)
                      : Colors.white.withOpacity(0.9),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyleClass.fredoka(
                        fontSize: 20,
                        color: isDarkMode ? ColorClass.white : Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Explore stories',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? ColorClass.grey400 : Colors.grey,
                      ),
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

  Widget _buildEmptyState(bool isDarkMode) {
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
              color: isDarkMode ? ColorClass.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Exciting new content is on the way!\nStay tuned for amazing stories.',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? ColorClass.grey400 : Colors.grey,
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
      default:
        return category.catTitleEn;
    }
  }
}
