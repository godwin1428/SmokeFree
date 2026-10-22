import 'package:flutter/material.dart';

import 'package:smokefree/dv_dq.dart';
import 'package:smokefree/ip.dart';


class Vm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First Container (Video 1)
              GestureDetector(
                onTap: () {
                  if(t=="1"){
                    opt="1";
                  }
                  else if(t=="2"){
                    opt="4";
                  }
                  else if(t=="3"){
                    opt="7";
                  }
                  else if(t=="4"){
                    opt="10";
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DoctorDq()),
                  );
                },
                child: _buildVideoContainer(
                  context,
                  'assets/vdoo.png', // Replace with your asset
                  'Video 1',
                ),
              ),
              SizedBox(height: 20),
              // Second Container (Video 2)
              GestureDetector(
                onTap: () {
                  if(t=="1"){
                    opt="2";
                  }
                  else if(t=="2"){
                    opt="5";
                  }
                  else if(t=="3"){
                    opt="8";
                  }
                  else if(t=="4"){
                    opt="11";
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DoctorDq()),
                  );
                },
                child: _buildVideoContainer(
                  context,
                  'assets/vdoo.png', // Replace with your asset
                  'Video 2',
                ),
              ),
              SizedBox(height: 20),
              // Third Container (Video 3)
              GestureDetector(
                onTap: () {
                  if(t=="1"){
                    opt="3";
                  }
                  else if(t=="2"){
                    opt="6";
                  }
                  else if(t=="3"){
                    opt="9";
                  }
                  else if(t=="4"){
                    opt="12";
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DoctorDq()),
                  );
                },
                child: _buildVideoContainer(
                  context,
                  'assets/vdoo.png', // Replace with your asset
                  'Video 3',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build a video container with custom background and content
  Widget _buildVideoContainer(BuildContext context, String imagePath, String text) {
    return Container(
      width: 160,
      padding: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Color(0xFFD2E0FB), // Background color equivalent to the shape drawable
        borderRadius: BorderRadius.circular(30), // Rounded corners
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 100,
            height: 100,
          ),
          SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Amethysta', // Ensure the Amethysta font is included in your project
              color: Color(0xFF252525),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
