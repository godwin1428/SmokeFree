import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smokefree/ip.dart';

import 'package:smokefree/afterpage.dart';
import 'package:smokefree/beforepage.dart';

class PftScreen extends StatefulWidget {
  @override
  _PftScreenState createState() => _PftScreenState();
}

class _PftScreenState extends State<PftScreen> {
  String beforeFEV1 = '--', afterFEV1 = '--', progressFEV1 = '--';
  String beforeFVC = '--', afterFVC = '--', progressFVC = '--';
  String beforeRatio = '--', afterRatio = '--', progressRatio = '--';
  String beforeTLC = '--', afterTLC = '--', progressTLC = '--';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    // Mock API URL (replace with the actual API endpoint)
    String apiUrl = ip+'pft.php';

    // Sending a POST request to the API
    final response = await http.post(Uri.parse(apiUrl), body: {'username':userid});

    if (response.statusCode == 200) {
      handleResponse(response.body);
    } else {
      // Handle error
      print('Failed to load data');
    }
  }

  void handleResponse(String response) {
    // Assuming the response format is similar to the one in Java code
    List<String> values = response.split(', ');

    setState(() {
      beforeFEV1 = values[0].trim().substring(1,values[0].length);
      beforeFVC = values[1];
      beforeRatio = values[2];
      beforeTLC = values[3];
      afterFEV1 = values[4];
      afterFVC = values[5];
      afterRatio = values[6];
      afterTLC = values[7].trim().substring(0,values[7].length-1);

      // Calculate progress for each field
      progressFEV1 = calculateProgress(values[0].trim().substring(1,values[0].length), values[4]);
      progressFVC = calculateProgress(values[1], values[5]);
      progressRatio = calculateProgress(values[2], values[6]);
      progressTLC = calculateProgress(values[3], values[7].trim().substring(0,values[7].length-1));
    });
  }

  String calculateProgress(String before, String after) {
    double beforeValue = double.tryParse(before) ?? 0.0;
    double afterValue = double.tryParse(after) ?? 0.0;

    double progress = afterValue - beforeValue;
    return progress >= 0 ? '+${progress.toStringAsFixed(2)}' : progress.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0), // 20 padding for the entire screen
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Text(
                  "PFT",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF302F2F),
                    fontFamily: 'Amethysta',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 25),
              // Image
              Image.asset(
                'assets/anl.png',
                width: MediaQuery.of(context).size.width,
                height: 300,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 30),
              // Table with TextFields
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFF605858), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Parameters Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildTableHeader(''),
                            buildTableCell('FEV1'),
                            buildTableCell('FVC'),
                            buildTableCell('Ratio'),
                            buildTableCell('TLC'),
                          ],
                        ),
                      ),
                      // Before Column
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BefPage()),
                            );
                          },
                          child: Column(
                            children: [
                              buildTableHeader('Before'),
                              buildTableCell(beforeFEV1),
                              buildTableCell(beforeFVC),
                              buildTableCell(beforeRatio),
                              buildTableCell(beforeTLC),
                            ],
                          ),
                        ),
                      ),
                      // After Column
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AfterPage()),
                            );
                          },
                          child: Column(
                            children: [
                              buildTableHeader('After'),
                              buildTableCell(afterFEV1),
                              buildTableCell(afterFVC),
                              buildTableCell(afterRatio),
                              buildTableCell(afterTLC),
                            ],
                          ),
                        ),
                      ),
                      // Progress Column
                      Expanded(
                        child: Column(
                          children: [
                            buildTableHeader('Progress'),
                            buildProgressCell(progressFEV1),
                            buildProgressCell(progressFVC),
                            buildProgressCell(progressRatio),
                            buildProgressCell(progressTLC),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build a table header
  Widget buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: 'Amethysta',
          color: Color(0xFF302F2F),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Helper function to build a table cell
  Widget buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontFamily: 'Amethysta',
          color: Color(0xFF2E2D2D),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Helper function to build a progress cell with color coding
  Widget buildProgressCell(String progress) {
    Color textColor = progress.startsWith('+') ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        progress,
        style: TextStyle(
          fontSize: 18,
          fontFamily: 'Amethysta',
          color: textColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
