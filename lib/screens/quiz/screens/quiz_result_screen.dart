import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/screens/quiz/provider/quiz_provider.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';
import 'package:zaitoon/screens/quiz/screens/quiz_result_detail_screen.dart';
import 'package:flutter/services.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      backgroundColor: ColorClass.white,
      body: SafeArea(
        child: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            final result = quizProvider.currentQuizResult;
            if (quizProvider.isLoading) {
              return _buildLoadingState();
            }
            if (result == null) {
              return _buildNoResultState();
            }

            return CustomScrollView(
              slivers: [
                _buildAppBar(context, quizProvider),
                SliverToBoxAdapter(
                  child: _buildCongratulationImage(),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // _buildScoreCard(result),
                        // const SizedBox(height: 24),
                        _buildStatsSection(result, context),
                        const SizedBox(height: 17),
                        _buildResultSummary(result),
                        const SizedBox(height: 24),
                        _buildDownloadCertificateText(context, quizProvider),
                        // _buildDetailedResults(result, quizProvider),
                        // const SizedBox(height: 32),
                        _buildActionButtons(context, quizProvider, result),
                        const SizedBox(height: 24),
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

  Widget _buildAppBar(BuildContext context, QuizProvider quizProvider) {
    return SliverAppBar(
      title: _buildGradientText(),
      //backgroundColor: ColorClass.white,
      // floating: true,
      // pinned: false,
      // elevation: 0,
      // leading: IconButton(
      //   onPressed: () => _resetToHome(quizProvider),
      //   icon: const Icon(
      //     LucideIcons.chevronLeft,
      //     color: Colors.black,
      //   ),
      // ),
    );
  }

  // Widget _buildScoreCard(dynamic result) {
  //   final percentage = result.percentage;
  //   final grade = result.grade;

  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(32),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [
  //           _getGradeColor(percentage).withOpacity(0.2),
  //           _getGradeColor(percentage).withOpacity(0.1),
  //         ],
  //       ),
  //       borderRadius: BorderRadius.circular(24),
  //       border: Border.all(
  //         color: _getGradeColor(percentage).withOpacity(0.3),
  //         width: 2,
  //       ),
  //     ),
  //     child: Column(
  //       children: [
  //         Container(
  //           width: 120,
  //           height: 120,
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             color: _getGradeColor(percentage).withOpacity(0.2),
  //             border: Border.all(
  //               color: _getGradeColor(percentage),
  //               width: 4,
  //             ),
  //           ),
  //           child: Center(
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Text(
  //                   '${percentage.toStringAsFixed(1)}%',
  //                   style: TextStyle(
  //                     fontSize: 24,
  //                     fontWeight: FontWeight.bold,
  //                     color: _getGradeColor(percentage),
  //                   ),
  //                 ),
  //                 Container(
  //                   padding:
  //                       const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //                   decoration: BoxDecoration(
  //                     color: _getGradeColor(percentage),
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                   child: Text(
  //                     grade,
  //                     style: const TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.blue,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 24),
  //         _buildGradientResultText(_getResultMessage(percentage)),
  //         const SizedBox(height: 8),
  //         Text(
  //           _getEncouragementMessage(percentage),
  //           style: TextStyleClass.poppinsRegular(
  //             fontSize: 14,
  //             color: Colors.blue.withOpacity(0.8),
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildStatsSection(dynamic result, BuildContext context) {
    final session = result.session;
    final percentage =
        session.correctAnswers != null && session.totalQuestions > 0
            ? (session.correctAnswers! / session.totalQuestions * 100)
            : 0.0;
    // Get user name from user data provider
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);
    final userName = userProvider.name ?? "Student";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Score, Percentage, and Grade in same line
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGradientScoreText(),
            const SizedBox(width: 8),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyleClass.fredoka(
                fontSize: 28,
                color: _getGradeColor(percentage),
              ),
            ),
            const SizedBox(width: 8),
            _buildGradeBadge(percentage, context.read<QuizProvider>()),
          ],
        ),
        const SizedBox(height: 16),
        // User message
        Text(
          '${_getResultMessage(percentage)}.\n $userName, ${_getEncouragementMessage(percentage)}',
          textAlign: TextAlign.center,
          style: TextStyleClass.openSans(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildGradientScoreText() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFFAC28DC), // Purple
          Color(0xFF7E1EB7), // Darker purple
          Color(0xFF501392), // Dark purple
        ],
        stops: [0.0, 0.50, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: Text(
        'Your Score :',
        style: TextStyleClass.fredoka(
          fontSize: 28,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildGradeBadge(double percentage, QuizProvider quizProvider) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getGradeColor(percentage),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          quizProvider.calculateGrade(percentage),
          style: TextStyleClass.fredoka(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildResultSummary(dynamic result) {
    final session = result.session;

    return Container(
      width: 357,
      height: 114,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Correct',
            '${session.correctAnswers ?? 0}',
            Colors.green,
            LucideIcons.check,
          ),
          _buildSummaryItem(
            'Wrong',
            '${session.totalQuestions - (session.correctAnswers ?? 0)}',
            Colors.red,
            LucideIcons.x,
          ),
          _buildSummaryItem(
            'Total',
            '${session.totalQuestions}',
            Colors.blue,
            LucideIcons.fileText,
          ),
          _buildSummaryItem(
            'Time',
            _formatTime(session.totalTimeTaken ?? 0),
            Colors.orange,
            LucideIcons.timer,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, Color color, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyleClass.openSansSemiBold(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyleClass.openSansSemiBold(
            fontSize: 12,
            color: Colors.black.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadCertificateText(
      BuildContext context, QuizProvider quizProvider) {
    return GestureDetector(
      onTap: () async {
        try {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFC107),
                ),
              );
            },
          );

          // Download certificate
          final result = await quizProvider.downloadCertificate();

          // Close loading dialog
          if (context.mounted) {
            Navigator.of(context).pop();
          }

          // Show success message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    result['message'] ?? 'Certificate downloaded successfully'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          // Close loading dialog if still open
          if (context.mounted) {
            Navigator.of(context).pop();
          }

          // Show error message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to download certificate: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
      child: Text(
        'Download Your Certificate',
        style: TextStyleClass.poppinsRegular(
          fontSize: 16,
          color: const Color(0xFFFFC107),
        ).copyWith(decoration: TextDecoration.underline),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Widget _buildDetailedResults(dynamic result, QuizProvider quizProvider) {
  //   final answers = result.answers;

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Question Review',
  //         style: TextStyleClass.poppinsSemiBold(
  //           fontSize: 18,
  //           color: ColorClass.white,
  //         ),
  //       ),
  //       const SizedBox(height: 16),
  //       ...answers.asMap().entries.map((entry) {
  //         final index = entry.key;
  //         final answer = entry.value;
  //         return _buildQuestionReviewCard(index + 1, answer);
  //       }).toList(),
  //     ],
  //   );
  // }

  // Widget _buildQuestionReviewCard(int questionNumber, dynamic answer) {
  //   final isCorrect = answer.isCorrect;
  //   final selectedAnswer = answer.selectedAnswer;
  //   final correctAnswer = answer.correctAnswer;
  //   final options = answer.options;
  //   final timeTaken = answer.timeTaken;

  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 16),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: ColorClass.white.withOpacity(0.05),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: isCorrect
  //             ? Colors.green.withOpacity(0.3)
  //             : Colors.red.withOpacity(0.3),
  //         width: 1,
  //       ),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //               decoration: BoxDecoration(
  //                 color: isCorrect ? Colors.green : Colors.red,
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Icon(
  //                     isCorrect ? LucideIcons.check : LucideIcons.x,
  //                     color: Colors.white,
  //                     size: 16,
  //                   ),
  //                   const SizedBox(width: 4),
  //                   Text(
  //                     'Q$questionNumber',
  //                     style: const TextStyle(
  //                       fontSize: 12,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             const Spacer(),
  //             Text(
  //               '${timeTaken}s',
  //               style: TextStyleClass.poppinsRegular(
  //                 fontSize: 12,
  //                 color: ColorClass.white.withOpacity(0.7),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         Text(
  //           answer.question,
  //           style: TextStyleClass.poppinsMedium(
  //             fontSize: 14,
  //             color: ColorClass.white,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         ...options.asMap().entries.map((optionEntry) {
  //           final optionIndex = optionEntry.key;
  //           final optionText = optionEntry.value;
  //           final isSelected = selectedAnswer == optionIndex;
  //           final isCorrectOption = correctAnswer == optionIndex;

  //           Color backgroundColor = Colors.transparent;
  //           Color borderColor = ColorClass.white.withOpacity(0.2);
  //           Color textColor = ColorClass.white.withOpacity(0.8);

  //           if (isSelected && isCorrectOption) {
  //             // Selected and correct
  //             backgroundColor = Colors.green.withOpacity(0.2);
  //             borderColor = Colors.green;
  //             textColor = Colors.green;
  //           } else if (isSelected && !isCorrectOption) {
  //             // Selected but wrong
  //             backgroundColor = Colors.red.withOpacity(0.2);
  //             borderColor = Colors.red;
  //             textColor = Colors.red;
  //           } else if (!isSelected && isCorrectOption) {
  //             // Not selected but is correct answer
  //             backgroundColor = Colors.green.withOpacity(0.1);
  //             borderColor = Colors.green.withOpacity(0.5);
  //             textColor = Colors.green.withOpacity(0.8);
  //           }

  //           return Container(
  //             margin: const EdgeInsets.only(bottom: 8),
  //             padding: const EdgeInsets.all(12),
  //             decoration: BoxDecoration(
  //               color: backgroundColor,
  //               borderRadius: BorderRadius.circular(8),
  //               border: Border.all(color: borderColor, width: 1),
  //             ),
  //             child: Row(
  //               children: [
  //                 Container(
  //                   width: 24,
  //                   height: 24,
  //                   decoration: BoxDecoration(
  //                     shape: BoxShape.circle,
  //                     color: isSelected
  //                         ? (isCorrectOption ? Colors.green : Colors.red)
  //                         : Colors.transparent,
  //                     border: Border.all(
  //                       color: isCorrectOption
  //                           ? Colors.green
  //                           : ColorClass.white.withOpacity(0.3),
  //                       width: 2,
  //                     ),
  //                   ),
  //                   child: Center(
  //                     child: Text(
  //                       String.fromCharCode(65 + (optionIndex as int)),
  //                       style: TextStyle(
  //                         fontSize: 12,
  //                         fontWeight: FontWeight.bold,
  //                         color: isSelected ? Colors.white : textColor,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 12),
  //                 Expanded(
  //                   child: Text(
  //                     optionText,
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       color: textColor,
  //                       fontWeight: isSelected || isCorrectOption
  //                           ? FontWeight.w600
  //                           : FontWeight.normal,
  //                     ),
  //                   ),
  //                 ),
  //                 if (isSelected)
  //                   Icon(
  //                     isCorrectOption ? LucideIcons.check : LucideIcons.x,
  //                     color: isCorrectOption ? Colors.green : Colors.red,
  //                     size: 16,
  //                   ),
  //                 if (!isSelected && isCorrectOption)
  //                   const Icon(
  //                     LucideIcons.lightbulb,
  //                     color: Colors.green,
  //                     size: 16,
  //                   ),
  //               ],
  //             ),
  //           );
  //         }).toList(),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildActionButtons(
      BuildContext context, QuizProvider quizProvider, dynamic result) {
    return Column(
      children: [
        // Home Button
        Container(
          width: 217,
          height: 45,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFAC28DC), // Purple
                Color(0xFF7E1EB7), // Darker purple
                Color(0xFF501392), // Dark purple
              ],
              stops: [0.0, 0.50, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: ElevatedButton(
            onPressed: () => _resetToHome(quizProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: Text(
              'Back to Home',
              style: TextStyleClass.fredoka(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Try Again Button
        SizedBox(
          width: 217,
          height: 45,
          child: OutlinedButton(
            onPressed: () {
              // Navigate to quiz result detail screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizResultDetailScreen(
                    session: result.session,
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: BorderSide(
                color: Colors.black.withOpacity(0.25),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Check My Result',
              style: TextStyleClass.fredoka(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: ColorClass.violet30,
      ),
    );
  }

  Widget _buildNoResultState() {
    return Center(
      child: Text(
        "No result available",
        style: TextStyleClass.fredoka(
          color: ColorClass.violet30,
          fontSize: 18,
        ),
      ),
    );
  }

  void _resetToHome(QuizProvider quizProvider) {
    // Clear current quiz result to go back to home
    quizProvider.currentQuizResult;
    // This will be handled by the provider to reset state
  }

  Color _getGradeColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.orange;
    if (percentage >= 60) return Colors.deepOrange;
    return Colors.red;
  }

  String _getResultMessage(double percentage) {
    if (percentage >= 90) return 'Outstanding! 🏆';
    if (percentage >= 80) return 'Excellent Work! 🌟';
    if (percentage >= 70) return 'Great Job! 👏';
    if (percentage >= 60) return 'Good Effort! 👍';
    if (percentage >= 50) return 'Not Bad! 💪';
    return 'Keep Trying! 📚';
  }

  String _getEncouragementMessage(double percentage) {
    if (percentage >= 90) {
      return 'You\'re a quiz master! Your knowledge is truly impressive.';
    }
    if (percentage >= 80) {
      return 'You\'re doing fantastic! Keep up the excellent work.';
    }
    if (percentage >= 70) {
      return 'You\'re on the right track! Practice makes perfect.';
    }
    if (percentage >= 60) {
      return 'Good progress! A little more study will boost your score.';
    }
    if (percentage >= 50) {
      return 'You\'re getting there! Don\'t give up, keep learning.';
    }
    return 'Every expert was once a beginner. Keep practicing!';
  }

  Widget _buildGradientText() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFFAC28DC), // Purple
          Color(0xFF7E1EB7), // Darker purple
          Color(0xFF501392), // Dark purple // Blue
        ],
        stops: [0.0, 0.50, 0.1],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Center(
        child: Text(
          'Congratulations',
          style: TextStyleClass.fredoka(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildGradientResultText(String message) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFFAC28DC), // Purple
          Color(0xFF7E1EB7), // Darker purple
          Color(0xFF501392), // Dark purple // Blue
        ],
        stops: [0.0, 0.50, 0.1],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: Text(
        message,
        style: TextStyleClass.poppinsSemiBold(
          fontSize: 20,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCongratulationImage() {
    return SizedBox(
      width: double.infinity,
      //padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            ImageClass.congo,
            fit: BoxFit.contain,
            height: 180, // Adjust height as needed
            width: 300, // Set a reasonable width
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
