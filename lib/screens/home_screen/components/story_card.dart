import 'package:flutter/material.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'dart:ui';

class StoryCard extends StatefulWidget {
  const StoryCard({
    super.key,
    this.imageUrl,
    required this.readTap,
    this.tag,
    this.name,
    this.discription,
    this.language,
  });
  final String? imageUrl;
  final String? tag;
  final String? name;
  final String? discription;
  final VoidCallback readTap;
  final String? language;
  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.readTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
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
                      padding: const EdgeInsets.all(10),
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
                                  style: widget.language == 'en'
                                      ? TextStyleClass.poppinsSemiBold(
                                          fontSize: 18,
                                          color: ColorClass.white,
                                        )
                                      : TextStyleClass.manjariSemiBold(
                                          fontSize: 18,
                                          color: ColorClass.white,
                                        ),
                                ),
                                const SizedBox(height: 4),

                                // Tag
                                Text(widget.tag ?? '',
                                    style: TextStyleClass.poppinsNormal(
                                      fontSize: 12,
                                      color: ColorClass.white,
                                    )),
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
                                  fontSize: 14,
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
