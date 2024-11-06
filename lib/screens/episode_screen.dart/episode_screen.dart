import 'package:d4tales/constants/image_class.dart';
import 'package:flutter/material.dart';

class StoryItem {
  final String title;
  final String category;
  final String subCategory;
  final String imageUrl;
  final int duration;
  final int rating;
  final bool hasAudio;

  StoryItem({
    required this.title,
    required this.category,
    required this.subCategory,
    required this.imageUrl,
    required this.duration,
    required this.rating,
    this.hasAudio = false,
  });
}

class EpisodeScreen extends StatefulWidget {
  const EpisodeScreen({super.key});

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  String selectedFilter = 'All';

  final List<StoryItem> stories = [
    StoryItem(
      title: 'The Sleepy Kitten',
      category: 'Mindfulness',
      subCategory: 'Sleep',
      imageUrl: ImageClass.onboarding1,
      duration: 7,
      rating: 4,
      hasAudio: true,
    ),
    StoryItem(
      title: 'The Naughty Gnome',
      category: 'Mindfulness',
      subCategory: 'Sleep',
      imageUrl: ImageClass.onboarding2,
      duration: 6,
      rating: 3,
      hasAudio: true,
    ),
    StoryItem(
      title: 'And Finally, To Sleep',
      category: 'Mindfulness',
      subCategory: 'Sleep',
      imageUrl: ImageClass.onboarding3,
      duration: 4,
      rating: 3,
    ),
    StoryItem(
      title: 'A Trip to Fantasy Land',
      category: 'Creativity',
      subCategory: '',
      imageUrl: ImageClass.onboarding1,
      duration: 7,
      rating: 3,
      hasAudio: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Bedtime Stories',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  _buildFilterChip('Episodes-4', icon: Icons.book_rounded),
                ],
              ),
            ),

            // Stories List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return _buildStoryCard(story);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {IconData? icon}) {
    return FilterChip(
      label: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          icon,
          size: 18,
          color: Colors.white,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ]),
      onSelected: (selected) {},
      backgroundColor: Colors.grey[900],
      selectedColor: Colors.green,
      checkmarkColor: Colors.transparent,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildStoryCard(StoryItem story) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Story Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey[800],
              child: Image.asset(
                story.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.image,
                      color: Colors.white54,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Story Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${story.category}${story.subCategory.isNotEmpty ? ", ${story.subCategory}" : ""}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      '${story.duration} min',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.star, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      '${story.rating}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Read',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
