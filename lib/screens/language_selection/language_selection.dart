// ignore_for_file: use_build_context_synchronously

import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/aknowledge_screen/aknowledge_screen.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LanguageSelection extends StatelessWidget {
  const LanguageSelection({super.key});

  void _showLanguageNotAvailableDialog(BuildContext context, String languageName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColorClass.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: ColorClass.primaryColor.withOpacity(0.3)),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: ColorClass.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Coming Soon!',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorClass.white,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$languageName content is not available yet.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: ColorClass.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please select English or Malayalam to enjoy our stories.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: ColorClass.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: ColorClass.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.black,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorClass.primaryColor.withOpacity(0.15),
                ColorClass.black,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Title with accent
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorClass.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border:
                        Border.all(color: ColorClass.primaryColor, width: 1),
                  ),
                  child: Text(
                    "Select Your Language",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: ColorClass.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                // Mascot with glow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: ColorClass.primaryColor.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    ImageClass.language,
                    height: MediaQuery.sizeOf(context).height * 0.15,
                  ),
                ),
                const Spacer(),
                // Headline text with gradient
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      ColorClass.primaryColor,
                      ColorClass.white,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    "Choose Your Reading Language",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle with better styling
                Text(
                  'Select your preferred language for stories\nYou can change it anytime later',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: ColorClass.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Language buttons
                Consumer<HomeProvider>(
                  builder: (context, snapshot, child) {
                    return Column(
                      children: [
                        // First row: English and Malayalam
                        Row(
                          children: [
                            _buildLanguageButton(
                              context: context,
                              isSelected: snapshot.selectedLanguage == "en",
                              onPressed: () {
                                snapshot.saveSelectedLanguage("en").then((_) {
                                  navigatePR(
                                    context: context,
                                    screen: const AknowledgeScreen(),
                                  );
                                });
                              },
                              label: 'English',
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                            const SizedBox(width: 12),
                            _buildLanguageButton(
                              context: context,
                              isSelected: snapshot.selectedLanguage == "ml",
                              onPressed: () {
                                snapshot.saveSelectedLanguage("ml").then((_) {
                                  navigatePR(
                                    context: context,
                                    screen: const AknowledgeScreen(),
                                  );
                                });
                              },
                              label: 'മലയാളം',
                              fontFamily: GoogleFonts.manjari().fontFamily,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Second row: Hindi and Urdu
                        Row(
                          children: [
                            _buildLanguageButton(
                              context: context,
                              isSelected: snapshot.selectedLanguage == "hi",
                              onPressed: () {
                                _showLanguageNotAvailableDialog(context, 'Hindi');
                              },
                              label: 'हिंदी',
                              fontFamily: GoogleFonts.notoSansDevanagari().fontFamily,
                            ),
                            const SizedBox(width: 12),
                            _buildLanguageButton(
                              context: context,
                              isSelected: snapshot.selectedLanguage == "ur",
                              onPressed: () {
                                _showLanguageNotAvailableDialog(context, 'Urdu');
                              },
                              label: 'اردو',
                              fontFamily: GoogleFonts.notoSansArabic().fontFamily,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildLanguageButton({
    required BuildContext context,
    required bool isSelected,
    required VoidCallback onPressed,
    required String label,
    required String? fontFamily,
  }) {
    return Expanded(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    ColorClass.primaryColor,
                    ColorClass.primaryColor.withOpacity(0.8),
                  ],
                )
              : null,
          border: Border.all(
            color: isSelected ? Colors.transparent : ColorClass.primaryColor,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ColorClass.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: fontFamily,
                  color:
                      isSelected ? ColorClass.white : ColorClass.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
