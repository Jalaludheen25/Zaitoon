import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/quiz/provider/quiz_provider.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.black,
      body: SafeArea(
        child: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            final result = quizProvider.currentQuizResult;
            
            if (result == null) {
              return _buildLoadingState();
            }

            return CustomScrollView(
              slivers: [
                _buildAppBar(context, quizProvider),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildScoreCard(result),
                        const SizedBox(height: 24),
                        _buildStatsSection(result),
                        const SizedBox(height: 24),
                        _buildDetailedResults(result, quizProvider),
                        const SizedBox(height: 32),
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
      title: const Text(
        'Quiz Results',
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
      leading: IconButton(
        onPressed: () => _resetToHome(quizProvider),
        icon: const Icon(
          LucideIcons.home,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildScoreCard(dynamic result) {
    final percentage = result.percentage;
    final grade = result.grade;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getGradeColor(percentage).withOpacity(0.2),
            _getGradeColor(percentage).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getGradeColor(percentage).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getGradeColor(percentage).withOpacity(0.2),
              border: Border.all(
                color: _getGradeColor(percentage),
                width: 4,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getGradeColor(percentage),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getGradeColor(percentage),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      grade,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _getResultMessage(percentage),
            style: TextStyleClass.poppinsSemiBold(
              fontSize: 20,
              color: ColorClass.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getEncouragementMessage(percentage),
            style: TextStyleClass.poppinsRegular(
              fontSize: 14,
              color: ColorClass.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(dynamic result) {
    final session = result.session;
    final correctAnswers = session.correctAnswers ?? 0;
    final totalQuestions = session.totalQuestions;
    final wrongAnswers = totalQuestions - correctAnswers;
    final timeTaken = session.totalTimeTaken ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quiz Statistics',
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
                icon: LucideIcons.checkCircle,
                title: 'Correct',
                value: '$correctAnswers',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: LucideIcons.xCircle,
                title: 'Wrong',
                value: '$wrongAnswers',
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: LucideIcons.helpCircle,
                title: 'Total Questions',
                value: '$totalQuestions',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: LucideIcons.clock,
                title: 'Time Taken',
                value: _formatTime(timeTaken),
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

  Widget _buildDetailedResults(dynamic result, QuizProvider quizProvider) {
    final answers = result.answers;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question Review',
          style: TextStyleClass.poppinsSemiBold(
            fontSize: 18,
            color: ColorClass.white,
          ),
        ),
        const SizedBox(height: 16),
        ...answers.asMap().entries.map((entry) {
          final index = entry.key;
          final answer = entry.value;
          return _buildQuestionReviewCard(index + 1, answer);
        }).toList(),
      ],
    );
  }

  Widget _buildQuestionReviewCard(int questionNumber, dynamic answer) {
    final isCorrect = answer.isCorrect;
    final selectedAnswer = answer.selectedAnswer;
    final correctAnswer = answer.correctAnswer;
    final options = answer.options;
    final timeTaken = answer.timeTaken;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorClass.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCorrect ? LucideIcons.check : LucideIcons.x,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Q$questionNumber',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${timeTaken}s',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 12,
                  color: ColorClass.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            answer.question,
            style: TextStyleClass.poppinsMedium(
              fontSize: 14,
              color: ColorClass.white,
            ),
          ),
          const SizedBox(height: 12),
          ...options.asMap().entries.map((optionEntry) {
            final optionIndex = optionEntry.key;
            final optionText = optionEntry.value;
            final isSelected = selectedAnswer == optionIndex;
            final isCorrectOption = correctAnswer == optionIndex;
            
            Color backgroundColor = Colors.transparent;
            Color borderColor = ColorClass.white.withOpacity(0.2);
            Color textColor = ColorClass.white.withOpacity(0.8);
            
            if (isSelected && isCorrectOption) {
              // Selected and correct
              backgroundColor = Colors.green.withOpacity(0.2);
              borderColor = Colors.green;
              textColor = Colors.green;
            } else if (isSelected && !isCorrectOption) {
              // Selected but wrong
              backgroundColor = Colors.red.withOpacity(0.2);
              borderColor = Colors.red;
              textColor = Colors.red;
            } else if (!isSelected && isCorrectOption) {
              // Not selected but is correct answer
              backgroundColor = Colors.green.withOpacity(0.1);
              borderColor = Colors.green.withOpacity(0.5);
              textColor = Colors.green.withOpacity(0.8);
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? (isCorrectOption ? Colors.green : Colors.red) : Colors.transparent,
                      border: Border.all(
                        color: isCorrectOption ? Colors.green : ColorClass.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + (optionIndex as int)),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      optionText,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                        fontWeight: isSelected || isCorrectOption ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      isCorrectOption ? LucideIcons.check : LucideIcons.x,
                      color: isCorrectOption ? Colors.green : Colors.red,
                      size: 16,
                    ),
                  if (!isSelected && isCorrectOption)
                    const Icon(
                      LucideIcons.lightbulb,
                      color: Colors.green,
                      size: 16,
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, QuizProvider quizProvider, dynamic result) {
    return Column(
      children: [
        if (!result.session.isSubmitted) ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: quizProvider.isSubmitting 
                  ? null 
                  : () => quizProvider.submitToAPI(result.session.sessionUuid),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorClass.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: quizProvider.isSubmitting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Submitting...'),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.send, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Submit to Server',
                          style: TextStyleClass.poppinsSemiBold(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _resetToHome(quizProvider),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorClass.primaryColor,
                  side: const BorderSide(color: ColorClass.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.home, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Home',
                      style: TextStyleClass.poppinsMedium(
                        fontSize: 16,
                        color: ColorClass.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _resetToHome(quizProvider);
                  // Start new quiz immediately
                  Future.delayed(const Duration(milliseconds: 100), () {
                    quizProvider.startNewQuiz();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.play, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Try Again',
                      style: TextStyleClass.poppinsMedium(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: ColorClass.primaryColor,
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
    if (percentage >= 90) return 'You\'re a quiz master! Your knowledge is truly impressive.';
    if (percentage >= 80) return 'You\'re doing fantastic! Keep up the excellent work.';
    if (percentage >= 70) return 'You\'re on the right track! Practice makes perfect.';
    if (percentage >= 60) return 'Good progress! A little more study will boost your score.';
    if (percentage >= 50) return 'You\'re getting there! Don\'t give up, keep learning.';
    return 'Every expert was once a beginner. Keep practicing!';
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
} 