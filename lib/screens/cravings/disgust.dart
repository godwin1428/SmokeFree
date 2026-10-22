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

class DisgustPage extends StatefulWidget {
  final String username;

  DisgustPage({super.key, String? username}) : username = username ?? userid;

  @override
  _DisgustPageState createState() => _DisgustPageState();
}

class _DisgustPageState extends State<DisgustPage> {
  int _selectedTab = 0; // 0: Biological Tar & Toxins, 1: Vascular & Heart, 2: Financial Burn

  @override
  Widget build(BuildContext context) {
    final patient = Provider.of<PatientProvider>(context);
    final isTamil = patient.isTamil;
    final smokeFreeDays = patient.days;
    final moneySaved = patient.moneySaved;

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
          isTamil ? 'எச்சரிக்கை AI • மருத்துவ உண்மை' : 'Aversion AI • Clinical Reality',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.coralRed,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.coralRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, size: 14, color: AppColors.coralRed),
                const SizedBox(width: 4),
                Text(
                  '${patient.points} Pts',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.coralRed,
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
              // Hero Reality Check Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF881337), Color(0xFFBE123C), Color(0xFFE11D48)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFBE123C).withValues(alpha: 0.3),
                      blurRadius: 18,
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
                        isTamil ? 'உடல்நல உண்மை எச்சரிக்கை' : 'Evidence-Based De-glamorization',
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
                          ? 'சிகரெட் அமைதி தருவதில்லை — அது உடலுக்குள் விஷத்தை செலுத்துகிறது!'
                          : 'Cigarettes Do Not Calm You. They Poison You.',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isTamil
                          ? 'ஒவ்வொரு முறை சிகரெட் பிடிக்கும்போதும் 7,000க்கும் மேற்பட்ட ரசாயனங்களும், 69 புற்றுநோய் காரணிகளும் நுரையீரலில் படிகின்றன.'
                          : 'Each puff deposits sticky, toxic tar on alveolar tissue, while carbon monoxide displaces oxygen in your blood.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.06, end: 0),

              const SizedBox(height: 20),

              // Interactive Segmented Switcher
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildTabButton(0, isTamil ? 'நச்சு தார்' : 'Tar & Toxins', Icons.science_rounded),
                    _buildTabButton(1, isTamil ? 'இதயம் & ரத்தம்' : 'Heart & Arteries', Icons.favorite_rounded),
                    _buildTabButton(2, isTamil ? 'நிதி சேமிப்பு' : 'Financial Drain', Icons.currency_rupee_rounded),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Dynamic Tab View
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentTabContent(isTamil, smokeFreeDays, moneySaved),
              ),

              const SizedBox(height: 24),

