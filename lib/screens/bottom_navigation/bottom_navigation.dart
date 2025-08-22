// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/screens/bookmark_screen/bookmark_screen.dart';
import 'package:zaitoon/screens/bottom_navigation/provider/bottom_navigation_provider.dart';
import 'package:zaitoon/screens/home_screen/home_screen.dart';
import 'package:zaitoon/screens/login_screen/provider/auth_provider.dart';

import 'package:zaitoon/screens/settings_screen/settings_screen.dart';
import 'package:zaitoon/screens/standalone_stories/standalone_story_list_screen.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';
import 'package:zaitoon/screens/student_form/view/student_form.dart';
import 'package:zaitoon/screens/bright_box/screens/bright_box_categories_screen.dart';

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
  @override
  void initState() {
    super.initState();
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    Future.microtask(() {
      if (authProvider.isSignedIn) {
        context.read<UserDataProvider>().initialize();
      }
      // Check quiz visibility from API
      context.read<NavigationProvider>().checkQuizVisibility();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.amber[300]!,
          surface: const Color(0xFF1E1E1E),
        ),
      ),
      home: Consumer<NavigationProvider>(
          builder: (context, navigationProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: navigationProvider.currentIndex,
            children: [
              const HomeScreen(),
              const StoriesScreen(),
              const BookmarkScreen(),
              const BrightBoxCategoriesScreen(),
              if (navigationProvider.showQuiz) const StudentFormScreen(),
              const SettingsScreen(),
            ],
          ),
          bottomNavigationBar: StoryAppBottomNav(
            currentIndex: navigationProvider.currentIndex,
            onTap: (index) => navigationProvider.setIndex(index, context),
            showQuiz: navigationProvider.showQuiz,
          ),
        );
      }),
    );
  }
}

class StoryAppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool showQuiz;

  const StoryAppBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap = defaultOnTap,
    this.showQuiz = false,
  });

  static void defaultOnTap(int index) {
    // Default empty implementation
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  fontSize: 10, // Smaller font size for selected labels
                  fontWeight: FontWeight.w600,
                );
              }
              return const TextStyle(
                fontSize: 10, // Smaller font size for unselected labels
                fontWeight: FontWeight.w400,
              );
            },
          ),
        ),
      ),
      child: NavigationBar(
        height: 65,
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        destinations: [
          const NavigationDestination(
            icon: Icon(LucideIcons.tv),
            selectedIcon: Icon(
              LucideIcons.tv2,
              color: Colors.white,
            ),
            label: 'Episodes',
          ),
          const NavigationDestination(
            icon: Icon(LucideIcons.book),
            selectedIcon: Icon(
              LucideIcons.bookOpen,
              color: Colors.white,
            ),
            label: 'Stories',
          ),
          const NavigationDestination(
            icon: Icon(LucideIcons.bookmark),
            selectedIcon: Icon(
              LucideIcons.bookMarked,
              color: Colors.white,
            ),
            label: 'Bookmarks',
          ),
          const NavigationDestination(
            icon: Icon(LucideIcons.box),
            selectedIcon: Icon(
              LucideIcons.package,
              color: Colors.white,
            ),
            label: 'Bright Box',
          ),
          if (showQuiz)
            const NavigationDestination(
              icon: Icon(LucideIcons.brain),
              selectedIcon: Icon(
                LucideIcons.brainCircuit,
                color: Colors.white,
              ),
              label: 'Quiz',
            ),
          const NavigationDestination(
            icon: Icon(LucideIcons.settings),
            selectedIcon: Icon(
              LucideIcons.settings2,
              color: Colors.white,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
