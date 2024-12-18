import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/screens/kids_corner_screen/components/content_card.dart';
import 'package:zaitoon/screens/kids_corner_screen/components/get_started_screen.dart';
import 'package:zaitoon/screens/kids_corner_screen/models/kids_content_model.dart';
import 'package:zaitoon/screens/kids_corner_screen/provider/kids_corner_provider.dart';

class KidsCornerScreen extends StatefulWidget {
  const KidsCornerScreen({super.key});

  @override
  State<KidsCornerScreen> createState() => _KidsCornerScreenState();
}

class _KidsCornerScreenState extends State<KidsCornerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KidsCornerProvider>().fetchContent();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildHighlightsSection(List<KidsContent> highlights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Highlights',
            style: GoogleFonts.poppins(
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
            itemCount: highlights.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final highlight = highlights[index];
              final imageUrl = context.read<KidsCornerProvider>().getAssetUrl(
                  highlight.coverImageForPoemAndStory ?? highlight.drawings);

              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[850],
                ),
                child: Stack(
                  children: [
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
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
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: ColorClass.primaryColor,
                            backgroundImage: highlight.kidPhoto != null
                                ? NetworkImage(context
                                    .read<KidsCornerProvider>()
                                    .getAssetUrl(highlight.kidPhoto))
                                : null,
                            child: highlight.kidPhoto == null
                                ? Text(highlight.kidName[0])
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            highlight.kidName,
                            style: GoogleFonts.poppins(
                              color: ColorClass.white,
                              fontSize: 14,
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
      ],
    );
  }

  Widget _buildContentGrid(List<KidsContent> items) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No content available',
          style: GoogleFonts.poppins(color: ColorClass.white),
        ),
      );
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
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final imageUrl = context
            .read<KidsCornerProvider>()
            .getAssetUrl(item.coverImageForPoemAndStory ?? item.drawings);

        return ContentCard(content: item, imageUrl: imageUrl);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GetStartedScreen()),
        ),
        backgroundColor: ColorClass.primaryColor,
        icon: const Icon(Icons.brush_outlined, color: ColorClass.white),
        label: Text(
          'Upload ✨',
          style: GoogleFonts.comicNeue(
            color: ColorClass.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Text(
          'Kids Corner',
          style: GoogleFonts.fredoka(
            color: ColorClass.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<KidsCornerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                'Error: ${provider.error}',
                style: GoogleFonts.poppins(color: ColorClass.white),
              ),
            );
          }

          return Column(
            children: [
              if (provider.highlights.isNotEmpty)
                _buildHighlightsSection(provider.highlights),
              Padding(
                padding: const EdgeInsets.all(16),
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
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ListView(children: [_buildContentGrid(provider.stories)]),
                    ListView(children: [_buildContentGrid(provider.poems)]),
                    ListView(children: [_buildContentGrid(provider.drawings)]),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
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
                  style: GoogleFonts.poppins(
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
}


