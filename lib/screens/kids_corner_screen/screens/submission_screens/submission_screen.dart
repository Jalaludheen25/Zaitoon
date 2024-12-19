import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:io';
import 'package:zaitoon/screens/kids_corner_screen/screens/submission_screens/personal_details_screen.dart';

class SubmissionScreen extends StatefulWidget {
  const SubmissionScreen({super.key});

  @override
  State<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen> {
  String selectedContentType = 'Story';
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isButtonHovered = false;

  final List<String> contentTypes = ['Story', 'Poem', 'Drawing'];

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920, // Limit max resolution
        maxHeight: 1080,
        imageQuality: 85, // Compress image quality (0-100)
      );

      if (image != null) {
        // Check file size (limit to 5MB)
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
          selectedImage = File(image.path);
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

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenSize = MediaQuery.of(context).size;
    final contentPadding = screenSize.height * 0.02; // 2% of screen height

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7C53F4),
              Color(0xFF4A25AA),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Share Your Masterpiece!',
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: contentPadding),

                // Main content in Expanded widget
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Content type selection
                        FadeInDown(
                          duration: const Duration(milliseconds: 800),
                          child: _buildContentTypeSection(),
                        ),
                        SizedBox(height: contentPadding),

                        // Form fields
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: _buildFormSection(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Next button at bottom
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: _buildNextButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Extract sections into separate methods for better organization
  Widget _buildContentTypeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What would you like to create?',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            child: DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF7C53F4),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                border: InputBorder.none,
              ),
              hint: Text(
                'Select content type',
                style: GoogleFonts.quicksand(color: Colors.white70),
              ),
              value: selectedContentType,
              items: contentTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        type == 'Story'
                            ? LucideIcons.book
                            : type == 'Poem'
                                ? LucideIcons.pencil
                                : LucideIcons.palette,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        type,
                        style: GoogleFonts.quicksand(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedContentType = value!;
                });
              },
              icon: const Icon(
                LucideIcons.chevronDown,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            'Title',
            titleController,
            icon: LucideIcons.textCursor,
          ),
          if (selectedContentType == 'Drawing')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Drawing',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: selectedImage != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  selectedImage!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Color(0xFF7C53F4),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.upload,
                                size: 40,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Upload your drawing',
                                style: GoogleFonts.quicksand(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to choose a file',
                                style: GoogleFonts.quicksand(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            )
          else
            _buildTextField(
              'Your $selectedContentType',
              contentController,
              icon: selectedContentType == 'Story'
                  ? LucideIcons.book
                  : LucideIcons.pencil,
              maxLines: 6, // Reduced from 10 to 6
            ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isButtonHovered = true),
      onExit: (_) => setState(() => _isButtonHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isButtonHovered ? 1.05 : 1.0),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              if (_validateSubmission()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalDetailsScreen(
                      contentType: selectedContentType,
                      title: titleController.text,
                      content: contentController.text,
                      drawingImage: selectedImage,
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF7C53F4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: _isButtonHovered ? 8 : 5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Next Step ✨',
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(LucideIcons.arrowRight),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    int? maxLines,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines ?? 1,
            style: GoogleFonts.quicksand(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: GoogleFonts.quicksand(
                color: Colors.white.withOpacity(0.7),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: maxLines != null ? 120 : 0),
                child: Icon(icon, color: Colors.white.withOpacity(0.7)),
              ),
              alignLabelWithHint: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                ),
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

  // Add this method to validate the form fields
  bool _validateSubmission() {
    if (titleController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a title');
      return false;
    }

    if (selectedContentType == 'Drawing') {
      if (selectedImage == null) {
        _showErrorDialog('Please upload your drawing');
        return false;
      }
    } else {
      // For Story or Poem
      if (contentController.text.trim().isEmpty) {
        _showErrorDialog(
            'Please enter your ${selectedContentType.toLowerCase()}');
        return false;
      }
    }

    return true;
  }

  // Add this method to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Required Fields', style: GoogleFonts.fredoka()),
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
  void dispose() {
    titleController.dispose();

    contentController.dispose();
    super.dispose();
  }
}
