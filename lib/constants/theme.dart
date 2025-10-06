import 'package:zaitoon/constants/color_class.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: ColorClass.white,
      fontFamily: 'openSans',
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
          color: ColorClass.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: ColorClass.black),
          titleTextStyle: GoogleFonts.openSans(color: ColorClass.black)),
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.openSans(color: ColorClass.neutral900),
        bodyMedium: GoogleFonts.openSans(color: ColorClass.neutral900),
        bodySmall: GoogleFonts.openSans(color: ColorClass.neutral900),
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

  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: ColorClass.black,
    fontFamily: 'openSans',
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorClass.black,
      foregroundColor: ColorClass.white,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: ColorClass.bg,
      iconTheme: IconThemeData(color: ColorClass.white),
      titleTextStyle: TextStyle(
        color: ColorClass.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    cardColor: ColorClass.bg,
    canvasColor: ColorClass.bg,
    colorScheme: const ColorScheme.dark(
      primary: ColorClass.black,
      secondary: ColorClass.violet30,
      onPrimary: ColorClass.white,
      onSecondary: ColorClass.white,
      onSurface: ColorClass.white,
      onBackground: ColorClass.white,
    ),
  );
}

const OutlineInputBorder outlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(28)),
  borderSide: BorderSide(color: ColorClass.neutral900),
  gapPadding: 10,
);
