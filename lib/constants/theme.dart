import 'package:zaitoon/constants/color_class.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: ColorClass.white,
      fontFamily: 'Poppins',
      appBarTheme: AppBarTheme(
          color: ColorClass.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: ColorClass.black),
          titleTextStyle: GoogleFonts.poppins(color: ColorClass.black)),
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.poppins(color: ColorClass.neutral900),
        bodyMedium: GoogleFonts.poppins(color: ColorClass.neutral900),
        bodySmall: GoogleFonts.poppins(color: ColorClass.neutral900),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
        enabledBorder: outlineInputBorder,
        focusedBorder: outlineInputBorder,
        border: outlineInputBorder,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: ColorClass.primaryColor,
          foregroundColor: ColorClass.white,
          minimumSize: const Size(double.infinity, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
    );
  }
}

const OutlineInputBorder outlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(28)),
  borderSide: BorderSide(color: ColorClass.neutral900),
  gapPadding: 10,
);
