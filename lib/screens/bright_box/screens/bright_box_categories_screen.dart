import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/bright_box/provider/bright_box_provider.dart';
import 'package:zaitoon/screens/bright_box/screens/bright_box_subcategories_screen.dart';

class BrightBoxCategoriesScreen extends StatefulWidget {
  const BrightBoxCategoriesScreen({super.key});

  @override
  State<BrightBoxCategoriesScreen> createState() => _BrightBoxCategoriesScreenState();
}

class _BrightBoxCategoriesScreenState extends State<BrightBoxCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BrightBoxProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.black,
      body: SafeArea(
        child: Consumer<BrightBoxProvider>(
          builder: (context, provider, child) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(),
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
                  _buildCategoriesList(provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false, // Remove back button
      title: Row(
        children: [
          Text(
            'Bright Box',
            style: TextStyleClass.poppinsSemiBold(
              fontSize: 20,
              color: ColorClass.white,
            ),
          ),
        ],
      ),
      backgroundColor: ColorClass.black,
      floating: true,
      pinned: false,
      elevation: 0,
      actions: [
        Consumer<BrightBoxProvider>(
          builder: (context, provider, child) {
            return PopupMenuButton<String>(
              icon: const Icon(
                LucideIcons.globe,
                color: ColorClass.white,
              ),
              onSelected: (String language) {
                provider.setLanguage(language);
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'en',
                  child: Row(
                    children: [
                      Icon(
                        provider.currentLanguage == 'en' 
                            ? LucideIcons.check 
                            : LucideIcons.circle,
                        size: 16,
                        color: provider.currentLanguage == 'en' 
                            ? Colors.green 
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      const Text('English'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'ml',
                  child: Row(
                    children: [
                      Icon(
                        provider.currentLanguage == 'ml' 
                            ? LucideIcons.check 
                            : LucideIcons.circle,
                        size: 16,
                        color: provider.currentLanguage == 'ml' 
                            ? Colors.green 
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      const Text('മലയാളം'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
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
                onPressed: () => provider.loadCategories(),
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

  Widget _buildCategoriesList(BrightBoxProvider provider) {
    if (provider.categories.isEmpty) {
      return _buildEmptyState();
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final category = provider.categories[index];
            return _buildCategoryCard(category, provider);
          },
          childCount: provider.categories.length,
        ),
      ),
    );
  }

  Widget _buildCategoryCard(category, BrightBoxProvider provider) {
    final title = provider.currentLanguage == 'en' 
        ? category.catTitleEn 
        : category.catTitleMl;

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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColorClass.primaryColor.withOpacity(0.8),
              ColorClass.primaryColor.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ColorClass.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.box,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyleClass.poppinsSemiBold(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Icon(
                LucideIcons.chevronRight,
                color: Colors.white.withOpacity(0.7),
                size: 16,
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
              LucideIcons.box,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No categories available',
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