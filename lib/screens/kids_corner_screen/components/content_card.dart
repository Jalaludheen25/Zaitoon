// widgets/content_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/screens/kids_corner_screen/models/kids_content_model.dart';
import 'package:zaitoon/screens/kids_corner_screen/provider/kids_corner_provider.dart';
import 'package:zaitoon/screens/kids_corner_screen/screens/content_detail_screen/content_detail_screen.dart';
import 'package:share_plus/share_plus.dart';

class ContentCard extends StatelessWidget {
  final KidsContent content;
  final String imageUrl;

  const ContentCard({
    super.key,
    required this.content,
    required this.imageUrl,
  });

  void _shareContent() {
    final String contentType = content.contentType ?? 'content';
    final String appStoreLink =
        'https://apps.apple.com/in/app/zai-toon-kids/id6737912105';
    final String playStoreLink =
        'https://play.google.com/store/apps/details?id=co.d4dx.zaitoon';

    // Create a deep link to the specific content
    // final String contentDeepLink =
    //     'https://zaitoonkids.com/content/${content.id}';
    // Or alternatively use your app's custom scheme
    // final String contentDeepLink = 'zaitoon://content/${content.id}';
    // 🌟 View this $contentType: $contentDeepLink

    final String shareText =
        '''Check out this amazing $contentType by ${content.kidName}!



🌟 Download Zai Toon Kids to start reading:

📱 iOS: $appStoreLink

📱 Android: $playStoreLink

Join thousands of families making reading time special! 🎉
#ZaiToonKids #ChildrenStories #InteractiveReading''';

    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentDetailScreen(content: content),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorClass.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: content.kidPhoto != null
                          ? NetworkImage(context
                              .read<KidsCornerProvider>()
                              .getAssetUrl(content.kidPhoto))
                          : null,
                      child: content.kidPhoto == null
                          ? Text(content.kidName[0])
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.kidName,
                          style: GoogleFonts.poppins(
                            color: ColorClass.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          content.schoolName,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 12,
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
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[700],
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: GoogleFonts.poppins(
                      color: ColorClass.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildEngagementButton(
                        icon: LucideIcons.heart,
                        label: 'Like',
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      _buildEngagementButton(
                        icon: LucideIcons.share2,
                        label: 'Share',
                        onPressed: _shareContent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(
            icon,
            color: ColorClass.white,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
