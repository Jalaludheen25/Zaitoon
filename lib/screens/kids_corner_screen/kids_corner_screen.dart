import 'package:flutter/material.dart';
import 'package:zaitoon/constants/color_class.dart';

class KidsCornerScreen extends StatefulWidget {
  const KidsCornerScreen({super.key});

  @override
  State<KidsCornerScreen> createState() => _KidsCornerScreenState();
}

class _KidsCornerScreenState extends State<KidsCornerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Stories',
                style: TextStyle(
                  color: ColorClass.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                children: [
                  _buildTabButton('Drawings', 0),
                  const SizedBox(width: 8),
                  _buildTabButton('Poems', 1),
                  const SizedBox(width: 8),
                  _buildTabButton('Stories', 2),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPost(),
                  _buildPost(),
                  _buildPost(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPost() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(
              radius: 20,
              backgroundColor: ColorClass.primaryColor,
            ),
            title: const Text(
              'Ahmad Dorwart',
              style: TextStyle(color: ColorClass.white),
            ),
            subtitle: const Text(
              '10 Mins Ago',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz, color: ColorClass.white),
              onPressed: () {},
            ),
          ),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[700],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border,
                      color: ColorClass.white),
                  onPressed: () {},
                ),
                const Text(
                  '229 Likes',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline,
                      color: ColorClass.white),
                  onPressed: () {},
                ),
                const Text(
                  '200 Comments',
                  style: TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.send, color: ColorClass.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
