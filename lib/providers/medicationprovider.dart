import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'medicationmodel.dart';
import 'package:utibu/api.dart';
class MedicationProvider with ChangeNotifier {
  List<Medication> _medications = [];
  bool _isLoading = true;

  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading;
  String _errorMessage = '';

  String get errorMessage => _errorMessage;
  
  void clearErrorMessage() {
    _errorMessage = '';
    notifyListeners();
  }
  Future<void> fetchMedications() async {
    _isLoading = true;
    _errorMessage = ''; // Reset error message on new fetch attempt
    
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final url = "${ApiClient.baseUrl}medications";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Token $token'},
      );

      if (response.statusCode == 200) {
        final List<Medication> loadedMedications = [];
        final extractedData = json.decode(response.body) as List<dynamic>;
        for (var medicationJson in extractedData) {
          loadedMedications.add(Medication.fromJson(medicationJson));
        }
        _medications = loadedMedications;
        _isLoading = false;
        notifyListeners();
        // return true; // Success
      } else if (response.statusCode == 401) {
      _errorMessage = 'Authentication Error. Please log in.';
      _isLoading = false;
      notifyListeners();
    } else {
      _errorMessage = 'Failed to load medications. Unknown error.';
      _isLoading = false;
      notifyListeners();
    }
    } catch (e) {
      // Handle exceptions from the http request
      print('Exception when loading medications: $e');
      _isLoading = false;
      notifyListeners();
      // return false; // Failure due to exception
    }
  }
}

