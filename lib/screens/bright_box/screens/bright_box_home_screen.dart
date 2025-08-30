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

class BrightBoxHomeScreen extends StatefulWidget {
  const BrightBoxHomeScreen({super.key});

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
    return Scaffold(
      backgroundColor: ColorClass.black,
      body: SafeArea(
        child: Consumer2<BrightBoxProvider, HomeProvider>(
          builder: (context, brightBoxProvider, homeProvider, child) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(),
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
                  _buildContent(brightBoxProvider, homeProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Text(
            'Bright Box',
            style: TextStyleClass.poppinsSemiBold(
              fontSize: 24,
              color: ColorClass.white,
            ),
          ),
        ],
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
      ),
    );
  }

  Widget _buildContent(
      BrightBoxProvider brightBoxProvider, HomeProvider homeProvider) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Categories Section
          _buildSectionHeader('Categories', homeProvider),
          const SizedBox(height: 16),
          _buildCategoriesList(brightBoxProvider, homeProvider),
        ]),
      ),
    );
  }

  Widget _buildSectionHeader(String title, HomeProvider homeProvider) {
    return Text(
      title,
      style: TextStyleClass.poppinsSemiBold(
        fontSize: 20,
        color: ColorClass.white,
      ),
    );
  }

  Widget _buildCategoriesList(
      BrightBoxProvider brightBoxProvider, HomeProvider homeProvider) {
    if (brightBoxProvider.categories.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: brightBoxProvider.categories.map((category) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCategoryCard(category, homeProvider),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryCard(category, HomeProvider homeProvider) {
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
        height: 200, // Fixed height for larger cards like in the image
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
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
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyleClass.poppinsSemiBold(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Explore stories',
                      style: TextStyleClass.poppinsRegular(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            LucideIcons.box,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No content available',
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
