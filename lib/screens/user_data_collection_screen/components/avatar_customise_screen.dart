// lib/screens/user_data_collection/screens/avatar_customizer_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';

class AvatarCustomizerScreen extends StatefulWidget {
  const AvatarCustomizerScreen({super.key});

  @override
  State<AvatarCustomizerScreen> createState() => _AvatarCustomizerScreenState();
}

class _AvatarCustomizerScreenState extends State<AvatarCustomizerScreen> {
  late final PageController _avatarPageController;
  double _avatarCurrentPage = 0;
  final List<String> _avatars = const [
    ImageClass.avatar1,
    ImageClass.avatar2,
    ImageClass.avatar3,
  ];

  @override
  void initState() {
    super.initState();
    _avatarPageController =
        PageController(viewportFraction: 1.0, initialPage: 1000);
    _avatarCurrentPage = _avatarPageController.initialPage.toDouble();
    _avatarPageController.addListener(() {
      setState(() {
        _avatarCurrentPage = _avatarPageController.page ?? _avatarCurrentPage;
      });
      final provider = Provider.of<UserDataProvider>(context, listen: false);
      final int len = _avatars.length;
      final int center = (((_avatarCurrentPage.round()) % len) + len) % len;
      provider.setAvatar(_avatars[center]);
    });
  }

  @override
  void dispose() {
    _avatarPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int mod(int a, int b) => (a % b + b) % b;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double big = (maxWidth * 0.28).clamp(90.0, 120.0);
        final double small = (big * 0.62).clamp(56.0, 90.0);
        // Evenly distribute remaining width as spacing (four gaps: left, between, between, right)
        final double usedWidth = big + small * 2;
        final double remaining = (maxWidth - usedWidth).clamp(0.0, maxWidth);
        final double gap = remaining / 4.0;

        return SizedBox(
          height: big + 12,
          child: PageView.builder(
            controller: _avatarPageController,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, pageIndex) {
              final int len = _avatars.length;
              final int center = mod(pageIndex, len);
              final int left = mod(center - 1, len);
              final int right = mod(center + 1, len);

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: gap),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _avatarPageController.animateToPage(
                          (_avatarCurrentPage.round()) - 1,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                        );
                      },
                      child: _buildAvatarCircle(
                        _avatars[left],
                        small,
                        false,
                        blurred: true,
                      ),
                    ),
                    _buildAvatarCircle(
                      _avatars[center],
                      big,
                      true,
                      blurred: false,
                    ),
                    GestureDetector(
                      onTap: () {
                        _avatarPageController.animateToPage(
                          (_avatarCurrentPage.round()) + 1,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                        );
                      },
                      child: _buildAvatarCircle(
                        _avatars[right],
                        small,
                        false,
                        blurred: true,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAvatarCircle(String assetPath, double size, bool highlight,
      {bool blurred = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: highlight ? ColorClass.violet30 : Colors.transparent,
          width: highlight ? 3 : 0,
        ),
      ),
      child: ClipOval(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: blurred ? 2.5 : 0.0,
            sigmaY: blurred ? 2.5 : 0.0,
          ),
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
