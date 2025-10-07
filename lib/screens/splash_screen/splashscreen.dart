// ignore_for_file: use_build_context_synchronously

// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/bottom_navigation/bottom_navigation.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/language_selection/language_selection.dart';
import 'package:zaitoon/screens/login_screen/login_screen.dart';
import 'package:zaitoon/screens/login_screen/provider/auth_provider.dart';
import 'package:zaitoon/screens/splash_screen/onboarding_screens.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';
import 'package:zaitoon/screens/user_data_collection_screen/user_data_collection_screen.dart';
import 'package:zaitoon/providers/theme_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _bounceController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
    _initializeAnimations();
  }

  Future<void> _initializeAndNavigate() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await Future.wait([
      homeProvider.loadSelectedLanguage(),
      authProvider.checkUserStatus(),
    ]);

    await Future.delayed(const Duration(seconds: 3));

    final bool isOnboardingCompleted =
        await homeProvider.isOnboardingCompleted();

    if (!isOnboardingCompleted) {
      navigateAndRemove(context: context, screen: const OnboardingScreen());
      return;
    }

    if (authProvider.isSignedIn) {
      // User is signed in, check if they've completed the full onboarding flow
      await _checkUserFlowCompletion();
    } else {
      navigateAndRemove(context: context, screen: const AuthScreen());
    }
  }

  Future<void> _checkUserFlowCompletion() async {
    try {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);

      // Check if language is selected
      if (homeProvider.selectedLanguage.isEmpty) {
        navigateAndRemove(context: context, screen: const LanguageSelection());
        return;
      }

      // Load user data and check if it's complete
      await userDataProvider.loadUserDetails();

      if (userDataProvider.name == null ||
          userDataProvider.name!.isEmpty ||
          userDataProvider.age == null ||
          userDataProvider.age! <= 0 ||
          userDataProvider.gender.isEmpty) {
        // User data is incomplete, go to user data collection
        navigateAndRemove(
          context: context,
          screen: const UserDataCollection(isFromOnboarding: true),
        );
      } else {
        // Everything is complete, go to home screen
        navigateAndRemove(
            context: context, screen: const BottomNavigationScreen());
      }
    } catch (e) {
      debugPrint('Error checking user flow completion: $e');
      // On error, start from language selection
      navigateAndRemove(context: context, screen: const LanguageSelection());
    }
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _bounceAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -15),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -15, end: 0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _mainController.forward();
    // _bounceController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to theme changes
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
        );

        return Scaffold(
          backgroundColor: isDark ? Colors.black87 : ColorClass.white,
          body: SizedBox(
            height: 852.0,
            width: MediaQuery.of(context).size.width,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) =>
                  Stack(
                children: [
                  // Centered Color Logo
                  Positioned(
                    top: (constraints.maxHeight / 2) - (852.0 / 2 - 326.0),
                    left: (constraints.maxWidth / 2) - (393.0 / 2 - 96.0),
                    child: _buildCenteredLogo(isDark),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenteredLogo(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnimation.value),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 200.0,
                height: 200.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(isDark ? ImageClass.splashBgDark : ImageClass.whiteLogo),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _bounceController.dispose();
    _glowController.dispose();
    super.dispose();
  }
}
