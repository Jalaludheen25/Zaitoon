import 'package:d4tales/constants/app_urls.dart';
import 'package:flutter/material.dart';

class StoryCard extends StatefulWidget {
  
  const StoryCard({super.key, this.imageUrl, required this.readTap});
final String? imageUrl;
final VoidCallback readTap;
  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 215, 135, 235), // Light blue sky
            Color.fromARGB(255, 112, 129, 239), // Light green ground
          ],
          stops: [0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Background arch decoration
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 270,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.3),
                image: DecorationImage(
                                        image: NetworkImage(
                                        widget.imageUrl!
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          ),
          
          // Content Column
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 258), 
   
                // Main title
                Text(
                  'Poocha Police',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const Text(
                  'Investigation',
                  style: TextStyle(
                    color: Color.fromARGB(255, 30, 29, 29),
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    // height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 5,),
                
            
                Row(
                  children: [
                
                    
             
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Poocha Police is a Malayalam animation series aimed at children, featuring the character Tiger. ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        
                        ],
                      ),
                    ),
                    
                    // Get button
                    InkWell(
                       onTap: 
                        widget.readTap,
                      
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Read',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
  }
}