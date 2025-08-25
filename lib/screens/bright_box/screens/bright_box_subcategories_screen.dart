import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/bright_box/provider/bright_box_provider.dart';
import 'package:zaitoon/screens/bright_box/models/bright_box_models.dart';
import 'package:zaitoon/screens/bright_box/screens/bright_box_stories_screen.dart';

class BrightBoxSubcategoriesScreen extends StatefulWidget {
  final BrightBoxCategory category;

  const BrightBoxSubcategoriesScreen({
    super.key,
    required this.category,
  });

  @override
  State<BrightBoxSubcategoriesScreen> createState() => _BrightBoxSubcategoriesScreenState();
}

class _BrightBoxSubcategoriesScreenState extends State<BrightBoxSubcategoriesScreen> {
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
        child: Consumer<BrightBoxProvider>(
          builder: (context, provider, child) {
            final categoryTitle = provider.currentLanguage == 'en' 
                ? widget.category.catTitleEn 
                : widget.category.catTitleMl;

            return CustomScrollView(
              slivers: [
                _buildAppBar(categoryTitle),
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
                  _buildSubcategoriesList(provider),
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

  Widget _buildSubcategoriesList(BrightBoxProvider provider) {
    if (provider.subcategories.isEmpty) {
      return _buildEmptyState();
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final subcategory = provider.subcategories[index];
            return _buildSubcategoryCard(subcategory, provider);
          },
          childCount: provider.subcategories.length,
        ),
      ),
    );
  }

  Widget _buildSubcategoryCard(BrightBoxSubcategory subcategory, BrightBoxProvider provider) {
    final title = provider.currentLanguage == 'en' 
        ? subcategory.subcatTitleEn 
        : subcategory.subcatTitleMl;

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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorClass.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
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
            const Icon(
              LucideIcons.folderOpen,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No subcategories available',
              style: TextStyleClass.poppinsMedium(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new content!',
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
}