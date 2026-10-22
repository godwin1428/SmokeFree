import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smokefree/patlog.dart';

import 'package:smokefree/ip.dart';

class SignUpPage2 extends StatefulWidget {
  final String username=userid;



  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage2> {
  bool cigarettesChecked = false;
  bool beediesChecked = false;
  TextEditingController emonController = TextEditingController();
  TextEditingController enoController = TextEditingController();
  TextEditingController eyController = TextEditingController();
  String apiUrl = ip+'sign2.php'; // Replace with your actual IP and endpoint

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF82A8D2),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Center(
                child: Text(
                  "", // No title in the top bar
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Image.asset(
                'assets/advc.png',
                width: 300,
                height: 220,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                "Form of Nicotine:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B2A2A)),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: cigarettesChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        cigarettesChecked = value ?? false;
                      });
                    },
                    title: Text("Cigarettes", style: TextStyle(fontSize: 16, color: Color(0xFF2B2A2A))),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: beediesChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        beediesChecked = value ?? false;
                      });
                    },
                    title: Text("Beedies", style: TextStyle(fontSize: 16, color: Color(0xFF2B2A2A))),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildTextField("Started working", emonController, "years"),
            SizedBox(height: 20),
            _buildTextField("I pay", enoController, "INR/Day"),
            SizedBox(height: 20),
            _buildTextField("Average no of cigarettes/day", eyController, "counts"),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _onStartPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF82A8D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  "Start",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B2A2A)),
            ),
          ),
          SizedBox(width: 10),
          Container(
            width: 80,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onStartPressed() async {
    String y = emonController.text.trim();
    String mon = enoController.text.trim();
    String no = eyController.text.trim();

    if (mon.isEmpty || no.isEmpty || y.isEmpty) {
      _showToast("Fields cannot be empty");
      return;
    }
    print(mon+" "+no);
    // Calculate rs as a float
    double rs = double.parse(mon) / double.parse(no);


    await _sendLoginRequest(widget.username, mon, rs);
  }

  Future<void> _sendLoginRequest(String username, String mon, double rs) async {
    try {

      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'username': username,
          'mon': mon,
          'rs': rs.toString(),
        },
      );

      if (response.statusCode == 200) {
        print(mon+" "+rs.toString());
        _handleResponse(response.body);
      } else {
        _showToast("Sign Up failed");
      }
    } catch (e) {
      _showToast("Error: $e");
    }
  }

  void _handleResponse(String response) {

    // Check if the response contains "success"
    if (response.toLowerCase().contains("success")) {
      _showToast("Sign Up successful");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PatientLoginPage()),
      ); // Replace with your actual route
    } else {
      _showToast("Sign Up failed");
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
