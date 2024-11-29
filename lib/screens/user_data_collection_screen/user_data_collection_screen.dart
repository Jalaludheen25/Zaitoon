// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:zaitoon/screens/language_selection/language_selection.dart';
import 'package:zaitoon/screens/user_data_collection_screen/components/custom_text_field.dart';
import 'package:zaitoon/screens/user_data_collection_screen/components/gender_card.dart';
import 'package:zaitoon/screens/user_data_collection_screen/components/submit_button.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';

import '../../../constants/color_class.dart';
import '../../../constants/textstyle_class.dart';
import '../../../helper/navigation_helper.dart';

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
  bool _isCustomizerVisible = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = Provider.of<UserDataProvider>(context, listen: false);
      await provider.initialize();
      await _loadUserDetails();
    });
  }

  Future<void> _loadUserDetails() async {
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
            navigateAndRemove(
              context: context,
              screen: const LanguageSelection(),
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'My Profile',
          style: TextStyleClass.poppinsNormal(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<UserDataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading &&
              (_nameController.text.isEmpty && _ageController.text.isEmpty)) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurpleAccent,
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: FluttermojiCircleAvatar(
                          backgroundColor: ColorClass.grey,
                          radius: 75,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildAvatarCustomizer(context),
                      _buildCustomizeButton(),
                      const SizedBox(height: 20),
                      _buildNameSection(provider),
                      const SizedBox(height: 24),
                      _buildAgeSection(provider),
                      const SizedBox(height: 24),
                      _buildGenderSection(provider),
                      if (provider.error.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          provider.error,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
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
          );
        },
      ),
    );
  }

  Widget _buildAvatarCustomizer(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isCustomizerVisible
          ? Column(
              key: const ValueKey('customizer'),
              children: [
                const SizedBox(height: 20),
                FluttermojiCustomizer(
                  autosave: true,
                  scaffoldWidth: MediaQuery.of(context).size.width,
                  theme: FluttermojiThemeData(
                    primaryBgColor: Colors.black,
                    secondaryBgColor: Colors.grey[900],
                    iconColor: Colors.white,
                    selectedIconColor: Colors.deepPurpleAccent,
                    unselectedIconColor: Colors.grey[600],
                    labelTextStyle: const TextStyle(color: Colors.white),
                    selectedTileDecoration: BoxDecoration(
                      color: Colors.deepPurpleAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    unselectedTileDecoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildCustomizeButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _isCustomizerVisible = !_isCustomizerVisible;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          _isCustomizerVisible ? 'Close Customizer' : 'Customize Avatar',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildNameSection(UserDataProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What\'s your name?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _nameController,
          hint: 'Enter your name',
          icon: LucideIcons.user,
          enabled: !provider.isLoading,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAgeSection(UserDataProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How old are you?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _ageController,
          hint: 'Enter your age',
          icon: LucideIcons.cake,
          enabled: !provider.isLoading,
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
      ],
    );
  }

  Widget _buildGenderSection(UserDataProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What\'s your gender?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            GenderCard(
              icon: LucideIcons.baby,
              label: "I'm a Boy",
              value: 'boy',
              selectedGender: provider.gender,
              onSelect: provider.isLoading ? null : provider.updateGender,
              enabled: !provider.isLoading,
            ),
            const SizedBox(width: 16),
            GenderCard(
              icon: LucideIcons.baby,
              label: "I'm a Girl",
              value: 'girl',
              selectedGender: provider.gender,
              onSelect: provider.isLoading ? null : provider.updateGender,
              enabled: !provider.isLoading,
            ),
          ],
        ),
      ],
    );
  }
}
