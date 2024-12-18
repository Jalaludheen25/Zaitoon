import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:zaitoon/constants/color_class.dart';

class SubmissionScreen extends StatefulWidget {
  const SubmissionScreen({super.key});

  @override
  State<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen> {
  String? selectedContentType;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> contentTypes = ['Story', 'Poem', 'Drawing'];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Submit Your Creation',
          style: GoogleFonts.fredoka(color: Colors.white),
        ),
        backgroundColor: ColorClass.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content Type',
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  border: InputBorder.none,
                ),
                hint: Text('Select content type',
                    style: GoogleFonts.quicksand(color: Colors.grey)),
                value: selectedContentType,
                items: contentTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type, style: GoogleFonts.quicksand()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedContentType = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Description',
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write a brief description...',
                hintStyle: GoogleFonts.quicksand(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (selectedContentType != null) ...[
              Text(
                selectedContentType == 'Drawing' ? 'Upload Drawing' : 'Content',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (selectedContentType == 'Drawing') ...[
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload,
                                  size: 50, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to upload drawing',
                                style: GoogleFonts.quicksand(
                                    color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                  ),
                ),
              ] else ...[
                TextFormField(
                  controller: contentController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: 'Write your ${selectedContentType?.toLowerCase()} here...',
                    hintStyle: GoogleFonts.quicksand(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Handle submission
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorClass.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Submit',
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    contentController.dispose();
    super.dispose();
  }
} 