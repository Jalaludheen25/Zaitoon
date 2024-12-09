import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'dart:ui';

class StoryCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback readTap;

  const StoryCard({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.readTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          children: [
            // Background image
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            // Gradient overlay for bottom shadow
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80, // Height of the gradient shadow
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            // Story name and arrow button
            Positioned(
              bottom: 0,
              left: 5,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward, color: Colors.white),
                    onPressed: readTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoryGrid extends StatelessWidget {
  final List<StoryCard> storyCards;

  const StoryGrid({Key? key, required this.storyCards}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the number of columns based on screen width
        int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 3 / 2, // Adjust the aspect ratio as needed
          ),
          itemCount: storyCards.length,
          itemBuilder: (context, index) {
            return storyCards[index];
          },
        );
      },
    );
  }
}
