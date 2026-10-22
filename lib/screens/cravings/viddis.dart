import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:smokefree/ip.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class Viddis extends StatefulWidget {
  final String username= userid;




  @override
  _Comp2PageState createState() => _Comp2PageState();
}

class _Comp2PageState extends State<Viddis> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    fetchData(widget.username);
  }

  Future<void> fetchData(String username) async {
    String url="";
    if(opt=="1"){
        url="dismslfv1.php";
    }
    else if(opt=="2"){
      url="dismslfv2.php";
    }
    else if(opt=="3"){
      url="dismslfv3.php";
    }
    else if(opt=="4"){
      url="dismlevv1.php";
    }
    else if(opt=="5"){
      url="dismlevv2.php";
    }
    else if(opt=="6"){
      url="dismlevv3.php";
    }
    else if(opt=="7"){
      url="dismsedv1.php";
    }
    else if(opt=="8"){
      url="dismsedv2.php";
    }
    else if(opt=="9"){
      url="dismsedv3.php";
    }
    else if(opt=="10"){
      url="dismsclv1.php";
    }
    else if(opt=="11"){
      url="dismsclv2.php";
    }
    else if(opt=="12"){
      url="dismsclv3.php";
    }
    String apiUrl = ip+url;

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
    final String title = lang == '1' ? '' : '';

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
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
            SizedBox(height: 60.0),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Amethysta',
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC4252424),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.0),
            Container(
              width: 350.0,
              height: 200.0,
              color: Colors.black,
              child: _chewieController != null
                  ? Chewie(controller: _chewieController!)
                  : Center(child: CircularProgressIndicator()),
            ),
            Spacer(),

            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
