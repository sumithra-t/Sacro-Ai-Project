import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ListOfPatientsScreen.dart';
import 'Patient_provider.dart';
import 'UploadScreen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String patientName;
  final int? patientAge; // Updated to allow nullable int
  final String patientGender;
  final String id; // Only id used here
  final List<Map<String, dynamic>> patients;

  const PatientDetailsScreen({
    Key? key,
    required this.patientName,
    required this.patientAge, // Updated to nullable
    required this.patientGender,
    required this.id, // Only id here
    required this.patients,
  }) : super(key: key);

  @override
  _PatientDetailsScreenState createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedGender = 'Male';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.patientName;
    _ageController.text = widget.patientAge?.toString() ?? ''; // Safely handle null patientAge
    _selectedGender = widget.patientGender;
  }

  Future<void> _savePatientDetails() async {
    final String apiUrl = 'http://180.235.121.245/sacroaidiagnosis/sample/Patientdetails.php';
    setState(() {
      _isSaving = true;
    });
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patient_name': _nameController.text.isNotEmpty ? _nameController.text : 'Unknown',
          'age': _ageController.text.isNotEmpty ? int.parse(_ageController.text) : 0,
          'gender': _selectedGender,
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        final patientProvider = Provider.of<PatientProvider>(
          context,
          listen: false,
        );
        patientProvider.addPatient({
          'id': widget.id.isNotEmpty ? widget.id : 'GeneratedID',
          'name': _nameController.text,
          'age': int.parse(_ageController.text),
          'gender': _selectedGender,
        });
        await patientProvider.savePatients();
        Navigator.pop(context);
      } else {
        _showError('Failed to add patient: ${responseData['message']}');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }


  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enter Patient Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0E9090),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListOfPatientsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Patient Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedGender = 'Male';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedGender == 'Male'
                        ? const Color(0xFF0E9090)
                        : Colors.grey,
                  ),
                  child: const Text(
                    'Male',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedGender = 'Female';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedGender == 'Female'
                        ? const Color(0xFF0E9090)
                        : Colors.grey,
                  ),
                  child: const Text(
                    'Female',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _ageController.text.isNotEmpty) {
                  _savePatientDetails();
                } else {
                  _showError('Please fill in all details.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E9090),
              ),
              child: const Text(
                'Save Details',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E9090),
              ),
              child: const Text(
                'Upload',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
