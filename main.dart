import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Patient_provider.dart'; // Provider for patient-related data
import 'PatientDetails.dart'; // Patient details screen
import 'UploadScreen.dart'; // Upload screen
import 'LoginScreen.dart'; // Login screen
import 'SignupScreen.dart'; // Signup screen
import 'WelcomeScreen.dart'; // Welcome screen

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientProvider()), // Provider for patient-related data
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/upload': (context) => UploadScreen(),
        '/patientDetails': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
          return PatientDetailsScreen(
            patientName: args['patientName'] ?? '',
            patientAge: args['patientAge'] ?? 0,
            patientGender: args['patientGender'] ?? '',
            id: args['id'] ?? '', // Updated from patientID to id
            patients: [] // pass the patient list if needed here
          );
        },
      },
    );
  }
}
