import 'package:flutter/material.dart';
import 'package:zaitoon/constants/color_class.dart';

/// KidsCornerScreen displays content for children including stories, poems and drawings
/// It uses a TabController to manage different content sections
class KidsCornerScreen extends StatefulWidget {
  const KidsCornerScreen({super.key});

  @override
  State<KidsCornerScreen> createState() => _KidsCornerScreenState();
}

class _KidsCornerScreenState extends State<KidsCornerScreen>
    with SingleTickerProviderStateMixin {
  // TabController for managing the three main content sections
  late TabController _tabController;

  // Sample story data - should be moved to a separate data model or provider
  final List<Map<String, String>> stories = [
    {
      'name': 'Adison Mango',
      'image': 'assets/forest_bg.jpg',
      'avatar': 'assets/adison_avatar.jpg'
    },
    {
      'name': 'Ahmad Dorwart',
      'image': 'assets/wave_bg.jpg',
      'avatar': 'assets/ahmad_avatar.jpg'
    },
    {
      'name': 'Lindsey',
      'image': 'assets/mountain_bg.jpg',
      'avatar': 'assets/lindsey_avatar.jpg'
    },
  ];

  // Add this list at the class level, after the stories list
  final List<String> _storyAuthors = [
    'Ahmad Dorwart',
    'Adison Mango',
    'Lindsey Williams',
    'Sarah Parker'
  ];
  final List<String> _poemAuthors = [
    'Emily Frost',
    'Robert Blake',
    'Maya Chen',
    'David Kumar'
  ];
  final List<String> _drawingArtists = [
    'Alex Turner',
    'Sofia Garcia',
    'Noah Kim',
    'Emma Watson'
  ];

  @override
  void initState() {
    // Initialize tab controller with 3 tabs (Stories, Poems, Drawings)
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Custom tab button builder that shows selected state
  Widget _buildTabButton(String text, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            return Container(
              height: 48,
              decoration: BoxDecoration(
                color: _tabController.index == index
                    ? ColorClass.primaryColor
                    : Colors.grey[850],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: ColorClass.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Kids Corner',
          style: TextStyle(
            color: ColorClass.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Highlights',
                    style: TextStyle(
                      color: ColorClass.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Horizontal scrolling highlights/stories section
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: stories.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey[850],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: ColorClass.primaryColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    stories[index]['name']!,
                                    style: const TextStyle(
                                      color: ColorClass.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Tab buttons row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Row(
                    children: [
                      _buildTabButton('Stories', 0),
                      const SizedBox(width: 8),
                      _buildTabButton('Poems', 1),
                      const SizedBox(width: 8),
                      _buildTabButton('Drawings', 2),
                    ],
                  ),
                ),
                // Tab-specific content
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, child) {
                    switch (_tabController.index) {
                      case 0:
                        return _buildPostGrid(itemCount: 6, title: 'Stories');
                      case 1:
                        return _buildPostGrid(itemCount: 4, title: 'Poems');
                      case 2:
                        return _buildPostGrid(itemCount: 8, title: 'Drawings');
                      default:
                        return _buildPostGrid(itemCount: 6, title: 'Stories');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostGrid({required int itemCount, required String title}) {
    // Get the appropriate author list based on the current tab
    List<String> authors;
    switch (title) {
      case 'Stories':
        authors = _storyAuthors;
        break;
      case 'Poems':
        authors = _poemAuthors;
        break;
      case 'Drawings':
        authors = _drawingArtists;
        break;
      default:
        authors = _storyAuthors;
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Get author name with wraparound if index exceeds list length
        final authorName = authors[index % authors.length];

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: ColorClass.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        authorName, // Use the dynamic author name here
                        style: const TextStyle(
                          color: ColorClass.white,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Post image
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                  ),
                ),
              ),
              // Engagement buttons
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          color: ColorClass.white,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '229',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: ColorClass.white,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '200',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
