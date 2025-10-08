import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/screens/quiz/provider/quiz_provider.dart';
import 'package:zaitoon/screens/quiz/screens/quiz_result_detail_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zaitoon/providers/theme_provider.dart';

class QuizHomeScreen extends StatefulWidget {
  const QuizHomeScreen({super.key});

  @override
  State<QuizHomeScreen> createState() => _QuizHomeScreenState();
}

class _QuizHomeScreenState extends State<QuizHomeScreen> {
  bool _isDownloadingCertificate = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<QuizProvider>().loadQuizConfig();
    });
  }

  Widget _buildStartQuizButton(
      BuildContext context, QuizProvider quizProvider) {
    return FutureBuilder<bool>(
      future: quizProvider.canAttemptQuiz(),
      builder: (context, snapshot) {
        final bool canAttempt = snapshot.data ?? false;
        final isDark = context.read<ThemeProvider>().isDarkMode;
        // Determine button text based on different states
        String buttonText;
        if (snapshot.connectionState == ConnectionState.waiting) {
          buttonText = 'Checking...';
        } else if (canAttempt) {
          buttonText = 'Start Now';
        } else {
          // Check if quiz hasn't started yet or already attempted
          if (quizProvider.quizConfig != null) {
            final now = DateTime.now();
            if (now.isBefore(quizProvider.quizConfig!.startDate)) {
              buttonText = 'Quiz Not Started Yet';
            } else {
              buttonText = 'Quiz Already Attempted';
            }
          } else {
            buttonText = 'Quiz Already Attempted';
          }
        }

        // When quiz cannot be attempted and we're not loading, show a message instead of a disabled button
        if (!canAttempt &&
            snapshot.connectionState != ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              buttonText,
              textAlign: TextAlign.center,
              style: TextStyleClass.fredoka(
                fontSize: 24,
                color: isDark? Colors.white : ColorClass.black,
              ),
            ),
          );
        }

        return Container(
          width: 215,
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: canAttempt
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColorClass.grad1,
                      ColorClass.grad2,
                      ColorClass.grad3,
                    ],
                  )
                : null,
            //color: canAttempt ? null : Colors.black,
          ),
          child: ElevatedButton(
            onPressed: !canAttempt
                ? null // Disable button if quiz time is over or already attempted
                : () async {
                    _showLanguageSelectionDialog(context, quizProvider);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              buttonText,
              style: TextStyleClass.fredoka(
                color: canAttempt ? Colors.white : isDark? Colors.white : Colors.black,
                fontSize: 18,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness:
            isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );
    return Scaffold(
      backgroundColor: isDark? ColorClass.black : ColorClass.white,
      body: SafeArea(
        child: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            if (quizProvider.isLoading) {
              return _buildLoadingState();
            }

            if (quizProvider.error != null) {
              return _buildErrorState(quizProvider.error!, quizProvider);
            }

            return Scaffold(
              backgroundColor: isDark? ColorClass.black : Colors.white,
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAppBar(context),
                      const SizedBox(height: 16),
                      _buildWelcomeSection(quizProvider),
                      const SizedBox(height: 30),
                      _buildStartQuizButton(context, quizProvider),
                      const SizedBox(height: 40),
                      _buildStatisticsSection(quizProvider),
                      const SizedBox(height: 32),
                      _buildQuizHistorySection(quizProvider, context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: ColorClass.violet30,
      ),
    );
  }

  Widget _buildErrorState(String error, QuizProvider quizProvider) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyleClass.openSansSemiBold(
                fontSize: 18,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyleClass.openSans(
                fontSize: 14,
                color: isDark? Colors.white : ColorClass.black.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => quizProvider.startNewQuiz(),
              child: Text('Try Again', style: TextStyleClass.openSans(
                fontSize: 14,
                color: isDark? Colors.white : ColorClass.black,
              ),),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
      dynamic session, QuizProvider quizProvider, BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final percentage =
        session.correctAnswers != null && session.totalQuestions > 0
            ? (session.correctAnswers / session.totalQuestions * 100)
            : 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultDetailScreen(session: session),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark? ColorClass.bg : ColorClass.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColorClass.violet30.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getGradeColor(percentage).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.fileText,
                color: _getGradeColor(percentage),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyleClass.poppinsSemiBold(
                          fontSize: 16,
                          color: isDark ? ColorClass.white : ColorClass.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getGradeColor(percentage),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _calculateGrade(percentage),
                          style: TextStyleClass.openSansSemiBold(
                            fontSize: 16,
                            color: isDark? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${session.correctAnswers}/${session.totalQuestions} correct • ${_formatTime(session.totalTimeTaken ?? 0)}',
                    style: TextStyleClass.poppinsRegular(
                      fontSize: 12,
                      color: isDark? Colors.white : ColorClass.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.chevronRight,
              color: isDark? Colors.white : ColorClass.black,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  String _calculateGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    if (percentage >= 40) return 'D';
    return 'F';
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [
                  Color(0xFFAC28DC),
                  Color(0xFF7E1EB7),
                  Color(0xFF501392),
                ],
                stops: [0.0, 0.50, 1.0],
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
            },
            blendMode: BlendMode.srcIn,
            child: Text(
              'Quiz challenge',
              textAlign: TextAlign.center,
              style: TextStyleClass.fredoka(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(QuizProvider quizProvider) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Quiz Home Image
          Container(
            width: 250,
            height: 236,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                ImageClass.quizHome,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorClass.primaryColor.withOpacity(0.1),
                          ColorClass.primaryColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.brain,
                        size: 64,
                        color: ColorClass.violet30,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          //const SizedBox(height: 20),

          // Welcome Text

          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [
                  Color(0xFFAC28DC),
                  Color(0xFF7E1EB7),
                  Color(0xFF501392),
                ],
                stops: [0.0, 0.50, 1.0],
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
            },
            blendMode: BlendMode.srcIn,
            child: Text(
              'Ready for a Challenge?',
              textAlign: TextAlign.center,
              style: TextStyleClass.fredoka(
                fontSize: 20,
                color: isDark? Colors.white : ColorClass.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Quiz Schedule
          if (quizProvider.quizConfig != null) ...[
            Text(
              'Start : ${_formatDateTime(quizProvider.quizConfig!.startDate)}',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'End : ${_formatDateTime(quizProvider.quizConfig!.endDate)}',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                color: Colors.deepOrangeAccent.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Every question is a step closer to victory—are you ready?',
              textAlign: TextAlign.center,
              style: TextStyleClass.openSans(
                color: isDark? Colors.white :  Color(0xCC000000),
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    // Convert UTC to local time
    final localDateTime = dateTime.toLocal();

    // Format: DD/MM/YYYY HH:MM AM/PM
    final day = localDateTime.day.toString().padLeft(2, '0');
    final month = localDateTime.month.toString().padLeft(2, '0');
    final year = localDateTime.year;

    // Get hour in 12-hour format
    int hour = localDateTime.hour % 12;
    hour = hour == 0 ? 12 : hour; // Convert 0 to 12 for 12 AM

    // Get AM/PM
    final period = localDateTime.hour < 12 ? 'AM' : 'PM';
    final minute = localDateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute $period';
  }

  Widget _buildStatisticsSection(QuizProvider quizProvider) {
    final stats = quizProvider.quizStatistics;
    final isDark = context.read<ThemeProvider>().isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Statistics',
            textAlign: TextAlign.center,
            style: TextStyleClass.openSansSemiBold(
              color: isDark? Colors.white : Colors.black,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: LucideIcons.trophy,
                  title: 'Quizzes Taken',
                  value: '${stats['totalQuizzes'] ?? 0}',
                  iconColor: const Color(0xFFAC28DC),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: LucideIcons.target,
                  title: 'Best Score',
                  value: '${(stats['bestScore'] ?? 0.0).toStringAsFixed(1)}%',
                  iconColor: const Color(0xFFAC28DC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: LucideIcons.barChart3,
                  title: 'Average Score',
                  value:
                      '${(stats['averageScore'] ?? 0.0).toStringAsFixed(1)}%',
                  iconColor: const Color(0xFFAC28DC),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: LucideIcons.timer,
                  title: 'Time Spent',
                  value: _formatTotalTime(stats['totalTimeSpent'] ?? 0),
                  iconColor: const Color(0xFFAC28DC),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    return Container(
      width: 171,
      height: 102,
      decoration: BoxDecoration(
        color: isDark? Colors.white : Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Icon background circle
          Positioned(
            left: 6,
            top: 6,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFAC28DC),
                    Color(0xFF7E1EB7),
                    Color(0xFF501392)
                  ],
                  stops: [0, 0.50, 1],
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          // Value text
          Positioned(
            left: 75,
            top: 19,
            child: Text(
              value,
              style: TextStyleClass.fredoka(
                color: iconColor == const Color(0xFFAC28DC)
                    ? const Color(0xFFAC28DC)
                    : isDark? Colors.white.withOpacity(0.5) :Color(0x3F000000),
                fontSize: 30,
              ),
            ),
          ),
          // Title text
          Positioned(
            left: 31,
            top: 65,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyleClass.openSans(
                color: isDark? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizHistorySection(
      QuizProvider quizProvider, BuildContext context) {
    final history = quizProvider.quizHistory;
    final isDark = context.read<ThemeProvider>().isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Recent Quizzes',
                style: TextStyleClass.openSansSemiBold(
                  fontSize: 20,
                  color: isDark?Colors.white : ColorClass.black,
                ),
              ),
              if (quizProvider.canDownloadCertificate)
                ElevatedButton.icon(
                  onPressed: _isDownloadingCertificate
                      ? null
                      : () async {
                          setState(() {
                            _isDownloadingCertificate = true;
                          });

                          try {
                            final result =
                                await quizProvider.downloadCertificate();
                            if (context.mounted) {
                              if (Platform.isIOS && result['isBase64'] == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Certificate download is not supported on iOS simulator'),
                                    backgroundColor: Colors.deepPurpleAccent,
                                  ),
                                );
                                return;
                              }

                              // Show success dialog with share option
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: ColorClass.white,
                                  title: Row(
                                    children: [
                                      const Icon(LucideIcons.award,
                                          color: Colors.green),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Success',
                                        style: TextStyleClass.poppinsSemiBold(
                                          fontSize: 18,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        result['message'] ??
                                            'Certificate generated successfully!',
                                        style: TextStyleClass.openSans(
                                          fontSize: 14,
                                          color: isDark? Colors.white: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      if (result['isBase64'] == true)
                                        Container(
                                          constraints: BoxConstraints(
                                            maxHeight: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.4,
                                          ),
                                          child: Image.memory(
                                            base64Decode(
                                                result['data'].split(',')[1]),
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Close',
                                        style: TextStyleClass.openSans(
                                          fontSize: 14,
                                          color: isDark? Colors.white: ColorClass.black87,
                                        ),
                                      ),
                                    ),
                                    if (!Platform.isIOS &&
                                        result['isBase64'] == true)
                                      ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            // Save image to temporary file
                                            final tempDir =
                                                await getTemporaryDirectory();
                                            final file = File(
                                                '${tempDir.path}/certificate.png');
                                            await file.writeAsBytes(base64Decode(
                                                result['data'].split(',')[1]));

                                            // Share the file
                                            await Share.shareXFiles(
                                              [XFile(file.path)],
                                              text: 'My Quiz Certificate',
                                            );
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Failed to share certificate: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              ColorClass.violet30,
                                        ),
                                        child: Text(
                                          'Share',
                                          style: TextStyleClass.openSans(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: isDark? Colors.black : ColorClass.white,
                                  title: Row(
                                    children: [
                                      const Icon(LucideIcons.alertTriangle,
                                          color: Colors.red),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Error',
                                        style: TextStyleClass.openSansSemiBold(
                                          fontSize: 18,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                    style: TextStyleClass.openSans(
                                      fontSize: 14,
                                      color: isDark? Colors.white : ColorClass.black87,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'OK',
                                        style: TextStyleClass.openSans(
                                          fontSize: 14,
                                          color: isDark? Colors.white : ColorClass.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isDownloadingCertificate = false;
                              });
                            }
                          }
                        },
                  icon: _isDownloadingCertificate
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                ColorClass.violet30),
                          ),
                        )
                      : const Icon(LucideIcons.download),
                  label: Text(
                    _isDownloadingCertificate ? 'Downloading...' : 'Certificate',
                    style: TextStyleClass.openSans(
                      fontSize: 14,
                      color: ColorClass.violet30,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (history.isEmpty)
            _buildEmptyHistory()
          else
            ...history.take(5).map(
                (session) => _buildHistoryItem(session, quizProvider, context)),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark? Colors.white.withOpacity(0.1) : ColorClass.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.history,
            size: 48,
            color: isDark? Colors.white : Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            'No quiz history yet',
            style: TextStyleClass.openSansSemiBold(
              fontSize: 16,
              color: ColorClass.violet30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your first quiz to see your progress!',
            style: TextStyleClass.openSans(
              fontSize: 14,
              color: isDark? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTotalTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  void _showLanguageSelectionDialog(
      BuildContext context, QuizProvider quizProvider) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: isDark? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ColorClass.violet30,
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Quiz Language',
                style: TextStyleClass.fredoka(
                  fontSize: 18,
                  color: isDark? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ColorClass.grad1,
                            ColorClass.grad2,
                            ColorClass.grad3,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          quizProvider.changeLanguage('en');
                          Navigator.pop(context);
                          try {
                            await quizProvider
                                .loadQuizConfig(); // Load quiz config first
                            await quizProvider.startNewQuiz();
                          } catch (e) {
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: isDark? Colors.black : ColorClass.white,
                                  title: Row(
                                    children: [
                                      const Icon(LucideIcons.alertTriangle,
                                          color: Colors.red),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Error',
                                        style: TextStyleClass.poppinsSemiBold(
                                          fontSize: 18,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                    style: TextStyleClass.openSans(
                                      fontSize: 14,
                                      color: isDark? Colors.white : ColorClass.black87,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'OK',
                                        style: TextStyleClass.poppinsMedium(
                                          fontSize: 14,
                                          color: isDark? Colors.white : ColorClass.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'English',
                          style: TextStyleClass.fredoka(
                            fontSize: 16,
                            color: isDark? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ColorClass.grad1,
                            ColorClass.grad2,
                            ColorClass.grad3,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          quizProvider.changeLanguage('ml');
                          Navigator.pop(context);
                          try {
                            await quizProvider
                                .loadQuizConfig(); // Load quiz config first
                            await quizProvider.startNewQuiz();
                          } catch (e) {
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: isDark? Colors.black : ColorClass.white,
                                  title: Row(
                                    children: [
                                      const Icon(LucideIcons.alertTriangle,
                                          color: Colors.red),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Error',
                                        style: TextStyleClass.poppinsSemiBold(
                                          fontSize: 18,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                    style: TextStyleClass.openSans(
                                      fontSize: 14,
                                      color: isDark? Colors.white : ColorClass.black87,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'OK',
                                        style: TextStyleClass.poppinsMedium(
                                          fontSize: 14,
                                          color: isDark? Colors.white : ColorClass.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'മലയാളം',
                          style: TextStyleClass.fredoka(
                            fontSize: 16,
                            color: isDark? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
