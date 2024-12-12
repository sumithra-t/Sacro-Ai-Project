import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'LoginScreen.dart'; // Updated import statement for LoginScreen.dart

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _className = "";
  double _confidenceScore = 0.0;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _className = ''; // Reset the class name when a new image is picked
        _confidenceScore = 0.0; // Reset confidence score
      });
    }
  }

  Future<void> _predictImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final uri = Uri.parse('http://180.235.121.245:5005/predict');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', _image!.path));
    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final result = json.decode(String.fromCharCodes(responseData));
    setState(() {
      _className = result['class_name'];
      _confidenceScore = result['confidence_score'];
      _isLoading = false;
    });
    await _uploadImageToXAMPP();
  }

  Future<void> _uploadImageToXAMPP() async {
    final xamppUri = Uri.parse('http://180.235.121.245/sacroaidiagnosis/sample/uploads.php');
    final request = http.MultipartRequest('POST', xamppUri)
      ..files.add(await http.MultipartFile.fromPath('image', _image!.path))
      ..fields['class_name'] = _className
      ..fields['confidence_score'] = _confidenceScore.toString();
    print("Uploading image with class: $_className and confidence: $_confidenceScore");
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final result = json.decode(String.fromCharCodes(responseData));
      print(result['message']);
    } else {
      print('Failed to upload image to XAMPP');
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Upload Image'),
        backgroundColor: const Color(0xFF0E9090),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: Icon(Icons.camera_alt, size: 28, color: Colors.white),
                label: Text(
                  'Take a Picture',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E9090),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icon(Icons.photo, size: 28, color: Colors.white),
                label: Text(
                  'Select from Gallery',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E9090),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_image != null)
                Column(
                  children: [
                    Image.file(_image!, height: 150),
                    SizedBox(height: 16),
                  ],
                ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _predictImage,
                icon: Icon(Icons.search, size: 28, color: Colors.white),
                label: Text(
                  'Predict',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E9090),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(height: 40),
              if (_isLoading)
                CircularProgressIndicator(),
              if (_className.isNotEmpty && !_isLoading)
                Column(
                  children: [
                    Text(
                      'Class Name: $_className',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Confidence: ${(_confidenceScore * 100).toStringAsFixed(2)}%',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              SizedBox(height: 40),
              Text(
                'Pick an image to make a prediction!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
