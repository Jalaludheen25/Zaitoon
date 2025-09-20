// ignore_for_file: use_build_context_synchronously

import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/user_data_collection_screen/user_data_collection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LanguageSelection extends StatelessWidget {
  const LanguageSelection({super.key});

  Future<void> _handleLanguageSelection(BuildContext context) async {
    // After language selection, always go to UserDataCollection screen
    // This ensures the proper flow: Language Selection → UserDataCollection → Home
    navigateAndRemove(
      context: context,
      screen: const UserDataCollection(
        isFromOnboarding: true,
      ),
    );
  }

  void _showLanguageNotAvailableDialog(
      BuildContext context, String languageName) {
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
    // Set system UI overlay style for white status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageClass.languageBg),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: Stack(
          children: [
            // Content positioned at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            ColorClass.grad1,
                            ColorClass.grad2,
                            ColorClass.grad3,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          "Choose Your Reading\nLanguage",
                          style: GoogleFonts.fredoka(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Subtitle with better styling
                      Text(
                        'Select your language for stories\nyou can change it anytime later',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          color: ColorClass.black87.withOpacity(0.8),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
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
                                    isSelected:
                                        snapshot.selectedLanguage == "en" ||
                                            snapshot.selectedLanguage.isEmpty,
                                    onPressed: () async {
                                      await snapshot.saveSelectedLanguage("en");
                                    },
                                    label: 'English',
                                    fontFamily:
                                        GoogleFonts.openSans().fontFamily,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildLanguageButton(
                                    context: context,
                                    isSelected:
                                        snapshot.selectedLanguage == "ml",
                                    onPressed: () async {
                                      await snapshot.saveSelectedLanguage("ml");
                                    },
                                    label: 'മലയാളം',
                                    fontFamily: GoogleFonts.notoSansMalayalam()
                                        .fontFamily,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Second row: Hindi and Urdu
                              Row(
                                children: [
                                  _buildLanguageButton(
                                    context: context,
                                    isSelected:
                                        snapshot.selectedLanguage == "hi",
                                    onPressed: () {
                                      _showLanguageNotAvailableDialog(
                                          context, 'Hindi');
                                    },
                                    label: 'हिंदी',
                                    fontFamily:
                                        GoogleFonts.openSans().fontFamily,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildLanguageButton(
                                    context: context,
                                    isSelected:
                                        snapshot.selectedLanguage == "ur",
                                    onPressed: () {
                                      _showLanguageNotAvailableDialog(
                                          context, 'Urdu');
                                    },
                                    label: 'اردو',
                                    fontFamily:
                                        GoogleFonts.openSans().fontFamily,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      // Next button with gradient
                      SizedBox(
                        width: 220,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to next screen when a language is selected
                            final homeProvider = Provider.of<HomeProvider>(
                                context,
                                listen: false);
                            if (homeProvider.selectedLanguage.isNotEmpty ||
                                homeProvider.selectedLanguage == "en") {
                              _handleLanguageSelection(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  ColorClass.grad1,
                                  ColorClass.grad2,
                                  ColorClass.grad3,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                'Next',
                                style: GoogleFonts.fredoka(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
      child: SizedBox(
        width: 145.0,
        height: 60.0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? ColorClass.violet30
                      : ColorClass.black87.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 0.0,
                          blurRadius: 2.0,
                          offset: const Offset(0.0, 1.0),
                        ),
                      ]
                    : null,
                color: Colors.white,
              ),
              child: Stack(
                children: [
                  // Background overlay for selected state
                  if (isSelected)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: ColorClass.violet30.withOpacity(0.15),
                      ),
                    ),

                  // Icon container
                  Positioned(
                    top: 15.0,
                    left: 10.0,
                    child: Container(
                      width: 30.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? null
                            : const LinearGradient(
                                colors: [
                                  ColorClass.grad1,
                                  ColorClass.grad2,
                                  ColorClass.grad3,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        color: isSelected
                            ? ColorClass.violet30.withOpacity(0.15)
                            : null,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Center(
                        child: Text(
                          _getLanguageIcon(label),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color:
                                isSelected ? ColorClass.black87 : Colors.white,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Main language text
                  Positioned(
                    left: 50.0,
                    top: 13.0,
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        color: ColorClass.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.0,
                      ),
                    ),
                  ),

                  // Secondary language text
                  Positioned(
                    left: 50.0,
                    top: 35.0,
                    child: Text(
                      _getLanguageSecondaryText(label),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 11.0,
                        color: ColorClass.black87,
                      ),
                    ),
                  ),

                  // Tick circle for selected state
                  if (isSelected)
                    Positioned(
                      right: 10.0,
                      top: 10.0,
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorClass.violet30,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getLanguageIcon(String label) {
    switch (label) {
      case 'English':
        return 'E';
      case 'മലയാളം':
        return 'മ';
      case 'हिंदी':
        return 'ह';
      case 'اردو':
        return 'ا';
      default:
        return label[0];
    }
  }

  String _getLanguageSecondaryText(String label) {
    switch (label) {
      case 'English':
        return 'English';
      case 'മലയാളം':
        return 'Malayalam';
      case 'हिंदी':
        return 'Hindi';
      case 'اردو':
        return 'Urdu';
      default:
        return label;
    }
  }
}
