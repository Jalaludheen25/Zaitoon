// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:zaitoon/constants/app_urls.dart';
import 'package:zaitoon/constants/theme.dart';
import 'package:zaitoon/helper/push_notification.dart';
import 'package:zaitoon/screens/bookmark_screen/hive/bookmark_hive_model.dart';
import 'package:zaitoon/screens/bookmark_screen/provider/bookmark_provider.dart';
import 'package:zaitoon/screens/bottom_navigation/provider/bottom_navigation_provider.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/reading_screen/provider/story_provider.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';
import 'package:zaitoon/screens/splash_screen/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/screens/standalone_stories/provider/story_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    PushNotificationService.initializeOneSignal(ApiUrls.oneSignalAppId);
  }
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(BookmarkModelAdapter());
  }

  // Create single instance of BookmarkProvider
  final bookmarkProvider = BookmarkProvider();
  await bookmarkProvider.initHive();

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
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => PdfProvider()),
        ChangeNotifierProvider(create: (context) => StoriesProvider()),
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
        ChangeNotifierProvider.value(value: bookmarkProvider),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Zai Toon',
        theme: AppTheme.lightTheme(context),
        home: const SplashScreen(),
      ),
    );
  }
}
