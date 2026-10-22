import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smokefree/providers/patient_provider.dart';
import 'package:smokefree/abs.dart';
import 'package:smokefree/comp.dart';
import 'package:smokefree/ip.dart';
import 'package:smokefree/theme/app_colors.dart';

class DailyQuePage extends StatefulWidget {
  const DailyQuePage({super.key});

  @override
  _DailyQuePageState createState() => _DailyQuePageState();
}

class _DailyQuePageState extends State<DailyQuePage> {
  int selectedMoodIndex = -1;
  int selectedScale = -1;

  final List<Map<String, dynamic>> _moods = [
    {
      'labelEn': 'Joyful',
      'labelTa': 'மகிழ்ச்சி',
      'icon': Icons.sentiment_very_satisfied_rounded,
      'color': AppColors.mintFresh,
      'asset': 'assets/e1.png',
    },
    {
      'labelEn': 'Calm',
      'labelTa': 'அமைதி',
      'icon': Icons.sentiment_satisfied_rounded,
      'color': AppColors.skyBlue,
      'asset': 'assets/e2.png',
    },
    {
      'labelEn': 'Neutral',
      'labelTa': 'சாதாரண',
      'icon': Icons.sentiment_neutral_rounded,
      'color': AppColors.amberGold,
      'asset': 'assets/e3.png',
    },
    {
      'labelEn': 'Anxious',
      'labelTa': 'கவலை',
      'icon': Icons.sentiment_dissatisfied_rounded,
      'color': AppColors.coralRed,
      'asset': 'assets/e4.png',
    },
    {
      'labelEn': 'Frustrated',
      'labelTa': 'விரக்தி',
      'icon': Icons.sentiment_very_dissatisfied_rounded,
      'color': const Color(0xFFD90429),
      'asset': 'assets/e5.png',
    },
  ];

  final List<Map<String, dynamic>> _cravingScales = [
    {'level': 1, 'descEn': 'Minimal', 'descTa': 'மிகக்குறைவு', 'color': AppColors.mintFresh},
    {'level': 2, 'descEn': 'Mild', 'descTa': 'லேசான', 'color': const Color(0xFF64DFDF)},
    {'level': 3, 'descEn': 'Moderate', 'descTa': 'மிதமான', 'color': AppColors.amberGold},
    {'level': 4, 'descEn': 'Strong', 'descTa': 'அதிகம்', 'color': const Color(0xFFF77F00)},
    {'level': 5, 'descEn': 'Intense', 'descTa': 'தீவிரம்', 'color': AppColors.coralRed},
  ];

  bool _isFormValid() {
    return selectedMoodIndex != -1 && selectedScale != -1;
  }

