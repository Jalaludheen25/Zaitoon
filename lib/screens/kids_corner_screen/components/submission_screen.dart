import 'package:flutter/material.dart';
import 'package:zaitoon/constants/color_class.dart';

class SubmissionScreen extends StatefulWidget {
  const SubmissionScreen({super.key});

  @override
  State<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen> {
  String _selectedType = 'Story';
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Create New Post',
          style: TextStyle(color: ColorClass.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorClass.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content Type Selector
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: Colors.grey[850],
                style: const TextStyle(color: ColorClass.white),
                items: ['Story', 'Poem', 'Drawing']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Title Field
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: ColorClass.white),
                decoration: InputDecoration(
                  hintText: 'Enter title',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Content Field
              TextFormField(
                controller: _contentController,
                style: const TextStyle(color: ColorClass.white),
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: _selectedType == 'Drawing' 
                      ? 'Add description (optional)'
                      : 'Write your content here',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (_selectedType != 'Drawing' && 
                      (value == null || value.isEmpty)) {
                    return 'Please enter your content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Upload Image Button (for drawings)
              if (_selectedType == 'Drawing')
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement image upload
                  },
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Drawing'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[850],
                    foregroundColor: ColorClass.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Implement submission logic
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorClass.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: ColorClass.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 