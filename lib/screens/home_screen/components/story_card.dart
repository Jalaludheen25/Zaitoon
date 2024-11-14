import 'package:flutter/material.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'dart:ui';

import 'package:zaitoon/constants/ui_styles.dart';

class StoryCard extends StatefulWidget {
  const StoryCard({
    super.key,
    this.imageUrl,
    required this.readTap,
    this.tag,
    this.name,
    this.discription,
  });
  final String? imageUrl;
  final String? tag;
  final String? name;
  final String? discription;
  final VoidCallback readTap;

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.readTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        width: double.infinity,
        // height: 400, // Fixed height for consistency
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  widget.imageUrl ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: ColorClass.grey);
                  },
                ),
              ),

              // Blurred overlay for text
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color.fromARGB(255, 255, 255, 255)
                                .withOpacity(0.0),
                            const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  widget.name ?? '',
                                  style: const TextStyle(
                                    color: ColorClass.white,
                                    fontSize: UiStyles.fontSizeMedium,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),

                                // Tag
                                Text(
                                  widget.tag ?? '',
                                  style: const TextStyle(
                                    color: ColorClass.white,
                                    fontSize: UiStyles.fontSizeSubTitle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: widget.readTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: ColorClass.black,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'Read Story',
                                style: TextStyle(
                                  color: ColorClass.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
