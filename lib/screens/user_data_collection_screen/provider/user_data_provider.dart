import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SharedPreferences Keys
  static const String _nameKey = 'user_name';
  static const String _ageKey = 'user_age';
  static const String _genderKey = 'user_gender';
  static const String _uidKey = 'uidKey';
  static const String _emailKey = 'emailKey';

  // State Variables
  String? _name;
  int? _age;
  String? _uid;
  String? _email;
  String _gender = 'boy';
  bool _isLoading = false;
  String _error = '';
  bool _isOnboardingCompleted = false;

  // Getters
  String? get name => _name;
  String? get uid => _uid;
  String? get email => _email;
  int? get age => _age;
  String get gender => _gender;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isGenderEmpty => _gender.isEmpty;
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  void clearUserData() {
    _name = null;
    _age = null;
    _email = null;
    _uid = null;
    _gender = '';
    notifyListeners();
  }

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

  Future<void> _syncWithFirestore() async {
    if (_uid == null) {
      log('_syncWithFirestore: No UID available');
      return;
    }

    try {
      log('_syncWithFirestore: Starting sync for UID: $_uid');
      log('_syncWithFirestore: Firestore instance: ${_firestore.toString()}');

      final doc = await _firestore.collection('users').doc(_uid).get();
      log('_syncWithFirestore: Document fetch completed');

      if (doc.exists) {
        log('_syncWithFirestore: Document exists');
        final data = doc.data();
        if (data != null) {
          log('_syncWithFirestore: Data found: ${data.toString()}');
          await updateUserDetails(
            name: data['name'] as String?,
            age: data['age'] as int?,
            gender: data['gender'] as String?,
            updateFirestore: false,
          );
        }
      } else {
        log('_syncWithFirestore: No document exists for this UID');
      }
    } catch (e, stackTrace) {
      log('_syncWithFirestore error: $e');
      log('Stack trace: $stackTrace');
    }
  }

  Future<void> checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnboardingCompleted = prefs.containsKey(_nameKey);
      notifyListeners();
    } catch (e) {
      setError('Failed to check onboarding status: $e');
    }
  }

  void updateGender(String value) {
    _gender = value;
    _error = '';
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  bool _validateAge(int age) => age >= 1;
  bool _validateName(String name) => name.trim().isNotEmpty;

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

      if (_uid != null) {
        await _firestore.collection('users').doc(_uid).set({
          'uid': _uid,
          'email': _email,
          'name': name,
          'age': age,
          'gender': gender,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to save user details: $e');
    }
  }

  Future<void> loadUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _name = prefs.getString(_nameKey);
      _age = prefs.getInt(_ageKey);
      _gender = prefs.getString(_genderKey) ?? '';
      _uid = prefs.getString(_uidKey);
      _email = prefs.getString(_emailKey);

      log('User Data Loaded: $uid, $email, $name, $age, $gender');
      await _syncWithFirestore();

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load user details: $e');
    }
  }

  Future<void> clearUserDetails() async {
    try {
      setLoading(true);
      final prefs = await SharedPreferences.getInstance();

      await Future.wait([
        prefs.remove(_nameKey),
        prefs.remove(_ageKey),
        prefs.remove(_genderKey),
      ]);

      if (_uid != null) {
        await _firestore.collection('users').doc(_uid).delete();
      }

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

  Future<bool> updateUserDetails({
    String? name,
    int? age,
    String? gender,
    bool updateFirestore = true,
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

      if (_uid != null && updateFirestore) {
        await _firestore.collection('users').doc(_uid).update({
          if (name != null) 'name': name,
          if (age != null) 'age': age,
          if (gender != null) 'gender': gender,
          'updatedAt': FieldValue.serverTimestamp(),
        });
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
