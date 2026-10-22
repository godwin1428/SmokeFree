import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smokefree/models/daily_checkin_result.dart';
import 'package:smokefree/providers/patient_provider.dart';
import 'package:smokefree/services/ai_behavioral_service.dart';
import 'package:smokefree/theme/app_colors.dart';

class Motivation extends StatefulWidget {
  const Motivation({super.key});

  @override
  State<Motivation> createState() => _MotivationState();
}

class _MotivationState extends State<Motivation> {
  MotivationPillar _selectedPillar = MotivationPillar.selfMotivation;
  MotivationTimeframe _selectedTimeframe = MotivationTimeframe.today;
  int _cravingIntensity = 5;
  String _userMood = 'Stressed';
  bool _claimedCurrentAction = false;

  final List<String> _moodOptions = ['Stressed', 'Anxious', 'Calm', 'Happy', 'Bored', 'Tired'];

  @override
  Widget build(BuildContext context) {
    final patient = Provider.of<PatientProvider>(context);
    final isTamil = patient.isTamil;

    // Synchronize initial craving intensity from provider if available
    if (patient.currentCravingAi != null && _cravingIntensity == 5) {
      _cravingIntensity = patient.currentCravingAi!.intensity;
    }

    final content = AIBehavioralService().generateMotivationContent(
      pillar: _selectedPillar,
      timeframe: _selectedTimeframe,
      cravingIntensity: _cravingIntensity,
      mood: _userMood,
      smokeFreeDays: patient.days,
      moneySaved: patient.moneySaved,
      wishlistName: patient.wishlistName,
      wishlistTarget: patient.wishlistTarget,
      isTamil: isTamil,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isTamil ? 'AI உந்துதல் & நடத்தை மையம்' : 'AI Behavioral Motivation Hub',
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
                const Icon(Icons.bolt_rounded, size: 16, color: AppColors.mintFresh),
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
              // Top Adaptive State Context Bar
              _buildContextBar(isTamil, patient),
              const SizedBox(height: 16),

              // Time Horizon Segmented Control (Today | 1 Week | 1 Month)
              _buildTimeframeSegmentedControl(isTamil),
              const SizedBox(height: 16),

              // 4 Motivation Pillars Selector
              _buildPillarTabs(isTamil),
              const SizedBox(height: 16),

              // Main Dynamic AI Motivational Content Card
              _buildMainMotivationCard(isTamil, content),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContextBar(bool isTamil, PatientProvider patient) {
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.psychology_outlined, color: AppColors.primaryTeal, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isTamil ? 'நடத்தை நிலை (செக்-இன் & ஆசை)' : 'Behavioral State Anchor',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDeepTeal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getIntensityColor().withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _cravingIntensity <= 3
                      ? (isTamil ? 'ஆசை: லேசானது' : 'Urge: Low (1-3)')
                      : _cravingIntensity <= 6
                          ? (isTamil ? 'ஆசை: மிதமானது' : 'Urge: Moderate (4-6)')
                          : (isTamil ? 'ஆசை: தீவிரமானது' : 'Urge: High (7-10)'),
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getIntensityColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTamil ? 'மனநிலை:' : 'Daily Mood:',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _userMood,
                        isDense: true,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryTeal, size: 18),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDeepTeal,
                        ),
                        items: _moodOptions.map((mood) {
                          return DropdownMenuItem<String>(
                            value: mood,
                            child: Text(mood),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _userMood = val;
                              _claimedCurrentAction = false;
                            });
                            HapticFeedback.selectionClick();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isTamil ? 'ஆசை தீவிரம்:' : 'Craving Level:',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                        ),
                        Text(
                          '$_cravingIntensity / 10',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getIntensityColor(),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: _getIntensityColor(),
                        thumbColor: _getIntensityColor(),
                        overlayColor: _getIntensityColor().withValues(alpha: 0.15),
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      ),
                      child: Slider(
                        value: _cravingIntensity.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (val) {
                          setState(() {
                            _cravingIntensity = val.round();
                            _claimedCurrentAction = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSegmentedControl(bool isTamil) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTimeframePill(
            MotivationTimeframe.today,
            isTamil ? 'இன்று' : 'Today',
            Icons.today_rounded,
          ),
          _buildTimeframePill(
            MotivationTimeframe.oneWeek,
            isTamil ? '1 வாரம்' : '1 Week',
            Icons.date_range_rounded,
          ),
          _buildTimeframePill(
            MotivationTimeframe.oneMonth,
            isTamil ? '1 மாதம்' : '1 Month',
            Icons.calendar_month_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframePill(MotivationTimeframe timeframe, String label, IconData icon) {
    final isSelected = _selectedTimeframe == timeframe;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTimeframe = timeframe;
            _claimedCurrentAction = false;
          });
          HapticFeedback.selectionClick();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.primaryTeal : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.primaryDeepTeal : AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillarTabs(bool isTamil) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPillarTabItem(
                pillar: MotivationPillar.selfMotivation,
                title: isTamil ? 'சுய உந்துதல்' : 'Self Motivation',
                icon: Icons.psychology_rounded,
                color: AppColors.primaryTeal,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPillarTabItem(
                pillar: MotivationPillar.leverage,
                title: isTamil ? 'முன்னேற்றம்' : 'Leverage',
                icon: Icons.trending_up_rounded,
                color: AppColors.amberGold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPillarTabItem(
                pillar: MotivationPillar.seduction,
                title: isTamil ? 'ஆபத்து ரேடார்' : 'Seduction',
                icon: Icons.radar_rounded,
                color: AppColors.coralRed,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPillarTabItem(
                pillar: MotivationPillar.social,
                title: isTamil ? 'சமூகக் கவசம்' : 'Social Shield',
                icon: Icons.diversity_3_rounded,
                color: AppColors.skyBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPillarTabItem({
    required MotivationPillar pillar,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedPillar == pillar;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPillar = pillar;
          _claimedCurrentAction = false;
        });
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.lightCardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMotivationCard(bool isTamil, MotivationContent content) {
    final color = _getPillarColor();
    final patient = Provider.of<PatientProvider>(context);
    final activityKey = 'motivation_${_selectedPillar.name}_${_selectedTimeframe.name}';
    final isCooldown = patient.isActivityOnCooldown(activityKey, cooldown: const Duration(minutes: 30));
    final cooldownRemainingStr = patient.getFormattedRemainingCooldown(activityKey, cooldown: const Duration(minutes: 30));
    final isActionDisabled = _claimedCurrentAction || isCooldown;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getPillarIcon(), color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPillarName(isTamil),
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                    Text(
                      _getTimeframeLabel(isTamil),
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  content.impactMetricValue,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Headline
          Text(
            content.headline,
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDeepTeal,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Core Mantra Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.format_quote_rounded, color: color, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    content.mantra,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDeepTeal,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Deep Behavioral Insight
          Text(
            content.insight,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppColors.textDark,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),

          // Key Bullets Takeaways
          Text(
            isTamil ? 'முக்கிய உந்துதல் உண்மைகள்:' : 'Key Motivational Pillars:',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDeepTeal,
            ),
          ),
          const SizedBox(height: 8),
          ...content.keyBullets.map((bullet) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, size: 10, color: color),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        bullet,
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark, height: 1.35),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),

          // Action Directive Box & Claim Button
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightCardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt_rounded, size: 16, color: AppColors.amberGold),
                    const SizedBox(width: 6),
                    Text(
                      isTamil ? 'இன்றைய இலக்கு செயல்பாடு:' : 'Active Challenge for this Timeframe:',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  content.actionStep,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark, height: 1.35),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    icon: Icon(
                      isActionDisabled ? Icons.check_circle_rounded : Icons.star_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isActionDisabled
                            ? (isCooldown
                                ? (isTamil ? 'செயலில் உள்ளது ($cooldownRemainingStr)' : 'Claimed (Cooldown: $cooldownRemainingStr)')
                                : (isTamil ? 'உறுதி செய்யப்பட்டது (+${content.pointsReward} Pts)' : 'Claimed (+${content.pointsReward} Pts)'))
                            : (isTamil ? 'செயல்படுத்து & புள்ளிகள் பெறு (+${content.pointsReward} Pts)' : 'Apply & Claim (+${content.pointsReward} Pts)'),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActionDisabled ? (isCooldown ? AppColors.textMuted : AppColors.mintFresh) : color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: isActionDisabled
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            final res = Provider.of<PatientProvider>(context, listen: false).addPoints(
                              content.pointsReward,
                              activityKey: activityKey,
                              cooldown: const Duration(minutes: 30),
                            );
                            setState(() => _claimedCurrentAction = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: res.awarded ? color : AppColors.amberGold,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                content: Text(
                                  res.awarded
                                      ? (isTamil
                                          ? 'உந்துதல் இலக்கு உறுதி செய்யப்பட்டது! (+${content.pointsReward} புள்ளிகள் சேர்க்கப்பட்டன)'
                                          : 'Motivation action verified! (+${content.pointsReward} Pts awarded)')
                                      : res.message,
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                ),
                              ),
                            );
                          },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Color _getIntensityColor() {
    if (_cravingIntensity <= 3) return AppColors.mintFresh;
    if (_cravingIntensity <= 6) return AppColors.amberGold;
    return AppColors.coralRed;
  }

  Color _getPillarColor() {
    switch (_selectedPillar) {
      case MotivationPillar.selfMotivation:
        return AppColors.primaryTeal;
      case MotivationPillar.leverage:
        return AppColors.amberGold;
      case MotivationPillar.seduction:
        return AppColors.coralRed;
      case MotivationPillar.social:
        return AppColors.skyBlue;
    }
  }

  IconData _getPillarIcon() {
    switch (_selectedPillar) {
      case MotivationPillar.selfMotivation:
        return Icons.psychology_rounded;
      case MotivationPillar.leverage:
        return Icons.trending_up_rounded;
      case MotivationPillar.seduction:
        return Icons.radar_rounded;
      case MotivationPillar.social:
        return Icons.diversity_3_rounded;
    }
  }

  String _getPillarName(bool isTamil) {
    switch (_selectedPillar) {
      case MotivationPillar.selfMotivation:
        return isTamil ? 'சுய உந்துதல்' : 'Self Motivation';
      case MotivationPillar.leverage:
        return isTamil ? 'முன்னேற்றம் & நிதி' : 'Leverage & Value';
      case MotivationPillar.seduction:
        return isTamil ? 'ஆபத்து ரேடார்' : 'Seduction & Risk Radar';
      case MotivationPillar.social:
        return isTamil ? 'சமூக எல்லை & ஆதரவு' : 'Social & Boundaries';
    }
  }

  String _getTimeframeLabel(bool isTamil) {
    switch (_selectedTimeframe) {
      case MotivationTimeframe.today:
        return isTamil ? 'இன்றைய இலக்கு' : 'Today’s Immediate Target';
      case MotivationTimeframe.oneWeek:
        return isTamil ? '1 வார கூட்டு முன்னேற்றம்' : '1-Week Compounding Milestone';
      case MotivationTimeframe.oneMonth:
        return isTamil ? '1 மாத வாழ்நாள் மாற்றம்' : '1-Month Transformation';
    }
  }
}
