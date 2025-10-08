// Import Cupertino widgets
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zaitoon/constants/app_constants.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/helper/url_launcher.dart';
import 'package:zaitoon/screens/language_selection/language_selection.dart';
import 'package:zaitoon/screens/login_screen/provider/auth_provider.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon/providers/theme_provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
            statusBarBrightness:
                themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness:
                themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
          ),
        );
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(themeProvider.isDarkMode
                    ? ImageClass.loginDark
                    : ImageClass.loginBg),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
            child: Stack(
              children: [
                // Bottom container with content
                Positioned(
                  top: 370,
                  left: 19,
                  right: 19,
                  child: Center(
                    child: Container(
                      width: 357,
                      height: 380,
                      decoration: BoxDecoration(
                        color: ColorClass.containerBg.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: themeProvider.isDarkMode
                            ? Border.all(color: ColorClass.violet30)
                            : null,
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.black.withOpacity(0.2),
                        //     blurRadius: 15,
                        //     offset: const Offset(0, 8),
                        //     spreadRadius: 0,
                        //   ),
                        // ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Headline text with gradient
                            themeProvider.isDarkMode
                                ? Text(
                                    'Welcome to Zai Toon',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 24,
                                      color: ColorClass.violet30,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                : ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        ColorClass.grad1,
                                        ColorClass.grad2,
                                        ColorClass.grad3,
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      'Welcome to Zai Toon',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 24,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                            const SizedBox(height: 14),
                            // Subtitle
                            Text(
                              'Interactive stories with sound effects as you read along',
                              style: GoogleFonts.openSans(
                                fontSize: 16,
                                color: themeProvider.isDarkMode
                                    ? ColorClass.white
                                    : ColorClass.black87.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            // Sign in buttons
                            Consumer<AuthProvider>(
                              builder: (context, auth, child) {
                                return Column(
                                  children: [
                                    // Apple Sign In Button
                                    ElevatedButton(
                                      onPressed: () {
                                        auth.signInWithGoogle(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        minimumSize:
                                            const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          side: BorderSide(
                                              color: ColorClass.black87
                                                  .withOpacity(0.2)),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/icons/google-icon.png',
                                            height: 24,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Continue with Google',
                                            style: GoogleFonts.openSans(
                                              color: themeProvider.isDarkMode
                                                  ? ColorClass.black
                                                  : ColorClass.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    // Google Sign In Button
                                    ElevatedButton(
                                      onPressed: () {
                                        auth.signInWithApple(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            themeProvider.isDarkMode
                                                ? ColorClass.black
                                                : ColorClass.white,
                                        minimumSize:
                                            const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          side: BorderSide(
                                              color: ColorClass.black87
                                                  .withOpacity(0.2)),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/icons/apple.png',
                                            height: 24,
                                            color: themeProvider.isDarkMode
                                                ? ColorClass.white
                                                : ColorClass.black,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Continue with Apple',
                                            style: GoogleFonts.openSans(
                                              color: themeProvider.isDarkMode
                                                  ? ColorClass.white
                                                  : ColorClass.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            // const SizedBox(height: 10),
                            // Skip sign in option
                            TextButton(
                              onPressed: () {
                                navigatePR(
                                  context: context,
                                  screen: const LanguageSelection(),
                                );
                              },
                              child: Text(
                                'Continue without account',
                                style: GoogleFonts.openSans(
                                  color: themeProvider.isDarkMode
                                      ? ColorClass.white
                                      : ColorClass.black87.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.openSans(
                                    color: themeProvider.isDarkMode
                                        ? ColorClass.white
                                        : ColorClass.black87.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                  children: [
                                    const TextSpan(
                                        text:
                                            'By continuing, you agree to our '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.blue,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          launchURL(
                                              ApiContants.privaryPolicyUrl);
                                        },
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Terms of Use',
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.blue,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          launchURL(
                                              ApiContants.privaryPolicyUrl);
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Loading indicator overlay
                // Consumer<AuthProvider>(
                //   builder: (context, auth, child) {
                //     if (auth.isLoading) {
                //       return const Center(
                //         child: CupertinoActivityIndicator(
                //           radius: 10,
                //           color: ColorClass.black,
                //         ),
                //       );
                //     } else {
                //       return const SizedBox.shrink();
                //     }
                //   },
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
