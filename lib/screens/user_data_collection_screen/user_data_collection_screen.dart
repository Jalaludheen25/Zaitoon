// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/bottom_navigation/bottom_navigation.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';
import 'package:zaitoon/screens/user_data_collection_screen/components/gender_card.dart';
import 'package:zaitoon/screens/user_data_collection_screen/components/custom_text_field.dart';
import 'package:zaitoon/screens/user_data_collection_screen/components/submit_button.dart';
import 'package:zaitoon/screens/user_data_collection_screen/components/avatar_customise_screen.dart';
import 'package:zaitoon/screens/language_selection/language_selection.dart';

import '../../../constants/color_class.dart';
import '../../../constants/image_class.dart';
import '../../../constants/icon_class.dart';
import '../../../helper/navigation_helper.dart';
import '../../../providers/theme_provider.dart';

class UserDataCollection extends StatefulWidget {
  final bool isFromOnboarding;
  const UserDataCollection({super.key, required this.isFromOnboarding});

  @override
  State<UserDataCollection> createState() => _UserDataCollectionState();
}

class _UserDataCollectionState extends State<UserDataCollection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
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
      // Persist currently centered avatar to provider
      final provider = Provider.of<UserDataProvider>(context, listen: false);
      final int len = _avatars.length;
      final int center = ((_avatarCurrentPage.round()) % len + len) % len;
      provider.setAvatar(_avatars[center]);
    });
    Future.microtask(() async {
      final provider = Provider.of<UserDataProvider>(context, listen: false);
      await provider.loadUserDetails();
      // Ensure an avatar is set on first load
      if (provider.avatar == null || provider.avatar!.isEmpty) {
        provider.setAvatar(
            _avatars[(_avatarCurrentPage.round()) % _avatars.length]);
      }
      await retriveUserData();
    });
  }

  Future<void> retriveUserData() async {
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    if (provider.name != null) {
      _nameController.text = provider.name!;
    }
    if (provider.age != null) {
      _ageController.text = provider.age.toString();
    }
    if (provider.gender.isNotEmpty) {
      provider.updateGender(provider.gender);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _avatarPageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final success =
            await context.read<UserDataProvider>().validateAndSaveUserDetails(
                  name: _nameController.text.trim(),
                  age: _ageController.text,
                );

        if (!mounted) return;

        if (success) {
          if (widget.isFromOnboarding) {
            // After completing user data collection during onboarding, go to home screen
            navigateAndRemove(
              context: context,
              screen: const BottomNavigationScreen(),
            );
          } else {
            navigateBack(context);
          }
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Set system UI overlay style to dark
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
            statusBarBrightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
          ),
        );

        return Scaffold(
          backgroundColor: themeProvider.isDarkMode ? ColorClass.black : Colors.white,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: themeProvider.isDarkMode ? ColorClass.black : Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: themeProvider.isDarkMode ? ColorClass.white : Colors.black),
          onPressed: () {
            navigateAndRemove(
              context: context,
              screen: const LanguageSelection(),
            );
          },
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              ColorClass.grad1,
              ColorClass.grad2,
              ColorClass.grad3,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'My Profile',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Consumer<UserDataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading &&
              (_nameController.text.isEmpty && _ageController.text.isEmpty)) {
            return const Center(
              child: CircularProgressIndicator(
                color: ColorClass.violet30,
              ),
            );
          }

          return Stack(
            children: [
              // Background with blur effects
              Container(
                  // decoration: const BoxDecoration(
                  //   gradient: LinearGradient(
                  //     begin: Alignment.topLeft,
                  //     end: Alignment.bottomRight,
                  //     colors: [
                  //       Color(0xFFF8F9FF),
                  //       Colors.white,
                  //       Color(0xFFF8F9FF),
                  //     ],
                  //   ),
                  // ),
                  ),

              // Top left blur effect
              Positioned(
                top: 150,
                left: -30,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        ColorClass.violet30.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Top right blur effect
              Positioned(
                top: 20,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        ColorClass.grad1.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 15),

                      // Avatar Selection Row (carousel)
                      AvatarCustomizerScreen(),

                      //const SizedBox(height: 20),
                      Text(
                        "Swipe to choose avatar",
                        style: TextStyleClass.openSans(
                          fontSize: 16,
                          color: themeProvider.isDarkMode ? ColorClass.white : Colors.black54,
                        ),
                      ),
                      // Container(
                      //   width: 184,
                      //   height: 40,
                      //   decoration: BoxDecoration(
                      //     gradient: const LinearGradient(
                      //       colors: [
                      //         ColorClass.grad1,
                      //         ColorClass.grad2,
                      //         ColorClass.grad3,
                      //       ],
                      //     ),
                      //     borderRadius: BorderRadius.circular(20),
                      //   ),
                      //   child: Center(
                      //     child: Text(
                      //       "Choose Avatar",
                      //       style: GoogleFonts.fredoka(
                      //         fontWeight: FontWeight.w500,
                      //         fontSize: 16,
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      const SizedBox(height: 25),

                      // Form Fields
                      Expanded(
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 24,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Name Section
                                CustomTextField(
                                  title: "What's your name?",
                                  controller: _nameController,
                                  hint: "Enter your name",
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Age Section
                                CustomTextField(
                                  title: "How old are you?",
                                  controller: _ageController,
                                  hint: "Enter your age",
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your age';
                                    }
                                    final age = int.tryParse(value);
                                    if (age == null || age < 1) {
                                      return 'Please enter a valid age';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Gender Section
                                // Gender Section using GenderCard component
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "What's your Gender?",
                                      style: TextStyleClass.fredoka(
                                        fontSize: 16,
                                        color: themeProvider.isDarkMode ? ColorClass.white : ColorClass.black,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GenderCard(
                                            icon: IconClass.boy,
                                            label: "I'm a Boy",
                                            isSelected:
                                                provider.gender == 'boy',
                                            onTap: () =>
                                                provider.updateGender('boy'),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: GenderCard(
                                            icon: IconClass.girl,
                                            label: "I'm a Girl",
                                            isSelected:
                                                provider.gender == 'girl',
                                            onTap: () =>
                                                provider.updateGender('girl'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 50),

                                // Error Message
                                if (provider.error.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color:
                                            Colors.redAccent.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      provider.error,
                                      style: GoogleFonts.inter(
                                        color: Colors.redAccent,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                // Get Started Button component
                                SubmitButton(
                                  isLoading: provider.isLoading,
                                  onPressed: _handleSubmit,
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      )
        );
      },
    );
  }

  // Widget _buildAvatarSelectionRow() {
  //   int mod(int a, int b) => (a % b + b) % b;
  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       final double maxWidth = constraints.maxWidth;
  //       final double big = (maxWidth * 0.28).clamp(90.0, 120.0);
  //       final double small = (big * 0.62).clamp(56.0, 90.0);
  //       // Evenly distribute remaining width as spacing (four gaps: left, between, between, right)
  //       final double usedWidth = big + small * 2;
  //       final double remaining = (maxWidth - usedWidth).clamp(0.0, maxWidth);
  //       final double gap = remaining / 4.0;

  //       return SizedBox(
  //         height: big + 12,
  //         child: PageView.builder(
  //           controller: _avatarPageController,
  //           physics: const BouncingScrollPhysics(),
  //           itemBuilder: (context, pageIndex) {
  //             final int len = _avatars.length;
  //             final int center = mod(pageIndex, len);
  //             final int left = mod(center - 1, len);
  //             final int right = mod(center + 1, len);

  //             return Padding(
  //               padding: EdgeInsets.symmetric(horizontal: gap),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   GestureDetector(
  //                     onTap: () {
  //                       _avatarPageController.animateToPage(
  //                         (_avatarCurrentPage.round()) - 1,
  //                         duration: const Duration(milliseconds: 220),
  //                         curve: Curves.easeOut,
  //                       );
  //                     },
  //                     child: _buildAvatarCircle(
  //                       _avatars[left],
  //                       small,
  //                       false,
  //                       blurred: true,
  //                     ),
  //                   ),
  //                   _buildAvatarCircle(
  //                     _avatars[center],
  //                     big,
  //                     true,
  //                     blurred: false,
  //                   ),
  //                   GestureDetector(
  //                     onTap: () {
  //                       _avatarPageController.animateToPage(
  //                         (_avatarCurrentPage.round()) + 1,
  //                         duration: const Duration(milliseconds: 220),
  //                         curve: Curves.easeOut,
  //                       );
  //                     },
  //                     child: _buildAvatarCircle(
  //                       _avatars[right],
  //                       small,
  //                       false,
  //                       blurred: true,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget _buildAvatarCircle(String assetPath, double size, bool highlight,
  //     {bool blurred = false}) {
  //   return Container(
  //     width: size,
  //     height: size,
  //     decoration: BoxDecoration(
  //       shape: BoxShape.circle,
  //       border: Border.all(
  //         color: highlight ? ColorClass.violet30 : Colors.transparent,
  //         width: highlight ? 3 : 0,
  //       ),
  //       boxShadow: [
  //         if (highlight)
  //           BoxShadow(
  //             color: ColorClass.violet30.withOpacity(0.25),
  //             blurRadius: 18,
  //             offset: const Offset(0, 6),
  //           ),
  //       ],
  //     ),
  //     child: ClipOval(
  //       child: ImageFiltered(
  //         imageFilter: ImageFilter.blur(
  //           sigmaX: blurred ? 2.5 : 0.0,
  //           sigmaY: blurred ? 2.5 : 0.0,
  //         ),
  //         child: Image.asset(
  //           assetPath,
  //           fit: BoxFit.cover,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // String _getAvatarImage(int index) {
  //   String imagePath;
  //   switch (index) {
  //     case 0:
  //       imagePath = ImageClass.avatar1;
  //       break;
  //     case 1:
  //       imagePath = ImageClass.avatar2;
  //       break;
  //     case 2:
  //       imagePath = ImageClass.avatar3;
  //       break;
  //     default:
  //       imagePath = ImageClass.avatar1;
  //   }
  //   return imagePath;
  // }
}
