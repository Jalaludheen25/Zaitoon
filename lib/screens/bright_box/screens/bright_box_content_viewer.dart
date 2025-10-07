import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class BrightBoxContentViewer extends StatelessWidget {
  final String id;
  final String title;
  final String thumbnail;
  final String contentType;

  const BrightBoxContentViewer({
    super.key,
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor:
              themeProvider.isDarkMode ? ColorClass.black : ColorClass.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
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
                      const SizedBox(width: 4),
                      // Title
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
                            'Bright Box Content',
                            style: TextStyleClass.fredoka(
                              fontSize: 24,
                              color: ColorClass.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail
                        if (thumbnail.isNotEmpty)
                          Container(
                            width: double.infinity,
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: thumbnail.startsWith('http')
                                    ? thumbnail
                                    : ApiUrls.assetBaseUrl + thumbnail,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: ColorClass.grey400.withOpacity(0.2),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: ColorClass.primaryColor,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: ColorClass.grey400.withOpacity(0.2),
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: ColorClass.grey,
                                    size: 48,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Title
                        Text(
                          title,
                          style: TextStyleClass.fredoka(
                            fontSize: 24,
                            color: themeProvider.isDarkMode
                                ? ColorClass.white
                                : ColorClass.black,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Content Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ColorClass.grad1,
                                ColorClass.grad2,
                                ColorClass.grad3,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            contentType == 'bright_box_story'
                                ? 'Bright Box Story'
                                : 'Bright Box Category',
                            style: TextStyleClass.fredoka(
                              fontSize: 14,
                              color: ColorClass.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Description
                        Text(
                          'This is your bookmarked Bright Box content. You can access the full content by navigating to the Bright Box section.',
                          style: TextStyle(
                            fontSize: 16,
                            color: ColorClass.grey,
                            height: 1.5,
                          ),
                        ),

                        const Spacer(),

                        // Action Button
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ColorClass.grad1,
                                ColorClass.grad2,
                                ColorClass.grad3,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate back to bookmarks
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              'Back to Bookmarks',
                              style: TextStyleClass.fredoka(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
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
      },
    );
  }
}
