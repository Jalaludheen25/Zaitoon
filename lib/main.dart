// ignore_for_file: deprecated_member_use

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/constants/theme.dart';
import 'package:zaitoon/firebase_options.dart';
import 'package:zaitoon/helper/push_notification.dart';
import 'package:zaitoon/screens/bookmark_screen/hive/bookmark_hive_model.dart';
import 'package:zaitoon/screens/bookmark_screen/provider/bookmark_provider.dart';
import 'package:zaitoon/screens/bottom_navigation/provider/bottom_navigation_provider.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/kids_corner_screen/provider/kids_corner_provider.dart';
import 'package:zaitoon/screens/login_screen/provider/auth_provider.dart';
import 'package:zaitoon/screens/reading_screen/provider/pdf_provider.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';
import 'package:zaitoon/services/navigation_service.dart';
import 'package:zaitoon/screens/splash_screen/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/screens/standalone_stories/provider/story_provider.dart';
import 'package:zaitoon/screens/version_check/provider/version_check_provider.dart';
import 'package:zaitoon/screens/quiz_screen/provider/quiz_login_provider.dart';
import 'package:zaitoon/screens/quiz/provider/quiz_provider.dart';
import 'package:zaitoon/screens/bright_box/provider/bright_box_provider.dart';
import 'package:zaitoon/screens/registration/providers/registration_provider.dart';
import 'package:zaitoon/screens/search/provider/search_provider.dart';
import 'package:zaitoon/screens/ott_watchlist/provider/ott_watchlist_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Remove or comment out the orientation lock
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);

  // Add support for all orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  PushNotificationService.initializeOneSignal(ApiUrls.oneSignalAppId);

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(BookmarkModelAdapter());
  }

  // Create single instance of BookmarkProvider
  final bookmarkProvider = BookmarkProvider();
  await bookmarkProvider.initHive();

  // Configure system UI for full screen experience
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [], // Empty array hides all overlays (both top and bottom)
  );

  runApp(MyApp(bookmarkProvider: bookmarkProvider));
}

class MyApp extends StatelessWidget {
  final BookmarkProvider bookmarkProvider;

  const MyApp({
    super.key,
    required this.bookmarkProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => PdfProvider()),
        ChangeNotifierProvider(create: (context) => StoriesProvider()),
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider.value(value: bookmarkProvider),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => VersionCheckProvider()),
        ChangeNotifierProvider(create: (_) => KidsCornerProvider()),
        ChangeNotifierProvider(create: (_) => QuizLoginProvider()),
        ChangeNotifierProvider(
          create: (context) => QuizProvider(context.read<HomeProvider>()),
        ),
        ChangeNotifierProvider(create: (_) => BrightBoxProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => OttWatchlistProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Zai Toon',
        theme: AppTheme.lightTheme(context),
        navigatorKey: NavigationService.navigatorKey,
        home: const SplashScreen(),
      ),
    );
  }
}
