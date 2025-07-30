import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/quiz_screen/provider/quiz_login_provider.dart';

class MobileInputSection extends StatefulWidget {
  const MobileInputSection({super.key});

  @override
  State<MobileInputSection> createState() => _MobileInputSectionState();
}

class _MobileInputSectionState extends State<MobileInputSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final provider = context.read<QuizLoginProvider>();
    _controller = TextEditingController(text: provider.mobile);
    _controller.addListener(() {
      if (_controller.text != provider.mobile) {
        provider.setMobile(_controller.text);
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
            _buildMobileInputField(quizProvider),
            const SizedBox(height: 20),
            _buildErrorText(quizProvider),
            const SizedBox(height: 30),
            _buildSendOtpButton(quizProvider),
            const SizedBox(height: 32),
            _buildTermsText(),
          ],
        );
      },
    );
  }

  Widget _buildMobileInputField(QuizLoginProvider quizLoginProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number',
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
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            style: TextStyleClass.poppinsRegular(
              fontSize: 16,
              color: ColorClass.white,
            ),
            decoration: const InputDecoration(
              hintText: 'Enter 10-digit mobile number',
              hintStyle: TextStyle(color: ColorClass.grey400),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Icon(
                Icons.phone_android,
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

  Widget _buildSendOtpButton(QuizLoginProvider quizLoginProvider) {
    final bool isValidMobile = quizLoginProvider.mobile.length == 10;
    
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (isValidMobile && !quizLoginProvider.isLoading)
            ? () => quizLoginProvider.sendOtp()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isValidMobile 
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
                'Send OTP',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 16,
                  color: ColorClass.white,
                ),
              ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        'By continuing, you agree to our Terms of Service and Privacy Policy',
        style: TextStyleClass.poppinsRegular(
          fontSize: 12,
          color: ColorClass.white70,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
} 