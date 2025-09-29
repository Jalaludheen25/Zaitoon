import 'package:google_fonts/google_fonts.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:flutter/material.dart';

const String primaryFontName = 'Poppins';

class TextStyleClass {
  static const double textHeight = 1.3;

  static TextStyle black16_400 = const TextStyle(
      fontFamily: primaryFontName,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: ColorClass.black);

  static TextStyle primaryFont300(double size, Color color) => TextStyle(
      fontFamily: primaryFontName,
      fontWeight: FontWeight.w300,
      color: color,
      height: textHeight,
      fontSize: size);

  static TextStyle primaryFont600(double size, Color color) => TextStyle(
      fontFamily: primaryFontName,
      fontWeight: FontWeight.w600,
      color: color,
      height: textHeight,
      fontSize: size);

  static TextStyle poppinsRegular(
          {required double fontSize, required Color color}) =>
      GoogleFonts.poppins(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
      );

  static TextStyle poppinsMedium(
          {required double fontSize, required Color color}) =>
      GoogleFonts.poppins(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      );
  static TextStyle poppinsBold(
          {required double fontSize, required Color color}) =>
      GoogleFonts.poppins(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      );

  static TextStyle poppinsSemiBold(
          {required double fontSize, required Color color}) =>
      GoogleFonts.poppins(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      );
  static TextStyle manjariSemiBold(
          {required double fontSize, required Color color}) =>
      GoogleFonts.anekMalayalam(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      );
  static TextStyle fredoka(
          {required double fontSize, required Color color}) =>
      GoogleFonts.fredoka(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      );
  static TextStyle fredokaRegular(
          {required double fontSize, required Color color}) =>
      GoogleFonts.fredoka(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
      );
  static TextStyle openSans(
          {required double fontSize, required Color color}) =>
      GoogleFonts.openSans(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
      );
  static TextStyle openSansSemiBold(
          {required double fontSize, required Color color}) =>
      GoogleFonts.openSans(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      );
}
