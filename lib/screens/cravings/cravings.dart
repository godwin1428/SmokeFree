import 'package:flutter/material.dart';
import 'package:smokefree/disgust.dart';
import 'package:smokefree/distract.dart';
import 'package:smokefree/emp.dart';

import 'package:smokefree/ip.dart';

class CravingsPage extends StatelessWidget {
   // Add this to capture the language

   // Default language

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            // Image
            Center(
              child: Image.asset(
                'assets/as.png', // Replace with the correct path of your image
                width: 400,
                height: 320,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 25),
            // Text: Reasons for your craving?
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                lang == "1" ? "உங்கள் ஆசைக்கான காரணங்கள்?" : "Reasons for your craving?",
                style: TextStyle(
                  fontFamily: 'Amethysta',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF323131),
                ),
              ),
            ),
            SizedBox(height: 25),
            // Horizontal CheckBox Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left Column Checkboxes
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customCheckBox(lang == "1" ? "விரக்தி" : "Frustration"),
                    customCheckBox(lang == "1" ? "அழுத்தம்" : "Stress"),
                  ],
                ),
                SizedBox(width: 10),
                // Right Column Checkboxes
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customCheckBox(lang == "1" ? "சோர்வு" : "Depression"),
                    customCheckBox(lang == "1" ? "கவலை" : "Anxiety"),
                  ],
                ),
              ],
            ),
            SizedBox(height: 25),
            // Text: On scale of 1-5 your craving?
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                lang == "1" ? "1-5 என்ற அளவில் உங்கள் ஆசை?" : "On scale of 1-5 your craving?",
                style: TextStyle(
                  fontFamily: 'Amethysta',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF323131),
                ),
              ),
            ),
            SizedBox(height: 19),
            // Craving Scale Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF82A8D2),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    cravingScaleButton(context, '1'),
                    cravingScaleButton(context, '2'),
                    cravingScaleButton(context, '3'),
                    cravingScaleButton(context, '4'),
                    cravingScaleButton(context, '5'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Checkbox Widget
  Widget customCheckBox(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        height: 48,
        width: 180,
        padding: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Color(0xFFFBF6F6),
          border: Border.all(color: Color(0xFF605858), width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Checkbox(
              value: false,
              onChanged: (bool? value) {},
              activeColor: Color(0xFF605858),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Amethysta',
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Craving Scale Button Widget with Navigation
  Widget cravingScaleButton(BuildContext context, String number) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              switch (number) {
                case '1':
                case '2':
                  return EmpPage();
                case '3':
                case '4':
                  return DistractPage();
                case '5':
                  return DisgustPage();
                default:
                  return CravingsPage();
              }
            },
          ),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Color(0xFFFBF6F6),
          border: Border.all(color: Color(0xFF605858), width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontFamily: 'Amethysta',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
