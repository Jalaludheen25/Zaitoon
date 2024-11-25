import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataProvider with ChangeNotifier {
  // SharedPreferences Keys
  static const String _nameKey = 'user_name';
  static const String _ageKey = 'user_age';
  static const String _genderKey = 'user_gender';

  // State Variables
  String? _name;
  int? _age;
  String _gender = 'boy';
  bool _isLoading = false;
  String _error = '';
  bool _isOnboardingCompleted = false;

  // Getters
  String? get name => _name;
  int? get age => _age;
  String get gender => _gender;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isGenderEmpty => _gender.isEmpty;
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  // Initialize Provider
  Future<void> initialize() async {
    try {
      setLoading(true);
      await loadUserDetails();
      await checkOnboardingStatus();
    } catch (e) {
      setError('Failed to initialize: $e');
    } finally {
      setLoading(false);
    }
  }

  // Check Onboarding Status
  Future<void> checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnboardingCompleted = prefs.containsKey(_nameKey);
      notifyListeners();
    } catch (e) {
      setError('Failed to check onboarding status: $e');
    }
  }

  // Update Gender
  void updateGender(String value) {
    _gender = value;
    _error = ''; // Clear error when gender is selected
    notifyListeners();
  }

  // Set Loading State
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Set Error Message
  void setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  // Clear Error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Validate Age
  bool _validateAge(int age) {
    return age >= 1 && age <= 15;
  }

  // Validate Name
  bool _validateName(String name) {
    return name.trim().isNotEmpty;
  }

  // Validate Form Data
  bool _validateFormData({
    required String name,
    required int age,
  }) {
    if (!_validateName(name)) {
      setError('Please enter a valid name');
      return false;
    }

    if (!_validateAge(age)) {
      setError('Please enter a valid age between 1-15');
      return false;
    }

    if (_gender.isEmpty) {
      setError('Please select your gender');
      return false;
    }

    return true;
  }

  // Save User Details with Validation
  Future<bool> validateAndSaveUserDetails({
    required String name,
    required String age,
  }) async {
    clearError();
    setLoading(true);

    try {
      final ageNum = int.tryParse(age);
      if (ageNum == null) {
        setError('Please enter a valid age');
        return false;
      }

      if (!_validateFormData(name: name, age: ageNum)) {
        return false;
      }

      await saveUserDetails(
        name: name.trim(),
        age: ageNum,
        gender: _gender,
      );

      _isOnboardingCompleted = true;
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to save user details: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Save User Details to SharedPreferences
  Future<void> saveUserDetails({
    required String name,
    required int age,
    required String gender,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await Future.wait([
        prefs.setString(_nameKey, name),
        prefs.setInt(_ageKey, age),
        prefs.setString(_genderKey, gender),
      ]);

      _name = name;
      _age = age;
      _gender = gender;

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to save user details: $e');
    }
  }

  // Load User Details from SharedPreferences
  Future<void> loadUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _name = prefs.getString(_nameKey);
      _age = prefs.getInt(_ageKey);
      _gender = prefs.getString(_genderKey) ?? '';

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load user details: $e');
    }
  }

  // Clear User Details
  Future<void> clearUserDetails() async {
    try {
      setLoading(true);
      final prefs = await SharedPreferences.getInstance();

      await Future.wait([
        prefs.remove(_nameKey),
        prefs.remove(_ageKey),
        prefs.remove(_genderKey),
      ]);

      _name = null;
      _age = null;
      _gender = '';
      _isOnboardingCompleted = false;

      notifyListeners();
    } catch (e) {
      setError('Failed to clear user details: $e');
    } finally {
      setLoading(false);
    }
  }

  // Update User Details
  Future<bool> updateUserDetails({
    String? name,
    int? age,
    String? gender,
  }) async {
    try {
      setLoading(true);
      final prefs = await SharedPreferences.getInstance();

      if (name != null) {
        await prefs.setString(_nameKey, name);
        _name = name;
      }

      if (age != null && _validateAge(age)) {
        await prefs.setInt(_ageKey, age);
        _age = age;
      }

      if (gender != null) {
        await prefs.setString(_genderKey, gender);
        _gender = gender;
      }

      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to update user details: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Check if specific detail exists
  Future<bool> hasUserDetail(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(key);
    } catch (e) {
      setError('Failed to check user detail: $e');
      return false;
    }
  }
}
