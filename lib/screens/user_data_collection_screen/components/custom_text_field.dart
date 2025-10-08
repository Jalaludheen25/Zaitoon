import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/providers/theme_provider.dart';
import 'package:zaitoon/constants/textstyle_class.dart';

class CustomTextField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.title,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyleClass.fredoka(
                fontSize: 16,
                color: themeProvider.isDarkMode
                    ? ColorClass.white
                    : ColorClass.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? ColorClass.black.withOpacity(0.3)
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: themeProvider.isDarkMode
                      ? ColorClass.white.withOpacity(0.3)
                      : ColorClass.black87.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorClass.black87.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.openSans(
                    color: themeProvider.isDarkMode
                        ? ColorClass.white.withOpacity(0.5)
                        : ColorClass.black87.withOpacity(0.4),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                style: GoogleFonts.openSans(
                  fontSize: 15,
                  color: themeProvider.isDarkMode
                      ? ColorClass.white
                      : ColorClass.black,
                ),
                validator: validator,
              ),
            ),
          ],
        );
      },
    );
  }
}
