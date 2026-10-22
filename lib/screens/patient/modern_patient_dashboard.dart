import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/patient_provider.dart';
import '../../theme/app_colors.dart';
import '../cravings/craving_sos_screen.dart';
import '../cravings/ai_counselor_screen.dart';
import '../../daily_questions.dart';
import '../../biweekly.dart';
import '../../models/daily_checkin_result.dart';
import '../../ip.dart' as legacy;
import '../../motivation.dart';

class ModernPatientDashboard extends StatefulWidget {
  const ModernPatientDashboard({super.key});

  @override
  State<ModernPatientDashboard> createState() => _ModernPatientDashboardState();
}

class _ModernPatientDashboardState extends State<ModernPatientDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PatientProvider>(context, listen: false).fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final patient = Provider.of<PatientProvider>(context);
    final isTamil = patient.isTamil;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'aria_ai_counselor_fab',
        onPressed: () {
          HapticFeedback.selectionClick();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AICounselorScreen()),
          );
        },
        backgroundColor: AppColors.primaryTeal,
        icon: const Icon(Icons.smart_toy_rounded, color: Colors.white),
        label: Text(
          isTamil ? 'AI ஆலோசகர்' : 'Ask Aria AI',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, patient, isTamil),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Smoke-Free Live Ticker Card
                  _buildLiveTickerHeroCard(patient, isTamil),
                  const SizedBox(height: 16),

                  // 24/7 AI Cessation Counselor Banner (Aria)
                  _buildAiCounselorBanner(context, isTamil),
                  const SizedBox(height: 16),

                  // AI Daily Clinical Prescription Card
                  _buildAiClinicalPrescriptionCard(context, patient, isTamil),
                  const SizedBox(height: 16),

                  // SOS Craving Panic Island Button
                  _buildSosCravingBanner(context, isTamil),
                  const SizedBox(height: 16),

                  // AI Behavioral Motivation Hub Island Button
                  _buildMotivationHubBanner(context, isTamil),
                  const SizedBox(height: 16),

                  // Financial Savings & Regained Life Cards
                  _buildFinancialAndVitalityRow(patient, isTamil),
                  const SizedBox(height: 16),

                  // Savings Goal / Wishlist Tracker
                  _buildWishlistProgressCard(patient, isTamil),
                  const SizedBox(height: 20),

                  // Daily & Biweekly Assessment Tasks
                  _buildActionTasksSection(context, patient, isTamil),
                  const SizedBox(height: 20),

                  // Doctor's Clinical Message Banner
                  if (patient.doctorMessage.isNotEmpty)
                    _buildDoctorMessageCard(patient, isTamil),

                  const SizedBox(height: 20),

                  // Scientific Health Recovery Milestones Carousel
                  _buildHealthMilestonesSection(patient, isTamil),
                  const SizedBox(height: 80), // Bottom padding for navigation
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, PatientProvider patient, bool isTamil) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 80,
      pinned: true,
      backgroundColor: AppColors.primaryTeal,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.eco_rounded, color: AppColors.mintFresh, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SmokeFree',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    isTamil ? 'நல்வாழ்வு தளம்' : 'Cessation Companion',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Health Points Badge
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.amberGold,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.amberGold.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                '${patient.points} Pts',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),

        // Dark/Light Mode Switcher
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_outlined,
              color: Colors.white,
              size: 19,
            ),
            tooltip: isTamil ? 'வண்ண அமைப்பை மாற்று' : 'Toggle Theme',
            onPressed: () {
              HapticFeedback.selectionClick();
              patient.toggleTheme();
            },
          ),
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _buildLiveTickerHeroCard(PatientProvider patient, bool isTamil) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isTamil ? 'புகைபிடிக்காத நேரம்' : 'SMOKE-FREE LIFETIME',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mintFresh.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.mintFresh,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: GoogleFonts.outfit(
                        color: AppColors.mintFresh,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // High-Visibility Multi-Unit Time Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeUnit('${patient.days}', isTamil ? 'நாட்கள்' : 'Days'),
              _buildTimeDivider(),
              _buildTimeUnit('${patient.hours}', isTamil ? 'மணி' : 'Hours'),
              _buildTimeDivider(),
              _buildTimeUnit('${patient.minutes}', isTamil ? 'நிமிடம்' : 'Mins'),
              _buildTimeDivider(),
              _buildTimeUnit(
                '${patient.seconds}',
                isTamil ? 'வினாடி' : 'Secs',
                isHighlight: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.verified, color: AppColors.mintFresh, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isTamil
                      ? 'உங்கள் நுரையீரல் நச்சுக்களை வெளியேற்றி தொடர்ந்து குணமடைந்து வருகிறது.'
                      : 'Your respiratory tissue is healing continuously. Keep breathing free!',
                  style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.9), fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTimeUnit(String value, String label, {bool isHighlight = false}) {
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 58),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isHighlight
                ? AppColors.mintFresh.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlight ? AppColors.mintFresh : Colors.white24,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            value.padLeft(2, '0'),
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDivider() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        ':',
        style: GoogleFonts.outfit(
          color: Colors.white38,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAiClinicalPrescriptionCard(BuildContext context, PatientProvider patient, bool isTamil) {
    final insight = patient.latestAiInsight;

    if (insight == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.mintFresh.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.mintFresh.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.mintFresh.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.mintFresh, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTamil ? 'AI மருத்துவ பரிந்துரை' : 'AI Cessation Prescription',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isTamil
                        ? 'இன்றைய மனநிலை & ஆசையை பதிவு செய்து AI ஆலோசனையை பெறுங்கள்.'
                        : 'Log today’s check-in to calibrate your daily AI cessation protocol.',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => DailyQuePage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                isTamil ? 'தொடங்கு' : 'Check-in',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (insight.riskLevel) {
      case RelapseRiskLevel.low:
        badgeColor = AppColors.successGreen;
        badgeText = isTamil ? 'ஆபத்து குறைவு • கட்டுப்பாடு' : 'Low Relapse Risk • Controlled';
        badgeIcon = Icons.check_circle_outline;
        break;
      case RelapseRiskLevel.moderate:
        badgeColor = AppColors.amberGold;
        badgeText = isTamil ? 'மிதமான எச்சரிக்கை • மீட்சி' : 'Moderate Craving • Resilience';
        badgeIcon = Icons.warning_amber_rounded;
        break;
      case RelapseRiskLevel.high:
        badgeColor = AppColors.coralRed;
        badgeText = isTamil ? 'உயர் ஆசை • உடனடி தலையீடு' : 'High Craving • Action Required';
        badgeIcon = Icons.error_outline_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: badgeColor.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                    const Icon(Icons.psychology, color: AppColors.primaryTeal, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isTamil ? 'AI மருத்துவ வழிகாட்டி' : 'AI Daily Prescription',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.primaryTeal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, color: badgeColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      badgeText,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.headline,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            insight.message,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (insight.recommendedTool == 'doctor') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isTamil ? 'மருத்துவருக்கு தகவல் அனுப்பப்பட்டது' : 'Clinical alert dispatched to your doctor'),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CravingSosScreen()),
                  );
                }
              },
              icon: const Icon(Icons.play_circle_outline, size: 18),
              label: Text(
                insight.actionLabel,
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: badgeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosCravingBanner(BuildContext context, bool isTamil) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CravingSosScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.alertGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.coralRed.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 28)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 800.ms),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTamil ? 'ஆசை வருகிறதா? SOS கேடயம்' : 'Craving Spike? SOS Shield',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isTamil ? '4-7-8 சுவாசம் & 3 நிமிட தணிப்பு உதவி' : '4-7-8 Breathing & 3-Min Coping Toolkit',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAiCounselorBanner(BuildContext context, bool isTamil) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AICounselorScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D9488), Color(0xFF1E3A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1200.ms),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.successGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          isTamil ? 'ஆரியா • 24/7 AI ஆலோசகர்' : 'Aria • 24/7 AI Counselor',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.mintFresh.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'CBT AI',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isTamil
                        ? 'உடனடி உளவியல் வழிகாட்டல் மற்றும் தணிப்பு அரட்டை'
                        : 'Instant conversational coping & craving de-escalation',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationHubBanner(BuildContext context, bool isTamil) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Motivation()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F766E), Color(0xFF134E4A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDeepTeal.withValues(alpha: 0.28),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_rounded, color: AppColors.mintFresh, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTamil ? 'AI நடத்தை உந்துதல் மையம்' : 'AI Behavioral Motivation Hub',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isTamil
                        ? 'சுய உந்துதல் • முன்னேற்றம் • ஆபத்து ரேடார் • சமூகக் கவசம்'
                        : 'Self Motivation • Leverage • Seduction • Social Shield',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialAndVitalityRow(PatientProvider patient, bool isTamil) {
    return Row(
      children: [
        // Money Saved
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.lightCardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isTamil ? 'சேமித்த பணம்' : 'Money Saved',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.currency_rupee, color: AppColors.successGreen, size: 18),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${patient.moneySaved.toStringAsFixed(0)}',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.successGreen,
                  ),
                ),
                Text(
                  isTamil
                      ? '${patient.cigarettesAvoided} தவிர்த்த சிகரெட்டுகள்'
                      : '${patient.cigarettesAvoided} cigs avoided',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSubtle),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Regained Life
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.lightCardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isTamil ? 'மீட்டெடுத்த ஆயுள்' : 'Life Regained',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.favorite, color: AppColors.coralRed, size: 18),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${(patient.lifeRegainedMinutes / 60).toStringAsFixed(1)} hrs',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTeal,
                  ),
                ),
                Text(
                  isTamil ? '~11 நிமிடம் / சிகரெட்' : '~11 min / cigarette',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSubtle),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWishlistProgressCard(PatientProvider patient, bool isTamil) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.card_giftcard, color: AppColors.amberGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isTamil ? 'சேமிப்பு இலக்கு' : 'Savings Target',
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                '₹${patient.moneySaved.toStringAsFixed(0)} / ₹${patient.wishlistTarget.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.amberGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            patient.wishlistName,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: patient.wishlistProgress,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.amberGold),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.amberGold, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'AI Forecast: ${patient.projectedWishlistDate}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.amberGold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTasksSection(BuildContext context, PatientProvider patient, bool isTamil) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTamil ? 'இன்றைய மருத்துவ பணிகள்' : 'Clinical Action Items',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Daily Questionnaire
            Expanded(
              child: GestureDetector(
                onTap: () {
                  legacy.user_pnts = patient.points.toString();
                  legacy.user_monsav = patient.moneySaved.toStringAsFixed(0);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DailyQuePage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.assignment_turned_in, color: AppColors.primaryTeal, size: 24),
                      const SizedBox(height: 10),
                      Text(
                        isTamil ? 'தினசரி பணி' : 'Daily Check-in',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        isTamil ? 'மனநிலை & ஆசை பதிவு' : 'Mood & craving log',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Biweekly Assessment
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Biweekly()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mintFresh.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.mintFresh.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.medical_services_outlined, color: AppColors.mintFresh, size: 24),
                      const SizedBox(height: 10),
                      Text(
                        isTamil ? 'இருவார ஆய்வு' : 'Biweekly Audit',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        isTamil ? 'மருத்துவ பரிசோதனை' : 'Clinical progression',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDoctorMessageCard(PatientProvider patient, bool isTamil) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.comment, color: AppColors.primaryTeal, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTamil ? 'மருத்துவர் ஆலோசனை' : "Doctor's Clinical Note",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  patient.doctorMessage,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMilestonesSection(PatientProvider patient, bool isTamil) {
    final milestones = patient.healthMilestones;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTamil ? 'உடல்நல மீட்பு காலவரிசை (WHO)' : 'Physical Health Recovery (WHO)',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: milestones.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final m = milestones[index];
              final percent = (m.progress * 100).toInt();

              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightCardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(m.icon, color: AppColors.primaryTeal, size: 22),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: percent >= 100
                                ? AppColors.successGreen.withValues(alpha: 0.15)
                                : AppColors.primaryTeal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$percent%',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: percent >= 100 ? AppColors.successGreen : AppColors.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.title,
                          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          m.timeFrame,
                          style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSubtle),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: m.progress,
                        minHeight: 5,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percent >= 100 ? AppColors.successGreen : AppColors.primaryTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
