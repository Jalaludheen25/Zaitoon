import 'package:cached_network_image/cached_network_image.dart';
import 'package:d4tales/constants/app_urls.dart';
import 'package:d4tales/constants/image_class.dart';
import 'package:d4tales/helper/navigation_helper.dart';
import 'package:d4tales/screens/home_screen/models/episode_model.dart';
import 'package:d4tales/screens/home_screen/provider/home_provider.dart';
import 'package:d4tales/screens/home_screen/story_reading_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class EpisodeScreen extends StatefulWidget {
  const EpisodeScreen({super.key, required this.id, required this.title});
final String id;
final String title;
  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {


  
  @override
  void initState() {
    Future.microtask(() {
      HomeProvider homeProvider =
          Provider.of<HomeProvider>(context, listen: false);
      homeProvider.fetchEpisodes(widget.id);
      
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Consumer<HomeProvider>(
          builder: (context,snapshot,_)=>
          snapshot.episodeModel==null?const Center(child: CupertinoActivityIndicator()):
          Column(
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
                      Text(
                      widget.title,
                      style: const TextStyle(
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
                    _buildFilterChip('Episodes-${snapshot.episodeModel!.data!.length}', icon: Icons.book_rounded),
                  ],
                ),
              ),
          
              // Stories List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.episodeModel!.data!.length,
                  itemBuilder: (context, index) {
                    final story = snapshot.episodeModel!.data![index];
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
              child:  CachedNetworkImage(
              imageUrl:ApiUrls.assetBaseUrl+story.coverImage!,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CupertinoActivityIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error)
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
                  story.storyTile!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${story.uploadDate} ',
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
                      '${story.readMinutes} min',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                   
                   
                  ],
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: (){
              navigatePRTo(context,  
               PDFViewerScreen(
                                        pdfUrl: ApiUrls.assetBaseUrl +
                                            snapshot.episodeModel!.data![index]
                                                .storyFile!,
                                      ),);
            },
            child: Container(
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
          ),
        ],
      ),
    );
                  },
                ),
              ),
            ],
          ),
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


}
