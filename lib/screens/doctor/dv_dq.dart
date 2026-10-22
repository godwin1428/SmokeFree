// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart'; // Import chewie
import 'package:http/http.dart' as http;

import 'package:smokefree/ip.dart';

class DoctorDq extends StatefulWidget {
  @override
  _DoctorDqState createState() => _DoctorDqState();
}

class _DoctorDqState extends State<DoctorDq> {
  ChewieController? _chewieController;
  VideoPlayerController? _videoController;
  File? _selectedVideo;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    fetchVideoFromDB();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  // Fetch video URL from the server (similar to your Java code with Volley)
  Future<void> fetchVideoFromDB() async {
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
    else if(opt=="0"){
      url="disdq.php";
    }
    else if(opt=="101"){
      url="discdgst.php";
    }
    else if(opt=="102"){
      url="discdstrct.php";
    }
    else if(opt=="103"){
      url="discdpb.php";
    }
    else if(opt=="104"){
      url="discemp.php";
    }
    else if(opt=="105"){
      url="discdly.php";
    }
    else if(opt=="106"){
      url="discdrnk.php";
    }
    String apiUrl = ip + url;

    try {
      final response = await http.post(Uri.parse(apiUrl), body: {'username': 'sai'});
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

  // Extract video URL from the response (assuming similar format)
  String extractVideoUrlFromResponse(String response) {
    List<String> values = response.split(":");
    return ip + 'videos/' + values[1].substring(9, values[1].length - 2);
  }

  // Play fetched video from URL
  void _playVideo(String videoUrl) {
    _videoController = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: true,
            looping: true,
            // Add more customization options here if needed
          );
        });
      });
  }

  // Pick a video from the gallery
  Future<void> _pickVideo() async {
    final pickedVideo = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      setState(() {
        _selectedVideo = File(pickedVideo.path);
        _videoController = VideoPlayerController.file(_selectedVideo!)
          ..initialize().then((_) {
            setState(() {
              _chewieController = ChewieController(
                videoPlayerController: _videoController!,
                autoPlay: true,
                looping: true,
                // Add more customization options here if needed
              );
            });
          });
      });
    }
  }

  // Upload the selected video
  Future<void> _uploadVideo(File videoFile) async {
    setState(() {
      _isUploading = true;
    });
    String ur="";
    if(opt=="1"){
      ur="vidmslfv1.php";
    }
    else if(opt=="2"){
      ur="vidmslfv2.php";
    }
    else if(opt=="3"){
      ur="vidmslfv3.php";
    }
    else if(opt=="4"){
      ur="vidmlevv1.php";
    }
    else if(opt=="5"){
      ur="vidmlevv2.php";
    }
    else if(opt=="6"){
      ur="vidmlevv3.php";
    }
    else if(opt=="7"){
      ur="vidmsedv1.php";
    }
    else if(opt=="8"){
      ur="vidmsedv2.php";
    }
    else if(opt=="9"){
      ur="vidmsedv3.php";
    }
    else if(opt=="10"){
      ur="vidmsclv1.php";
    }
    else if(opt=="11"){
      ur="vidmsclv2.php";
    }
    else if(opt=="12"){
      ur="vidmsclv3.php";
    }
    else if(opt=="0"){
      ur="viddq.php";
    }
    else if(opt=="101"){
      ur="vidcdgst.php";
    }
    else if(opt=="102"){
      ur="vidcdstrct.php";
    }
    else if(opt=="103"){
      ur="vidcdpb.php";
    }
    else if(opt=="104"){
      ur="vidcemp.php";
    }
    else if(opt=="105"){
      ur="vidcdly.php";
    }
    else if(opt=="106"){
      ur="vidcdrnk.php";
    }
    var request = http.MultipartRequest('POST', Uri.parse(ip + ur));
    request.files.add(await http.MultipartFile.fromPath('uploaded_file', videoFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print("Video uploaded successfully.");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Video uploaded successfully')));
      } else {
        print("Failed to upload video.");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload video')));
      }
    } catch (e) {
      print("Error uploading video: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading video')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color
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
            // Top Image
            Image.asset(
              'assets/upl.png',
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 25),
            // Video View
            Container(
              width: 350,
              height: 220,
              child: _chewieController != null
                  ? Chewie(controller: _chewieController!)
                  : Center(child: CircularProgressIndicator()),
            ),
            SizedBox(height: 60),
            // Bottom Image
            Image.asset(
              'assets/vdpld.png',
              height: 70,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 60),
            // Pick Video Button
            ElevatedButton(
              onPressed: _pickVideo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF81A7D1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text('Pick Video', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            // Upload Video Button
            ElevatedButton(
              onPressed: _selectedVideo != null && !_isUploading ? () => _uploadVideo(_selectedVideo!) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF81A7D1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: _isUploading ? CircularProgressIndicator() : Text('Upload Video', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ),
  ),
),
      // Play/Pause Floating Action Button
      floatingActionButton: _chewieController != null
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _chewieController!.isPlaying
                ? _chewieController!.pause()
                : _chewieController!.play();
          });
        },
        child: Icon(_chewieController!.isPlaying ? Icons.pause : Icons.play_arrow),
      )
          : null,
    );
  }
}
