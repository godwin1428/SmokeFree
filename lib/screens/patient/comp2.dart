import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:smokefree/providers/patient_provider.dart';
import 'package:smokefree/ip.dart';
import 'package:smokefree/patient.dart';
import 'package:smokefree/theme/app_colors.dart';
import 'package:video_player/video_player.dart';

class Comp2Page extends StatefulWidget {
  final String username;

  Comp2Page({super.key, String? username}) : username = username ?? userid;

  @override
  _Comp2PageState createState() => _Comp2PageState();
}

class _Comp2PageState extends State<Comp2Page> {
  ChewieController? _chewieController;
  VideoPlayerController? _videoPlayerController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    fetchData(widget.username);
  }

  Future<void> fetchData(String username) async {
    final String apiUrl = '${ip}discdstrct.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'username': username},
      );

      if (response.statusCode == 200 && response.body.contains(":")) {
        final String videoUrl = extractVideoUrlFromResponse(response.body);
        _playVideo(videoUrl);
      } else {
        if (mounted) setState(() => _hasError = true);
      }
    } catch (e) {
      debugPrint('Error fetching distraction video: $e');
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String extractVideoUrlFromResponse(String response) {
    final List<String> values = response.split(":");
    if (values.length > 1) {
      final String rawSub = values[1];
      if (rawSub.length > 11) {
        return '${ip}videos/${rawSub.substring(9, rawSub.length - 2)}';
      }
    }
    return '';
  }

  void _playVideo(String videoUrl) {
    if (videoUrl.isEmpty) {
      setState(() => _hasError = true);
      return;
    }

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _videoPlayerController!,
              autoPlay: true,
              looping: true,
              aspectRatio: _videoPlayerController!.value.aspectRatio > 0
                  ? _videoPlayerController!.value.aspectRatio
                  : 16 / 9,
              errorBuilder: (context, errorMessage) {
                return Center(
                  child: Text(
                    'Unable to play video: $errorMessage',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                  ),
                );
              },
            );
          });
        }).catchError((err) {
          debugPrint('Video init error: $err');
          if (mounted) setState(() => _hasError = true);
        });
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final patient = Provider.of<PatientProvider>(context);
    final isTamil = patient.isTamil;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.primaryDeepTeal),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => Patient()),
              (route) => false,
            );
          },
        ),
        title: Text(
          isTamil ? 'கவனச்சிதறல் பயிற்சி' : 'Urge Distraction & Relief',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDeepTeal,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calming Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isTamil ? 'உடனடி அமைதி' : 'Mindful Reset',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isTamil ? 'ஆழ்ந்த சுவாசத்துடன் கவனத்தை திருப்புங்கள்' : 'Shift Your Focus & Breathe',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isTamil
                          ? 'இந்த 2 நிமிட வீடியோ உங்கள் மூளையின் சிகரெட் தேடலை திசைதிருப்பி அமைதியை மீட்க உதவும்.'
                          : 'Urges peak within 3 to 5 minutes. Watching this calming guidance helps dopamine receptors recalibrate.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.1, end: 0),

              const SizedBox(height: 24),

              // Video Container
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildVideoContent(isTamil),
              ),

              const SizedBox(height: 24),

              // Calming Tips Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightCardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.spa_rounded, color: AppColors.mintFresh, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isTamil ? '3 எளிய படிகள்' : '3 Rapid Calming Steps',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDeepTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTipRow('1', isTamil ? 'குளிர்ந்த நீர் ஒரு டம்ளர் மெதுவாக குடியுங்கள்.' : 'Drink a glass of ice-cold water slowly.'),
                    const SizedBox(height: 8),
                    _buildTipRow('2', isTamil ? '4 வினாடிகள் மூச்சை உள்ளிழுத்து, 7 வினாடிகள் பிடித்து, 8 வினாடிகள் வெளிவிடுங்கள்.' : 'Inhale for 4s, hold for 7s, exhale for 8s.'),
                    const SizedBox(height: 8),
                    _buildTipRow('3', isTamil ? 'உங்கள் கைகளை குளிர்ந்த நீரில் கழுவி நரம்புகளை அமைதிப்படுத்துங்கள்.' : 'Wash your hands or face with cold water to trigger calming reflex.'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Return Home Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => Patient()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 4,
                    shadowColor: AppColors.primaryTeal.withValues(alpha: 0.4),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.home_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isTamil ? 'முகப்புக்கு செல்' : 'Return to Dashboard',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent(bool isTamil) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.mintFresh),
            const SizedBox(height: 12),
            Text(
              isTamil ? 'வீடியோ ஏற்றப்படுகிறது...' : 'Loading distraction guidance...',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (_hasError || _chewieController == null) {
      return Container(
        color: const Color(0xFF1E293B),
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.self_improvement_rounded, color: AppColors.mintFresh, size: 48),
            const SizedBox(height: 12),
            Text(
              isTamil ? 'சுவாசப் பயிற்சியை மேற்கொள்ளுங்கள்' : 'Focus on Mindful Breathing',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isTamil
                  ? 'ஆழ்ந்த சுவாசத்துடன் சறுக்கலை வெல்லுங்கள். நீங்கள் மீண்டும் வெற்றி பெறுவீர்கள்.'
                  : 'Take 5 deep belly breaths. The physical urge will dissipate in minutes.',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Chewie(controller: _chewieController!);
  }

  Widget _buildTipRow(String num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            num,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTeal,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textDark,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }
}
