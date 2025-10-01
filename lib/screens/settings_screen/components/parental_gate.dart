import 'dart:math';
import 'package:flutter/material.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';

class ParentalGate extends StatefulWidget {
  final Function onSuccess;
  final String title;

  const ParentalGate({
    super.key,
    required this.onSuccess,
    this.title = 'Parental Gate',
  });

  @override
  State<ParentalGate> createState() => _ParentalGateState();
}

class _ParentalGateState extends State<ParentalGate> {
  late int num1;
  late int num2;
  final TextEditingController _answerController = TextEditingController();
  String errorText = '';

  @override
  void initState() {
    super.initState();
    _generateNewProblem();
  }

  void _generateNewProblem() {
    final random = Random();
    num1 = random.nextInt(10) + 1;
    num2 = random.nextInt(10) + 1;
  }

  void _checkAnswer() {
    final userAnswer = int.tryParse(_answerController.text);
    if (userAnswer == null) {
      setState(() => errorText = 'Please enter a number');
      return;
    }

    if (userAnswer == num1 + num2) {
      Navigator.of(context).pop();
      widget.onSuccess();
    } else {
      setState(() {
        errorText = 'Incorrect answer, please try again';
        _answerController.clear();
        _generateNewProblem();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ColorClass.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Parental Access\nRequired',
              textAlign: TextAlign.center,
              style: TextStyleClass.fredoka(
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),

            // Description
            const Text(
              'This section is for parents only.\nTo continue, please solve this simple\nmath problem:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Math Problem
            Text(
              '$num1 + $num2 =',
              style: TextStyleClass.fredoka(
                fontSize: 48,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),

            // Answer Input
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(50),
              ),
              child: TextField(
                controller: _answerController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyleClass.fredoka(
                  fontSize: 18,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Type your answer here...',
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  errorText: errorText.isNotEmpty ? errorText : null,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyleClass.fredoka(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Confirm Button
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorClass.grad1,
                          ColorClass.grad2,
                          ColorClass.grad3,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton(
                      onPressed: _checkAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'Confirm',
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
          ],
        ),
      ),
    );
  }
}
