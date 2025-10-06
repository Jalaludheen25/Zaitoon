import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../constants/color_class.dart';
import '../../../constants/textstyle_class.dart';
import '../../../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      final isDark = themeProvider.isDarkMode;
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          // backgroundColor: ColorClass.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: isDark ? Colors.white : Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                ColorClass.grad1,
                ColorClass.grad2,
                ColorClass.grad3,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'Contact us',
              style: TextStyleClass.fredoka(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Title and Subtitle
              Text(
                'Get in Touch',
                style: TextStyleClass.fredoka(
                  color: isDark ? Colors.white : ColorClass.black,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "We'd love to hear from you",
                style: TextStyleClass.openSans(
                  color: isDark ? ColorClass.violet30 : Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 40),

              // Contact Information Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ColorClass.containerBg.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // Phone Section
                    _buildContactSection(
                      icon: LucideIcons.phone,
                      title: 'Phone',
                      detail: '+91 99466 66139',
                    ),

                    Divider(
                      color:isDark? Colors.white :  Colors.white24,
                      height: 32,
                    ),

                    // Email Section
                    _buildContactSection(
                      icon: LucideIcons.mail,
                      title: 'Email',
                      detail: 'mail@d4dx.co',
                    ),

                    Divider(
                      color: isDark? Colors.white : Colors.white24,
                      height: 32,
                    ),

                    // Address Section
                    _buildContactSection(
                      icon: LucideIcons.mapPin,
                      title: 'Address',
                      detail:
                          'D4DX Innovations LLP\nMavoor Road, Calicut, Kerala,\nPin 673004',
                      isMultiLine: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildContactSection({
    required IconData icon,
    required String title,
    required String detail,
    bool isMultiLine = false,
  }) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      final isDark = themeProvider.isDarkMode;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorClass.grad1,
                  ColorClass.grad2,
                  ColorClass.grad3,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white, // Light blue color
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyleClass.fredoka(
                    color: isDark ? ColorClass.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: TextStyleClass.openSans(
                    color: isDark? Colors.white: Colors.white24,
                    fontSize: 14,
                    // height: isMultiLine ? 1.4 : 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
