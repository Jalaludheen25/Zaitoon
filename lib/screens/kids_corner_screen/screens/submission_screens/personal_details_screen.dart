import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/screens/kids_corner_screen/provider/kids_corner_provider.dart';
import 'dart:io';
import 'submission_acknowledgment_screen.dart';
import 'package:lottie/lottie.dart';

class PersonalDetailsScreen extends StatefulWidget {
  final String contentType;
  final String title;
  final String content;
  final File? drawingImage;

  const PersonalDetailsScreen({
    super.key,
    required this.contentType,
    required this.title,
    required this.content,
    this.drawingImage,
  });

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController parentNameController = TextEditingController();
  final TextEditingController parentPhoneController = TextEditingController();
  File? kidImage;
  final ImagePicker _picker = ImagePicker();
  bool _isButtonHovered = false;
  final bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final sizeInBytes = await file.length();
        final sizeInMB = sizeInBytes / (1024 * 1024);

        if (sizeInMB > 5) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select an image smaller than 5MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          kidImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error selecting image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitContent() async {
    if (!_validateFields()) return;

    try {
      final provider = Provider.of<KidsCornerProvider>(context, listen: false);

      final success = await provider.submitContent(
        title: widget.title,
        contentType: widget.contentType.toLowerCase(),
        storyOrPoem:
            widget.contentType.toLowerCase() == 'drawing' ? '' : widget.content,
        kidName: nameController.text,
        kidAge: int.parse(ageController.text),
        schoolName: schoolController.text,
        parentName: parentNameController.text.isEmpty
            ? null
            : parentNameController.text,
        parentPhoneNumber: parentPhoneController.text.isEmpty
            ? null
            : parentPhoneController.text,
        kidPhoto: kidImage,
        drawings: widget.contentType.toLowerCase() == 'drawing'
            ? widget.drawingImage
            : null,
        descriptionForDrawings: widget.contentType.toLowerCase() == 'drawing'
            ? widget.content
            : null,
      );

      if (success) {
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SubmissionAcknowledgmentScreen(),
            ),
          );
        }
      } else if (mounted) {
        Navigator.of(context).pop();
        String errorMessage =
            provider.error ?? 'Failed to submit content. Please try again.';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      log('Error in _submitContent: $e');
      _showErrorDialog(
          'An error occurred while submitting your content. Please try again.');
    }
  }

  bool _validateFields() {
    if (nameController.text.trim().isEmpty ||
        ageController.text.trim().isEmpty ||
        schoolController.text.trim().isEmpty) {
      _showErrorDialog('Please fill in all required fields');
      return false;
    }

    if (int.tryParse(ageController.text) == null) {
      _showErrorDialog('Please enter a valid age');
      return false;
    }

    if (kidImage == null) {
      _showErrorDialog('Please add a photo');
      return false;
    }

    if (widget.contentType.toLowerCase() == 'drawing' &&
        widget.drawingImage == null) {
      _showErrorDialog('Please add your drawing');
      return false;
    }

    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error', style: GoogleFonts.fredoka()),
        content: Text(message, style: GoogleFonts.quicksand()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.fredoka()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7C53F4), Color(0xFF4A25AA)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildProfileImage(),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildFormSection(),
                ),
                const SizedBox(height: 16),
                _buildSubmitButton(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Tell Us About Yourself!',
          style: GoogleFonts.fredoka(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: FadeInDown(
        duration: const Duration(milliseconds: 800),
        child: Stack(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: kidImage != null
                    ? ClipOval(
                        child: Image.file(kidImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_a_photo,
                            size: 30,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add Photo',
                            style: GoogleFonts.quicksand(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (kidImage != null)
              Positioned(
                right: 5,
                bottom: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Color(0xFF7C53F4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 20),
            _buildTextField('Child\'s Name', nameController,
                icon: LucideIcons.user2),
            const SizedBox(height: 10),
            _buildTextField('Age', ageController,
                keyboardType: TextInputType.number, icon: LucideIcons.cake),
            const SizedBox(height: 10),
            _buildTextField('School Name', schoolController,
                icon: LucideIcons.school),
            const SizedBox(height: 10),
            _buildTextField('Parent\'s Name', parentNameController,
                icon: LucideIcons.users),
            const SizedBox(height: 10),
            _buildTextField('Parent\'s Phone Number', parentPhoneController,
                keyboardType: TextInputType.phone, icon: LucideIcons.phone),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType, IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.quicksand(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: GoogleFonts.quicksand(
                color: Colors.white.withOpacity(0.7),
              ),
              prefixIcon:
                  Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isButtonHovered = true),
        onExit: (_) => setState(() => _isButtonHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isButtonHovered ? 1.05 : 1.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitContent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF7C53F4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: _isButtonHovered ? 8 : 5,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF7C53F4)),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Submit ✨',
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(LucideIcons.send),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    schoolController.dispose();
    parentNameController.dispose();
    parentPhoneController.dispose();
    super.dispose();
  }
}
