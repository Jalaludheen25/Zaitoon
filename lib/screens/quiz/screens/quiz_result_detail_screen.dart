import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/quiz/provider/quiz_provider.dart';
import 'package:zaitoon/screens/quiz/models/quiz_models.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon/screens/bottom_navigation/bottom_navigation.dart';
import 'package:zaitoon/providers/theme_provider.dart';

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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
            statusBarBrightness:
                themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            systemNavigationBarColor:
                themeProvider.isDarkMode ? ColorClass.black : Colors.white,
            systemNavigationBarIconBrightness:
                themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
          ),
        );
        return Scaffold(
          backgroundColor:
              themeProvider.isDarkMode ? ColorClass.black : ColorClass.white,
          body: SafeArea(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: themeProvider.isDarkMode
                          ? ColorClass.violet30
                          : ColorClass.primaryColor,
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      _buildAppBar(themeProvider),
                      //_buildResultSummary(),
                      _buildQuestionsList(themeProvider),
                      SliverToBoxAdapter(
                        child: SizedBox(
                            height:
                                100), // Add bottom padding for the floating button
                      ),
                    ],
                  ),
          ),
          floatingActionButton: _buildBackToHomeButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildAppBar(ThemeProvider themeProvider) {
    return SliverAppBar(
      leading: IconButton(
        icon: Icon(
          LucideIcons.chevronLeft,
          color: themeProvider.isDarkMode ? Colors.white : ColorClass.black,
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

  Widget _buildQuestionsList(ThemeProvider themeProvider) {
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

          return _buildQuestionCard(question, answer, index + 1, themeProvider);
        },
        childCount: _answers.length,
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion question, QuizAnswer answer,
      int questionNumber, ThemeProvider themeProvider) {
    final isCorrect = answer.isCorrect;
    final language = context.read<QuizProvider>().currentLanguage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.black : ColorClass.grey3,
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
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : ColorClass.black,
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
                color: themeProvider.isDarkMode
                    ? ColorClass.white
                    : Colors.black, // check the color here
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
                    themeProvider,
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
                      color: themeProvider.isDarkMode ? Colors.white : ColorClass.black,
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
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
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

  Widget _buildOptionItem(String option, int index, int correctIndex,
      int? selectedIndex, ThemeProvider themeProvider) {
    bool isCorrect = index == correctIndex;
    bool isSelected = index == selectedIndex;

    Color backgroundColor;
    Color textColor;
    // IconData? icon;

    if (isCorrect) {
      backgroundColor = ColorClass.green3.withOpacity(0.2);
      textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
      // icon = LucideIcons.check;
    } else if (isSelected && !isCorrect) {
      backgroundColor = Colors.red.withOpacity(0.1);
      textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
      // icon = LucideIcons.x;
    } else {
      backgroundColor = themeProvider.isDarkMode
          ? ColorClass.bg
          : ColorClass.grey33.withOpacity(0.15);
      textColor = themeProvider.isDarkMode ? Colors.white : ColorClass.black;
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
          // if (icon != null) ...[
          //   const SizedBox(width: 8),
          //   Icon(
          //     icon,
          //     color: textColor,
          //     size: 16,
          //   ),
          // ],
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
