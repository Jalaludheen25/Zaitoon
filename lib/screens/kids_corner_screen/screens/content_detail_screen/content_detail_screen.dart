// screens/content_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          content.title,
          style: GoogleFonts.poppins(
            color: ColorClass.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content Image
            if (imageUrl.isNotEmpty)
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Author Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
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
                        Text(
                          content.schoolName,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            if (content.storyOrPoem != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  content.storyOrPoem!,
                  style: GoogleFonts.poppins(
                    color: ColorClass.white,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),

            // Drawing Description
            if (content.descriptionForDrawings != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  content.descriptionForDrawings!,
                  style: GoogleFonts.poppins(
                    color: ColorClass.white,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
