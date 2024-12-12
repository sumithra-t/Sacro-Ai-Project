import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  List<List<String>> _csvData = [];
  TextEditingController _fileNameController = TextEditingController();

  // Function to fetch CSV data from the server
  Future<void> fetchCsvData() async {
    final response = await http.get(Uri.parse('http://180.235.121.245/sacroaidiagnosis/sample/Download.php'));

    if (response.statusCode == 200) {
      final data = response.body;
      List<List<String>> parsedData = parseCsv(data);

      // Normalize the CSV data
      parsedData = normalizeCsv(parsedData);

      setState(() {
        _csvData = parsedData;
      });
    } else {
      print('Failed to load CSV');
    }
  }

  // Function to parse the CSV string into a List of Lists (rows and columns)
  List<List<String>> parseCsv(String data) {
    List<List<String>> rows = [];
    List<String> lines = LineSplitter.split(data).toList();

    for (var line in lines) {
      rows.add(line.split(',').map((e) => e.trim()).toList());
    }

    return rows;
  }

  // Function to normalize CSV data to match the header's column count
  List<List<String>> normalizeCsv(List<List<String>> csvData) {
    if (csvData.isEmpty) return csvData;

    final int headerLength = csvData.first.length; // Determine column count from the header

    return csvData.map((row) {
      if (row.length > headerLength) {
        return row.sublist(0, headerLength); // Truncate extra cells
      } else if (row.length < headerLength) {
        return [...row, ...List.filled(headerLength - row.length, '')]; // Pad missing cells
      }
      return row;
    }).toList();
  }

  // Function to get a writable directory for saving files
  Future<String?> getWritableDirectory() async {
    final directory = await getExternalStorageDirectory();
    return directory?.path;
  }

  // Function to request permission and save CSV to the selected folder
  Future<void> saveCsvToFile() async {
    var status = await Permission.storage.request();

    if (status.isGranted || await Permission.manageExternalStorage.request().isGranted) {
      if (_csvData.isNotEmpty) {
        String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

        if (selectedDirectory != null) {
          String? fileName = await _showFileNameDialog();

          if (fileName != null && fileName.isNotEmpty) {
            try {
              // Ensure the file path is valid
              final file = File('$selectedDirectory/$fileName.csv');
              await file.create(recursive: true);

              // Write CSV data to file
              String csvContent = _csvData.map((row) => row.join(',')).join('\n');
              await file.writeAsString(csvContent);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('CSV file saved to ${file.path}')),
              );
            } catch (e) {
              print('Error saving file: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error saving file: $e')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No file name provided.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No folder selected.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No CSV data to save.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied! Unable to save CSV file.')),
      );
    }
  }


  // Function to show a dialog for the user to input the file name
  Future<String?> _showFileNameDialog() async {
    String? fileName = '';
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter File Name'),
          content: TextField(
            onChanged: (value) {
              fileName = value;
            },
            decoration: InputDecoration(hintText: "Enter file name here"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(fileName);
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // Cancel the operation
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCsvData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CSV Data',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: Color(0xFF0E9090), // Set the app bar color
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Set back arrow icon color to white
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _csvData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20.0,
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0E9090),
                  fontSize: 16,
                ),
                columns: _csvData.isNotEmpty
                    ? _csvData[0]
                    .map((col) => DataColumn(label: Text(col)))
                    .toList()
                    : [],
                rows: _csvData.isNotEmpty
                    ? _csvData
                    .sublist(1)
                    .map(
                      (row) => DataRow(
                    cells: row
                        .map((cell) => DataCell(Text(cell)))
                        .toList(),
                  ),
                )
                    .toList()
                    : [],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: saveCsvToFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0E9090),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Save CSV to Selected Folder',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), // Set text color to white
              ),
            ),
          ),
        ],
      ),
    );
  }
}