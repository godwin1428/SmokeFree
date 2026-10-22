import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smokefree/models/daily_checkin_result.dart';
import 'package:smokefree/providers/patient_provider.dart';
import 'package:smokefree/services/ai_behavioral_service.dart';
import 'package:smokefree/theme/app_colors.dart';

class MotivationPillarDetailScreen extends StatefulWidget {
  final MotivationPillar pillar;

  const MotivationPillarDetailScreen({super.key, required this.pillar});

  @override
  State<MotivationPillarDetailScreen> createState() => _MotivationPillarDetailScreenState();
}

class _MotivationPillarDetailScreenState extends State<MotivationPillarDetailScreen> {
  MotivationTimeframe _selectedTimeframe = MotivationTimeframe.today;
  int _cravingIntensity = 5;
  String _userMood = 'Stressed';
  bool _claimedCurrentAction = false;

  @override
  Widget build(BuildContext context) {
    final patient = Provider.of<PatientProvider>(context);
    final isTamil = patient.isTamil;

    if (patient.currentCravingAi != null && _cravingIntensity == 5) {
      _cravingIntensity = patient.currentCravingAi!.intensity;
    }

    final color = _getPillarColor();
    final content = AIBehavioralService().generateMotivationContent(
      pillar: widget.pillar,
      timeframe: _selectedTimeframe,
      cravingIntensity: _cravingIntensity,
      mood: _userMood,
      smokeFreeDays: patient.days,
      moneySaved: patient.moneySaved,
      wishlistName: patient.wishlistName,
      wishlistTarget: patient.wishlistTarget,
      isTamil: isTamil,
    );

    final activityKey = 'motivation_detail_${widget.pillar.name}_${_selectedTimeframe.name}';
    final isCooldown = patient.isActivityOnCooldown(activityKey, cooldown: const Duration(minutes: 30));
    final cooldownRemainingStr = patient.getFormattedRemainingCooldown(activityKey, cooldown: const Duration(minutes: 30));
    final isActionDisabled = _claimedCurrentAction || isCooldown;

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
          _getPillarTitle(isTamil),
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  '${patient.points} Pts',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
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
              // Segmented Control (Today | 1 Week | 1 Month)
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildTimeframePill(MotivationTimeframe.today, isTamil ? 'இன்று' : 'Today', Icons.today_rounded, color),
                    _buildTimeframePill(MotivationTimeframe.oneWeek, isTamil ? '1 வாரம்' : '1 Week', Icons.date_range_rounded, color),
                    _buildTimeframePill(MotivationTimeframe.oneMonth, isTamil ? '1 மாதம்' : '1 Month', Icons.calendar_month_rounded, color),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Main Motivational Pillar Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_getPillarIcon(), color: color, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                content.headline,
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDeepTeal,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getTimeframeLabel(isTamil),
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Mantra Quote Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.format_quote_rounded, color: color, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              content.mantra,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
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
                    const SizedBox(height: 16),

                    // Psychological Insight
                    Text(
                      content.insight,
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark, height: 1.45),
                    ),
                    const SizedBox(height: 18),

                    // Metric pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.lightCardBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            content.impactMetricLabel,
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                          ),
                          Text(
                            content.impactMetricValue,
                            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: color),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Bullets
                    Text(
                      isTamil ? 'செயல் தந்திரங்கள்:' : 'Actionable Guidelines:',
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDeepTeal),
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
                    const SizedBox(height: 20),

                    // Active Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          isActionDisabled ? Icons.check_circle_rounded : Icons.star_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(
                          isActionDisabled
                              ? (isCooldown
                                  ? (isTamil ? 'செயலில் உள்ளது ($cooldownRemainingStr)' : 'Claimed (Cooldown: $cooldownRemainingStr)')
                                  : (isTamil ? 'உறுதி செய்யப்பட்டது (+${content.pointsReward} Pts)' : 'Claimed (+${content.pointsReward} Pts)'))
                              : (isTamil ? 'செயல்படுத்து & புள்ளிகள் பெறு (+${content.pointsReward} Pts)' : 'Apply & Claim (+${content.pointsReward} Pts)'),
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActionDisabled ? (isCooldown ? AppColors.textMuted : AppColors.mintFresh) : color,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                              ? 'புள்ளிகள் சேர்க்கப்பட்டன (+${content.pointsReward} Pts)!'
                                              : 'Points awarded (+${content.pointsReward} Pts)!')
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframePill(MotivationTimeframe timeframe, String label, IconData icon, Color activeColor) {
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
              Icon(icon, size: 14, color: isSelected ? activeColor : AppColors.textMuted),
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

  Color _getPillarColor() {
    switch (widget.pillar) {
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
    switch (widget.pillar) {
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

  String _getPillarTitle(bool isTamil) {
    switch (widget.pillar) {
      case MotivationPillar.selfMotivation:
        return isTamil ? 'சுய உந்துதல்' : 'Self Motivation';
      case MotivationPillar.leverage:
        return isTamil ? 'முன்னேற்றம் & நிதி' : 'Leverage & Value';
      case MotivationPillar.seduction:
        return isTamil ? 'ஆபத்து ரேடார்' : 'Seduction Defense';
      case MotivationPillar.social:
        return isTamil ? 'சமூக எல்லை' : 'Social Shield';
    }
  }

  String _getTimeframeLabel(bool isTamil) {
    switch (_selectedTimeframe) {
      case MotivationTimeframe.today:
        return isTamil ? 'இன்றைய உடனடி வழிகாட்டி' : 'Today’s Immediate Focus';
      case MotivationTimeframe.oneWeek:
        return isTamil ? '1 வார கூட்டு முன்னேற்றம்' : '1-Week Compounding Focus';
      case MotivationTimeframe.oneMonth:
        return isTamil ? '1 மாத வாழ்நாள் மாற்றம்' : '1-Month Transformation Focus';
    }
  }
}
