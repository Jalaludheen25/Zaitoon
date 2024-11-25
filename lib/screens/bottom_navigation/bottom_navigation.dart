import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zaitoon/screens/bookmark_screen/bookmark_screen.dart';
import 'package:zaitoon/screens/home_screen/home_screen.dart';
import 'package:zaitoon/screens/settings_screen/settings_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  final int currentIndex;
  const BottomNavigationScreen({
    super.key,
    this.currentIndex = 0,
  });

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.dark(
          primary: Colors.purple[300]!,
          secondary: Colors.amber[300]!,
          surface: const Color(0xFF1E1E1E),
        ),
      ),
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            HomeScreen(),
            StoriesScreen(),
            BookmarkScreen(),
            SettingsScreen(),
          ],
        ),
        bottomNavigationBar: StoryAppBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}

class StoryAppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const StoryAppBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap = defaultOnTap,
  });

  static void defaultOnTap(int index) {
    // Default empty implementation
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 65,
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: Theme.of(context).colorScheme.surface,
      indicatorColor: Theme.of(context).colorScheme.primaryContainer,
      destinations: const [
        NavigationDestination(
          icon: Icon(LucideIcons.tv),
          selectedIcon: Icon(LucideIcons.tv2),
          label: 'Episodes',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.book),
          selectedIcon: Icon(LucideIcons.bookOpen),
          label: 'Stories',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.bookmark),
          selectedIcon: Icon(LucideIcons.bookMarked),
          label: 'Bookmarks',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.settings),
          selectedIcon: Icon(LucideIcons.settings2),
          label: 'Settings',
        ),
      ],
    );
  }
}

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const Center(
        child: Text(
          'Stories',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
