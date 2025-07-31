import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/quiz/provider/quiz_provider.dart';

class QuizActiveScreen extends StatelessWidget {
  const QuizActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.black,
      body: SafeArea(
        child: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            final currentQuestion = quizProvider.currentQuestion;
            
            if (currentQuestion == null) {
              return _buildLoadingState();
            }

            return Column(
              children: [
                _buildHeader(context, quizProvider),
                _buildProgressIndicator(quizProvider),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildQuestionCard(quizProvider, currentQuestion),
                        const SizedBox(height: 24),
                        _buildOptionsSection(quizProvider, currentQuestion),
                        const Spacer(),
                        _buildNavigationButtons(context, quizProvider),
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

  Widget _buildHeader(BuildContext context, QuizProvider quizProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorClass.primaryColor.withOpacity(0.15),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ColorClass.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.clock,
                  color: ColorClass.primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  quizProvider.formattedTotalTime,
                  style: TextStyleClass.poppinsSemiBold(
                    fontSize: 14,
                    color: ColorClass.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Question ${quizProvider.currentQuestionIndex + 1} of ${quizProvider.currentQuizQuestions.length}',
            style: TextStyleClass.poppinsMedium(
              fontSize: 16,
              color: ColorClass.white,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _showQuizMenuBottomSheet(context, quizProvider),
            icon: const Icon(
              LucideIcons.menu,
              color: ColorClass.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(QuizProvider quizProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 12,
                  color: ColorClass.white.withOpacity(0.7),
                ),
              ),
              Text(
                '${quizProvider.questionsAnswered}/${quizProvider.currentQuizQuestions.length} answered',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 12,
                  color: ColorClass.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (quizProvider.currentQuestionIndex + 1) / quizProvider.currentQuizQuestions.length,
            backgroundColor: ColorClass.white.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(ColorClass.primaryColor),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuizProvider quizProvider, dynamic currentQuestion) {
    final question = quizProvider.currentLanguage == 'en' 
        ? currentQuestion.questionEn 
        : currentQuestion.questionMl;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorClass.primaryColor.withOpacity(0.1),
            ColorClass.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getQuestionTypeColor(currentQuestion.type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentQuestion.type == 'multiple_choice' ? 'Multiple Choice' : 'True/False',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(currentQuestion.difficulty),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currentQuestion.difficulty.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            question,
            style: TextStyleClass.poppinsSemiBold(
              fontSize: 18,
              color: ColorClass.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(QuizProvider quizProvider, dynamic currentQuestion) {
    final options = quizProvider.currentLanguage == 'en' 
        ? currentQuestion.optionsEn 
        : currentQuestion.optionsMl;
    
    return Column(
      children: options.asMap().entries.map<Widget>((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = quizProvider.selectedAnswers[currentQuestion.id] == index;
        
        return GestureDetector(
          onTap: () => quizProvider.answerQuestion(index),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? ColorClass.primaryColor.withOpacity(0.2)
                  : ColorClass.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                    ? ColorClass.primaryColor
                    : ColorClass.white.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? ColorClass.primaryColor
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected 
                          ? ColorClass.primaryColor
                          : ColorClass.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + (index as int)), // A, B, C, D
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : ColorClass.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyleClass.poppinsMedium(
                      fontSize: 16,
                      color: isSelected ? ColorClass.white : ColorClass.white.withOpacity(0.9),
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    LucideIcons.check,
                    color: ColorClass.primaryColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, QuizProvider quizProvider) {
    return Row(
      children: [
        if (quizProvider.currentQuestionIndex > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: quizProvider.previousQuestion,
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
                  const Icon(LucideIcons.chevronLeft, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Previous',
                    style: TextStyleClass.poppinsMedium(
                      fontSize: 16,
                      color: ColorClass.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (quizProvider.currentQuestionIndex > 0)
          const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: quizProvider.hasAnsweredCurrentQuestion
                ? (quizProvider.isLastQuestion 
                    ? () => _showSubmitDialog(context, quizProvider)
                    : quizProvider.nextQuestion)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorClass.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  quizProvider.isLastQuestion ? 'Submit Quiz' : 'Next',
                  style: TextStyleClass.poppinsMedium(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  quizProvider.isLastQuestion ? LucideIcons.send : LucideIcons.chevronRight,
                  size: 20,
                ),
              ],
            ),
          ),
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

  void _showQuizMenuBottomSheet(BuildContext context, QuizProvider quizProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorClass.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Menu',
              style: TextStyleClass.poppinsSemiBold(
                fontSize: 20,
                color: ColorClass.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildQuestionGrid(quizProvider),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue Quiz'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSubmitDialog(context, quizProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('End Quiz'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionGrid(QuizProvider quizProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Questions',
          style: TextStyleClass.poppinsMedium(
            fontSize: 16,
            color: ColorClass.white,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: quizProvider.currentQuizQuestions.length,
          itemBuilder: (context, index) {
            final question = quizProvider.currentQuizQuestions[index];
            final isAnswered = quizProvider.selectedAnswers.containsKey(question.id);
            final isCurrent = index == quizProvider.currentQuestionIndex;
            
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                quizProvider.goToQuestion(index);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrent
                      ? ColorClass.primaryColor
                      : (isAnswered 
                          ? Colors.green.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrent
                        ? ColorClass.primaryColor
                        : (isAnswered ? Colors.green : Colors.grey),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isCurrent || isAnswered ? Colors.white : Colors.grey[400],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showSubmitDialog(BuildContext context, QuizProvider quizProvider) {
    final unansweredCount = quizProvider.currentQuizQuestions.length - quizProvider.questionsAnswered;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorClass.black,
        title: Text(
          'Submit Quiz?',
          style: TextStyleClass.poppinsSemiBold(
            fontSize: 20,
            color: ColorClass.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have answered ${quizProvider.questionsAnswered} out of ${quizProvider.currentQuizQuestions.length} questions.',
              style: TextStyleClass.poppinsRegular(
                fontSize: 14,
                color: ColorClass.white.withOpacity(0.8),
              ),
            ),
            if (unansweredCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Warning: You have $unansweredCount unanswered questions. These will be marked as incorrect.',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 14,
                  color: Colors.orange,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to submit your quiz?',
              style: TextStyleClass.poppinsMedium(
                fontSize: 16,
                color: ColorClass.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Quiz'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              quizProvider.submitQuiz();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorClass.primaryColor,
            ),
            child: quizProvider.isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Color _getQuestionTypeColor(String type) {
    switch (type) {
      case 'multiple_choice':
        return Colors.blue;
      case 'true_false':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 