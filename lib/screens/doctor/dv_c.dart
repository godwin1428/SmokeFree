import 'package:flutter/material.dart';
import 'package:smokefree/dv_dq.dart';

import 'package:smokefree/ip.dart';

class DoctorCravings extends StatelessWidget {
  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Horizontal Container
                  Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // First Vertical Column
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        opt="101";
                        // Navigate to a specific page for Disgust videos
                        navigateToPage(context, DoctorDq());
                      },
                      child: Container(
                        width: 140,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/tm3.png',
                              width: 100,
                              height: 100,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Disgust videos',
                              style: TextStyle(
                                fontFamily: 'Amethysta',
                                color: Color(0xFF252525),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        opt="102";
                        // Navigate to a specific page for Distract
                        navigateToPage(context, DoctorDq());
                      },
                      child: Container(
                        width: 140,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/vc2.png',
                              width: 100,
                              height: 100,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Distract',
                              style: TextStyle(
                                fontFamily: 'Amethysta',
                                color: Color(0xFF252525),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        opt="103";
                        // Navigate to a specific page for Deep breathing
                        navigateToPage(context, DoctorDq());
                      },
                      child: Container(
                        width: 140,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/vc3.png',
                              width: 100,
                              height: 100,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Deep breathing',
                              style: TextStyle(
                                fontFamily: 'Amethysta',
                                color: Color(0xFF252525),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 15),
                // Second Vertical Column
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        opt="104";
                        // Navigate to a specific page for Empower
                        navigateToPage(context, DoctorDq());
                      },
                      child: Container(
                        width: 140,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/vc5.png',
                              width: 100,
                              height: 100,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Empower',
                              style: TextStyle(
                                fontFamily: 'Amethysta',
                                color: Color(0xFF252525),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        opt="105";
                        // Navigate to a specific page for Delay
                        navigateToPage(context, DoctorDq());
                      },
                      child: Container(
                        width: 140,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/vc1.png',
                              width: 100,
                              height: 100,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Delay',
                              style: TextStyle(
                                fontFamily: 'Amethysta',
                                color: Color(0xFF252525),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        opt="106";
                        // Navigate to a specific page for Drink water
                        navigateToPage(context, DoctorDq());
                      },
                      child: Container(
                        width: 140,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/vc4.png',
                              width: 100,
                              height: 100,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Drink water',
                              style: TextStyle(
                                fontFamily: 'Amethysta',
                                color: Color(0xFF252525),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
),
);
}
}

