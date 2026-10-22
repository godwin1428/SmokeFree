import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart'; // Import chewie

import 'package:smokefree/drinkwater.dart';
import 'package:smokefree/ip.dart';

class DelayPage extends StatefulWidget {
  final String username=userid;




  @override
  _DelayPageState createState() => _DelayPageState();
}

class _DelayPageState extends State<DelayPage> {
  ChewieController? _chewieController;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    fetchData(widget.username);
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> fetchData(String username) async {
    String apiUrl = '${ip}discdly.php';

    try {
      final response = await http.post(Uri.parse(apiUrl), body: {'username': username});
      if (response.statusCode == 200) {
        String videoUrl = extractVideoUrlFromResponse(response.body);
        _playVideo(videoUrl);
      } else {
        print('Failed to fetch video.');
      }
    } catch (e) {
      print('Error fetching video: $e');
    }
  }

  String extractVideoUrlFromResponse(String response) {
    List<String> values = response.split(":");
    return '${ip}videos/${values[1].substring(9, values[1].length - 2)}';
  }

  void _playVideo(String videoUrl) {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: true,
            looping: true,
          );
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    String title = lang == "1" ? "தாமதப்படுத்து" : "Delay";
    String subtitle =lang == "1"
        ? "பக்ரேவ் கடிகார சவாலை வெல்லுங்கள்!!!\n10 நிமிடங்களுக்கு நீங்களே"
        : "Beat the crave clock challenge!!! yourself for 10 mins";
    String buttonText = lang == "1" ? "அடுத்து" : "Next";

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 80.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF82A8D2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25.0),
                bottomRight: Radius.circular(25.0),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Amethysta',
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC4252424),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.0),
          Container(
            width: 350.0,
            height: 200.0,
            color: Colors.black,
            child: _chewieController != null
                ? Chewie(controller: _chewieController!)
                : Center(child: CircularProgressIndicator()),
          ),
          SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Amethysta',
                fontSize: 18.0,
                color: Color(0xFF454545),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20.0),
          Image.asset(
            'assets/clk.png',
            width: 100.0,
            height: 100.0,
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DrinkWaterPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF82A8D2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                fixedSize: Size(150.0, 50.0),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontFamily: 'Amethysta',
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
