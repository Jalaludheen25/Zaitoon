import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/quiz/provider/quiz_provider.dart';
import 'package:zaitoon/screens/quiz/models/quiz_models.dart';

class QuizResultDetailScreen extends StatefulWidget {
  final QuizSession session;

  const QuizResultDetailScreen({
    super.key,
    required this.session,
  });

  @override
  State<QuizResultDetailScreen> createState() => _QuizResultDetailScreenState();
}

class _QuizResultDetailScreenState extends State<QuizResultDetailScreen> {
  List<QuizAnswer> _answers = [];
  List<QuizQuestion> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizDetails();
  }

  Future<void> _loadQuizDetails() async {
    try {
      final quizProvider = context.read<QuizProvider>();
      
      // Load answers for this session
      _answers = await quizProvider.getQuizAnswers(widget.session.sessionUuid);
      
      // Load all questions to get the full question data
      await quizProvider.loadQuestions();
      _questions = quizProvider.allQuestions;
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading quiz details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.black,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: ColorClass.primaryColor,
                ),
              )
            : CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  _buildResultSummary(),
                  _buildQuestionsList(),
                ],
              ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      leading: IconButton(
        icon: const Icon(
          LucideIcons.arrowLeft,
          color: ColorClass.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Quiz Results',
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

  Widget _buildResultSummary() {
    final percentage = widget.session.correctAnswers != null && widget.session.totalQuestions > 0
        ? (widget.session.correctAnswers! / widget.session.totalQuestions * 100)
        : 0.0;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getGradeColor(percentage).withOpacity(0.2),
              _getGradeColor(percentage).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getGradeColor(percentage).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  percentage >= 60 ? LucideIcons.trophy : LucideIcons.target,
                  color: _getGradeColor(percentage),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyleClass.poppinsBold(
                    fontSize: 32,
                    color: ColorClass.white,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getGradeColor(percentage),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _calculateGrade(percentage),
                    style: TextStyleClass.poppinsBold(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Correct',
                  '${widget.session.correctAnswers ?? 0}',
                  Colors.green,
                  LucideIcons.check,
                ),
                _buildSummaryItem(
                  'Wrong',
                  '${widget.session.totalQuestions - (widget.session.correctAnswers ?? 0)}',
                  Colors.red,
                  LucideIcons.x,
                ),
                _buildSummaryItem(
                  'Total',
                  '${widget.session.totalQuestions}',
                  Colors.blue,
                  LucideIcons.fileText,
                ),
                _buildSummaryItem(
                  'Time',
                  _formatTime(widget.session.totalTimeTaken ?? 0),
                  Colors.orange,
                  LucideIcons.clock,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyleClass.poppinsSemiBold(
            fontSize: 16,
            color: ColorClass.white,
          ),
        ),
        Text(
          label,
          style: TextStyleClass.poppinsRegular(
            fontSize: 12,
            color: ColorClass.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final answer = _answers[index];
          final question = _questions.firstWhere(
            (q) => q.id == answer.questionId,
            orElse: () => QuizQuestion(
              id: answer.questionId,
              type: 'multiple_choice',
              questionEn: answer.question,
              questionMl: answer.question,
              optionsEn: answer.options,
              optionsMl: answer.options,
              correctAnswer: answer.correctAnswer,
              difficulty: 'medium',
            ),
          );

          return _buildQuestionCard(question, answer, index + 1);
        },
        childCount: _answers.length,
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion question, QuizAnswer answer, int questionNumber) {
    final isCorrect = answer.isCorrect;
    final language = context.read<QuizProvider>().currentLanguage;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ColorClass.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect 
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCorrect 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Question $questionNumber',
                  style: TextStyleClass.poppinsSemiBold(
                    fontSize: 16,
                    color: ColorClass.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
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
                        isCorrect ? 'Correct' : 'Incorrect',
                        style: TextStyleClass.poppinsMedium(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Question text
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              language == 'en' ? question.questionEn : question.questionMl,
              style: TextStyleClass.poppinsMedium(
                fontSize: 16,
                color: ColorClass.white,
              ),
            ),
          ),
          
          // Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Options:',
                  style: TextStyleClass.poppinsMedium(
                    fontSize: 14,
                    color: ColorClass.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  question.optionsEn.length,
                  (optionIndex) => _buildOptionItem(
                    language == 'en' 
                        ? question.optionsEn[optionIndex]
                        : question.optionsMl[optionIndex],
                    optionIndex,
                    question.correctAnswer,
                    answer.selectedAnswer,
                  ),
                ),
              ],
            ),
          ),
          
          // Answer summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Correct Answer:',
                        style: TextStyleClass.poppinsMedium(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        language == 'en' 
                            ? question.optionsEn[question.correctAnswer]
                            : question.optionsMl[question.correctAnswer],
                        style: TextStyleClass.poppinsRegular(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Answer:',
                        style: TextStyleClass.poppinsMedium(
                          fontSize: 12,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        answer.selectedAnswer != null
                            ? (language == 'en' 
                                ? question.optionsEn[answer.selectedAnswer!]
                                : question.optionsMl[answer.selectedAnswer!])
                            : 'Not answered',
                        style: TextStyleClass.poppinsRegular(
                          fontSize: 14,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(String option, int index, int correctIndex, int? selectedIndex) {
    bool isCorrect = index == correctIndex;
    bool isSelected = index == selectedIndex;
    
    Color backgroundColor;
    Color textColor;
    IconData? icon;
    
    if (isCorrect) {
      backgroundColor = Colors.green.withOpacity(0.2);
      textColor = Colors.green;
      icon = LucideIcons.check;
    } else if (isSelected && !isCorrect) {
      backgroundColor = Colors.red.withOpacity(0.2);
      textColor = Colors.red;
      icon = LucideIcons.x;
    } else {
      backgroundColor = Colors.transparent;
      textColor = ColorClass.white.withOpacity(0.7);
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect 
              ? Colors.green.withOpacity(0.5)
              : isSelected 
                  ? Colors.red.withOpacity(0.5)
                  : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              option,
              style: TextStyleClass.poppinsRegular(
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(
              icon,
              color: textColor,
              size: 16,
            ),
          ],
        ],
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
}