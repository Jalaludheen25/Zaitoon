import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/quiz/provider/quiz_provider.dart';
import 'package:zaitoon/screens/quiz/models/quiz_models.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon/screens/bottom_navigation/bottom_navigation.dart';

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
        child: _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: ColorClass.primaryColor,
            ),
          )
        : CustomScrollView(
            slivers: [
              _buildAppBar(),
              //_buildResultSummary(),
              _buildQuestionsList(),
              SliverToBoxAdapter(
                child: SizedBox(
                    height: 100), // Add bottom padding for the floating button
              ),
            ],
          ),    
      ),
      floatingActionButton: _buildBackToHomeButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      leading: IconButton(
        icon: const Icon(
          LucideIcons.chevronLeft,
          color: ColorClass.black,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              ColorClass.grad1,
              ColorClass.grad2,
              ColorClass.grad3,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Check My Answers',
            style: TextStyleClass.fredoka(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
      backgroundColor: ColorClass.transparent,
      floating: true,
      pinned: false,
      elevation: 0,
    );
  }
  Widget _buildBackToHomeButton() {
    return Container(
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _navigateToHome(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        label: Text(
          'Back to Home',
          style: TextStyleClass.fredoka(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  // Widget _buildResultSummary() {
  //   return
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceAround,
  //             children: [
  //               _buildSummaryItem(
  //                 'Correct',
  //                 '${widget.session.correctAnswers ?? 0}',
  //                 Colors.green,
  //                 LucideIcons.check,
  //               ),
  //               _buildSummaryItem(
  //                 'Wrong',
  //                 '${widget.session.totalQuestions - (widget.session.correctAnswers ?? 0)}',
  //                 Colors.red,
  //                 LucideIcons.x,
  //               ),
  //               _buildSummaryItem(
  //                 'Total',
  //                 '${widget.session.totalQuestions}',
  //                 Colors.blue,
  //                 LucideIcons.fileText,
  //               ),
  //               _buildSummaryItem(
  //                 'Time',
  //                 _formatTime(widget.session.totalTimeTaken ?? 0),
  //                 Colors.orange,
  //                 LucideIcons.clock,
  //               ),
  //             ],
  //   );
  // }

  // Widget _buildSummaryItem(String label, String value, Color color, IconData icon) {
  //   return Column(
  //     children: [
  //       Icon(icon, color: color, size: 20),
  //       const SizedBox(height: 4),
  //       Text(
  //         value,
  //         style: TextStyleClass.poppinsSemiBold(
  //           fontSize: 16,
  //           color: ColorClass.white,
  //         ),
  //       ),
  //       Text(
  //         label,
  //         style: TextStyleClass.poppinsRegular(
  //           fontSize: 12,
  //           color: ColorClass.white.withOpacity(0.7),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const BottomNavigationScreen(currentIndex: 4),
      ),
      (route) => false,
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

  Widget _buildQuestionCard(
      QuizQuestion question, QuizAnswer answer, int questionNumber) {
    final isCorrect = answer.isCorrect;
    final language = context.read<QuizProvider>().currentLanguage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: ColorClass.grey3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorClass.violet30,
          width: 0.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Question $questionNumber',
                  style: TextStyleClass.fredoka(
                    fontSize: 20,
                    color: ColorClass.black,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.lightGreen : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isCorrect ? 'Correct' : 'Incorrect',
                        style: TextStyleClass.openSansSemiBold(
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              language == 'en' ? question.questionEn : question.questionMl,
              style: TextStyleClass.openSans(
                fontSize: 16,
                color: ColorClass.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          if (!isCorrect)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Correct Answer:',
                    style: TextStyleClass.openSansSemiBold(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      language == 'en'
                          ? question.optionsEn[question.correctAnswer]
                          : question.optionsMl[question.correctAnswer],
                      style: TextStyleClass.openSans(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              // const SizedBox(width: 16),
              // Expanded(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         'Your Answer:',
              //         style: TextStyleClass.poppinsMedium(
              //           fontSize: 12,
              //           color: isCorrect ? Colors.green : Colors.red,
              //         ),
              //       ),
              //       Text(
              //         answer.selectedAnswer != null
              //             ? (language == 'en'
              //                 ? question.optionsEn[answer.selectedAnswer!]
              //                 : question.optionsMl[answer.selectedAnswer!])
              //             : 'Not answered',
              //         style: TextStyleClass.poppinsRegular(
              //           fontSize: 14,
              //           color: isCorrect ? Colors.green : Colors.red,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(
      String option, int index, int correctIndex, int? selectedIndex) {
    bool isCorrect = index == correctIndex;
    bool isSelected = index == selectedIndex;

    Color backgroundColor;
    Color textColor;
    IconData? icon;

    if (isCorrect) {
      backgroundColor = ColorClass.green3.withOpacity(0.2);
      textColor = Colors.black;
      // icon = LucideIcons.check;
    } else if (isSelected && !isCorrect) {
      backgroundColor = Colors.red.withOpacity(0.1);
      textColor = Colors.black;
      // icon = LucideIcons.x;
    } else {
      backgroundColor = ColorClass.grey33.withOpacity(0.15);
      textColor = ColorClass.black;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCorrect
              ? ColorClass.green3
              : isSelected
                  ? Colors.red
                  : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              option,
              style: TextStyleClass.openSans(
                fontSize: 16,
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

  // Color _getGradeColor(double percentage) {
  //   if (percentage >= 80) return Colors.green;
  //   if (percentage >= 60) return Colors.orange;
  //   return Colors.red;
  // }

  // String _calculateGrade(double percentage) {
  //   if (percentage >= 90) return 'A+';
  //   if (percentage >= 80) return 'A';
  //   if (percentage >= 70) return 'B+';
  //   if (percentage >= 60) return 'B';
  //   if (percentage >= 50) return 'C';
  //   if (percentage >= 40) return 'D';
  //   return 'F';
  // }

  // String _formatTime(int seconds) {
  //   final minutes = seconds ~/ 60;
  //   final remainingSeconds = seconds % 60;
  //   return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  // }
}
