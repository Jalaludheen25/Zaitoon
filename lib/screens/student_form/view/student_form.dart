import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../model/student_model.dart';
import '../database/db_helper.dart';
import '../../../constants/color_class.dart';
import '../../../constants/icon_class.dart';
import '../../../screens/user_data_collection_screen/components/gender_card.dart';
import '../../../constants/textstyle_class.dart';
import '../../../screens/bottom_navigation/provider/bottom_navigation_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({super.key});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();

  String _selectedGender = 'boy';
  String _selectedDistrict = 'Kozhikode';
  String _selectedClass = 'LKG';
  bool _isLoading = false;

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final List<String> _districtOptions = [
    'Thiruvananthapuram',
    'Kollam',
    'Pathanamthitta',
    'Alappuzha',
    'Kottayam',
    'Idukki',
    'Ernakulam',
    'Thrissur',
    'Palakkad',
    'Malappuram',
    'Kozhikode',
    'Wayanad',
    'Kannur',
    'Kasaragod',
  ];
  final List<String> _classOptions = [
    'LKG',
    'UKG',
    '1st',
    '2nd',
    '3rd',
    '4th',
    '5th',
    '6th',
    '7th',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final student = Student(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        gender: _selectedGender.substring(0, 1).toUpperCase() +
            _selectedGender.substring(1),
        className: _selectedClass,
        district: _selectedDistrict,
      );

      await _databaseHelper.insertStudent(student);
      List<Student> students = await _databaseHelper.getAllStudents();
      // Print saved student data to terminal
      debugPrint('=== STUDENT SAVED SUCCESSFULLY ===');
      debugPrint('ID: ${student.id}');
      debugPrint('Name: ${student.name}');
      debugPrint('Mobile: ${student.mobile}');
      debugPrint('Gender: ${student.gender}');
      debugPrint('Class: ${student.className}');
      debugPrint('District: ${student.district}');
      debugPrint('================================');
      for (var student in students) {
        debugPrint(student.toString());
      }

      if (mounted) {
        // Mark quiz landing as completed and refresh the state
        context.read<NavigationProvider>().markQuizLandingCompleted();

        // Navigate back to bottom navigation (quiz tab will now show QuizScreen)
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error saving student: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
            'Enter your Details',
            style: TextStyleClass.fredoka(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background with blur effects
          Container(),

          // Top left blur effect
          Positioned(
            top: 200,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                //shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFAC28DC).withOpacity(0.25),
                    Color(0xFF4E1BCF).withOpacity(0.25),
                    Color(0xFF7E1EB7).withOpacity(0.25),
                    Color(0xFF501392).withOpacity(0.25),
                  ],
                ),
                borderRadius: BorderRadius.circular(150), // ellipse shape
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 50,
                  sigmaY: 50,
                ),
                child: Container(
                  color: Colors.white.withOpacity(0.0), // keeps blur visible
                ),
              ),
            ),
          ),

          // Top right blur effect
          Positioned(
            top: 42,
            // right: -50,
            left: 304,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                //shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFAC28DC).withOpacity(0.25),
                    Color(0xFF4E1BCF).withOpacity(0.25),
                    Color(0xFF7E1EB7).withOpacity(0.25),
                    Color(0xFF501392).withOpacity(0.25),
                  ],
                ),
                borderRadius: BorderRadius.circular(150), // ellipse shape
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 50,
                  sigmaY: 50,
                ),
                child: Container(
                  color: Colors.white.withOpacity(0.0), // keeps blur visible
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
                  //         const SizedBox(height: 20),

                  //         // Welcome message
                  //         Text(
                  //           'Join the Quiz!',
                  //           style: GoogleFonts.fredoka(
                  //             fontSize: 24,
                  //             fontWeight: FontWeight.w700,
                  //             color: ColorClass.black,
                  //           ),
                  //         ),
                  //         const SizedBox(height: 8),
                  //         Text(
                  //           'Please fill in your details to continue',
                  //           style: GoogleFonts.openSans(
                  //             fontSize: 14,
                  //             color: Colors.black.withOpacity(0.6),
                  //           ),
                  //         ),

                  //         const SizedBox(height: 25),

                  // Form Fields
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(height: 5),
                            _buildTextField(
                              'Student Name',
                              _nameController,
                              icon: LucideIcons.user2,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter student name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 19),
                            _buildTextField(
                              'Mobile Number',
                              _mobileController,
                              icon: LucideIcons.phone,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter mobile number';
                                }
                                if (value.length < 10) {
                                  return 'Please enter a valid mobile number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 19),
                            _buildGenderSelection(),
                            const SizedBox(height: 19),
                            _buildDistrictDropdown(),
                            const SizedBox(height: 19),
                            _buildClassDropdown(),
                            const SizedBox(height: 25),
                            _buildSubmitButton(),
                            const SizedBox(height: 10),
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
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleClass.fredokaRegular(
            fontSize: 16,
            color: ColorClass.black,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.openSans(color: ColorClass.black),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: GoogleFonts.openSans(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              // color: ColorClass.primaryColor,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: ColorClass.violet30, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: Colors.red[300]!),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: Colors.red[400]!, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            errorStyle: GoogleFonts.openSans(
              color: Colors.red[600],
              fontSize: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gender",
          style: TextStyleClass.fredokaRegular(
            fontSize: 16,
            color: ColorClass.black,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GenderCard(
                icon: IconClass.boy,
                label: "I'm a Boy",
                isSelected: _selectedGender == 'boy',
                onTap: () {
                  setState(() {
                    _selectedGender = 'boy';
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GenderCard(
                icon: IconClass.girl,
                label: "I'm a Girl",
                isSelected: _selectedGender == 'girl',
                onTap: () {
                  setState(() {
                    _selectedGender = 'girl';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDistrictDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'District',
          style: TextStyleClass.fredoka(
            fontSize: 16,
            color: ColorClass.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[300]!, width: 0.5),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedDistrict,
            style: GoogleFonts.openSans(color: ColorClass.black),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              prefixIcon: Icon(
                LucideIcons.mapPin,
                //color: ColorClass.primaryColor,
                size: 20,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            dropdownColor: Colors.white,
            icon: Icon(
              LucideIcons.chevronDown,
              color: ColorClass.primaryColor,
            ),
            items: _districtOptions.map((String district) {
              return DropdownMenuItem<String>(
                value: district,
                child: Text(
                  district,
                  style: GoogleFonts.openSans(color: ColorClass.black),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedDistrict = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClassDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Class',
          style: TextStyleClass.fredoka(
            fontSize: 16,
            color: ColorClass.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[300]!, width: 0.5),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedClass,
            style: GoogleFonts.openSans(color: ColorClass.black),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              prefixIcon: Icon(
                LucideIcons.graduationCap,
                //color: ColorClass.primaryColor,
                size: 20,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            dropdownColor: Colors.white,
            icon: Icon(
              LucideIcons.chevronDown,
              color: ColorClass.primaryColor,
            ),
            items: _classOptions.map((String classLevel) {
              return DropdownMenuItem<String>(
                value: classLevel,
                child: Text(
                  classLevel,
                  style: GoogleFonts.openSans(color: ColorClass.black),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedClass = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: 275,
      height: 45,
      decoration: BoxDecoration(
        gradient: _isLoading
            ? null
            : const LinearGradient(
                colors: [
                  ColorClass.grad1,
                  ColorClass.grad2,
                  ColorClass.grad3,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        borderRadius: BorderRadius.circular(24),
        color: _isLoading ? Colors.grey[300] : null,
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveStudent,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Start Quiz',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
