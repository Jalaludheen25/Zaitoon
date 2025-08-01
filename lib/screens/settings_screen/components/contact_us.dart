import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../constants/color_class.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ColorClass.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Contact us',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Title and Subtitle
            Text(
              'Get in Touch',
              style: GoogleFonts.poppins(
                color: ColorClass.black,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We'd love to hear from you",
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            // Contact Information Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ColorClass.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Phone Section
                  _buildContactSection(
                    icon: LucideIcons.phone,
                    title: 'Phone',
                    detail: '+91 99466 66139',
                  ),

                  const Divider(
                    color: Colors.white24,
                    height: 32,
                  ),

                  // Email Section
                  _buildContactSection(
                    icon: LucideIcons.mail,
                    title: 'Email',
                    detail: 'mail@d4dx.co',
                  ),

                  const Divider(
                    color: Colors.white24,
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
  }

  Widget _buildContactSection({
    required IconData icon,
    required String title,
    required String detail,
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon Container
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4A90E2), // Light blue color
            size: 24,
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
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  height: isMultiLine ? 1.4 : 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
