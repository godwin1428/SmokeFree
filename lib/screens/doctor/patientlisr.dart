import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smokefree/patview.dart';
import 'dart:convert';

import 'package:smokefree/ip.dart';

// Add your IP address or endpoint here


class Patient {
  final String name;
  final int age;
  final String user;
  final String imagePath;

  Patient({
    required this.name,
    required this.age,
    required this.user,
    required this.imagePath,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    // Print the type and value to debug
    print('Age from API: ${json['age']} (${json['age'].runtimeType})');
    print('Image path from API: ${json['dp']} (${json['dp'].runtimeType})');

    // Handle empty or null image path
    final imagePath = json['dp']?.toString().trim() ?? 'assets/poo.png';

    return Patient(
      name: json['name'],
      age: int.parse(json['age'].toString()), // Ensure age is parsed as int
      user: json['username'],
      imagePath: imagePath.isNotEmpty ? imagePath : 'assets/poo.png',
    );
  }
}

class PatientSearchPage extends StatefulWidget {
  @override
  _PatientSearchPageState createState() => _PatientSearchPageState();
}

class _PatientSearchPageState extends State<PatientSearchPage> {
  List<Patient> _patients = [];
  late List<Patient> _filteredPatients;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPatients();
    _filteredPatients = _patients; // Initialize with all patients
    _searchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPatients() async {
    try {
      final String patientUrl = ip + 'dhome.php'; // Replace with your API URL
      final patientResponse = await http.post(Uri.parse(patientUrl));
      if (patientResponse.statusCode == 200) {
        final List<dynamic> patientsJson = json.decode(patientResponse.body);
        setState(() {
          _patients = patientsJson.map((json) => Patient.fromJson(json)).toList();
          _filteredPatients = _patients; // Initialize filtered list
        });
      } else {
        throw Exception('Failed to load patients');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _filterPatients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _patients.where((patient) {
        return patient.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _onPatientTap(Patient patient) {
    print(patient.user);
    userid=patient.user;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PatView()),
    );
    // Handle the onTap action here
    // For example, navigate to a detailed patient page or show a dialog



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        flexibleSpace: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30.0),
            bottomLeft: Radius.circular(30.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF81A7D1),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0, left: 20.0),
              child: Text(
                '\n',
                style: TextStyle(
                  fontFamily: 'Amethysta',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for patients',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: _filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = _filteredPatients[index];
                return GestureDetector(
                  onTap: () => _onPatientTap(patient),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 15.0),
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFE0F7FA),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 15.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.asset(
                              patient.imagePath,
                              width: 100,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Name: ${patient.name}',
                                style: TextStyle(
                                  fontFamily: 'Amethysta',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Age: ${patient.age}',
                                style: TextStyle(
                                  fontFamily: 'Amethysta',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
