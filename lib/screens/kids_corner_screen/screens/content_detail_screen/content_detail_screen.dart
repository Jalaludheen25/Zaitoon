// screens/content_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/screens/kids_corner_screen/models/kids_content_model.dart';
import 'package:zaitoon/screens/kids_corner_screen/provider/kids_corner_provider.dart';

class ContentDetailScreen extends StatelessWidget {
  final KidsContent content;

  const ContentDetailScreen({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = context
        .read<KidsCornerProvider>()
        .getAssetUrl(content.coverImageForPoemAndStory ?? content.drawings);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorClass.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          content.contentType,
          style: GoogleFonts.fredoka(
            color: ColorClass.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorClass.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: ColorClass.primaryColor,
                      backgroundImage: content.kidPhoto != null
                          ? NetworkImage(context
                              .read<KidsCornerProvider>()
                              .getAssetUrl(content.kidPhoto))
                          : null,
                      child: content.kidPhoto == null
                          ? Text(
                              content.kidName[0],
                              style: const TextStyle(
                                color: ColorClass.white,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.kidName,
                        style: GoogleFonts.poppins(
                          color: ColorClass.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width -
                            120, // Account for avatar and padding
                        child: Text(
                          content.schoolName,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Image
            if (imageUrl.isNotEmpty)
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Engagement buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildEngagementButton(
                    icon: LucideIcons.heart,
                    label: '2.3k',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 24),
                  _buildEngagementButton(
                    icon: LucideIcons.share2,
                    label: 'Share',
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Content title and description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: GoogleFonts.poppins(
                      color: ColorClass.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (content.storyOrPoem != null)
                    Text(
                      content.storyOrPoem!,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[300],
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  if (content.descriptionForDrawings != null)
                    Text(
                      content.descriptionForDrawings!,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[300],
                        fontSize: 16,
                        height: 1.6,
                      ),
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
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
