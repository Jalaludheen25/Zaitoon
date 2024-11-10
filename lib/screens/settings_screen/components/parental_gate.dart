import 'dart:math';
import 'package:flutter/material.dart';
import 'package:zaitoon/constants/color_class.dart';

class ParentalGate extends StatefulWidget {
  final Function onSuccess;
  final String title;

  const ParentalGate({
    Key? key,
    required this.onSuccess,
    this.title = 'Parental Gate',
  }) : super(key: key);

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

    if (userAnswer == num1 * num2) {
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
    return AlertDialog(
      backgroundColor: ColorClass.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: ColorClass.white, width: 2),
      ),
      content: SizedBox(
        width: double.minPositive,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ColorClass.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'This section requires parent permission.\nPlease solve this math problem:',
              textAlign: TextAlign.center,
              style: TextStyle(color: ColorClass.white),
            ),
            const SizedBox(height: 20),
            Text(
              '$num1 × $num2 = ?',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorClass.white,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _answerController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: ColorClass.white),
              decoration: InputDecoration(
                hintText: 'Enter your answer',
                hintStyle: const TextStyle(color: ColorClass.grey),
                errorText: errorText.isNotEmpty ? errorText : null,
                border: const OutlineInputBorder(),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: ColorClass.white),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: ColorClass.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 100,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: ColorClass.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: _checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorClass.white,
                      foregroundColor: ColorClass.black,
                    ),
                    child: const Text('Submit'),
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