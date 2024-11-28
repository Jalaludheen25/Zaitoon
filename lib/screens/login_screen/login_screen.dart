import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:zaitoon/constants/app_constants.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/helper/url_launcher.dart';
import 'package:zaitoon/screens/language_selection/language_selection.dart';
import 'package:zaitoon/screens/login_screen/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mascot character container
              Container(
                decoration: BoxDecoration(
                  // color: ColorClass.teal[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Image.asset(
                    ImageClass.appIconPlain,
                    height: MediaQuery.sizeOf(context).height * 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Headline text
              Text(
                'Welcome to Zai Toon',
                style: TextStyleClass.poppinsNormal(
                    fontSize: 22, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Interactive stories with sound effects as you read along',
                style: TextStyleClass.poppinsNormal(
                  fontSize: 16,
                  color: ColorClass.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Sign in buttons
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return Column(
                    children: [
                      Visibility(
                        visible: Platform.isIOS,
                        child: ElevatedButton(
                          onPressed: () {
                            auth.signInWithApple(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorClass.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.apple, color: ColorClass.black),
                              const SizedBox(width: 8),
                              Text(
                                'Continue with Apple',
                                style: TextStyleClass.poppinsNormal(
                                  color: ColorClass.black,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          auth.signInWithGoogle(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorClass.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/google-icon.png', // Add Google logo asset
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Continue with Google',
                              style: TextStyleClass.poppinsNormal(
                                color: ColorClass.black,
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
              const SizedBox(height: 24),

              // Skip sign in option
              TextButton(
                onPressed: () {
                  navigatePR(
                      context: context, screen: const LanguageSelection());
                },
                child: Text(
                  'Continue without account',
                  style: TextStyleClass.poppinsNormal(
                    color: ColorClass.white70,
                    fontSize: 14,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyleClass.poppinsNormal(
                      color: ColorClass.white70,
                      fontSize: 12,
                    ),
                    children: [
                      const TextSpan(text: 'By continuing, you agree to our '),
                      TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchURL(ApiContants.privaryPolicyUrl);
                            }),
                      const TextSpan(text: ' and '),
                      TextSpan(
                          text: 'Terms of Use',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchURL(ApiContants.privaryPolicyUrl);
                            }),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
