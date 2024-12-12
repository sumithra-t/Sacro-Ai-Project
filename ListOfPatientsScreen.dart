import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For HTTP requests
import 'PatientDetails.dart';
import 'Patient_provider.dart';
import 'LoginScreen.dart';
import 'CSV.dart';

class ListOfPatientsScreen extends StatefulWidget {
  @override
  _ListOfPatientsScreenState createState() => _ListOfPatientsScreenState();
}

class _ListOfPatientsScreenState extends State<ListOfPatientsScreen> {
  String searchQuery = '';

  // Fetch patients data from the server
  Future<void> fetchPatients() async {
    final String apiUrl = 'http://180.235.121.245/sacroaidiagnosis/sample/viewpatients.php';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success' && data['patients'] != null) {
          List<Map<String, dynamic>> patientsList = List<Map<String, dynamic>>.from(
              data['patients'].map((patient) => Map<String, dynamic>.from(patient)));
          final patientProvider = Provider.of<PatientProvider>(context, listen: false);
          patientProvider.setPatients(patientsList);
        } else {
          _showError('Failed to load patient data: ${data['message']}');
        }
      } else {
        _showError('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error: $e');
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
  void initState() {
    super.initState();
    fetchPatients();
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);
    final filteredPatients = searchQuery.isEmpty
        ? patientProvider.patients
        : patientProvider.patients
        .where((patient) => patient['patient_name']
        .toLowerCase()
        .contains(searchQuery.toLowerCase()))
        .toList();
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('List of Patients', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF0E9090),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Welcome()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientDetailsScreen(
                      patientName: 'New Patient',
                      patientAge: null,
                      patientGender: '',
                      id: '',
                      patients: [],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search Patient',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredPatients.length,
                itemBuilder: (context, index) {
                  final patient = filteredPatients[index];
                  return ListTile(
                    title: Text(patient['patient_name']),
                    subtitle: Text(
                      'ID: ${patient['id']}, Age: ${patient['age']}, Gender: ${patient['gender']}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
