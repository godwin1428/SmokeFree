import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smokefree/ip.dart';

import 'package:smokefree/pft.dart';

class AfterPage extends StatefulWidget {
  final String username=userid;



  @override
  _AfterPageState createState() => _AfterPageState();
}

class _AfterPageState extends State<AfterPage> {
  // Controllers for input fields
  final TextEditingController _fevController = TextEditingController();
  final TextEditingController _fvcController = TextEditingController();
  final TextEditingController _ratioController = TextEditingController();
  final TextEditingController _tlcController = TextEditingController();

  bool _isLoading = false;

  // Function to send the POST request
  Future<void> _sendUpdateRequest() async {
    final fev = _fevController.text.trim();
    final fvc = _fvcController.text.trim();
    final ratio = _ratioController.text.trim();
    final tlc = _tlcController.text.trim();

    if (fev.isEmpty || fvc.isEmpty || ratio.isEmpty || tlc.isEmpty) {
      // Show an error message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fields cannot be empty')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ip+'af.php'), // Replace with your actual API URL
        body: {
          'username': widget.username,
          'fev': fev,
          'fvc': fvc,
          'rto': ratio,
          'tlc': tlc,
        },
      );

      if (response.statusCode == 200) {
        // Parse the response
        final result = response.body.toLowerCase();
        if (result.contains("success")) {
          // Navigate to PftScreen if successful
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PftScreen()),
          );
        } else {
          // Show failure message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update failed')),
          );
        }
      } else {
        // Handle non-200 responses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                    "After",
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
                    'assets/aff.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                // Input fields
                InputField(controller: _fevController, hintText: "FEV1"),
                SizedBox(height: 15),
                InputField(controller: _fvcController, hintText: "FVC"),
                SizedBox(height: 15),
                InputField(controller: _ratioController, hintText: "Ratio"),
                SizedBox(height: 15),
                InputField(controller: _tlcController, hintText: "TLC"),
                SizedBox(height: 30),
                // Update Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendUpdateRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF82A8D2),
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
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
