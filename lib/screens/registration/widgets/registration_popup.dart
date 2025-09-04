import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/color_class.dart';
import '../../../constants/textstyle_class.dart';
import '../providers/registration_provider.dart';

class RegistrationPopup extends StatefulWidget {
  final bool isCompulsory;

  const RegistrationPopup({
    super.key, 
    this.isCompulsory = false,
  });

  @override
  State<RegistrationPopup> createState() => _RegistrationPopupState();
}

class _RegistrationPopupState extends State<RegistrationPopup> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _schoolNameController = TextEditingController();

  String _selectedGender = 'boy';
  String _selectedClass = '1';

  final List<String> _genderOptions = ['boy', 'girl'];
  final List<String> _classOptions = ['1', '2', '3', '4', '5', '6', '7'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegistrationProvider>().loadDistricts();
    });
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _schoolNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isCompulsory,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          decoration: BoxDecoration(
            color: ColorClass.black,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorClass.primaryColor.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCompulsoryMessage(),
                        _buildStudentInfoSection(),
                        const SizedBox(height: 20),
                        _buildLocationSection(),
                        const SizedBox(height: 30),
                        _buildSubmitButton(),
                      ],
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

  Widget _buildCompulsoryMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorClass.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorClass.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: ColorClass.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child:             Text(
              widget.isCompulsory 
                ? 'Registration is required to use this app. Please complete the form below to continue.'
                : 'Join Malarvadi to get exclusive access to educational content and connect with our community.',
              style: TextStyleClass.poppinsRegular(
                fontSize: 14,
                color: ColorClass.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorClass.primaryColor.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_add,
            color: ColorClass.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.isCompulsory ? 'Complete Registration' : 'Malarvadi Membership Registration',
              style: TextStyleClass.poppinsSemiBold(
                fontSize: 18,
                color: ColorClass.white,
              ),
            ),
          ),
          // Only show close button if registration is not compulsory
          if (!widget.isCompulsory)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              color: ColorClass.white,
            ),
        ],
      ),
    );
  }

  Widget _buildStudentInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person, color: ColorClass.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Student Information',
              style: TextStyleClass.poppinsSemiBold(
                fontSize: 16,
                color: ColorClass.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Student Name',
          _studentNameController,
          'Enter student\'s full name',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter student name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                'Class',
                _selectedClass,
                _classOptions,
                (value) => setState(() => _selectedClass = value!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdown(
                'Gender',
                _selectedGender,
                _genderOptions,
                (value) => setState(() => _selectedGender = value!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'School Name',
          _schoolNameController,
          'Enter school name',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter school name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Consumer<RegistrationProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on,
                    color: ColorClass.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Location Information',
                  style: TextStyleClass.poppinsSemiBold(
                    fontSize: 16,
                    color: ColorClass.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLocationDropdown(
              'District',
              provider.selectedDistrict?.name ?? 'Select District',
              provider.districts.map((d) => d.name).toList(),
              provider.isLoadingDistricts,
              (value) {
                final district =
                    provider.districts.firstWhere((d) => d.name == value);
                provider.selectDistrict(district);
              },
            ),
            const SizedBox(height: 16),
            _buildLocationDropdown(
              'Area',
              provider.selectedArea?.name ?? 'Select Area',
              provider.areas.map((a) => a.name).toList(),
              provider.isLoadingAreas,
              provider.selectedDistrict != null
                  ? (value) {
                      final area =
                          provider.areas.firstWhere((a) => a.name == value);
                      provider.selectArea(area);
                    }
                  : null,
            ),
            const SizedBox(height: 16),
            _buildLocationDropdown(
              'Unit',
              provider.selectedUnit?.name ?? 'Select Unit',
              provider.units.map((u) => u.name).toList(),
              provider.isLoadingUnits,
              provider.selectedArea != null
                  ? (value) {
                      final unit =
                          provider.units.firstWhere((u) => u.name == value);
                      provider.selectUnit(unit);
                    }
                  : null,
            ),
            if (provider.error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.error!,
                        style: TextStyleClass.poppinsRegular(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleClass.poppinsMedium(
            fontSize: 14,
            color: ColorClass.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyleClass.poppinsRegular(
            fontSize: 14,
            color: ColorClass.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyleClass.poppinsRegular(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: ColorClass.black.withOpacity(0.3),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorClass.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleClass.poppinsMedium(
            fontSize: 14,
            color: ColorClass.white,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          style: TextStyleClass.poppinsRegular(
            fontSize: 14,
            color: ColorClass.white,
          ),
          dropdownColor: ColorClass.black,
          decoration: InputDecoration(
            filled: true,
            fillColor: ColorClass.black.withOpacity(0.3),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorClass.primaryColor, width: 2),
            ),
          ),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: TextStyleClass.poppinsRegular(
                  fontSize: 14,
                  color: ColorClass.white,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildLocationDropdown(
    String label,
    String value,
    List<String> options,
    bool isLoading,
    void Function(String?)? onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleClass.poppinsMedium(
            fontSize: 14,
            color: ColorClass.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: ColorClass.black.withOpacity(0.3),
            border: Border.all(color: Colors.grey.shade600),
            borderRadius: BorderRadius.circular(12),
          ),
          child: isLoading
              ? Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ColorClass.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Loading...',
                      style: TextStyleClass.poppinsRegular(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                )
              : DropdownButton<String>(
                  value: options.contains(value) ? value : null,
                  hint: Text(
                    value,
                    style: TextStyleClass.poppinsRegular(
                      fontSize: 14,
                      color: onChanged == null
                          ? Colors.grey.shade400
                          : ColorClass.white,
                    ),
                  ),
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: ColorClass.black,
                  items: options.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(
                        option,
                        style: TextStyleClass.poppinsRegular(
                          fontSize: 14,
                          color: ColorClass.white,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<RegistrationProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: provider.isSubmitting ? null : _submitRegistration,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorClass.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: provider.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Submit Registration',
                    style: TextStyleClass.poppinsSemiBold(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    print('Form validation passed, submitting...');
    final provider = context.read<RegistrationProvider>();
    provider.clearError();

    final success = await provider.submitRegistration(
      studentName: _studentNameController.text.trim(),
      className: _selectedClass,
      schoolName: _schoolNameController.text.trim(),
      gender: _selectedGender,
    );

    if (success && mounted) {
      Navigator.pop(context, true); // Pass success result back
    }
  }
}
