import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smokefree/ip.dart';
import 'package:smokefree/models/daily_checkin_result.dart';
import 'package:smokefree/providers/patient_provider.dart';
import 'package:smokefree/theme/app_colors.dart';

class Biweekly extends StatefulWidget {
  final String username;
  final String ind;

  Biweekly({super.key, String? username, String? ind})
      : username = username ?? userid,
        ind = ind ?? user_ind;

  @override
  _BiweeklyState createState() => _BiweeklyState();
}

class _BiweeklyState extends State<Biweekly> {
  // Store selected option index for each question (0-based)
  int? _q1Index;
  int? _q2Index;
  int? _q3Index;
  int? _q4Index;
  int? _q5Index;
  int? _q6Index;

  bool _isSubmitting = false;

  // Definitions for all 6 FTND questions
  final List<Map<String, dynamic>> _questions = [
    {
      'id': 1,
      'icon': Icons.wb_sunny_rounded,
      'titleEn': 'How soon after waking up do you smoke your first cigarette?',
      'titleTa': 'காலையில் விழித்த பிறகு எவ்வளவு சீக்கிரம் முதல் சிகரெட் புகைப்பீர்கள்?',
      'subtitleEn': 'Tests physical morning nicotine dependency surge',
      'subtitleTa': 'காலை நேர நிகோடின் சார்பு தீவிரத்தை மதிப்பிடுகிறது',
      'options': [
        {'en': 'Within 5 minutes', 'ta': '5 நிமிடங்களுக்குள்', 'pts': 3},
        {'en': '5 - 30 minutes', 'ta': '5 - 30 நிமிடங்கள்', 'pts': 2},
        {'en': '31 - 60 minutes', 'ta': '31 - 60 நிமிடங்கள்', 'pts': 1},
      ],
    },
    {
      'id': 2,
      'icon': Icons.not_interested_rounded,
      'titleEn': 'Do you find it difficult to refrain from smoking in forbidden places?',
      'titleTa': 'தடைசெய்யப்பட்ட இடங்களில் புகைபிடிப்பதைத் தவிர்ப்பது உங்களுக்கு கடினமாக இருக்கிறதா?',
      'subtitleEn': 'e.g. hospitals, cinema, buses, workplaces',
      'subtitleTa': 'எ.கா. மருத்துவமனை, பேருந்து, திரையரங்கம்',
      'options': [
        {'en': 'Yes', 'ta': 'ஆம்', 'pts': 1},
        {'en': 'No', 'ta': 'இல்லை', 'pts': 0},
      ],
    },
    {
      'id': 3,
      'icon': Icons.alarm_on_rounded,
      'titleEn': 'Which cigarette would you hate to give up the most?',
      'titleTa': 'எந்த சிகரெட்டை கைவிடுவதை நீங்கள் மிகவும் கடினமாக உணர்கிறீர்கள்?',
      'subtitleEn': 'Identifies key neural reward cues in your routine',
      'subtitleTa': 'உங்கள் அன்றாட பழக்கவழக்க தூண்டுதலை அறிய',
      'options': [
        {'en': 'The first in the morning', 'ta': 'காலையின் முதல் சிகரெட்', 'pts': 1},
        {'en': 'Any other', 'ta': 'மற்றவை', 'pts': 0},
      ],
    },
    {
      'id': 4,
      'icon': Icons.smoke_free_rounded,
      'titleEn': 'How many cigarettes a day do you smoke?',
      'titleTa': 'ஒரு நாளைக்கு எத்தனை சிகரெட் புகைக்கிறீர்கள்?',
      'subtitleEn': 'Measures baseline daily toxicant exposure',
      'subtitleTa': 'தினசரி புகைபிடிக்கும் அளவை கணக்கிட',
      'options': [
        {'en': '10 or less', 'ta': '10 அல்லது குறைவாக', 'pts': 0},
        {'en': '11 - 20', 'ta': '11 - 20', 'pts': 1},
        {'en': '21 - 30', 'ta': '21 - 30', 'pts': 2},
        {'en': '31 or more', 'ta': '31 அல்லது அதற்கு மேல்', 'pts': 3},
      ],
    },
    {
      'id': 5,
      'icon': Icons.coffee_rounded,
      'titleEn': 'Do you smoke more frequently during the morning hours?',
      'titleTa': 'நீங்கள் காலையில் மற்ற நேரங்களை விட அடிக்கடி புகைப்பிடிப்பீர்களா?',
      'subtitleEn': 'Peak nicotine level restoration pattern',
      'subtitleTa': 'காலை நேர அடிக்ஷன் வேகம்',
      'options': [
        {'en': 'Yes', 'ta': 'ஆம்', 'pts': 1},
        {'en': 'No', 'ta': 'இல்லை', 'pts': 0},
      ],
    },
    {
      'id': 6,
      'icon': Icons.local_hospital_rounded,
      'titleEn': 'Do you smoke even if you are sick in bed most of the day?',
      'titleTa': 'உடல்நிலை சரியில்லாமல் படுக்கையில் இருக்கும் போதும் புகைப்பிடிப்பீர்களா?',
      'subtitleEn': 'Measures compulsive physical compulsion over physiological discomfort',
      'subtitleTa': 'உடல் உபாதையை மீறிய நிகோடின் தேவை',
      'options': [
        {'en': 'Yes', 'ta': 'ஆம்', 'pts': 1},
        {'en': 'No', 'ta': 'இல்லை', 'pts': 0},
      ],
    },
  ];

