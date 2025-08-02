import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/quiz/provider/quiz_provider.dart';

class QuizHomeScreen extends StatelessWidget {
  const QuizHomeScreen({super.key});

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
              Text(
                'Test your knowledge with ${quizProvider.quizConfig?.totalQuestions ?? 20} questions!',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 14,
                  color: ColorClass.white.withOpacity(0.8),
                ),
              ),
              if (quizProvider.quizConfig != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quiz ends at: ${quizProvider.formatClockTime(quizProvider.quizConfig!.endDate)}',
                      style: TextStyleClass.poppinsRegular(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                    // Text(
                    //   quizProvider.getFormattedRemainingTime(),
                    //   style: TextStyleClass.poppinsRegular(
                    //     fontSize: 12,
                    //     color: quizProvider.getRemainingTime() <= 5 ? Colors.red : Colors.green,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStartQuizButton(BuildContext context, QuizProvider quizProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: !quizProvider.canAttemptQuiz()
            ? null // Disable button if quiz time is over
            : () async {
                try {
                  await quizProvider.startNewQuiz();
                } catch (e) {
                  if (context.mounted) {
                    final errorMsg = e.toString().replaceAll('Exception: ', '');
                    if (errorMsg.contains('already attempted')) {
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
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Oops! Something went wrong',
                                  style: TextStyleClass.poppinsSemiBold(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  errorMsg,
                                  style: TextStyleClass.poppinsRegular(
                                    fontSize: 14,
                                    color: Colors.grey[400]!,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.grey[900],
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Try Again',
                                      style: TextStyleClass.poppinsMedium(
                                        fontSize: 16,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            errorMsg,
                            style: TextStyleClass.poppinsRegular(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: quizProvider.canAttemptQuiz() 
              ? ColorClass.primaryColor 
              : Colors.grey[800],
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
              quizProvider.canAttemptQuiz() 
                  ? 'Start New Quiz'
                  : 'Quiz Time Over',
              style: TextStyleClass.poppinsSemiBold(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildQuizHistorySection(QuizProvider quizProvider, BuildContext context) {
    final history = quizProvider.quizHistory;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Quizzes',
          style: TextStyleClass.poppinsSemiBold(
            fontSize: 18,
            color: ColorClass.white,
          ),
        ),
        const SizedBox(height: 16),
        if (history.isEmpty)
          _buildEmptyHistory()
        else
          ...history.take(5).map((session) => _buildHistoryItem(session, quizProvider, context)),
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

  Widget _buildHistoryItem(dynamic session, QuizProvider quizProvider, BuildContext context) {
    final percentage = session.correctAnswers != null && session.totalQuestions > 0
        ? (session.correctAnswers / session.totalQuestions * 100)
        : 0.0;
    
    return Dismissible(
      key: Key(session.sessionUuid),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
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
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Delete Quiz Record?',
                    style: TextStyleClass.poppinsSemiBold(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This action cannot be undone. Are you sure you want to delete this quiz record?',
                    style: TextStyleClass.poppinsRegular(
                      fontSize: 14,
                      color: Colors.grey[400]!,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey[900],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyleClass.poppinsMedium(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Delete',
                            style: TextStyleClass.poppinsMedium(
                              fontSize: 16,
                              color: Colors.red,
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
      },
      onDismissed: (direction) async {
        try {
          await quizProvider.deleteQuizSession(session.sessionUuid);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Quiz record deleted',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to delete quiz record: ${e.toString().replaceAll('Exception: ', '')}',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24.0),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.red,
          size: 24,
        ),
      ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
            if (!session.isSubmitted)
              IconButton(
                onPressed: quizProvider.isSubmitting 
                  ? null 
                  : () async {
                      try {
                        final answers = await quizProvider.getQuizAnswers(session.sessionUuid);
                        await quizProvider.submitToAPI(session, answers);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Quiz submitted successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              backgroundColor: ColorClass.black,
                              title: Row(
                                children: [
                                  const Icon(LucideIcons.alertTriangle, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Submission Failed',
                                    style: TextStyleClass.poppinsSemiBold(
                                      fontSize: 18,
                                      color: ColorClass.white,
                                    ),
                                  ),
                                ],
                              ),
                              content: Text(
                                'Failed to submit quiz. Would you like to retry?',
                                style: TextStyleClass.poppinsRegular(
                                  fontSize: 14,
                                  color: ColorClass.white70,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyleClass.poppinsMedium(
                                      fontSize: 14,
                                      color: ColorClass.white70,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(dialogContext);
                                    try {
                                      await quizProvider.retrySubmission(session);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Quiz submitted successfully!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Retry failed: ${e.toString()}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorClass.primaryColor,
                                  ),
                                  child: Text(
                                    'Retry',
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
                      }
                    },
                icon: quizProvider.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(ColorClass.primaryColor),
                      ),
                    )
                  : const Icon(
                      LucideIcons.upload,
                      color: ColorClass.primaryColor,
                      size: 20,
                    ),
              ),
          ],
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

  String _formatTotalTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
} 