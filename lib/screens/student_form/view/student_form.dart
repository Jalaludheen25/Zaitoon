import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../model/student_model.dart';
import '../database/db_helper.dart';
import '../../../constants/color_class.dart';
import '../../../screens/quiz/quiz_screen.dart';
import '../../../screens/quiz/provider/quiz_provider.dart';

class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({super.key});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();

  String _selectedGender = 'Boy';
  String _selectedDistrict = 'Kozhikode';
  String _selectedClass = 'LKG';
  bool _isLoading = false;

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final List<String> _genderOptions = ['Boy', 'Girl'];
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
        gender: _selectedGender,
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
        // Navigate to quiz screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QuizScreen()),
        );
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ColorClass.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Enter your details',
          style: GoogleFonts.poppins(
            color: ColorClass.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                _buildGenderDropdown(),
                const SizedBox(height: 20),
                _buildDistrictDropdown(),
                const SizedBox(height: 20),
                _buildClassDropdown(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
                const SizedBox(height: 20),
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorClass.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(color: ColorClass.black),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[500],
            ),
            prefixIcon: Icon(
              icon,
              color: ColorClass.primaryColor,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorClass.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[300]!),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[300]!, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            errorStyle: GoogleFonts.poppins(
              color: Colors.red[600],
              fontSize: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorClass.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedGender,
            style: GoogleFonts.poppins(color: ColorClass.black),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              prefixIcon: Icon(
                LucideIcons.users,
                color: ColorClass.primaryColor,
                size: 20,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            dropdownColor: Colors.white,
            icon: Icon(
              Icons.arrow_drop_down,
              color: ColorClass.primaryColor,
            ),
            items: _genderOptions.map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(
                  gender,
                  style: GoogleFonts.poppins(color: ColorClass.black),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedGender = newValue!;
              });
            },
          ),
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
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorClass.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedDistrict,
            style: GoogleFonts.poppins(color: ColorClass.black),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              prefixIcon: Icon(
                LucideIcons.mapPin,
                color: ColorClass.primaryColor,
                size: 20,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            dropdownColor: Colors.white,
            icon: Icon(
              Icons.arrow_drop_down,
              color: ColorClass.primaryColor,
            ),
            items: _districtOptions.map((String district) {
              return DropdownMenuItem<String>(
                value: district,
                child: Text(
                  district,
                  style: GoogleFonts.poppins(color: ColorClass.black),
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
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorClass.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedClass,
            style: GoogleFonts.poppins(color: ColorClass.black),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              prefixIcon: Icon(
                LucideIcons.graduationCap,
                color: ColorClass.primaryColor,
                size: 20,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            dropdownColor: Colors.white,
            icon: Icon(
              Icons.arrow_drop_down,
              color: ColorClass.primaryColor,
            ),
            items: _classOptions.map((String classLevel) {
              return DropdownMenuItem<String>(
                value: classLevel,
                child: Text(
                  classLevel,
                  style: GoogleFonts.poppins(color: ColorClass.black),
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
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveStudent,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorClass.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Save Student',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
