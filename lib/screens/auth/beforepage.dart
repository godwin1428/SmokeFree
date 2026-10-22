import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smokefree/ip.dart';
import 'dart:convert';

import 'package:smokefree/pft.dart';

class BefPage extends StatefulWidget {
  final String username=userid;



  @override
  _BefPageState createState() => _BefPageState();
}

class _BefPageState extends State<BefPage> {
  final TextEditingController _fevController = TextEditingController();
  final TextEditingController _fvcController = TextEditingController();
  final TextEditingController _ratioController = TextEditingController();
  final TextEditingController _tlcController = TextEditingController();

  // API call to submit data
  Future<void> _submitData() async {
    final String apiUrl = ip+'bf.php';

    final Map<String, String> body = {
      'username': widget.username,
      'fev': _fevController.text,
      'fvc': _fvcController.text,
      'rto': _ratioController.text,
      'tlc': _tlcController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.toString().toLowerCase().contains('success')) {
          // Handle successful update
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PftScreen()),
          );
        } else {
          _showToast('Update failed');
        }
      } else {
        _showToast('Server error: ${response.statusCode}');
      }
    } catch (error) {
      _showToast('Error: $error');
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Text(
                    "Before",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amethysta',
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  height: 250,
                  child: Image.asset(
                    'assets/bef.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                InputField(
                  controller: _fevController,
                  hintText: "FEV1",
                ),
                SizedBox(height: 15),
                InputField(
                  controller: _fvcController,
                  hintText: "FVC",
                ),
                SizedBox(height: 15),
                InputField(
                  controller: _ratioController,
                  hintText: "Ratio",
                ),
                SizedBox(height: 15),
                InputField(
                  controller: _tlcController,
                  hintText: "TLC",
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (_fevController.text.isNotEmpty &&
                        _fvcController.text.isNotEmpty &&
                        _ratioController.text.isNotEmpty &&
                        _tlcController.text.isNotEmpty) {
                      _submitData();
                    } else {
                      _showToast("Fields cannot be empty");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF82A8D2),
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Update",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amethysta',
                    ),
                  ),
                ),
                SizedBox(height: 70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom InputField widget
class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  InputField({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 275,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFF605858), width: 1),
      ),
      padding: EdgeInsets.only(left: 20),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16,
            fontFamily: 'Amethysta',
            color: Colors.black54,
          ),
          border: InputBorder.none,
        ),
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Amethysta',
          color: Colors.black,
        ),
        textAlignVertical: TextAlignVertical.center,
      ),
    );
  }
}
