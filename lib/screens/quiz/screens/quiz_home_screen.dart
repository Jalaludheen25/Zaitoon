import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/quiz/provider/quiz_provider.dart';
import 'package:zaitoon/screens/quiz/screens/quiz_result_detail_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FutureBuilder<bool>(
        future: quizProvider.canAttemptQuiz(),
        builder: (context, snapshot) {
          final bool canAttempt = snapshot.data ?? false;

          // Determine button text based on different states
          String buttonText;
          if (snapshot.connectionState == ConnectionState.waiting) {
            buttonText = 'Checking...';
          } else if (canAttempt) {
            buttonText = 'Start Quiz';
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

          return ElevatedButton(
            onPressed: !canAttempt
                ? null // Disable button if quiz time is over or already attempted
                : () async {
                    _showLanguageSelectionDialog(context, quizProvider);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  canAttempt ? ColorClass.primaryColor : Colors.grey[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.play, size: 24),
                const SizedBox(width: 12),
                Text(
                  buttonText,
                  style: TextStyleClass.poppinsSemiBold(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.black,
      body: SafeArea(
        child: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            if (quizProvider.isLoading) {
              return _buildLoadingState();
            }

            if (quizProvider.error != null) {
              return _buildErrorState(quizProvider.error!, quizProvider);
            }

            return CustomScrollView(
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeSection(),
                        const SizedBox(height: 24),
                        _buildStartQuizButton(context, quizProvider),
                        const SizedBox(height: 32),
                        _buildStatisticsSection(quizProvider),
                        const SizedBox(height: 32),
                        _buildQuizHistorySection(quizProvider, context),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: ColorClass.primaryColor,
      ),
    );
  }

  Widget _buildErrorState(String error, QuizProvider quizProvider) {
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
              style: TextStyleClass.poppinsSemiBold(
                fontSize: 18,
                color: ColorClass.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyleClass.poppinsRegular(
                fontSize: 14,
                color: ColorClass.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => quizProvider.startNewQuiz(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
      dynamic session, QuizProvider quizProvider, BuildContext context) {
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
          color: ColorClass.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColorClass.primaryColor.withOpacity(0.2),
            width: 1,
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
                          color: ColorClass.white,
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
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${session.correctAnswers}/${session.totalQuestions} correct • ${_formatTime(session.totalTimeTaken ?? 0)}',
                    style: TextStyleClass.poppinsRegular(
                      fontSize: 12,
                      color: ColorClass.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.chevronRight,
              color: ColorClass.white.withOpacity(0.5),
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
    return SliverAppBar(
      leading: IconButton(
        icon: const Icon(
          LucideIcons.arrowLeft,
          color: ColorClass.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Quiz Challenge',
        style: TextStyleClass.poppinsSemiBold(
          fontSize: 20,
          color: ColorClass.white,
        ),
      ),
      backgroundColor: ColorClass.black,
      floating: true,
      pinned: false,
      elevation: 0,
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorClass.primaryColor.withOpacity(0.2),
                ColorClass.primaryColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🧠',
                style: TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 12),
              Text(
                'Ready for a Challenge?',
                style: TextStyleClass.poppinsSemiBold(
                  fontSize: 20,
                  color: ColorClass.white,
                ),
              ),
              const SizedBox(height: 8),
              if (quizProvider.quizConfig != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ColorClass.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.calendar,
                            color: ColorClass.primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Quiz Schedule',
                            style: TextStyleClass.poppinsMedium(
                              fontSize: 14,
                              color: ColorClass.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.play,
                            color: Colors.green,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Starts: ${_formatDateTime(quizProvider.quizConfig!.startDate)}',
                              style: TextStyleClass.poppinsRegular(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.square,
                            color: Colors.red,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ends: ${_formatDateTime(quizProvider.quizConfig!.endDate)}',
                              style: TextStyleClass.poppinsRegular(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // const SizedBox(height: 8),
                      // Row(
                      //   children: [
                      //     Icon(
                      //       LucideIcons.clock,
                      //       color: Colors.orange,
                      //       size: 14,
                      //     ),
                      //     const SizedBox(width: 8),
                      //     Expanded(
                      //       child: Text(
                      //         'Time Remaining: ${quizProvider.getFormattedRemainingTime()}',
                      //         style: TextStyleClass.poppinsRegular(
                      //           fontSize: 12,
                      //           color: Colors.orange,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Statistics',
          style: TextStyleClass.poppinsSemiBold(
            fontSize: 18,
            color: ColorClass.white,
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
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: LucideIcons.target,
                title: 'Best Score',
                value: '${(stats['bestScore'] ?? 0.0).toStringAsFixed(1)}%',
                color: Colors.green,
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
                value: '${(stats['averageScore'] ?? 0.0).toStringAsFixed(1)}%',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: LucideIcons.clock,
                title: 'Time Spent',
                value: _formatTotalTime(stats['totalTimeSpent'] ?? 0),
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyleClass.poppinsSemiBold(
              fontSize: 18,
              color: ColorClass.white,
            ),
          ),
          Text(
            title,
            style: TextStyleClass.poppinsRegular(
              fontSize: 12,
              color: ColorClass.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizHistorySection(
      QuizProvider quizProvider, BuildContext context) {
    final history = quizProvider.quizHistory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Quizzes',
              style: TextStyleClass.poppinsSemiBold(
                fontSize: 18,
                color: ColorClass.white,
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
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            // Show success dialog with share option
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: ColorClass.black,
                                title: Row(
                                  children: [
                                    const Icon(LucideIcons.award,
                                        color: Colors.green),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Success',
                                      style: TextStyleClass.poppinsSemiBold(
                                        fontSize: 18,
                                        color: ColorClass.white,
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
                                      style: TextStyleClass.poppinsRegular(
                                        fontSize: 14,
                                        color: ColorClass.white70,
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
                                      style: TextStyleClass.poppinsMedium(
                                        fontSize: 14,
                                        color: ColorClass.white70,
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
                                            ColorClass.primaryColor,
                                      ),
                                      child: Text(
                                        'Share',
                                        style: TextStyleClass.poppinsMedium(
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
                                backgroundColor: ColorClass.black,
                                title: Row(
                                  children: [
                                    const Icon(LucideIcons.alertTriangle,
                                        color: Colors.red),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Error',
                                      style: TextStyleClass.poppinsSemiBold(
                                        fontSize: 18,
                                        color: ColorClass.white,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  e.toString().replaceAll('Exception: ', ''),
                                  style: TextStyleClass.poppinsRegular(
                                    fontSize: 14,
                                    color: ColorClass.white70,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'OK',
                                      style: TextStyleClass.poppinsMedium(
                                        fontSize: 14,
                                        color: ColorClass.white70,
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(LucideIcons.download),
                label: Text(
                  _isDownloadingCertificate ? 'Downloading...' : 'Certificate',
                  style: TextStyleClass.poppinsMedium(
                    fontSize: 14,
                    color: Colors.white,
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
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ColorClass.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            LucideIcons.history,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            'No quiz history yet',
            style: TextStyleClass.poppinsMedium(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            'Start your first quiz to see your progress!',
            style: TextStyleClass.poppinsRegular(
              fontSize: 14,
              color: Colors.grey,
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey[900]!,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Quiz Language',
                style: TextStyleClass.poppinsSemiBold(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
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
                                backgroundColor: ColorClass.black,
                                title: Row(
                                  children: [
                                    const Icon(LucideIcons.alertTriangle,
                                        color: Colors.red),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Error',
                                      style: TextStyleClass.poppinsSemiBold(
                                        fontSize: 18,
                                        color: ColorClass.white,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  e.toString().replaceAll('Exception: ', ''),
                                  style: TextStyleClass.poppinsRegular(
                                    fontSize: 14,
                                    color: ColorClass.white70,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'OK',
                                      style: TextStyleClass.poppinsMedium(
                                        fontSize: 14,
                                        color: ColorClass.white70,
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
                        backgroundColor: ColorClass.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'English',
                        style: TextStyleClass.poppinsMedium(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
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
                                backgroundColor: ColorClass.black,
                                title: Row(
                                  children: [
                                    const Icon(LucideIcons.alertTriangle,
                                        color: Colors.red),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Error',
                                      style: TextStyleClass.poppinsSemiBold(
                                        fontSize: 18,
                                        color: ColorClass.white,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  e.toString().replaceAll('Exception: ', ''),
                                  style: TextStyleClass.poppinsRegular(
                                    fontSize: 14,
                                    color: ColorClass.white70,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'OK',
                                      style: TextStyleClass.poppinsMedium(
                                        fontSize: 14,
                                        color: ColorClass.white70,
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
                        backgroundColor: ColorClass.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'മലയാളം',
                        style: TextStyleClass.poppinsMedium(
                          fontSize: 16,
                          color: Colors.white,
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
