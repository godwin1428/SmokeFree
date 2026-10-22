import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Add this import
import 'package:smokefree/daily_questions.dart';

import 'package:smokefree/biweekly.dart';
import 'package:smokefree/services/cross_role_sync_service.dart';
import 'package:smokefree/ip.dart';

class PatientHomePage extends StatefulWidget {
  @override
  _PatientHomePageState createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  // Initialize variables to store data
  String points = '0';
  String moneySaved = '0';
  String mon = '0';
  String rs = '0';
  String ind = '0';
  String logDate = '';
  String dqDate = '';
  String bwkDate = '';
  String docMsg = '';
  String daysWithoutCigarette = '0';
  String hoursWithoutCigarette = '0';
  String minutesWithoutCigarette = '0';
  String t1 = "";
  String t2 = "";
  String t3 = "";
  String b1 = "";
  String t4 = "";
  String t5 = "";
  String t6 = "";
  String t7 = "";
  String t8 = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
    _setLocalizedText();
  }
  void _setLocalizedText() {
    if (lang == "1") {
      t1 = "உங்கள் தினசரி கேள்விகள் தயாராக உள்ளன";
      t2 = "தினசரி பணி";
      t3 = "சிகரெட் இல்லாத நேரம்";
      b1 = "எடு";
      t4 = "நாட்கள்";
      t5 = "மணிகள்";
      t6 = "நிமிடங்கள்";
      t7 = "பணம்\nசேமிக்கப்பட்டது";
      t8 = "ஆரோக்கியம்";
    } else {
      t1 = "Your daily questionnaires are ready";
      t2 = "Daily Task";
      t3 = "Time without Cigarette";
      b1 = "Take";
      t4 = "Days";
      t5 = "Hours";
      t6 = "Minutes";
      t7 = "Money Saved";
      t8 = "Health";
    }
  }
  Future<void> _showNotificationPopup() async {
    // Ensure bwkDate is parsed correctly
    DateTime bwkDateTime;
    try {
      bwkDateTime = DateTime.parse(bwkDate);
    } catch (e) {
      print('Error parsing bwkDate: $e');
      return;
    }

    DateTime currentDate = DateTime.now();
    int daysDifference = currentDate.difference(bwkDateTime).inDays;
    user_ind=ind;
    print(user_ind);
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from closing when tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          content: Container(
            width: 320,
            decoration: BoxDecoration(
              color: Color(0xFFD2E0FB),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    docMsg,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Amethysta',
                      color: Color(0xFF201F1F),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Divider(),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Biweekly Task",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Amethysta',
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Your biweekly Questionnaires are ready.",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Amethysta',
                          color: Color(0xFF272626),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (daysDifference < 14) {
                          Navigator.of(context).pop(); // Close dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Come back in ${14 - daysDifference} days."),
                            ),
                          );
                        } else {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Biweekly()),
                          );
                        }
                      },
                      child: Text(
                        "Take",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Amethysta',
                          color: Colors.white,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF7CA0C8),
                      ),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Amethysta',
                          color: Color(0xFF7CA0C8),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> _fetchData() async {
    // Replace with your API URL and parameters
    final String apiUrl = ip + 'home.php';
    final String username = userid; // Provide the username

    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({'username': username}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'failure') {
        // Handle failure
        print(data['message']);
      } else {
        setState(() {
          print(response.body);
          // Store each value in a separate string
          points = data['points']?.toString() ?? '0';
          moneySaved = data['moneySaved']?.toString() ?? '0';
          mon = data['mon']?.toString() ?? '0';
          rs = data['rs']?.toString() ?? '0';
          ind = data['ind']?.toString() ?? '0';
          logDate = data['logDate']?.toString() ?? '';
          dqDate = data['dqDate']?.toString() ?? '';
          bwkDate = data['bwkDate']?.toString() ?? '';
          docMsg = data['docMsg']?.toString() ?? '';
          daysWithoutCigarette = data['days']?.toString() ?? '0';

          // Calculate hours and minutes based on days
          int days = int.tryParse(daysWithoutCigarette) ?? 0;
          hoursWithoutCigarette = (days * 24).toString();
          minutesWithoutCigarette = (days * 24 * 60).toString();
        });
      }
    } else {
      // Handle error
      print('Failed to load data');
    }

    // Cross-Role Sync: Fetch live doctor directive for this patient
    final syncedDirective = await CrossRoleSyncService().getDoctorDirectiveForPatient(userid);
    if (syncedDirective != null && syncedDirective.isNotEmpty) {
      if (mounted) {
        setState(() {
          docMsg = syncedDirective;
        });
      }
    }

    // Cross-Role Sync: Broadcast patient telemetry to Doctor & Admin
    final parsedDays = int.tryParse(daysWithoutCigarette) ?? 0;
    final parsedSaved = double.tryParse(moneySaved) ?? 0.0;
    await CrossRoleSyncService().updatePatientTelemetry(
      patientUsername: userid,
      smokeFreeDays: parsedDays,
      moneySaved: parsedSaved,
      name: user_name.isNotEmpty ? user_name : userid,
    );
  }

  void _handleTakeButtonPress() {
    // Format today's date
    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    user_pnts=points;
    user_monsav=moneySaved;
    user_mon=mon;
    user_rs=rs;
    print(dqDate+" "+todayDate);
    if (dqDate == todayDate) {
      // Show a popup message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Reminder'),
            content: Text('You have already given today\'s questionnaire. Come back tomorrow.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Navigate to the Daily Questionnaire page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DailyQuePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF82A8D2), Color(0xFF82A8D2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            padding: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF7CA0C8),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/ggg.png',
                        height: 32,
                        width: 32,
                      ),
                      SizedBox(width: 10),
                      Text(
                        points,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Amethysta',
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    print('Bell icon tapped'); // Debugging statement
                    _showNotificationPopup();
                  },
                  child: Image.asset(
                    'assets/bell.png',
                    height: 30,
                    width: 30,
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
        )

      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          primary: false,
          physics: const BouncingScrollPhysics(),
          child: Column(
          children: [
            if (docMsg.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.medical_services_rounded, color: Color(0xFF16A34A), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Attending Doctor\'s Directive',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF166534),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            docMsg,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1E293B),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: docMsg.isNotEmpty ? 20 : 50),
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFEEFEFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Color(0xFF7CA0C8), width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    //"Daily Task",
                    t2,
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFF7CA0C8),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amethysta',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    //"Your daily Questionnaires are Ready",
                    t1,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontFamily: 'Amethysta',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _handleTakeButtonPress, // Updated handler
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7CA0C8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 30,
                      ),
                      child: Text(
                        //"Take",
                        b1,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Amethysta',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0xFF7CA0C8), width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    //"Time without Cigarette",
                    t3,
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFF7CA0C8),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amethysta',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildTimeColumn(daysWithoutCigarette, t4),
                      buildTimeColumn(hoursWithoutCigarette, t5),
                      buildTimeColumn(minutesWithoutCigarette, t6),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        //"Health",
                        t8,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7CA0C8),
                          fontFamily: 'Amethysta',
                        ),
                      ),
                      SizedBox(height: 10),
                      Image.asset(
                        'assets/lungs.png',
                        height: 140,
                        width: 140,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Amethysta',
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        //"Money Saved",
                        t7,
                        style: TextStyle(
                          fontSize: 22,
                          color: Color(0xFF7CA0C8),
                          fontFamily: 'Amethysta',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Color(0xFF7CA0C8), width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.currency_rupee, size: 30),
                            SizedBox(width: 5),
                            Text(
                              moneySaved,
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.black87,
                                fontFamily: 'Amethysta',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget buildTimeColumn(String value, String unit) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Color(0xFF7CA0C8), width: 1),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black87,
                  fontFamily: 'Amethysta',
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontFamily: 'Amethysta',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
