// lib/screens/user_data_collection/screens/user_data_collection_screen.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/language_selection/language_selection.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';

class UserDataCollection extends StatefulWidget {
  const UserDataCollection({super.key});

  @override
  State<UserDataCollection> createState() => _UserDataCollectionState();
}

class _UserDataCollectionState extends State<UserDataCollection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Print user details
    Future.microtask(() async {
      await _printUserDetails();
    });
  }

  Future<void> _printUserDetails() async {
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    await provider.loadUserDetails(); // Load details from SharedPreferences

    debugPrint('User Details:');
    debugPrint('Name: ${provider.name ?? 'Not set'}');
    debugPrint('Age: ${provider.age ?? 'Not set'}');
    debugPrint(
        'Gender: ${provider.gender.isEmpty ? 'Not set' : provider.gender}');
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
      final success =
          await context.read<UserDataProvider>().validateAndSaveUserDetails(
                name: _nameController.text,
                age: _ageController.text,
              );

      if (success && mounted) {
        navigateAndReplace(context, const LanguageSelection());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<UserDataProvider>(
        builder: (context, provider, child) {
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
                      const SizedBox(height: 40),
                      // Header
                      const Text(
                        'Welcome to\nZai Toon! 👋',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Let\'s get to know you better',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Name Input
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Age Input
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
                      const SizedBox(height: 24),

                      // Gender Selection
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
                            onSelect: provider.updateGender,
                          ),
                          const SizedBox(width: 16),
                          GenderCard(
                            icon: LucideIcons.baby,
                            label: "I'm a Girl",
                            value: 'girl',
                            selectedGender: provider.gender,
                            onSelect: provider.updateGender,
                          ),
                        ],
                      ),
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

                      // Submit Button
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
}

// lib/screens/user_data_collection/widgets/custom_text_field.dart

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: validator,
    );
  }
}

// lib/screens/user_data_collection/widgets/gender_card.dart

class GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String selectedGender;
  final Function(String) onSelect;

  const GenderCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.selectedGender,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedGender == value;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(value),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurpleAccent : Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: Colors.deepPurpleAccent, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/screens/user_data_collection/widgets/submit_button.dart

class SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const SubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Let\'s Start Reading!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
