import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PatientProvider with ChangeNotifier {
  List<Map<String, dynamic>> _patients = []; // Store the patient list

  // Getter for the patients list
  List<Map<String, dynamic>> get patients => _patients;

  // API URL for patient-related operations
  final String apiUrl = 'https://180.235.121.245/sacroaidiagnosis/patient_api.php';

  // Constructor to load patients from API when the app starts
  PatientProvider() {
    loadPatients(); // Load patients from API when the app starts
  }

  // Load patients from the API
  Future<void> loadPatients() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl?action=load'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _patients = List<Map<String, dynamic>>.from(data);
        print("Patients loaded from API: $_patients"); // Debug statement
      } else {
        print("Failed to load patients from API.");
      }
    } catch (e) {
      print("Error loading patients: $e");
    }
    notifyListeners(); // Notify listeners that the list is loaded or updated
  }

  // Save patients to the API
  Future<void> savePatients() async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl?action=save'),
        body: json.encode({'patients': _patients}),
      );

      if (response.statusCode == 200) {
        print("Patients saved to API: $_patients"); // Debugging statement
      } else {
        print("Failed to save patients to API.");
      }
    } catch (e) {
      print("Error saving patients: $e");
    }
  }

  // Add a new patient without deleting previous entries
  Future<void> addPatient(Map<String, dynamic> patient) async {
    // Generate a unique ID if not provided
    if (!patient.containsKey('id') || patient['id'].isEmpty) {
      patient['id'] = 'GeneratedID_${DateTime.now().millisecondsSinceEpoch}';
    }
    _patients.add(patient); // Add new patient to the existing list

    await savePatients(); // Save the updated list with the new patient
    print("New patient added: $patient"); // Debugging statement
    notifyListeners(); // Notify listeners of the new addition
  }

  // Update an existing patient
  Future<void> updatePatient(int index, Map<String, dynamic> updatedPatient) async {
    if (index >= 0 && index < _patients.length) {
      _patients[index] = updatedPatient;
      await savePatients(); // Save the updated list
      notifyListeners(); // Notify listeners of the update
    } else {
      print("Invalid index for update"); // Debug statement
    }
  }

  // Set patients data directly (this method is now added)
  void setPatients(List<Map<String, dynamic>> patientsData) {
    _patients = patientsData;
    notifyListeners(); // Notify listeners that the list has been updated
  }
}
