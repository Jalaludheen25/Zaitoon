// lib/screens/user_data_collection/screens/avatar_customizer_screen.dart

import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';

class AvatarCustomizerScreen extends StatelessWidget {
  const AvatarCustomizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Avatar'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FluttermojiCustomizer(
            scaffoldWidth: MediaQuery.of(context).size.width * 0.85,
            autosave: true,
            theme: FluttermojiThemeData(
              primaryBgColor: Colors.black,
              secondaryBgColor: Colors.grey[900],
              iconColor: Colors.white,
              selectedIconColor: Colors.deepPurpleAccent,
              unselectedIconColor: Colors.grey[600],
              labelTextStyle: const TextStyle(color: Colors.white),
              selectedTileDecoration: BoxDecoration(
                color: Colors.deepPurpleAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              unselectedTileDecoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
