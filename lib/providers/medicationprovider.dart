import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'medicationmodel.dart';
import 'package:utibu/api.dart';

class MedicationProvider with ChangeNotifier {
  List<Medication> _medications = [];
  bool _isLoading = true; // loading state

  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading; // Getter for loading state

  Future<void> fetchMedications() async {
    _isLoading = true; // Set loading to true when fetch begins
    notifyListeners(); // Notify listeners to update UI
    // Retrieve the auth token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    // Update the request to include the Authorization header with the token
    final url = "${ApiClient.baseUrl}medications";
    final response = await http.get(
      Uri.parse(url),
      // Include the Authorization header
      headers: {
        'Authorization': 'Token $token', // Adjust if your API uses a different scheme, e.g., Bearer
      },
    );

    if (response.statusCode == 200) {
      final List<Medication> loadedMedications = [];
      final extractedData = json.decode(response.body) as List<dynamic>;
      for (var medicationJson in extractedData) {
        loadedMedications.add(Medication.fromJson(medicationJson));
      }
      _medications = loadedMedications;
      _isLoading = false; // Set loading to false when fetch is complete
      notifyListeners();
    } else {
      // Handle errors or invalid responses
      print('Failed to load medications');

    }
  }
}
