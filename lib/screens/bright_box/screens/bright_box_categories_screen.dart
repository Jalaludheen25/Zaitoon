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
import 'package:zaitoon/providers/theme_provider.dart';

class BrightBoxCategoriesScreen extends StatefulWidget {
  const BrightBoxCategoriesScreen({super.key});

  @override
  State<BrightBoxCategoriesScreen> createState() =>
      _BrightBoxCategoriesScreenState();
}

class _BrightBoxCategoriesScreenState extends State<BrightBoxCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<BrightBoxProvider>().loadCategories();
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
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              'Freedom fighters of india',
                              style: TextStyleClass.fredoka(
                                fontSize: 28,
                                color: ColorClass.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Did you know ?',
                            style: TextStyle(
                              fontSize: 16,
                              color: themeProvider.isDarkMode
                                  ? ColorClass.grey400
                                  : ColorClass.grey,
                            ),
                          ),
                        ],
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
                                : _buildCategoriesGrid(brightBoxProvider,
                                    homeProvider, themeProvider.isDarkMode),
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
              onPressed: () => provider.loadCategories(),
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

  Widget _buildCategoriesGrid(BrightBoxProvider brightBoxProvider,
      HomeProvider homeProvider, bool isDarkMode) {
    if (brightBoxProvider.categories.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: brightBoxProvider.categories.length,
      itemBuilder: (context, index) {
        final category = brightBoxProvider.categories[index];
        return _buildCategoryCard(category, homeProvider, isDarkMode);
      },
    );
  }

  Widget _buildCategoryCard(
      category, HomeProvider homeProvider, bool isDarkMode) {
    final title = _getCategoryTitle(category, homeProvider.selectedLanguage);
    debugPrint('Category: $title, Cover Image: ${category.coverImage}');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BrightBoxSubcategoriesScreen(
              category: category,
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
                      child: category.coverImage.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl:
                                  ApiUrls.assetBaseUrl + category.coverImage,
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
                                      ColorClass.primaryColor.withOpacity(0.3),
                                      ColorClass.primaryColor.withOpacity(0.1),
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
                                    ColorClass.primaryColor.withOpacity(0.3),
                                    ColorClass.primaryColor.withOpacity(0.1),
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
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? ColorClass.bg.withOpacity(0.5)
                      : Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(16)),
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
                            color: isDarkMode ? ColorClass.white : Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '8 Episode',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDarkMode ? ColorClass.grey400 : Colors.grey,
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

  // Helper method for multi-language support
  String _getCategoryTitle(category, String language) {
    switch (language) {
      case 'ml':
        return category.catTitleMl ?? category.catTitleEn ?? '';
      case 'hi':
        return category.catTitleHi ?? category.catTitleEn ?? '';
      case 'ur':
        return category.catTitleUr ?? category.catTitleEn ?? '';
      default: // 'en' or any other language
        return category.catTitleEn ?? '';
    }
  }
}
