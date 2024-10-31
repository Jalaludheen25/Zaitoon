import 'package:d4tales/constants/color_class.dart';
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
}
