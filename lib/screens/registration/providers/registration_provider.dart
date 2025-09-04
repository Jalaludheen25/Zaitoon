import 'package:flutter/material.dart';
import '../models/registration_model.dart';
import '../services/registration_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationProvider extends ChangeNotifier {
  static const String _registrationStatusKey = 'user_registration_completed';
  
  List<District> _districts = [];
  List<Area> _areas = [];
  List<Unit> _units = [];
  List<RegistrationModel> _registrations = [];

  District? _selectedDistrict;
  Area? _selectedArea;
  Unit? _selectedUnit;

  bool _isLoadingDistricts = false;
  bool _isLoadingAreas = false;
  bool _isLoadingUnits = false;
  bool _isSubmitting = false;
  bool _isRegistrationCompleted = false;

  String? _error;

  // Getters
  List<District> get districts => _districts;
  List<Area> get areas => _areas;
  List<Unit> get units => _units;
  List<RegistrationModel> get registrations => _registrations;

  District? get selectedDistrict => _selectedDistrict;
  Area? get selectedArea => _selectedArea;
  Unit? get selectedUnit => _selectedUnit;

  bool get isLoadingDistricts => _isLoadingDistricts;
  bool get isLoadingAreas => _isLoadingAreas;
  bool get isLoadingUnits => _isLoadingUnits;
  bool get isSubmitting => _isSubmitting;
  bool get isRegistrationCompleted => _isRegistrationCompleted;

  String? get error => _error;

  // Initialize and check registration status
  Future<void> initialize() async {
    await checkRegistrationStatus();
  }

  // Check if user has completed registration
  Future<void> checkRegistrationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isRegistrationCompleted = prefs.getBool(_registrationStatusKey) ?? false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to check registration status: $e';
      notifyListeners();
    }
  }

  // Mark registration as completed
  Future<void> markRegistrationCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_registrationStatusKey, true);
      _isRegistrationCompleted = true;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save registration status: $e';
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Load districts
  Future<void> loadDistricts() async {
    _isLoadingDistricts = true;
    _error = null;
    notifyListeners();

    try {
      _districts = await RegistrationService.getDistricts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingDistricts = false;
      notifyListeners();
    }
  }

  // Select district and load areas
  Future<void> selectDistrict(District district) async {
    _selectedDistrict = district;
    _selectedArea = null;
    _selectedUnit = null;
    _areas.clear();
    _units.clear();
    notifyListeners();

    await loadAreas(district.id);
  }

  // Load areas by district
  Future<void> loadAreas(String districtId) async {
    _isLoadingAreas = true;
    _error = null;
    notifyListeners();

    try {
      _areas = await RegistrationService.getAreasByDistrict(districtId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingAreas = false;
      notifyListeners();
    }
  }

  // Select area and load units
  Future<void> selectArea(Area area) async {
    _selectedArea = area;
    _selectedUnit = null;
    _units.clear();
    notifyListeners();

    await loadUnits(area.id);
  }

  // Load units by area
  Future<void> loadUnits(String areaId) async {
    _isLoadingUnits = true;
    _error = null;
    notifyListeners();

    try {
      _units = await RegistrationService.getUnitsByArea(areaId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingUnits = false;
      notifyListeners();
    }
  }

  // Select unit
  void selectUnit(Unit unit) {
    _selectedUnit = unit;
    notifyListeners();
  }

  // Submit registration
  Future<bool> submitRegistration({
    required String studentName,
    required String className,
    required String schoolName,
    required String gender,
  }) async {
    if (_selectedDistrict == null ||
        _selectedArea == null ||
        _selectedUnit == null) {
      _error = 'Please select district, area, and unit';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final registration = RegistrationModel(
        studentName: studentName,
        className: className,
        schoolName: schoolName,
        gender: gender,
        districtId: _selectedDistrict!.id,
        districtName: _selectedDistrict!.name,
        areaId: _selectedArea!.id,
        areaName: _selectedArea!.name,
        unitId: _selectedUnit!.id,
        unitName: _selectedUnit!.name,
      );

      final success =
          await RegistrationService.submitRegistration(registration);

      if (success) {
        // Mark registration as completed
        await markRegistrationCompleted();
        // Reset form
        resetForm();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Reset form
  void resetForm() {
    _selectedDistrict = null;
    _selectedArea = null;
    _selectedUnit = null;
    _areas.clear();
    _units.clear();
    _error = null;
    notifyListeners();
  }

  // Load registrations
  Future<void> loadRegistrations() async {
    try {
      _registrations = await RegistrationService.getRegistrations();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete registration
  Future<bool> deleteRegistration(int id) async {
    try {
      final success = await RegistrationService.deleteRegistration(id);
      if (success) {
        _registrations.removeWhere((reg) => reg.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Debug method to reset registration status (for testing)
  Future<void> resetRegistrationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_registrationStatusKey);
      _isRegistrationCompleted = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to reset registration status: $e';
      notifyListeners();
    }
  }
}