  int get _answeredCount {
    int count = 0;
    if (_q1Index != null) count++;
    if (_q2Index != null) count++;
    if (_q3Index != null) count++;
    if (_q4Index != null) count++;
    if (_q5Index != null) count++;
    if (_q6Index != null) count++;
    return count;
  }

  int _calculateScore() {
    if (_answeredCount < 6) return -1;
    int score = 0;
    score += (_questions[0]['options'] as List)[_q1Index!]['pts'] as int;
    score += (_questions[1]['options'] as List)[_q2Index!]['pts'] as int;
    score += (_questions[2]['options'] as List)[_q3Index!]['pts'] as int;
    score += (_questions[3]['options'] as List)[_q4Index!]['pts'] as int;
    score += (_questions[4]['options'] as List)[_q5Index!]['pts'] as int;
    score += (_questions[5]['options'] as List)[_q6Index!]['pts'] as int;
    return score;
  }

  int? _getIndexForQuestion(int qId) {
    switch (qId) {
      case 1:
        return _q1Index;
      case 2:
        return _q2Index;
      case 3:
        return _q3Index;
      case 4:
        return _q4Index;
      case 5:
        return _q5Index;
      case 6:
        return _q6Index;
      default:
        return null;
    }
  }

  void _setIndexForQuestion(int qId, int index) {
    HapticFeedback.selectionClick();
    setState(() {
      switch (qId) {
        case 1:
          _q1Index = index;
          break;
        case 2:
          _q2Index = index;
          break;
        case 3:
          _q3Index = index;
          break;
        case 4:
          _q4Index = index;
          break;
        case 5:
          _q5Index = index;
          break;
        case 6:
          _q6Index = index;
          break;
      }
    });
  }

