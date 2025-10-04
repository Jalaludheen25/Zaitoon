import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/bottom_navigation/bottom_navigation.dart';
import 'package:zaitoon/screens/quiz/provider/quiz_provider.dart';
import 'package:flutter/services.dart';

class QuizActiveScreen extends StatefulWidget {
  const QuizActiveScreen({super.key});

  @override
  State<QuizActiveScreen> createState() => _QuizActiveScreenState();
}

class _QuizActiveScreenState extends State<QuizActiveScreen> {
  @override
  void initState() {
    super.initState();
    _checkQuizTime();
  }

  Future<void> _checkQuizTime() async {
    final quizProvider = context.read<QuizProvider>();
    final canAttempt = await quizProvider.canAttemptQuiz();
    if (!canAttempt && mounted) {
      _showTimeOverDialog();
    }
  }

  void _showTimeOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.deepPurple,
                width: 0.3,
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
                    Icons.timer_off_outlined,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Time\'s Up!',
                  style: TextStyleClass.fredoka(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'The quiz time is over. Your answers will be submitted automatically.',
                  style: TextStyleClass.openSans(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
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
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final quizProvider = context.read<QuizProvider>();
                          await quizProvider.submitQuiz(context);
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const BottomNavigationScreen(
                                          currentIndex: 4)),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                backgroundColor: ColorClass.white,
                                title: Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.alertTriangle,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Submission Failed',
                                      style: TextStyleClass.fredoka(
                                        fontSize: 18,
                                        color: ColorClass.black,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  e.toString().replaceAll('Exception: ', ''),
                                  style: TextStyleClass.poppinsRegular(
                                    fontSize: 14,
                                    color: ColorClass.black87,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const BottomNavigationScreen(
                                                    currentIndex: 4)),
                                      );
                                    },
                                    child: Text(
                                      'Return to Home',
                                      style: TextStyleClass.fredokaRegular(
                                        fontSize: 14,
                                        color: ColorClass.black87,
                                      ),
                                    ),
                                  ),
                                  Container(
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
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(
                                            context); // Close error dialog
                                        final quizProvider =
                                            context.read<QuizProvider>();
                                        try {
                                          await quizProvider
                                              .submitQuiz(context);
                                          if (context.mounted) {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const BottomNavigationScreen(
                                                          currentIndex: 4)),
                                            );
                                          }
                                        } catch (e) {
                                          // Show error dialog again
                                          if (context.mounted) {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) => AlertDialog(
                                                backgroundColor: ColorClass
                                                    .white, //check here the color, change it to black
                                                title: const Text(
                                                    'Submission Failed'),
                                                content: Text(e.toString()),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const BottomNavigationScreen(
                                                                  currentIndex:
                                                                      4,
                                                                )),
                                                      );
                                                    },
                                                    child: const Text(
                                                        'Return to Home'), //check the color here
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
                                        overlayColor:
                                            Colors.white.withOpacity(0.2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                      ),
                                      child: Text(
                                        'Try Again',
                                        style: TextStyleClass.fredoka(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
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
                        overlayColor: Colors.white.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'Submit & Return',
                        style: TextStyleClass.fredoka(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildQuestionCard(quizProvider, currentQuestion),
                          const SizedBox(height: 24),
                          _buildOptionsSection(quizProvider, currentQuestion),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildNavigationButtons(context, quizProvider),
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
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: Alignment.topCenter,
      //     end: Alignment.bottomCenter,
      //     colors: [
      //       ColorClass.primaryColor.withOpacity(0.15),
      //       Colors.transparent,
      //     ],
      //   ),
      // ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context); // go back to previous screen
                },
                icon: const Icon(
                  LucideIcons.arrowLeft, // or Icons.arrow_back
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Text(
                'Question ${quizProvider.currentQuestionIndex + 1} of ${quizProvider.currentQuizQuestions.length}',
                style: TextStyleClass.fredoka(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () =>
                    _showQuizMenuBottomSheet(context, quizProvider),
                icon: const Icon(
                  LucideIcons.menu,
                  color: Colors.deepPurpleAccent,
                ),
              ),
            ],
          ),
          if (quizProvider.quizConfig != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quiz ends at: ${quizProvider.formatClockTime(quizProvider.quizConfig!.endDate)}',
                  style: TextStyleClass.openSans(
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  quizProvider.getFormattedRemainingTime(),
                  style: TextStyleClass.openSans(
                    fontSize: 12,
                    color: quizProvider.getRemainingTime() <= 5
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // String _formatTime(DateTime time) {
  //   return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  // }

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
                style: TextStyleClass.openSans(
                  fontSize: 12,
                  color: ColorClass.black.withOpacity(0.7),
                ),
              ),
              const SizedBox.shrink(),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyleClass.openSansSemiBold(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '${quizProvider.questionsAnswered}',
                    ),
                    TextSpan(
                      text: '/${quizProvider.currentQuizQuestions.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final double progress = ((quizProvider.currentQuestionIndex + 1) /
                      (quizProvider.currentQuizQuestions.isEmpty
                          ? 1
                          : quizProvider.currentQuizQuestions.length))
                  .clamp(0.0, 1.0);
              const double barHeight = 12.0;
              return SizedBox(
                width: double.infinity,
                height: 22,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: 5,
                      child: Container(
                        width: constraints.maxWidth,
                        height: barHeight,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 5,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        width: constraints.maxWidth * progress,
                        height: barHeight,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFAC28DC),
                              Color(0xFF7E1DB7),
                              Color(0xFF501392),
                            ],
                            stops: [0, 0.50, 1],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
      QuizProvider quizProvider, dynamic currentQuestion) {
    final question = quizProvider.currentLanguage == 'en'
        ? currentQuestion.questionEn
        : currentQuestion.questionMl;
    // final questionNumber = quizProvider.currentQuestionIndex + 1;

    return
        // width: double.infinity,
        // padding: const EdgeInsets.all(24),
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //     colors: [
        //       ColorClass.primaryColor.withOpacity(0.1),
        //       ColorClass.primaryColor.withOpacity(0.05),
        //     ],
        //   ),
        //   borderRadius: BorderRadius.circular(20),
        //   border: Border.all(
        //     color: ColorClass.primaryColor.withOpacity(0.3),
        //     width: 1,
        //   ),
        // ),
        Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Container(
            //   padding:
            //       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            //   decoration: BoxDecoration(
            //     color: ColorClass.primaryColor.withOpacity(0.2),
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Text(
            //     'Question $questionNumber',
            //     style: TextStyleClass.poppinsMedium(
            //       fontSize: 14,
            //       color: ColorClass.primaryColor,
            //     ),
            //   ),
            // ),
            // const Spacer(),
            // Text(
            //   quizProvider.formattedQuestionTime,
            //   style: TextStyleClass.poppinsRegular(
            //     fontSize: 14,
            //     color: ColorClass.violet20,
            //   ),
            // ),
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
                    style: TextStyleClass.openSans(
                      fontSize: 14,
                      color: ColorClass.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          question,
          style: TextStyleClass.fredoka(
            fontSize: 24,
            color: ColorClass.black,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsSection(
      QuizProvider quizProvider, dynamic currentQuestion) {
    final options = quizProvider.currentLanguage == 'en'
        ? currentQuestion.optionsEn
        : currentQuestion.optionsMl;

    return Column(
      children: options.asMap().entries.map<Widget>((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected =
            quizProvider.selectedAnswers[currentQuestion.id] == index;

        return GestureDetector(
          onTap: () => quizProvider.answerQuestion(index),
          child: Container(
            width: double.infinity,
            height: 70,
            margin: const EdgeInsets.only(bottom: 12),
            //padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ColorClass.containerBg2.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? ColorClass.violet30
                    : ColorClass.white.withOpacity(0.1),
                width: isSelected ? 1.5 : 0,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: ColorClass.violet30.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + (index as int)), // A, B, C, D
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyleClass.openSans(
                        fontSize: 16, color: ColorClass.black),
                  ),
                ),
                // if (isSelected)
                //   const Icon(
                //     LucideIcons.check,
                //     color: ColorClass.primaryColor,
                //     size: 16,
                //   ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButtons(
      BuildContext context, QuizProvider quizProvider) {
    return Row(
      children: [
        if (quizProvider.currentQuestionIndex > 0)
          Expanded(
            child: Container(
              height: 45, // match your design
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFAC28DC),
                    Color(0xFF7E1EB7),
                    Color(0xFF501392),
                  ],
                  stops: [0, 0.50, 1],
                ),
              ),
              child: OutlinedButton(
                onPressed: quizProvider.previousQuestion,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white, // text/icon color
                  side: BorderSide.none, // remove default outline
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  //padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.arrowLeft, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Previous',
                      textAlign: TextAlign.center,
                      style: TextStyleClass.fredoka(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (quizProvider.currentQuestionIndex > 0) const SizedBox(width: 16),
        Expanded(
          child: Center(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFAC28DC),
                    Color(0xFF7E1EB7),
                    Color(0xFF501392),
                  ],
                  stops: [0, 0.50, 1],
                ),
              ),
              child: SizedBox(
                width: 217,
                height: 45,
                child: ElevatedButton(
                  onPressed: quizProvider.hasAnsweredCurrentQuestion
                      ? () {
                          if (quizProvider.isLastQuestion) {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: ColorClass.white,
                                title: Row(
                                  children: [
                                    const Icon(LucideIcons.alertTriangle,
                                        color: ColorClass.primaryColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      quizProvider.error != null
                                          ? 'Retry Submission?'
                                          : 'Submit Quiz?',
                                      style: TextStyleClass.fredoka(
                                        fontSize: 18,
                                        color: ColorClass.black,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  quizProvider.error != null
                                      ? 'Previous submission failed. Would you like to retry?'
                                      : 'Are you sure you want to submit the quiz? This action cannot be undone.',
                                  style: TextStyleClass.openSans(
                                    fontSize: 14,
                                    color: ColorClass.black87,
                                  ),
                                ),
                                actions: [
                                  Row(
                                    children: [
                                      // Continue Quiz / Cancel Button
                                      Expanded(
                                        child: Container(
                                          height: 45,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            border: Border.all(
                                              color: ColorClass.violet30,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              overlayColor: ColorClass.violet30
                                                  .withOpacity(0.1),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                            ),
                                            child: Text(
                                              quizProvider.error != null
                                                  ? 'Cancel'
                                                  : 'Continue Quiz',
                                              textAlign: TextAlign.center,
                                              style: TextStyleClass.fredoka(
                                                fontSize: 14,
                                                color: ColorClass.violet30,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Submit / Retry Button
                                      Expanded(
                                        child: Container(
                                          height: 45,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFAC28DC),
                                                Color(0xFF7E1EB7),
                                                Color(0xFF501392),
                                              ],
                                              stops: [0, 0.50, 1],
                                            ),
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                  context); // Close dialog
                                              quizProvider.submitQuiz(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              overlayColor:
                                                  Colors.white.withOpacity(0.2),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                            ),
                                            child: Text(
                                              quizProvider.error != null
                                                  ? 'Retry'
                                                  : 'Submit',
                                              style: TextStyleClass.fredoka(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          } else {
                            quizProvider.nextQuestion();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    //padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        quizProvider.isLastQuestion ? 'Submit Quiz' : 'Next',
                        style: TextStyleClass.fredoka(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!quizProvider.isLastQuestion)
                        Icon(
                          // _isLastQuestion
                          //     ? LucideIcons.check
                          //     :
                          LucideIcons.arrowRight,
                          size: 20,
                          color: Colors.white,
                        ),
                    ],
                  ),
                ),
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
        color: ColorClass.primaryColor,
      ),
    );
  }

  void _showQuizMenuBottomSheet(
      BuildContext context, QuizProvider quizProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorClass.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quiz Menu',
                style: TextStyleClass.fredoka(
                  fontSize: 20,
                  color: ColorClass.black,
                ),
              ),
              const SizedBox(height: 24),
              _buildQuestionGrid(quizProvider),
              const SizedBox(height: 24),
              SafeArea(
                child: Row(
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
                          borderRadius:
                              BorderRadius.circular(8), // match button radius
                        ),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide.none, // remove border
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Center(
                            child: Text(
                              'Continue Quiz',
                              style: TextStyle(
                                color: Colors.white, // text white
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              overflow:
                                  TextOverflow.ellipsis, // keeps single line
                            ),
                          ),
                        ),
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
                        child: Text(
                          'End Quiz',
                          style: TextStyleClass.fredoka(
                            fontSize: 16,
                            color: Colors.white, // clearly visible on red
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionGrid(QuizProvider quizProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Questions:',
          style: TextStyleClass.openSansSemiBold(
            fontSize: 16,
            color: ColorClass.violet,
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
            final isAnswered =
                quizProvider.selectedAnswers.containsKey(question.id);
            final isCurrent = index == quizProvider.currentQuestionIndex;

            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                quizProvider.goToQuestion(index);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrent
                      ? ColorClass.violet30.withOpacity(0.1)
                      : (isAnswered
                          ? Colors.green.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrent
                        ? ColorClass.violet30
                        : (isAnswered ? Colors.green : Colors.grey),
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isCurrent || isAnswered
                          ? Colors.white
                          : Colors.grey[400],
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
    final unansweredCount = quizProvider.currentQuizQuestions.length -
        quizProvider.questionsAnswered;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorClass.white,
        title: Text(
          quizProvider.error != null ? 'Retry Submission?' : 'Submit Quiz?',
          style: TextStyleClass.fredoka(
            fontSize: 20,
            color: ColorClass.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (quizProvider.error != null) ...[
              Text(
                'Previous submission failed. Would you like to retry?',
                style: TextStyleClass.openSans(
                  fontSize: 14,
                  color: Colors.orange,
                ),
              ),
            ] else ...[
              Text(
                'You have answered ${quizProvider.questionsAnswered} out of ${quizProvider.currentQuizQuestions.length} questions.',
                style: TextStyleClass.openSans(
                  fontSize: 14,
                  color: Colors.black54,
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
                style: TextStyleClass.fredokaRegular(
                  fontSize: 16,
                  color: ColorClass.black,
                ),
              ),
            ],
          ],
        ),
        actions: [
          Row(
            children: [
              // Continue Quiz / Return to Home Button
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: ColorClass.violet30,
                      width: 1.5,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (quizProvider.error != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const BottomNavigationScreen(
                                      currentIndex: 4)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      overlayColor: ColorClass.violet30.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      quizProvider.error != null
                          ? 'Return to Home'
                          : 'Continue Quiz',
                      textAlign: TextAlign.center,
                      style: TextStyleClass.fredoka(
                        fontSize: 14,
                        color: ColorClass.violet30,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Submit / Retry Button
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFAC28DC),
                        Color(0xFF7E1EB7),
                        Color(0xFF501392),
                      ],
                      stops: [0, 0.50, 1],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      quizProvider.submitQuiz(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      overlayColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
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
                        : Text(
                            quizProvider.error != null ? 'Retry' : 'Submit',
                            style: TextStyleClass.fredoka(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Color _getQuestionTypeColor(String type) {
  //   switch (type) {
  //     case 'multiple_choice':
  //       return Colors.blue;
  //     case 'true_false':
  //       return Colors.green;
  //     default:
  //       return Colors.grey;
  //   }
  // }

  // Color _getDifficultyColor(String difficulty) {
  //   switch (difficulty) {
  //     case 'easy':
  //       return Colors.green;
  //     case 'medium':
  //       return Colors.orange;
  //     case 'hard':
  //       return Colors.red;
  //     default:
  //       return Colors.grey;
  //   }
  // }
}
