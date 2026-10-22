import 'dart:async';
import 'dart:math';
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

class DistractPage extends StatefulWidget {
  final String username;

  DistractPage({super.key, String? username}) : username = username ?? userid;

  @override
  _DistractPageState createState() => _DistractPageState();
}

class _DistractPageState extends State<DistractPage> {
  // Game state: 60-second rapid focus puzzle
  int _secondsLeft = 60;
  Timer? _gameTimer;
  bool _isPlaying = false;
  int _score = 0;
  int _targetNumber = 1;
  List<int> _gridNumbers = [];
  bool _isFinished = false;
  RewardResult? _gameRewardResult;

  @override
  void initState() {
    super.initState();
    _resetGrid();
  }

  void _resetGrid() {
    final rand = Random();
    _gridNumbers = List.generate(9, (index) => index + 1)..shuffle(rand);
    _targetNumber = 1;
  }

  void _startGame() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isPlaying = true;
      _secondsLeft = 60;
      _score = 0;
      _isFinished = false;
      _resetGrid();
    });

    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
        final res = Provider.of<PatientProvider>(context, listen: false).addPoints(
          15,
          activityKey: ActivityCooldownKeys.copingDistract,
          cooldown: const Duration(minutes: 15),
        );
        setState(() {
          _isPlaying = false;
          _isFinished = true;
          _gameRewardResult = res;
        });
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _onTileTap(int num) {
    if (!_isPlaying) return;
    if (num == _targetNumber) {
      HapticFeedback.selectionClick();
      setState(() {
        _score += 10;
        if (_targetNumber < 9) {
          _targetNumber++;
        } else {
          // Completed one set!
          _resetGrid();
        }
      });
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isTamil ? 'கவனச்சிதறல் கேடயம்' : 'Cognitive Dopamine Diverter',
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
              color: AppColors.skyBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, size: 14, color: AppColors.skyBlue),
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.3),
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
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isTamil ? 'மூளை மறுசுழற்சி விளையாட்டு' : 'Prefrontal Cortex Engagement',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isTamil ? '60 வினாடி நரம்பியல் திசைதிருப்பல்' : '60-Second Dopamine Hijack',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isTamil
                          ? 'ஆசை எழும்போது உங்கள் மூளையின் இயக்க மையத்தை இந்த எளிய விளையாட்டுடன் இணைத்தால் சிகரெட் தேடல் உடனடியாக அடங்கும்.'
                          : 'Activating visual-motor centers diverts blood flow away from the craving impulse in your amygdala.',
                      style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.95), height: 1.35),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.08, end: 0),

              const SizedBox(height: 20),

              // Game Console Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.skyBlue.withValues(alpha: 0.1),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Timer & Score Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined, size: 16, color: AppColors.skyBlue),
                              const SizedBox(width: 6),
                              Text(
                                '$_secondsLeft s',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDeepTeal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.mintFresh.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 16, color: AppColors.mintFresh),
                              const SizedBox(width: 6),
                              Text(
                                'Score: $_score',
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mintFresh,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    if (!_isPlaying && !_isFinished) ...[
                      Text(
                        isTamil ? 'வரிசைப்படி 1 முதல் 9 வரை தொடவும்!' : 'Tap the numbers in order: 1 -> 9!',
                        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryDeepTeal),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isTamil ? 'விரைவாக தொட்டு அதிக புள்ளிகளைப் பெறுங்கள்' : 'Keep your fingers moving to completely collapse the urge',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 220,
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                          label: Text(
                            isTamil ? 'விளையாட்டைத் தொடங்கு' : 'Start 60s Challenge',
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.skyBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: _startGame,
                        ),
                      ),
                    ] else if (_isPlaying) ...[
                      Text(
                        isTamil ? 'அடுத்து தொடவும்: #$_targetNumber' : 'Target Next: #$_targetNumber',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.skyBlue),
                      ),
                      const SizedBox(height: 14),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _gridNumbers.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.25,
                        ),
                        itemBuilder: (context, index) {
                          final n = _gridNumbers[index];
                          final isTarget = n == _targetNumber;
                          final isDone = n < _targetNumber;

                          return GestureDetector(
                            onTap: () => _onTileTap(n),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? const Color(0xFFE2E8F0)
                                    : isTarget
                                        ? AppColors.skyBlue
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isTarget ? AppColors.skyBlue : const Color(0xFFCBD5E1),
                                  width: isTarget ? 2 : 1,
                                ),
                                boxShadow: isTarget
                                    ? [
                                        BoxShadow(
                                          color: AppColors.skyBlue.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$n',
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDone
                                      ? AppColors.textMuted
                                      : isTarget
                                          ? Colors.white
                                          : AppColors.primaryDeepTeal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      // Game finished!
                      const Icon(Icons.emoji_events_rounded, size: 54, color: AppColors.amberGold),
                      const SizedBox(height: 8),
                      Text(
                        isTamil ? 'சிறப்பு! நீங்கள் ஆசையை முறியடித்துவிட்டீர்கள்!' : 'Brilliant! Urge Peak Diverted!',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDeepTeal),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (_gameRewardResult?.awarded ?? true)
                            ? (isTamil ? 'புள்ளிகள்: $_score (+15 போனஸ் சேர்க்கப்பட்டது)' : 'Final Score: $_score (+15 Pts awarded!)')
                            : (isTamil
                                ? 'புள்ளிகள்: $_score (குளிர்விப்பு: ${_gameRewardResult?.formattedRemainingTime})'
                                : 'Final Score: $_score (Cooldown: ${_gameRewardResult?.formattedRemainingTime})'),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: (_gameRewardResult?.awarded ?? true) ? AppColors.mintFresh : AppColors.amberGold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 180,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.skyBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _startGame,
                          child: Text(
                            isTamil ? 'மீண்டும் விளையாடு' : 'Play Again',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5-4-3-2-1 Sensory Grounding Pillar
              Text(
                isTamil ? '5-4-3-2-1 புலன் விழிப்புணர்வு பயிற்சி' : '5-4-3-2-1 Sensory Grounding',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDeepTeal),
              ),
              const SizedBox(height: 10),
              _buildGroundingItem('5', isTamil ? 'சுற்றிலும் இருக்கும் 5 பொருட்களை கவனியுங்கள்' : 'Acknowledge 5 things you can see around you'),
              _buildGroundingItem('4', isTamil ? 'உங்களை தொடும் 4 உணர்வுகளை கவனியுங்கள்' : 'Acknowledge 4 things you can physically touch'),
              _buildGroundingItem('3', isTamil ? 'சுற்றிலும் கேட்கும் 3 ஒலிகளை கேளுங்கள்' : 'Acknowledge 3 distinct sounds you can hear'),
              _buildGroundingItem('2', isTamil ? '2 வாசனைகளை நுகருங்கள்' : 'Acknowledge 2 scents you can smell'),
              _buildGroundingItem('1', isTamil ? '1 எளிய ஆழ்ந்த மூச்சை உணருங்கள்' : 'Acknowledge 1 deep, clean breath in your lungs'),

              const SizedBox(height: 30),

              // Return Home Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                  label: Text(
                    isTamil ? 'வெற்றியுடன் திரும்பு' : 'I Outlasted the Craving • Return Home',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
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

  Widget _buildGroundingItem(String number, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightCardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.skyBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.skyBlue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
