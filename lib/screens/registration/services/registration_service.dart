import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/registration_model.dart';

class RegistrationService {
  static const String baseUrl = 'https://cenloginbackend.d4dx.co';
  static const String registrationEndpoint = '$baseUrl/api/registrations';
  static const String districtEndpoint = '$baseUrl/api/districts';
  static const String areaEndpoint = '$baseUrl/api/areas/district';
  static const String unitEndpoint = '$baseUrl/api/halqas/area';

  // Get all districts
  static Future<List<District>> getDistricts() async {
    try {
      final response = await http.get(
        Uri.parse(districtEndpoint),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Districts API Response: ${response.body}');
        final responseData = json.decode(response.body);

        // Handle different response structures
        List<dynamic> data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          data = responseData['data'] as List<dynamic>;
        } else if (responseData is List<dynamic>) {
          data = responseData;
        } else {
          print('Unexpected response format: $responseData');
          throw Exception('Unexpected response format');
        }

        return data.map((json) => District.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load districts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching districts: $e');
    }
  }

  // Get areas by district ID
  static Future<List<Area>> getAreasByDistrict(String districtId) async {
    try {
      final response = await http.get(
        Uri.parse('$areaEndpoint/$districtId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Handle different response structures
        List<dynamic> data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          data = responseData['data'] as List<dynamic>;
        } else if (responseData is List<dynamic>) {
          data = responseData;
        } else {
          throw Exception('Unexpected response format');
        }

        return data.map((json) => Area.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load areas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching areas: $e');
    }
  }

  // Get units by area ID
  static Future<List<Unit>> getUnitsByArea(String areaId) async {
    try {
      final response = await http.get(
        Uri.parse('$unitEndpoint/$areaId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Handle different response structures
        List<dynamic> data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          data = responseData['data'] as List<dynamic>;
        } else if (responseData is List<dynamic>) {
          data = responseData;
        } else {
          throw Exception('Unexpected response format');
        }

        return data.map((json) => Unit.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load units: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching units: $e');
    }
  }

  // Submit registration
  static Future<bool> submitRegistration(RegistrationModel registration) async {
    try {
      final requestBody = json.encode(registration.toJson());
      print('Registration API URL: $registrationEndpoint');
      print('Registration Request Body: $requestBody');

      // TODO: Replace this with actual API call once endpoint is ready
      // For now, simulate a successful submission for testing
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay

      print('Registration submitted successfully (simulated)');
      return true;

      /* Uncomment this when the actual API endpoint is ready:
      final response = await http.post(
        Uri.parse(registrationEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('Registration Response Status: ${response.statusCode}');
      print('Registration Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
            'Failed to submit registration: ${response.statusCode}');
      }
      */
    } catch (e) {
      throw Exception('Error submitting registration: $e');
    }
  }

  // Get all registrations
  static Future<List<RegistrationModel>> getRegistrations() async {
    try {
      final response = await http.get(
        Uri.parse(registrationEndpoint),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => RegistrationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load registrations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching registrations: $e');
    }
  }

  // Delete registration
  static Future<bool> deleteRegistration(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$registrationEndpoint/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
            'Failed to delete registration: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting registration: $e');
    }
  }
}
