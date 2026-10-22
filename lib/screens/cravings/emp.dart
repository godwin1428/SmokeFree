import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smokefree/ip.dart';
import 'package:smokefree/models/reward_result.dart';
import 'package:smokefree/patient.dart';
import 'package:smokefree/providers/patient_provider.dart';
import 'package:smokefree/theme/app_colors.dart';

class EmpPage extends StatefulWidget {
  final String username;

  EmpPage({super.key, String? username}) : username = username ?? userid;

  @override
  _EmpPageState createState() => _EmpPageState();
}

class _EmpPageState extends State<EmpPage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _breatheSeconds = 4;
  String _breathePhase = 'Inhale peace';
  bool _isBreathingActive = false;
  int _cyclesDone = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  void _startBreathing() {
    setState(() {
      _isBreathingActive = true;
      _breathePhase = 'Inhale gently';
      _breatheSeconds = 4;
    });
    _pulseController.duration = const Duration(seconds: 4);
    _pulseController.forward(from: 0.0);

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted || !_isBreathingActive) return;
      setState(() {
        _breathePhase = 'Hold calmly';
        _breatheSeconds = 7;
      });
      Future.delayed(const Duration(seconds: 7), () {
        if (!mounted || !_isBreathingActive) return;
        setState(() {
          _breathePhase = 'Exhale all tension';
          _breatheSeconds = 8;
        });
        _pulseController.duration = const Duration(seconds: 8);
        _pulseController.reverse(from: 1.0);

        Future.delayed(const Duration(seconds: 8), () {
          if (!mounted || !_isBreathingActive) return;
          setState(() {
            _cyclesDone++;
            _isBreathingActive = false;
          });
          HapticFeedback.mediumImpact();
          Provider.of<PatientProvider>(context, listen: false).addPoints(
            10,
            activityKey: ActivityCooldownKeys.copingBreathing,
            cooldown: const Duration(minutes: 15),
          );
        });
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patient = Provider.of<PatientProvider>(context);
    final isTamil = patient.isTamil;
    final userName = widget.username.isNotEmpty ? widget.username : (isTamil ? 'நண்பரே' : 'Friend');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.primaryDeepTeal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isTamil ? 'பரிவு AI உளவியல் அரவணைப்பு' : 'Empathy AI Emotional Shield',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDeepTeal,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.mintFresh.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite_rounded, size: 14, color: AppColors.mintFresh),
                const SizedBox(width: 4),
                Text(
                  '${patient.points} Pts',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDeepTeal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
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
                        isTamil ? 'குற்ற உணர்வற்ற ஆதரவு' : 'Non-Judgmental Emotional Safehouse',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isTamil
                          ? '$userName, ஆசை தோன்றுவது பலவீனம் அல்ல!'
                          : '$userName, It is Normal to Feel This.',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isTamil
                          ? 'உங்கள் நரம்பு மண்டலம் அமைதியை தேடுகிறது. சிகரெட் அமைதி தருவதில்லை; உண்மையான அமைதி உங்கள் ஆழ்ந்த சுவாசத்தில் உள்ளது.'
                          : 'Cravings are not commands—they are temporary electrochemical echoes of old habits. You are in complete control.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.08, end: 0),

              const SizedBox(height: 24),

              // Interactive Breathing Orb Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.mintFresh, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mintFresh.withValues(alpha: 0.1),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      isTamil ? 'நரம்புத்தளர்ச்சி தணிப்பு சுவாசம்' : 'Vagus Nerve Reset Pacer',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isTamil
                          ? 'ஆழ்ந்த சுவாசம் இதயத் துடிப்பை குறைத்து உடனடி அமைதியைத் தரும்.'
                          : 'Slow rhythmic exhalation physically switches off the fight-or-flight surge.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Breathing Pulsing Orb
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isBreathingActive ? _pulseAnimation.value : 1.0,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.mintFresh.withValues(alpha: 0.8),
                                  AppColors.primaryTeal,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.mintFresh.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isBreathingActive)
                                  Text(
                                    '$_breatheSeconds s',
                                    style: GoogleFonts.outfit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                Text(
                                  _breathePhase,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: 220,
                      height: 46,
                      child: ElevatedButton.icon(
                        icon: Icon(_isBreathingActive ? Icons.hourglass_top : Icons.play_arrow_rounded, color: Colors.white),
                        label: Text(
                          _isBreathingActive
                              ? (isTamil ? 'சுவாசிக்கவும்...' : 'Breathing...')
                              : (isTamil ? 'சுவாசத்தை தொடங்கு' : 'Start 4-7-8 Breathing'),
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: _isBreathingActive ? null : _startBreathing,
                      ),
                    ),
                    if (_cyclesDone > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        isTamil ? 'வெற்றிகரமான சுழற்சிகள்: $_cyclesDone (+10 புள்ளிகள்)' : 'Completed cycles: $_cyclesDone (+10 Pts each)',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mintFresh),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // CBT Cognitive Reframe Pillars
              Text(
                isTamil ? 'மன உறுதி மறுசீரமைப்பு' : 'Cognitive Behavioral Reassurance',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDeepTeal),
              ),
              const SizedBox(height: 12),

              _buildReframeCard(
                icon: Icons.waves_rounded,
                title: isTamil ? 'ஆசை ஒரு அலை மட்டுமே' : 'The 3-Minute Wave Principle',
                body: isTamil
                    ? 'ஆசை தொடர்ந்து நீடிப்பதில்லை; அது 3 நிமிடங்களில் உச்சம் தொட்டு தானாகவே சரிந்துவிடும்.'
                    : 'Cravings naturally crest and recede within 180 seconds. You do not need willpower—you only need 3 minutes of patience.',
                color: AppColors.primaryTeal,
              ),
              const SizedBox(height: 10),

              _buildReframeCard(
                icon: Icons.shield_outlined,
                title: isTamil ? 'உங்கள் இலக்கு பாதுகாப்பானது' : 'Your Progress is Intact',
                body: isTamil
                    ? 'நீங்கள் இதுவரை புகைக்காமல் இருந்த ஒவ்வொரு நாளும் உங்கள் உடலில் புதிய செல்களை உருவாக்கியுள்ளது.'
                    : 'Your smoke-free days belong to you. No craving can steal the biological healing your lungs have achieved.',
                color: AppColors.mintFresh,
              ),
              const SizedBox(height: 10),

              _buildReframeCard(
                icon: Icons.water_drop_outlined,
                title: isTamil ? 'எளிய உடனடி மாற்று' : 'Immediate Sensory Grounding',
                body: isTamil
                    ? 'ஒரு டம்ளர் குளிர்ந்த நீரை மெதுவாக குடியுங்கள். நரம்புகள் உடனடியாக அமைதியடையும்.'
                    : 'Sip cold water slowly. Engaging your swallow reflex activates the parasympathetic calming network.',
                color: AppColors.skyBlue,
              ),

              const SizedBox(height: 30),

              // Return / Claim Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                  label: Text(
                    isTamil ? 'வெற்றியை உறுதி செய்து திரும்பு' : 'I Outlasted the Urge • Return Home',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Provider.of<PatientProvider>(context, listen: false).addPoints(
                      15,
                      activityKey: 'emp_reframe_completion',
                      cooldown: const Duration(minutes: 15),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => Patient()),
                      (route) => false,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReframeCard({required IconData icon, required String title, required String body, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDeepTeal),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