              // Addiction Cycle Reality Breakdown
              Container(
                padding: const EdgeInsets.all(18),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.loop_rounded, color: AppColors.coralRed, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isTamil ? 'நிக்கோடின் பொய் சுழற்சி' : 'The Dopamine Trap Exposed',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDeepTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isTamil
                          ? 'சிகரெட் உங்கள் அழுத்தத்தை தணிக்கவில்லை. அது உருவாக்கிய பசியை அதுவே தற்காலிகமாக பூர்த்தி செய்கிறது. அடுத்த 45 நிமிடங்களில் அதே அழுத்தம் இரட்டிப்பாகும்!'
                          : 'Smoking does not relieve life stress. It only relieves the withdrawal symptoms caused by the previous cigarette. It is an artificial itch designed to sell you another scratch.',
                      style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textDark, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Affirmation & Claim Shield Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.shield_rounded, color: Colors.white),
                  label: Text(
                    isTamil ? 'நான் நச்சுக்கு அடிமையல்ல • திரும்பு' : 'I Refuse the Poison • Claim Victory',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coralRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Provider.of<PatientProvider>(context, listen: false).addPoints(
                      15,
                      activityKey: ActivityCooldownKeys.copingDisgust,
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

  Widget _buildTabButton(int index, String title, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = index);
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
              Icon(icon, size: 14, color: isSelected ? AppColors.coralRed : AppColors.textMuted),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.coralRed : AppColors.textMuted,
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

  Widget _buildCurrentTabContent(bool isTamil, int smokeFreeDays, double moneySaved) {
    switch (_selectedTab) {
      case 0:
        return _buildToxinsContent(isTamil);
      case 1:
        return _buildCardioContent(isTamil);
      case 2:
      default:
        return _buildFinancialContent(isTamil, moneySaved);
    }
  }

  Widget _buildToxinsContent(bool isTamil) {
    return Column(
      key: const ValueKey(0),
      children: [
        _buildStatCard(
          icon: Icons.dangerous_rounded,
          color: AppColors.coralRed,
          title: isTamil ? 'கார்பன் மோனாக்சைடு (CO)' : 'Carbon Monoxide Hypoxia',
          desc: isTamil
              ? 'புகைபிடிக்கும் போது இரத்தத்தில் ஆக்சிஜனை விரட்டிவிட்டு விஷ வாயு படிகிறது. இதயமும் மூளையும் ஆக்சிஜன் இன்றி தவிக்கின்றன.'
              : 'CO binds to red blood cells 200x tighter than oxygen, suffocating muscles and heart tissue.',
          metricLabel: isTamil ? 'உடலில் நச்சு நிலை' : 'Toxicity Factor',
          metricVal: '200x Higher',
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: Icons.bubble_chart_rounded,
          color: AppColors.amberGold,
          title: isTamil ? 'கரி மற்றும் தார் (Tar) படிவு' : 'Chemical Tar Accumulation',
          desc: isTamil
              ? 'ஆண்டுக்கு ஒரு பாக்கெட் சிகரெட் பிடிப்பவர் ஒரு கோப்பை அளவுக்கு கறுப்பு தாரை நுரையீரலில் தேக்குகிறார்.'
              : '1 pack/day deposits ~1 full cup of black viscous carcinogens into bronchial lining per year.',
          metricLabel: isTamil ? 'நுரையீரல் சுமை' : 'Annual Tar Dose',
          metricVal: '~250 ml/year',
        ),
      ],
    );
  }

  Widget _buildCardioContent(bool isTamil) {
    return Column(
      key: const ValueKey(1),
      children: [
        _buildStatCard(
          icon: Icons.monitor_heart_rounded,
          color: AppColors.coralRed,
          title: isTamil ? 'இதயத் துடிப்பு & இரத்த அழுத்தம்' : 'Instant Vasoconstriction',
          desc: isTamil
              ? 'முதல் இழுப்பிலேயே நிக்கோடின் இரத்த நாளங்களை சுருக்கி இதயத் துடிப்பை 20-30 bpm அதிகரிக்கிறது.'
              : 'Within 10 seconds of inhalation, coronary arteries clamp tight and resting pulse accelerates by 25 bpm.',
          metricLabel: isTamil ? 'இதயத் துடிப்பு உயர்வு' : 'Pulse Spike',
          metricVal: '+25 BPM',
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: Icons.bloodtype_rounded,
          color: AppColors.primaryTeal,
          title: isTamil ? 'இரத்த ஓட்ட மீட்பு' : 'Endothelial Healing',
          desc: isTamil
              ? 'புகைபிடிப்பதை நிறுத்திய 24 மணி நேரத்தில் மாரடைப்புக்கான ஆபத்து உடனடியாக குறையத் தொடங்குகிறது.'
              : 'Quitting initiates cellular repair immediately. Don’t reverse weeks of arterial rebuilding.',
          metricLabel: isTamil ? 'மீட்பு சாத்தியம்' : 'Recovery Window',
          metricVal: 'Immediate',
        ),
      ],
    );
  }

  Widget _buildFinancialContent(bool isTamil, double moneySaved) {
    return Column(
      key: const ValueKey(2),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.amberGold.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: AppColors.amberGold.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
                    isTamil ? 'நீங்கள் பாதுகாத்த பணம்' : 'Hard-Earned Money Protected',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDeepTeal,
                    ),
                  ),
                  const Icon(Icons.savings_rounded, color: AppColors.amberGold, size: 24),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '₹${moneySaved.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.amberGold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isTamil
                    ? 'இந்த பணம் உங்கள் குழந்தைகளின் கல்வி அல்லது உங்கள் கனவு இலக்குக்கானது. புகையிலை நிறுவனங்களுக்கு இலவசமாக தாரை வார்க்காதீர்கள்!'
                    : 'This money belongs to your family and your dreams—not corporate tobacco balance sheets.',
                style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textDark, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
    required String metricLabel,
    required String metricVal,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDeepTeal,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        metricVal,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textDark,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
