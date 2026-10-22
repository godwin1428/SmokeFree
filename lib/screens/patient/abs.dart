import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smokefree/ip.dart';
import 'package:smokefree/models/daily_checkin_result.dart';
import 'package:smokefree/patient.dart';
import 'package:smokefree/providers/patient_provider.dart';
import 'package:smokefree/theme/app_colors.dart';

class AbsPage extends StatefulWidget {
  final String username;
  final int points;
  final String mon;
  final String selectedMood;
  final int cravingScale;

  AbsPage({
    super.key,
    String? username,
    int? points,
    String? mon,
    this.selectedMood = 'Calm',
    this.cravingScale = 1,
  })  : username = username ?? userid,
        points = points ?? (int.tryParse(user_pnts) ?? 0),
        mon = mon ?? user_mon;

  @override
  _AbsPageState createState() => _AbsPageState();
}

class _AbsPageState extends State<AbsPage> {
  final TextEditingController reason1Controller = TextEditingController();
  final TextEditingController reason2Controller = TextEditingController();
  final TextEditingController reason3Controller = TextEditingController();

  bool _isSubmitting = false;

  final List<String> _quickChipsEn = [
    'Deep breathing 🧘',
    'Drank cold water 💧',
    'Family support 👨‍👩‍👧',
    'Saved my money 💰',
    'Brisk walk outdoors 🏃',
    'Healthy snack 🍏',
  ];

  final List<String> _quickChipsTa = [
    'ஆழ்ந்த சுவாசம் 🧘',
    'குளிர்ந்த நீர் குடித்தல் 💧',
    'குடும்ப ஆதரவு 👨‍👩‍👧',
    'பணம் சேமிப்பு 💰',
    'வெளியே நடைப்பயிற்சி 🏃',
    'ஆரோக்கிய சிற்றுண்டி 🍏',
  ];

  void _addQuickReason(String text) {
    HapticFeedback.lightImpact();
    setState(() {
      if (reason1Controller.text.trim().isEmpty) {
        reason1Controller.text = text;
      } else if (reason2Controller.text.trim().isEmpty) {
        reason2Controller.text = text;
      } else if (reason3Controller.text.trim().isEmpty) {
        reason3Controller.text = text;
      } else {
        reason1Controller.text = text;
      }
    });
  }

  Future<void> _submitReasons() async {
    final isTamil = lang == "1";
    final now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final String url = "${ip}abs.php";

    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'username': widget.username,
          'points': (widget.points + 50).toString(),
          'mon': widget.mon,
          'log_dt': formattedDate,
        },
      );

      if (response.statusCode == 200) {
        final String responseString = response.body;

        if (responseString.toLowerCase().contains("success")) {
          // Combine logged reasons into clinical notes
          final List<String> reasons = [
            reason1Controller.text.trim(),
            reason2Controller.text.trim(),
            reason3Controller.text.trim(),
          ].where((r) => r.isNotEmpty).toList();

          final checkIn = DailyCheckIn(
            timestamp: DateTime.now(),
            mood: widget.selectedMood,
            cravingScale: widget.cravingScale,
            cigarettesSmoked: 0,
            notes: reasons.isNotEmpty ? reasons.join('; ') : 'Staying smoke-free with resilience.',
          );

          try {
            await Provider.of<PatientProvider>(context, listen: false).submitDailyCheckIn(checkIn);
          } catch (_) {}

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.mintFresh,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              content: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isTamil
                          ? '🎉 புகைபிடிக்காத நாள் உறுதி செய்யப்பட்டது! +50 புள்ளிகள் சேர்க்கப்பட்டது.'
                          : '🎉 Smoke-free day confirmed! +50 points added & AI plan updated.',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Patient()),
            (route) => false,
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
              content: Text(isTamil ? 'சர்வர் பிழை. மீண்டும் முயற்சிக்கவும்.' : 'Server error. Please try again.'),
              backgroundColor: AppColors.coralRed,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: AppColors.coralRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    reason1Controller.dispose();
    reason2Controller.dispose();
    reason3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = lang == "1";
    final quickChips = isTamil ? _quickChipsTa : _quickChipsEn;

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
          isTamil ? 'வெற்றி பதிவு' : 'Daily Victory Journal',
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
              // Celebratory Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withValues(alpha: 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.mintFresh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.stars_rounded, size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                '+50 Points Reward',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.celebration_rounded, color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isTamil ? 'புகைபிடிக்காத மற்றொரு நாள் வெற்றி!' : 'Another Smoke-Free Day Won!',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isTamil
                          ? 'இன்று நீங்கள் வென்றதற்கான காரணங்களை பதிவு செய்யுங்கள். இது உங்கள் எதிர்கால மன வலிமையை இரட்டிப்பாக்கும்.'
                          : 'Documenting what worked today reinforces your cognitive resistance pathways against tomorrow\'s cravings.',
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

              // Quick Inspiration Chips
              Text(
                isTamil ? 'விரைவு காரணங்கள் (தட்டவும்)' : 'Quick Inspiration (Tap to add)',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDeepTeal,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickChips.map((chip) {
                  return ActionChip(
                    label: Text(
                      chip,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    elevation: 0,
                    side: const BorderSide(color: AppColors.lightCardBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onPressed: () => _addQuickReason(chip),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // 3 Modern Reason Inputs
              Text(
                isTamil ? 'உங்கள் காரணங்களை எழுதவும்' : 'Your Personal Defense Anchors',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDeepTeal,
                ),
              ),
              const SizedBox(height: 12),

              _buildModernTextField(
                controller: reason1Controller,
                hintText: isTamil ? 'முதன்மை காரணம் (எ.கா. ஆழ்ந்த சுவாசம்)' : 'Primary reason (e.g. 4-7-8 breathing practice)',
                label: isTamil ? 'காரணம் 1 (முக்கியமானது)' : 'Reason 1 (Key Trigger Defeated)',
                icon: Icons.emoji_events_rounded,
                accentColor: AppColors.mintFresh,
              ),
              const SizedBox(height: 14),

              _buildModernTextField(
                controller: reason2Controller,
                hintText: isTamil ? 'இரண்டாம் காரணம் (எ.கா. நடைப்பயிற்சி)' : 'Secondary reason (e.g. brisk walk after lunch)',
                label: isTamil ? 'காரணம் 2' : 'Reason 2',
                icon: Icons.favorite_rounded,
                accentColor: AppColors.skyBlue,
              ),
              const SizedBox(height: 14),

              _buildModernTextField(
                controller: reason3Controller,
                hintText: isTamil ? 'கூடுதல் காரணம் (விரும்பினால்)' : 'Bonus motivation (e.g. saving for my dream wish)',
                label: isTamil ? 'காரணம் 3' : 'Reason 3',
                icon: Icons.shield_rounded,
                accentColor: AppColors.amberGold,
              ),

              const SizedBox(height: 32),

              // Submit & Claim Reward Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReasons,
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
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  isTamil ? 'வெற்றியை உறுதி செய் (+50 புள்ளி)' : 'Claim +50 Pts & Save Log',
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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hintText,
    required String label,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accentColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          TextField(
            controller: controller,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSubtle,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
