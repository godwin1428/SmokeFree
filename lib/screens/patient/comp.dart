import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:smokefree/comp2.dart';
import 'package:smokefree/ip.dart';
import 'package:smokefree/models/daily_checkin_result.dart';
import 'package:smokefree/providers/patient_provider.dart';
import 'package:smokefree/theme/app_colors.dart';

class CompPage extends StatefulWidget {
  final String username;
  final int points;
  final String mon;
  final String mon_sav;
  final String rs;
  final String selectedMood;
  final int cravingScale;

  CompPage({
    super.key,
    String? username,
    int? points,
    String? mon,
    String? mon_sav,
    String? rs,
    this.selectedMood = 'Stressed',
    this.cravingScale = 4,
  })  : username = username ?? userid,
        points = points ?? (int.tryParse(user_pnts) ?? 0),
        mon = mon ?? user_mon,
        mon_sav = mon_sav ?? user_monsav,
        rs = rs ?? user_rs;

  @override
  _CompPageState createState() => _CompPageState();
}

class _CompPageState extends State<CompPage> {
  int _selectedCigaretteCount = 0;
  late int currentPoints;
  late double m, r, ms;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    currentPoints = widget.points;
    m = double.tryParse(widget.mon) ?? 0.0;
    r = double.tryParse(widget.rs) ?? 0.0;
    ms = double.tryParse(widget.mon_sav) ?? 0.0;
  }

  final List<Map<String, dynamic>> _slipTiers = [
    {
      'count': 1,
      'titleEn': '1 Cigarette',
      'titleTa': '1 சிகரெட்',
      'subtitleEn': 'Quick recovery slip. Minor dopamine blip.',
      'subtitleTa': 'லேசான சறுக்கல். உடனே மீண்டு விடலாம்.',
      'ptsImpact': '+25 Pts',
      'ptsColor': AppColors.mintFresh,
      'icon': Icons.filter_1_rounded,
    },
    {
      'count': 2,
      'titleEn': '2 - 4 Cigarettes',
      'titleTa': '2 - 4 சிகரெட்டுகள் (5 க்கும் குறைவு)',
      'subtitleEn': 'Mild lapse. Urge triggers need adjustment.',
      'subtitleTa': 'மிதமான சறுக்கல். தூண்டுதல்களை மாற்ற வேண்டும்.',
      'ptsImpact': '+10 Pts',
      'ptsColor': AppColors.skyBlue,
      'icon': Icons.filter_2_rounded,
    },
    {
      'count': 3,
      'titleEn': '5 - 10 Cigarettes',
      'titleTa': '5 - 10 சிகரெட்டுகள்',
      'subtitleEn': 'Moderate slip. Relapse guard protocol triggered.',
      'subtitleTa': 'மீட்பு வழிகாட்டி தேவைப்படுகிறது.',
      'ptsImpact': '+5 Pts',
      'ptsColor': AppColors.amberGold,
      'icon': Icons.filter_3_rounded,
    },
    {
      'count': 4,
      'titleEn': '10 - 15 Cigarettes',
      'titleTa': '10 - 15 சிகரெட்டுகள்',
      'subtitleEn': 'Heavy slip. Review social and stress triggers.',
      'subtitleTa': 'மன அழுத்தம் மற்றும் நண்பர்கள் சூழலை ஆய்வு செய்ய.',
      'ptsImpact': '0 Pts',
      'ptsColor': AppColors.textMuted,
      'icon': Icons.filter_4_rounded,
    },
    {
      'count': 5,
      'titleEn': 'More than 15 Cigarettes',
      'titleTa': '15 க்கும் மேற்பட்ட சிகரெட்டுகள்',
      'subtitleEn': 'Intense relapse risk. Doctor protocol alerted.',
      'subtitleTa': 'மருத்துவ தீவிர ஆலோசனை பரிந்துரைக்கப்படுகிறது.',
      'ptsImpact': '-5 Pts',
      'ptsColor': AppColors.coralRed,
      'icon': Icons.filter_5_rounded,
    },
  ];

  Future<void> _submitData() async {
    final isTamil = Provider.of<PatientProvider>(context, listen: false).isTamil;

    if (_selectedCigaretteCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isTamil ? 'சிகரெட் எண்ணிக்கையைத் தேர்ந்தெடுக்கவும்' : 'Please select the number of cigarettes smoked',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppColors.coralRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    int updatedPoints = currentPoints;
    double b = 0;

    if (_selectedCigaretteCount == 1) {
      updatedPoints += 25;
      b = m - r;
    } else if (_selectedCigaretteCount == 2) {
      updatedPoints += 10;
      b = m - (r * 5);
    } else if (_selectedCigaretteCount == 3) {
      updatedPoints += 5;
      b = m - (r * 10);
    } else if (_selectedCigaretteCount == 4) {
      b = m - (r * 15);
    } else if (_selectedCigaretteCount == 5) {
      updatedPoints = updatedPoints > 5 ? updatedPoints - 5 : 0;
      b = m - (r * 20);
    }

    final double newMonSav = (ms + b) <= 0 ? 0 : ms + b;
    final now = DateTime.now();
    final String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      final response = await http.post(
        Uri.parse("${ip}comp.php"),
        body: {
          'username': widget.username,
          'points': updatedPoints.toString(),
          'mon_sav': newMonSav.toString(),
          'log_dt': formattedDate,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody.toString().toLowerCase().contains("success")) {
          // Trigger AI Slip Recalibration
          final checkIn = DailyCheckIn(
            timestamp: DateTime.now(),
            mood: widget.selectedMood,
            cravingScale: widget.cravingScale,
            cigarettesSmoked: _selectedCigaretteCount,
            notes: 'Slip logged: Tier $_selectedCigaretteCount. Recalibrating behavioral coping plan.',
          );

          try {
            await Provider.of<PatientProvider>(context, listen: false).submitDailyCheckIn(checkIn);
          } catch (_) {}

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Comp2Page()),
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isTamil ? 'புள்ளிகள் புதுப்பித்தல் தோல்வி' : 'Points update failed on server.'),
                backgroundColor: AppColors.coralRed,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isTamil ? 'சர்வர் பிழை' : 'Server error: ${response.statusCode}'),
              backgroundColor: AppColors.coralRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.coralRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isTamil ? 'சறுக்கல் பகுப்பாய்வு' : 'Slip Calibration & Reset',
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
              // Compassionate Clinical Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF264653), Color(0xFF2A9D8F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF264653).withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.amberGold.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isTamil ? 'சறுக்கல் ஒரு முடிவு அல்ல' : 'Slips are Data, Not Defeat',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isTamil ? 'நேர்மையான பதிவு, விரைவான மீட்சி' : 'Honest Logging Protects You',
                            style: GoogleFonts.outfit(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isTamil
                                ? 'எண்ணிக்கையை நேர்மையாகப் பதிவு செய்யுங்கள். உடனடியாக ஒரு கவனச்சிதறல் உத்தியைத் தொடங்குவோம்.'
                                : 'Clinical data proves immediate honest logging halts full relapses. Your AI plan adjusts in real-time.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.replay_circle_filled_rounded, color: Colors.white, size: 34),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.1, end: 0),

              const SizedBox(height: 24),

              // Title for options
              Text(
                isTamil ? 'புகைத்த சிகரெட்டுகளின் எண்ணிக்கை:' : 'Select Cigarettes Smoked Today:',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDeepTeal,
                ),
              ),
              const SizedBox(height: 12),

              // Choice Cards (Replacing raw RadioListTiles)
              ..._slipTiers.map((tier) {
                final int count = tier['count'] as int;
                final bool isSelected = _selectedCigaretteCount == count;
                final String title = isTamil ? tier['titleTa'] as String : tier['titleEn'] as String;
                final String subtitle = isTamil ? tier['subtitleTa'] as String : tier['subtitleEn'] as String;
                final String ptsImpact = tier['ptsImpact'] as String;
                final Color ptsColor = tier['ptsColor'] as Color;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCigaretteCount = count);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryTeal.withValues(alpha: 0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryTeal : AppColors.lightCardBorder,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? AppColors.primaryTeal : Colors.white,
                            border: Border.all(
                              color: isSelected ? AppColors.primaryTeal : const Color(0xFFCBD5E1),
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: isSelected
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.primaryDeepTeal : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                subtitle,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textSubtle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: ptsColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            ptsImpact,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ptsColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Motivational Support Note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.psychology_rounded, color: AppColors.primaryTeal, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isTamil
                            ? "அடுத்ததாக கவனத்தை திசைதிருப்பும் மற்றும் அமைதிப்படுத்தும் பயிற்சி தொடங்கும்!"
                            : "Submitting unlocks an immediate cognitive distraction session to calm nicotine receptors.",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.primaryDeepTeal,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Submit Action Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitData,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: _selectedCigaretteCount > 0 ? 4 : 0,
                    shadowColor: AppColors.primaryTeal.withValues(alpha: 0.4),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: _selectedCigaretteCount > 0
                          ? AppColors.primaryGradient
                          : LinearGradient(
                              colors: [Colors.grey.shade400, Colors.grey.shade500],
                            ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isTamil ? 'மீட்புப் பயிற்சியைத் தொடங்கு' : 'Recalibrate & Begin Relief',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
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
}
