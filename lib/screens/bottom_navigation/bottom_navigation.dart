// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/screens/bookmark_screen/bookmark_screen.dart';
import 'package:zaitoon/screens/bottom_navigation/provider/bottom_navigation_provider.dart';
import 'package:zaitoon/screens/home_screen/home_screen.dart';
import 'package:zaitoon/screens/login_screen/provider/auth_provider.dart';
import 'package:zaitoon/screens/settings_screen/settings_screen.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/icon_class.dart';
import 'package:zaitoon/screens/standalone_stories/standalone_story_list_screen.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';
import 'package:zaitoon/screens/student_form/view/student_form.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zaitoon/screens/kids_corner_screen/kids_corner_screen.dart';

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

      // Set the current index to the provided index (important for back navigation)
      context.read<NavigationProvider>().setIndexDirectly(widget.currentIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
        builder: (context, navigationProvider, child) {
      return Scaffold(
        //backgroundColor: const Color(0xFF121212),
        body: IndexedStack(
          index: navigationProvider.currentIndex,
          children: [
            const HomeScreen(),
            const StoriesScreen(),
            const KidsCornerScreen(),
            const BookmarkScreen(),
            // 5th tab: either Quiz placeholder or Settings
            if (navigationProvider.showQuiz)
              const StudentFormScreen() // Quiz tab (but navigation is handled in provider)
            else
              const SettingsScreen(), // Settings tab
          ],
        ),
        bottomNavigationBar: StoryAppBottomNav(
          currentIndex: navigationProvider.currentIndex,
          onTap: (index) => navigationProvider.setIndex(index, context),
          showQuiz: navigationProvider.showQuiz,
        ),
      );
    });
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

  // Helper: build SVG icon with gradient color when selected
  Widget _buildSvgIcon(String iconPath, bool isSelected, {double size = 24}) {
    return SvgPicture.asset(
      iconPath,
      width: size,
      height: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build destinations list dynamically
    List<NavigationDestination> destinations = [
      NavigationDestination(
        icon: const Icon(LucideIcons.home),
        selectedIcon: _buildSvgIcon(IconClass.home, true),
        label: 'Home',
      ),
      NavigationDestination(
        icon: const Icon(LucideIcons.tv),
        selectedIcon: _buildSvgIcon(IconClass.tv, true),
        label: 'Watchlist',
      ),
      NavigationDestination(
        icon: _buildSvgIcon(IconClass.note, true),
        selectedIcon: _buildSvgIcon(IconClass.kidsCorner, true),
        label: 'kids Corner',
      ),
      NavigationDestination(
        icon: const Icon(LucideIcons.bookmark),
        selectedIcon: _buildSvgIcon(IconClass.bookmark, true),
        label: 'Bookmarks',
      ),
    ];

    // Add either Quiz or Settings as the 5th tab (always keep 5 tabs total)
    if (showQuiz) {
      destinations.add(
        NavigationDestination(
          icon: const Icon(LucideIcons.brain),
          selectedIcon: Icon(LucideIcons.brainCircuit),
          label: 'Quiz',
        ),
      );
    } else {
      destinations.add(
        NavigationDestination(
          icon: const Icon(LucideIcons.user2),
          selectedIcon: _buildSvgIcon(IconClass.profile, true),
          label: 'profile',
        ),
      );
    }
    final Paint gradientPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFAC28DC), Color(0xFF7E1EB7), Color(0xFF501392)],
        stops: [0, 0.50, 1],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(
        // Use screen width so gradient spans nicely across labels
        Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width, 20),
      );
    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return GoogleFonts.openSans(
                  fontSize: 12, // Consistent font size for 5 tabs
                  foreground: gradientPaint,
                );
              }
              return TextStyleClass.openSans(
                fontSize: 12, // Consistent font size for 5 tabs

                color: ColorClass.black87.withOpacity(0.5),
              );
            },
          ),
        ),
      ),
      child: NavigationBar(
        height: 65, // Consistent height for 5 tabs
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        destinations: destinations,
      ),
    );
  }
}
