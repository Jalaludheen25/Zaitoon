import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/quiz_screen/provider/quiz_login_provider.dart';

class OtpInputSection extends StatefulWidget {
  const OtpInputSection({super.key});

  @override
  State<OtpInputSection> createState() => _OtpInputSectionState();
}

class _OtpInputSectionState extends State<OtpInputSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final provider = context.read<QuizLoginProvider>();
    _controller = TextEditingController(text: provider.otp);
    _controller.addListener(() {
      if (_controller.text != provider.otp) {
        provider.setOtp(_controller.text);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizLoginProvider>(
      builder: (context, quizProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOtpHeader(quizProvider),
            const SizedBox(height: 30),
            _buildOtpInputField(quizProvider),
            const SizedBox(height: 20),
            _buildErrorText(quizProvider),
            const SizedBox(height: 30),
            _buildVerifyOtpButton(quizProvider),
            const SizedBox(height: 20),
            _buildResendOtpSection(quizProvider),
            const SizedBox(height: 32),
            _buildBackToMobileButton(quizProvider),
          ],
        );
      },
    );
  }

  Widget _buildOtpHeader(QuizLoginProvider quizLoginProvider) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: ColorClass.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(
            Icons.lock_outline,
            size: 30,
            color: ColorClass.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Enter OTP',
          style: TextStyleClass.poppinsBold(
            fontSize: 20,
            color: ColorClass.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ve sent a 6-digit code to\n${Provider.of<QuizLoginProvider>(context, listen: false).mobile}',
          style: TextStyleClass.poppinsRegular(
            fontSize: 14,
            color: ColorClass.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOtpInputField(QuizLoginProvider quizLoginProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OTP Code',
          style: TextStyleClass.poppinsMedium(
            fontSize: 16,
            color: ColorClass.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: ColorClass.grey900,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: quizLoginProvider.error != null 
                  ? ColorClass.secondaryColor 
                  : ColorClass.grey800,
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            style: TextStyleClass.poppinsRegular(
              fontSize: 18,
              color: ColorClass.white,
            ).copyWith(letterSpacing: 2),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '000000',
              hintStyle: TextStyle(
                color: ColorClass.grey400,
              ).copyWith(letterSpacing: 2),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: const Icon(
                Icons.security,
                color: ColorClass.grey400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorText(QuizLoginProvider quizLoginProvider) {
    if (quizLoginProvider.error == null) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColorClass.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ColorClass.secondaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: ColorClass.secondaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              quizLoginProvider.error!,
              style: TextStyleClass.poppinsRegular(
                fontSize: 14,
                color: ColorClass.secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyOtpButton(QuizLoginProvider quizLoginProvider) {
    final bool isValidOtp = quizLoginProvider.otp.length == 6;
    
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (isValidOtp && !quizLoginProvider.isLoading)
            ? () => quizLoginProvider.verifyOtp(onSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('OTP verified successfully!'),
                      backgroundColor: ColorClass.primaryColor,
                    ),
                  );
                })
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isValidOtp 
              ? ColorClass.primaryColor 
              : ColorClass.grey800,
          foregroundColor: ColorClass.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: quizLoginProvider.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(ColorClass.white),
                ),
              )
            : Text(
                'Verify OTP',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 16,
                  color: ColorClass.white,
                ),
              ),
      ),
    );
  }

  Widget _buildResendOtpSection(QuizLoginProvider quizLoginProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Didn\'t receive the code? ',
          style: TextStyleClass.poppinsRegular(
            fontSize: 14,
            color: ColorClass.white70,
          ),
        ),
        if (quizLoginProvider.resendTimer > 0)
          Text(
            'Resend in ${quizLoginProvider.resendTimer}s',
            style: TextStyleClass.poppinsMedium(
              fontSize: 14,
              color: ColorClass.grey400,
            ),
          )
        else
          GestureDetector(
            onTap: () => quizLoginProvider.resendOtp(),
            child: Text(
              'Resend OTP',
              style: TextStyleClass.poppinsMedium(
                fontSize: 14,
                color: ColorClass.primaryColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBackToMobileButton(QuizLoginProvider quizLoginProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextButton(
        onPressed: () => quizLoginProvider.reset(),
        child: Text(
          'Change Mobile Number',
          style: TextStyleClass.poppinsMedium(
            fontSize: 14,
            color: ColorClass.white70,
          ),
        ),
      ),
    );
  }
} 