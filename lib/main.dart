// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:zaitoon/constants/theme.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/home_screen/provider/story_provider.dart';
import 'package:zaitoon/screens/login_screen/provider/auth_provider.dart';
import 'package:zaitoon/screens/splash_screen/onboarding_screens.dart';
import 'package:zaitoon/screens/splash_screen/splashscreen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    bool isTestMode = Platform.isLinux;
    int deviceWidth = isTestMode ? 200 : 800;

    final isMobileDevice = MediaQuery.of(context).size.width < deviceWidth;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => PDFState()),
      ],
      child: isMobileDevice
          ? MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Zaitoon',
              theme: AppTheme.lightTheme(context),
              home: const SplashScreen(),
            )
          : DevicePreview(
              enabled: true,
              isToolbarVisible: false,
              builder: (context) => MaterialApp(
                useInheritedMediaQuery: true,
                theme: AppTheme.lightTheme(context),
                home: const OnboardingScreen(),
                locale: DevicePreview.locale(context),
                builder: DevicePreview.appBuilder,
                debugShowCheckedModeBanner: false,
                title: 'Zaitoon',
              ),
            ),
    );
  }
}
