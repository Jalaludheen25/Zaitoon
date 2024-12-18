import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';

class SubmissionAcknowledgmentScreen extends StatelessWidget {
  const SubmissionAcknowledgmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7C53F4), Color(0xFF4A25AA)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 150,
                            child: Lottie.asset(
                              'assets/animations/success.json',
                              repeat: false,
                              delegates: LottieDelegates(
                                values: [
                                  ValueDelegate.color(
                                    const ['**'],
                                    value: const Color(0xFF7C53F4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeIn(
                            delay: const Duration(milliseconds: 800),
                            duration: const Duration(milliseconds: 800),
                            child: ShakeX(
                              delay: const Duration(milliseconds: 1600),
                              duration: const Duration(milliseconds: 1000),
                              child: Text(
                                'Successfully Submitted!',
                                style: GoogleFonts.fredoka(
                                  fontSize: 24,
                                  color: const Color(0xFF7C53F4),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeIn(
                            delay: const Duration(milliseconds: 1200),
                            duration: const Duration(milliseconds: 800),
                            child: Text(
                              'Thank you for sharing your details with us!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeIn(
                            delay: const Duration(milliseconds: 1400),
                            duration: const Duration(milliseconds: 800),
                            child: Text(
                              '🎉 We\'ll get back to you soon! 🎉',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.quicksand(
                                fontSize: 14,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ZoomIn(
                    delay: const Duration(milliseconds: 1600),
                    duration: const Duration(milliseconds: 800),
                    child: Pulse(
                      delay: const Duration(milliseconds: 2400),
                      duration: const Duration(milliseconds: 1500),
                      infinite: true,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF7C53F4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.home),
                            const SizedBox(width: 8),
                            Text(
                              'Back to Home',
                              style: GoogleFonts.fredoka(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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
}
