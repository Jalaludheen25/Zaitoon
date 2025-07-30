import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/quiz_screen/provider/quiz_login_provider.dart';
import 'package:zaitoon/screens/quiz_screen/components/mobile_input_section.dart';
import 'package:zaitoon/screens/quiz_screen/components/otp_input_section.dart';

class QuizLoginScreen extends StatelessWidget {
  const QuizLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizLoginProvider>(
      builder: (context, quizProvider, child) {
        return Scaffold(
          backgroundColor: ColorClass.black,
          appBar: _buildAppBar(context, quizProvider.isOtpSent),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildBody(),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isOtpSent) {
    return AppBar(
      backgroundColor: ColorClass.black,
      elevation: 0,
      title: Text(
        'Quiz Corner',
        style: TextStyleClass.poppinsSemiBold(
          fontSize: 20,
          color: ColorClass.white,
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: isOtpSent
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: ColorClass.white),
              onPressed: () => context.read<QuizLoginProvider>().reset(),
            )
          : null,
    );
  }

  Widget _buildBody() {
    return Consumer<QuizLoginProvider>(
      builder: (context, quizProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            if (!quizProvider.isOtpSent) ...[
              _buildHeaderSection(),
              const SizedBox(height: 40),
            ],
            quizProvider.isOtpSent
                ? const OtpInputSection()
                : const MobileInputSection(),
            const SizedBox(height: 40),
          ],
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        // Quiz icon or mascot
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: ColorClass.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(60),
          ),
          child: const Icon(
            Icons.quiz,
            size: 60,
            color: ColorClass.primaryColor,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Test Your Knowledge',
          style: TextStyleClass.poppinsBold(
            fontSize: 24,
            color: ColorClass.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your mobile number to start the quiz and win exciting rewards!',
          style: TextStyleClass.poppinsRegular(
            fontSize: 16,
            color: ColorClass.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 