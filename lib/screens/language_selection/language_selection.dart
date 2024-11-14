// ignore_for_file: use_build_context_synchronously

import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/aknowledge_screen/aknowledge_screen.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LanguageSelection extends StatelessWidget {
  const LanguageSelection({super.key});

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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/tiger2.png', // Add your mascot image
                    height: MediaQuery.sizeOf(context).height * 0.4,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Headline text
              const Text(
                "Choose language for reading",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ColorClass.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              const Text(
                'Choose your preferred language to read stories, you can change it later',
                style: TextStyle(
                  fontSize: 16,
                  color: ColorClass.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Sign in buttons
              Consumer<HomeProvider>(
                builder: (context, snapshot, child) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                snapshot
                                    .saveSelectedLanguage("en")
                                    .then((value) {
                                  navigateTo(
                                      context: context,
                                      route: const AknowledgeScreen());
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor:
                                    snapshot.selectedLanguage == "en"
                                        ? ColorClass.white
                                        : ColorClass.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                      color: ColorClass.white,
                                      width: 2), // Border color and width
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'English',
                                    style: TextStyle(
                                      color: snapshot.selectedLanguage == "en"
                                          ? ColorClass.black
                                          : ColorClass.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                snapshot
                                    .saveSelectedLanguage("ml")
                                    .then((value) {
                                  navigateTo(
                                      context: context,
                                      route: const AknowledgeScreen());
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor:
                                    snapshot.selectedLanguage == "ml"
                                        ? ColorClass.white
                                        : ColorClass.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                      color: ColorClass.white,
                                      width: 2), // Border color and width
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'മലയാളം',
                                    style: GoogleFonts.manjari(
                                      color: snapshot.selectedLanguage == "ml"
                                          ? ColorClass.black
                                          : ColorClass.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     navigateTo(
                      //         context: context,
                      //         route: const AknowledgeScreen());
                      //     debugPrint(snapshot.selectedLanguage.toString());
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: ColorClass.primaryColor,
                      //     minimumSize: const Size(double.infinity, 50),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //   ),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       Text(
                      //         'Continue',
                      //         style: GoogleFonts.manrope(
                      //           color: ColorClass.white,
                      //           fontSize: 16,
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
