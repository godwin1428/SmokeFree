import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:smokefree/ip.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:smokefree/patient.dart';

class DeepBreathPage extends StatefulWidget {
  final String username=userid;




  @override
  _DeepBreathPageState createState() => _DeepBreathPageState();
}

class _DeepBreathPageState extends State<DeepBreathPage> {
  late VideoPlayerController _videoPlayerController;
  late String videoUrl;
  ChewieController? _chewieController;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    fetchData(widget.username);
  }

  Future<void> fetchData(String username) async {
    String apiUrl = ip+'discdpb.php'; // Replace with your API URL

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'username': username},
      );

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
    final TextStyle textStyle = TextStyle(
      fontFamily: 'Amethysta',
      fontSize: 16.0,
      color: Color(0xFF454545),
    );

    final Map<String, String> localizedTexts = lang == '1'
        ? {
      'title': 'ஆழ்ந்த மூச்சை விடுங்கள்',
      'inhale': 'உள்ளிழுத்து நேர்மறையான எண்ணங்கள்:',
      'inhaleText': 'வினாடிகள் உங்கள் மூக்கின் வழியாக மெதுவாக சுவாசிக்கவும், நேர்மறை மற்றும் நல்ல எண்ணங்களால் உங்களை நிரப்பவும்.',
      'hold': 'பிடித்து அணைத்துக்கொள்:',
      'holdText': 'உங்கள் மூச்சை 5 வினாடிகள் வைத்திருங்கள், உங்களுக்குள் நேர்மறையை நிலைநிறுத்த அனுமதிக்கிறது.',
      'exhale': 'மூச்சை வெளியேற்றி விடுங்கள்:',
      'exhaleText': 'எந்த எதிர்மறை அல்லது பதற்றத்தையும் விட்டுவிடாமல், 7 வினாடிகளுக்கு உங்கள் வாய் வழியாக மெதுவாக மூச்சை விடுங்கள்.',
      'next': 'அடுத்து',
    }
        : {
      'title': 'Deep Breathing',
      'inhale': 'INHALE AND POSITIVE THOUGHTS:',
      'inhaleText': '“Breathe in slowly through your nose for 3 seconds, filling yourself with positivity and good thoughts.”',
      'hold': 'HOLD AND EMBRACE:',
      'holdText': '“Hold your breath for 5 seconds, allowing the positivity to settle within you.”',
      'exhale': 'EXHALE AND RELEASE:',
      'exhaleText': '“Exhale gently through your mouth for 7 seconds, letting go of any negativity or tension.”',
      'next': 'Next',
    };

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 80.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF82A8D2), // AppBar color
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25.0),
                bottomRight: Radius.circular(25.0),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Text(
            localizedTexts['title']!,
            style: TextStyle(
              fontFamily: 'Amethysta',
              fontSize: 24.0,
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
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 28.0),
              children: [
                Text(
                  localizedTexts['inhale']!,
                  style: TextStyle(
                    fontFamily: 'Amethysta',
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF323131),
                  ),
                ),
                SizedBox(height: 5.0),
                Text(
                  localizedTexts['inhaleText']!,
                  style: textStyle,
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 15.0),
                Text(
                  localizedTexts['hold']!,
                  style: TextStyle(
                    fontFamily: 'Amethysta',
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF323131),
                  ),
                ),
                SizedBox(height: 5.0),
                Text(
                  localizedTexts['holdText']!,
                  style: textStyle,
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 15.0),
                Text(
                  localizedTexts['exhale']!,
                  style: TextStyle(
                    fontFamily: 'Amethysta',
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF323131),
                  ),
                ),
                SizedBox(height: 5.0),
                Text(
                  localizedTexts['exhaleText']!,
                  style: textStyle,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Patient(), // Replace with your next page
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
                localizedTexts['next']!,
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

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }
}