  Future<void> _sendScore(int score) async {
    String url = "";
    if (int.tryParse(user_ind) != null && int.tryParse(user_ind)! > 11) {
      url = "${ip}biweek.php";
    } else {
      url = "${ip}bwk$user_ind.php";
    }

    final String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final requestBody = jsonEncode({
      'username': userid,
      'bwk': score,
      'bwk_dt': formattedDate,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to submit score. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Biweekly server sync note: $e");
    }
  }

  Future<void> _handleSubmit() async {
    final score = _calculateScore();
    final isTamil = Provider.of<PatientProvider>(context, listen: false).isTamil;

    if (score == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isTamil
                ? 'அனைத்து 6 கேள்விகளுக்கும் பதிலளிக்கவும்!'
                : 'Please answer all 6 clinical questions before submitting.',
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

    try {
      await _sendScore(score);

      // Trigger AI Clinical Biweekly Synthesis
      final provider = Provider.of<PatientProvider>(context, listen: false);
      final report = await provider.submitBiweeklyAudit(slipsLogged: score < 5 ? 0 : 1);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      _showResultDialog(score, report);
    } catch (e) {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _getDependenceLevel(int score, bool isTamil) {
    if (score <= 2) {
      return isTamil ? 'மிகக் குறைந்த சார்பு (குணமடையும் நிலை)' : 'Very Low Dependence (Optimal)';
    } else if (score <= 4) {
      return isTamil ? 'குறைந்த சார்பு' : 'Low Dependence';
    } else if (score <= 6) {
      return isTamil ? 'மிதமான சார்பு' : 'Moderate Dependence';
    } else if (score <= 8) {
      return isTamil ? 'அதிக சார்பு' : 'High Dependence';
    } else {
      return isTamil ? 'மிக அதிக சார்பு (கவனம் தேவை)' : 'Very High Dependence (Clinical Attention)';
    }
  }

  Color _getDependenceColor(int score) {
    if (score <= 2) return AppColors.mintFresh;
    if (score <= 4) return AppColors.skyBlue;
    if (score <= 6) return AppColors.amberGold;
    return AppColors.coralRed;
  }

  void _showResultDialog(int score, AIBiweeklyReport report) {
    final isTamil = Provider.of<PatientProvider>(context, listen: false).isTamil;
    final depLevel = _getDependenceLevel(score, isTamil);
    final depColor = _getDependenceColor(score);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          contentPadding: const EdgeInsets.all(24),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isTamil ? 'AI மருத்துவ அறிக்கை' : 'AI Biweekly Health Audit',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDeepTeal,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Score Gauge Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: depColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: depColor, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isTamil ? 'FTND சார்பு மதிப்பீடு' : 'FTND Dependence Score',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$score',
                            style: GoogleFonts.outfit(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: depColor,
                            ),
                          ),
                          Text(
                            ' / 10',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        depLevel,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: depColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Clinical Summary Text
                Text(
                  report.patientProgressSummary,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.45,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),

                // Recovery Metrics Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.lightCardBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.air, size: 16, color: AppColors.primaryTeal),
                              const SizedBox(width: 6),
                              Text(
                                isTamil ? 'இருமல் தணிப்பு:' : 'Cough Reduction:',
                                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          Text(
                            '${report.coughReductionPercent}%',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: AppColors.successGreen,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bedtime_outlined, size: 16, color: AppColors.skyBlue),
                              const SizedBox(width: 6),
                              Text(
                                isTamil ? 'தூக்க தரம் முன்னேற்றம்:' : 'Sleep Quality Boost:',
                                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          Text(
                            '+${report.sleepImprovementPercent}%',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: AppColors.mintFresh,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Telemetry status
                Row(
                  children: [
                    const Icon(Icons.verified, size: 16, color: AppColors.primaryTeal),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isTamil
                            ? 'மருத்துவர் பார்வைக்கு உடனடியாக புதுப்பிக்கப்பட்டது.'
                            : 'Synchronized with doctor clinical dashboard.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSubtle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // dismiss dialog
                  Navigator.of(context).pop(); // back to dashboard
                },
                child: Text(
                  isTamil ? 'முகப்புக்கு செல்' : 'Return to Dashboard',
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = Provider.of<PatientProvider>(context);
    final isTamil = patient.isTamil;
    final progress = _answeredCount / 6.0;

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
          isTamil ? 'இருவார மருத்துவ ஆய்வு' : 'Biweekly Health Audit',
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
              color: AppColors.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.biotech, size: 14, color: AppColors.primaryTeal),
                const SizedBox(width: 4),
                Text(
                  'FTND Scale',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Clinical Banner
                    _buildHeroBanner(isTamil),
                    const SizedBox(height: 20),

                    // Progress Tracker Card
                    _buildProgressCard(isTamil, progress),
                    const SizedBox(height: 24),

                    // The 6 Question Cards
                    ..._questions.map((q) => _buildQuestionCard(q, isTamil)),

                    const SizedBox(height: 80), // padding for sticky bottom bar
                  ],
                ),
              ),
            ),

            // Bottom Sticky Submit Action
            _buildStickyBottomBar(isTamil),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(bool isTamil) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isTamil ? 'மருத்துவ மறுஆய்வு' : '14-Day Cycle Evaluation',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isTamil ? 'நிகோடின் சார்பு நிலை' : 'Nicotine Dependency Audit',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isTamil
                      ? 'இந்த 6 கேள்விகள் உங்கள் மூளையின் நிகோடின் தேவையை கணக்கிட்டு AI மருத்துவ ஆலோசனையை மாற்றிமைக்கும்.'
                      : 'Validated Fagerström (FTND) assessment to measure behavioral and physical dependency changes.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment_turned_in_rounded, color: Colors.white, size: 36),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildProgressCard(bool isTamil, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isTamil
                    ? 'முன்னேற்றம்: $_answeredCount / 6 பதிலளிக்கப்பட்டது'
                    : 'Progress: $_answeredCount of 6 Answered',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDeepTeal,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mintFresh),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          // Question jump dots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final isDone = _getIndexForQuestion(index + 1) != null;
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.mintFresh : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone ? AppColors.mintFresh : AppColors.lightCardBorder,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                        '${index + 1}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                        ),
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> q, bool isTamil) {
    final int qId = q['id'] as int;
    final int? selectedIndex = _getIndexForQuestion(qId);
    final String title = isTamil ? q['titleTa'] as String : q['titleEn'] as String;
    final String subtitle = isTamil ? q['subtitleTa'] as String : q['subtitleEn'] as String;
    final List options = q['options'] as List;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selectedIndex != null ? AppColors.primaryTeal.withValues(alpha: 0.3) : AppColors.lightCardBorder,
          width: selectedIndex != null ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(q['icon'] as IconData, size: 14, color: AppColors.primaryTeal),
                    const SizedBox(width: 4),
                    Text(
                      'Q$qId',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (selectedIndex != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.mintFresh.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.mintFresh),
                      const SizedBox(width: 4),
                      Text(
                        isTamil ? 'தேர்வு செய்யப்பட்டது' : 'Answered',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mintFresh,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Question Title
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDeepTeal,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSubtle,
            ),
          ),
          const SizedBox(height: 14),

          // Selectable Options (Replacing deprecated Radio widgets)
          ...List.generate(options.length, (optIndex) {
            final opt = options[optIndex];
            final isSelected = selectedIndex == optIndex;
            final String optLabel = isTamil ? opt['ta'] as String : opt['en'] as String;

            return GestureDetector(
              onTap: () => _setIndexForQuestion(qId, optIndex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryTeal.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryTeal : AppColors.lightCardBorder,
                    width: isSelected ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 20,
                      height: 20,
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
                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        optLabel,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? AppColors.primaryDeepTeal : AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(bool isTamil) {
    final isComplete = _answeredCount == 6;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isTamil ? 'மொத்த வினாக்கள்' : 'Questions',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSubtle),
                ),
                Text(
                  '$_answeredCount / 6 ${isTamil ? "முடித்தவை" : "Completed"}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isComplete ? AppColors.successGreen : AppColors.primaryDeepTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: isComplete ? 4 : 0,
                    shadowColor: AppColors.primaryTeal.withValues(alpha: 0.4),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: isComplete
                          ? AppColors.primaryGradient
                          : LinearGradient(
                              colors: [Colors.grey.shade400, Colors.grey.shade500],
                            ),
                      borderRadius: BorderRadius.circular(16),
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
                                  isTamil ? 'பதிவு செய்' : 'Submit Audit',
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
            ),
          ],
        ),
      ),
    );
  }
}
