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
      backgroundColor: ColorClass.black,
      body: SafeArea(
        child: Consumer2<BrightBoxProvider, HomeProvider>(
          builder: (context, brightBoxProvider, homeProvider, child) {
            final categoryTitle = _getCategoryTitle(
                widget.category, homeProvider.selectedLanguage);

            return CustomScrollView(
              slivers: [
                _buildAppBar(categoryTitle),
                if (brightBoxProvider.isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ColorClass.primaryColor,
                      ),
                    ),
                  )
                else if (brightBoxProvider.error != null)
                  _buildErrorState(brightBoxProvider.error!, brightBoxProvider)
                else
                  _buildSubcategoriesList(brightBoxProvider, homeProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(String categoryTitle) {
    return SliverAppBar(
      leading: IconButton(
        icon: const Icon(
          LucideIcons.arrowLeft,
          color: ColorClass.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        categoryTitle,
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
                onPressed: () => provider.loadSubcategories(widget.category.id),
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

  Widget _buildSubcategoriesList(
      BrightBoxProvider brightBoxProvider, HomeProvider homeProvider) {
    if (brightBoxProvider.subcategories.isEmpty) {
      return _buildEmptyState();
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final subcategory = brightBoxProvider.subcategories[index];
            return _buildSubcategoryCard(subcategory, homeProvider);
          },
          childCount: brightBoxProvider.subcategories.length,
        ),
      ),
    );
  }

  Widget _buildSubcategoryCard(
      BrightBoxSubcategory subcategory, HomeProvider homeProvider) {
    final title =
        _getSubcategoryTitle(subcategory, homeProvider.selectedLanguage);
    debugPrint('Subcategory: $title, Cover Image: ${subcategory.coverImage}');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ColorClass.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ColorClass.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: ColorClass.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: subcategory.coverImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl:
                              ApiUrls.assetBaseUrl + subcategory.coverImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (context, url) {
                            debugPrint(
                                'Loading subcategory image: ${ApiUrls.assetBaseUrl}${subcategory.coverImage}');
                            return const Icon(
                              LucideIcons.folderOpen,
                              color: ColorClass.primaryColor,
                              size: 24,
                            );
                          },
                          errorWidget: (context, url, error) {
                            debugPrint(
                                'Subcategory image error for ${subcategory.coverImage}: $error');
                            return const Icon(
                              LucideIcons.folderOpen,
                              color: ColorClass.primaryColor,
                              size: 24,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        LucideIcons.folderOpen,
                        color: ColorClass.primaryColor,
                        size: 24,
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
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to explore stories',
                      style: TextStyleClass.poppinsRegular(
                        fontSize: 12,
                        color: ColorClass.white.withOpacity(0.7),
                      ),
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
            Icon(
              LucideIcons.clock,
              size: 64,
              color: ColorClass.primaryColor.withOpacity(0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'Coming Soon',
              style: TextStyleClass.poppinsSemiBold(
                fontSize: 24,
                color: ColorClass.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Exciting new content is on the way!\nStay tuned for amazing stories.',
              style: TextStyleClass.poppinsRegular(
                fontSize: 16,
                color: ColorClass.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for multi-language support
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

  String _getSubcategoryTitle(
      BrightBoxSubcategory subcategory, String language) {
    switch (language) {
      case 'ml':
        return subcategory.subcatTitleMl ?? subcategory.subcatTitleEn ?? '';
      case 'hi':
        return subcategory.subcatTitleHi ?? subcategory.subcatTitleEn ?? '';
      case 'ur':
        return subcategory.subcatTitleUr ?? subcategory.subcatTitleEn ?? '';
      default: // 'en' or any other language
        return subcategory.subcatTitleEn ?? '';
    }
  }
}