  void _showWarningMessage(BuildContext context) {
    final isTamil = lang == '1';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isTamil
              ? 'தயவுசெய்து மனநிலை மற்றும் ஆசை அளவு இரண்டையும் தேர்ந்தெடுக்கவும்.'
              : 'Please select both your mood and craving level before proceeding.',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: AppColors.coralRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = Provider.of<PatientProvider>(context);
    final isTamil = patient.isTamil;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isTamil ? 'தினசரி சிந்தனை' : 'Daily Reflection',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withValues(alpha: 0.25),
                      blurRadius: 15,
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
                          Text(
                            isTamil ? 'இன்றைய மனநிலை பதிவு' : 'Mindful Daily Check-in',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isTamil
                                ? 'உங்கள் பதிவுகள் AI மருத்துவ ஆலோசனையை நிகழ்நேரத்தில் புதுப்பிக்கும்.'
                                : 'Your check-in directly calibrates your AI cessation protocol and threat index.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      'assets/dly.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.1, end: 0),

              const SizedBox(height: 24),

              // Question 1: Mood Selection
              _buildSectionTitle(
                isTamil ? '1. இன்றைய உங்கள் மனநிலை என்ன?' : '1. How are you feeling today?',
                Icons.mood_rounded,
              ),
              const SizedBox(height: 12),
              _buildMoodSelector(isTamil),

              const SizedBox(height: 28),

              // Question 2: Craving Scale
              _buildSectionTitle(
                isTamil ? '2. இன்றைய உங்கள் ஆசை அளவு (1 - 5)?' : '2. How intense is your craving urge (1 - 5)?',
                Icons.speed_rounded,
              ),
              const SizedBox(height: 12),
              _buildCravingScaleSelector(isTamil),

              const SizedBox(height: 28),

              // Question 3: Smoke-Free Day Confirmation
              _buildSectionTitle(
                isTamil ? '3. இன்று புகைபிடிக்காமல் இருந்தீர்களா?' : '3. Have you stayed smoke-free today?',
                Icons.health_and_safety_rounded,
              ),
              const SizedBox(height: 14),
              _buildConfirmationCards(context, isTamil),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryTeal, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDeepTeal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodSelector(bool isTamil) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightCardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_moods.length, (index) {
          final isSelected = selectedMoodIndex == index;
          final mood = _moods[index];
          final label = isTamil ? mood['labelTa'] : mood['labelEn'];

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedMoodIndex = index;
                });
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected ? (mood['color'] as Color).withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? (mood['color'] as Color) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? (mood['color'] as Color) : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        mood['asset'] as String,
                        width: 28,
                        height: 28,
                        errorBuilder: (_, __, ___) => Icon(
                          mood['icon'] as IconData,
                          color: isSelected ? Colors.white : mood['color'] as Color,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.primaryDeepTeal : AppColors.textMuted,
                        ),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCravingScaleSelector(bool isTamil) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightCardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_cravingScales.length, (index) {
              final scale = _cravingScales[index];
              final level = scale['level'] as int;
              final isSelected = selectedScale == level;
              final color = scale['color'] as Color;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedScale = level;
                    });
                    HapticFeedback.selectionClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? color : AppColors.lightCardBorder,
                        width: 2,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: color.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$level',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (selectedScale != -1) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: (_cravingScales[selectedScale - 1]['color'] as Color).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Intensity: ${_cravingScales[selectedScale - 1][isTamil ? 'descTa' : 'descEn']} Urge',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _cravingScales[selectedScale - 1]['color'] as Color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmationCards(BuildContext context, bool isTamil) {
    return Row(
      children: [
        // YES Card (Smoke Free!)
        Expanded(
          child: InkWell(
            onTap: () {
              if (_isFormValid()) {
                final mood = _moods[selectedMoodIndex]['labelEn'] as String;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AbsPage(
                      selectedMood: mood,
                      cravingScale: selectedScale,
                    ),
                  ),
                );
              } else {
                _showWarningMessage(context);
              }
            },
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.mintFresh.withValues(alpha: 0.12),
                    AppColors.primaryTeal.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.mintFresh, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mintFresh.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.mintFresh,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 22),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isTamil ? 'ஆம், புகைக்கவில்லை!' : 'Yes, Smoke-Free!',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDeepTeal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isTamil ? '+50 புள்ளிகள் பெறுங்கள்' : '+50 Points Reward',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mintFresh,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // NO Card (Had a Slip)
        Expanded(
          child: InkWell(
            onTap: () {
              if (_isFormValid()) {
                final mood = _moods[selectedMoodIndex]['labelEn'] as String;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CompPage(
                      selectedMood: mood,
                      cravingScale: selectedScale,
                    ),
                  ),
                );
              } else {
                _showWarningMessage(context);
              }
            },
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9F5),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.amberGold.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.amberGold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.replay, color: AppColors.amberGold, size: 22),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isTamil ? 'சறுக்கல் ஏற்பட்டது' : 'I Had a Slip',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDeepTeal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isTamil ? 'AI மீட்பு உதவி பெறுங்கள்' : 'AI Resilience Shield',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.amberGold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
