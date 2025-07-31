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
                _buildAppBar(),
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
                        _buildQuizHistorySection(quizProvider),
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

  Widget _buildAppBar() {
    return const SliverAppBar(
      title: Text(
        'Quiz Challenge',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: ColorClass.black,
      floating: true,
      pinned: false,
      elevation: 0,
    );
  }

  Widget _buildWelcomeSection() {
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
            'Test your knowledge with 20 random questions from our collection of 100 exciting questions!',
            style: TextStyleClass.poppinsRegular(
              fontSize: 14,
              color: ColorClass.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartQuizButton(BuildContext context, QuizProvider quizProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => quizProvider.startNewQuiz(),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorClass.primaryColor,
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
              'Start New Quiz',
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

  Widget _buildQuizHistorySection(QuizProvider quizProvider) {
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
          ...history.take(5).map((session) => _buildHistoryItem(session, quizProvider)),
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

  Widget _buildHistoryItem(dynamic session, QuizProvider quizProvider) {
    final percentage = session.correctAnswers != null && session.totalQuestions > 0
        ? (session.correctAnswers / session.totalQuestions * 100)
        : 0.0;
    
    return Container(
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
              onPressed: () => quizProvider.submitToAPI(session.sessionUuid),
              icon: const Icon(
                LucideIcons.upload,
                color: ColorClass.primaryColor,
                size: 20,
              ),
            ),
        ],
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