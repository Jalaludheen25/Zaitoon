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
      'image': 'assets/images/onboarding1.png',
      'avatar': 'assets/images/appicon.png'
    },
    {
      'name': 'Ahmad Dorwart',
      'image': 'assets/images/onboarding1.png',
      'avatar': 'assets/images/appicon.png'
    },
    {
      'name': 'Lindsey',
      'image': 'assets/images/onboarding1.png',
      'avatar': 'assets/images/appicon.png'
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
                          image: DecorationImage(
                            image: AssetImage(stories[index]['image']!),
                            fit: BoxFit.cover,
                          ),
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
                                    backgroundImage:
                                        AssetImage(stories[index]['avatar']!),
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
        childAspectRatio: 1.2,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final authorName = authors[index % authors.length];

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Section
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                          child: const CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage:
                                AssetImage('assets/images/appicon.png'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authorName,
                              style: const TextStyle(
                                color: ColorClass.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '2 hours ago',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Like and Share buttons
                    Row(
                      children: [
                        _buildEngagementButton(
                          icon: Icons.favorite_border,
                          label: '2.3k',
                          onPressed: () {},
                        ),
                        const SizedBox(width: 16),
                        _buildEngagementButton(
                          icon: Icons.share_outlined,
                          label: 'Share',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Cover Image
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[700],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/onboarding1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Engagement Section
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Caption
                    Text(
                      'Beautiful ${title.toLowerCase()} by $authorName #kidscorner #creativity',
                      style: const TextStyle(
                        color: ColorClass.white,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
