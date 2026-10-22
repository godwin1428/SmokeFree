import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smokefree/theme/app_colors.dart';

class DoctorCravingsAiScreen extends StatefulWidget {
  const DoctorCravingsAiScreen({super.key});

  @override
  State<DoctorCravingsAiScreen> createState() => _DoctorCravingsAiScreenState();
}

class _DoctorCravingsAiScreenState extends State<DoctorCravingsAiScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // AI Rule Toggles
  bool _aiSmartRouting = true;
  bool _autoEmpathyEscalation = true;
  bool _cooldownThrottleActive = true;
  bool _alertOnRepeatedSos = true;

  // Selected parameters
  int _delayDurationMinutes = 3;
  int _breathingCycles = 4;

  final List<Map<String, dynamic>> _copingPillars = [
    {
      'id': 'breath',
      'title': '4-7-8 Vagus Nerve Breathing Pacer',
      'category': 'Somatic Regulation',
      'mechanism': 'Parasympathetic activation & heart rate deceleration',
      'efficacy': '88% Craving Reduction',
      'badge': 'High Efficacy',
      'color': AppColors.primaryTeal,
      'icon': Icons.air_rounded,
      'aiStatus': 'Active (Stress Triggered)',
    },
    {
      'id': 'delay',
      'title': '3-Minute Delay Protocol (Urge Surfing)',
      'category': 'Neurochemical Decay',
      'mechanism': 'Allows acute dopamine craving peak to naturally subside',
      'efficacy': '74% Urge Dissipation',
      'badge': 'ACT Protocol',
      'color': AppColors.amberGold,
      'icon': Icons.timer_outlined,
      'aiStatus': 'Active (Habit Triggered)',
    },
    {
      'id': 'empathy',
      'title': 'AI Empathy Cognitive Chatbot',
      'category': 'Psychological Support',
      'mechanism': 'CBT reframing & emotional distress de-escalation',
      'efficacy': '81% Emotional Relief',
      'badge': 'GenAI Powered',
      'color': const Color(0xFF7C3AED),
      'icon': Icons.psychology_alt_rounded,
      'aiStatus': 'Active (Anxiety Triggered)',
    },
    {
      'id': 'distract',
      'title': 'Sensory Distraction & Grounding Engine',
      'category': 'Attentional Bias Shift',
      'mechanism': 'Disrupts obsessive nicotine thought loops via cognitive puzzles',
      'efficacy': '72% Focus Redirection',
      'badge': 'Cognitive Shift',
      'color': AppColors.skyBlue,
      'icon': Icons.extension_rounded,
      'aiStatus': 'Active (Boredom Triggered)',
    },
    {
      'id': 'reality',
      'title': 'Clinical Reality & Aversion Insights',
      'category': 'Motivation Reinforcement',
      'mechanism': 'Medical evidence of arterial recovery & toxicity benchmarks',
      'efficacy': '70% Resistance Boost',
      'badge': 'Clinical Evidence',
      'color': AppColors.coralRed,
      'icon': Icons.health_and_safety_rounded,
      'aiStatus': 'Active (Ambivalence Triggered)',
    },
    {
      'id': 'water',
      'title': 'Cold Water Hydration Pacer',
      'category': 'Oral-Sensory Reset',
      'mechanism': 'Vagus nerve stimulation via cold fluid & oral substitution',
      'efficacy': '69% Craving Reset',
      'badge': 'Behavioral Substitution',
      'color': const Color(0xFF0284C7),
      'icon': Icons.water_drop_rounded,
      'aiStatus': 'Active (Oral Fixation)',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cravings & Coping AI Hub',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDeepTeal,
              ),
            ),
            Text(
              'Neurobehavioral SOS & Intervention Telemetry',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.coralRed,
                indicatorWeight: 3,
                labelColor: AppColors.coralRed,
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'SOS Protocols'),
                  Tab(text: 'Efficacy Telemetry'),
                  Tab(text: 'AI Smart Dispatch'),
                ],
              ),
              Container(color: const Color(0xFFE2E8F0), height: 1),
            ],
          ),
        ),
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildProtocolsTab(),
            _buildEfficacyTelemetryTab(),
            _buildSmartDispatchTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.coralRed,
        elevation: 4,
        onPressed: _showTuneProtocolsModal,
        icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
        label: Text(
          'Tune SOS Settings',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: SOS Protocols & Coping Pillars
  // -------------------------------------------------------------
  Widget _buildProtocolsTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      children: [
        // Hero Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.coralRed, Color(0xFFBE123C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.coralRed.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 4),
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
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'AI SOS COPING ENGINE',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Evidence-Based Acute Cessation',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI pairs real-time craving intensity with somatic and cognitive de-escalation protocols.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.85),
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
                child: const Icon(Icons.shield_rounded, size: 36, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Configured Coping Protocols (6 Pillars)',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'All Active',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ..._copingPillars.map((pillar) => _buildPillarCard(pillar)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildPillarCard(Map<String, dynamic> pillar) {
    final Color color = pillar['color'] as Color;
    final IconData icon = pillar['icon'] as IconData;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pillar['title'],
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      pillar['category'],
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  pillar['badge'],
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            pillar['mechanism'],
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF475569),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt_rounded, size: 14, color: AppColors.mintFresh),
                  const SizedBox(width: 4),
                  Text(
                    pillar['efficacy'],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF166534),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 10, color: Color(0xFF7C3AED)),
                    const SizedBox(width: 4),
                    Text(
                      pillar['aiStatus'],
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
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

  // -------------------------------------------------------------
  // TAB 2: AI Efficacy Telemetry & Surge Heatmap
  // -------------------------------------------------------------
  Widget _buildEfficacyTelemetryTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      children: [
        // AI Surge Brief Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFECDD3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.coralRed, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Craving Surge Telemetry (Today)',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9F1239),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '31 SOS sessions completed today. 4-7-8 Breathing and 3-Minute Delay achieved an 83% combined urge dissipation without slips.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF881337),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Clinical Efficacy by Coping Strategy',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),

        _buildEfficacyBar('4-7-8 Breathing Pacer', 0.88, '88%', AppColors.primaryTeal),
        _buildEfficacyBar('AI Empathy Cognitive Dialogue', 0.81, '81%', const Color(0xFF7C3AED)),
        _buildEfficacyBar('3-Minute Delay Protocol', 0.74, '74%', AppColors.amberGold),
        _buildEfficacyBar('Sensory Distraction Puzzles', 0.72, '72%', AppColors.skyBlue),
        _buildEfficacyBar('Clinical Reality Check', 0.70, '70%', AppColors.coralRed),
        _buildEfficacyBar('Cold Water Hydration', 0.69, '69%', const Color(0xFF0284C7)),

        const SizedBox(height: 24),
        Text(
          'Peak Craving Hour Heatmap (Cohort Wide)',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildTimeRow('Morning (7:30 AM - 9:00 AM)', 'Nicotine Hunger & Waking Routine', 'High (26%)', AppColors.coralRed),
              const Divider(height: 18),
              _buildTimeRow('Post-Lunch (1:30 PM - 2:30 PM)', 'Post-Meal Digestive Nicotine Urge', 'Moderate (19%)', AppColors.amberGold),
              const Divider(height: 18),
              _buildTimeRow('Evening Commute (6:00 PM - 7:30 PM)', 'Workday Decompression & Traffic Stress', 'High (33%)', AppColors.coralRed),
              const Divider(height: 18),
              _buildTimeRow('Late Night (9:30 PM - 11:00 PM)', 'Boredom & Solitary Craving Loops', 'Moderate (22%)', AppColors.mintFresh),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildEfficacyBar(String title, double percentage, String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 7,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String time, String contextDesc, String status, Color color) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(time, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              Text(contextDesc, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 3: Smart Dispatch Rules & Dynamic Recommendations
  // -------------------------------------------------------------
  Widget _buildSmartDispatchTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      children: [
        Text(
          'Automated AI Coping Dispatch Rules',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Configure how the AI routes patients to specific coping strategies based on real-time biometric and self-report inputs.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 16),

        _buildRuleSwitch(
          title: 'AI Smart Routing by Trigger Category',
          description: 'Route acute somatic stress to 4-7-8 Breathing, and boredom/habit urges to 3-Min Delay & Games.',
          icon: Icons.alt_route_rounded,
          color: AppColors.primaryTeal,
          value: _aiSmartRouting,
          onChanged: (val) => setState(() => _aiSmartRouting = val),
        ),

        _buildRuleSwitch(
          title: 'Auto-Escalate to AI Empathy Bot on Extreme Distress',
          description: 'If patient rates urge intensity as 5/5, immediately open supportive conversational agent.',
          icon: Icons.psychology_rounded,
          color: const Color(0xFF7C3AED),
          value: _autoEmpathyEscalation,
          onChanged: (val) => setState(() => _autoEmpathyEscalation = val),
        ),

        _buildRuleSwitch(
          title: 'Enforce Cooldown / Throttle Timer',
          description: 'Prevent duplicate reward claims within 15 minutes to encourage genuine coping completion.',
          icon: Icons.hourglass_top_rounded,
          color: AppColors.amberGold,
          value: _cooldownThrottleActive,
          onChanged: (val) => setState(() => _cooldownThrottleActive = val),
        ),

        _buildRuleSwitch(
          title: 'Doctor SOS Emergency Alert (3+ Triggers / Hour)',
          description: 'Notify the physician portal if a patient activates SOS Shield 3 or more times within 60 minutes.',
          icon: Icons.emergency_rounded,
          color: AppColors.coralRed,
          value: _alertOnRepeatedSos,
          onChanged: (val) => setState(() => _alertOnRepeatedSos = val),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildRuleSwitch({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: value,
            activeTrackColor: color.withValues(alpha: 0.5),
            activeThumbColor: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Tune Protocol Modal
  // -------------------------------------------------------------
  void _showTuneProtocolsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tune Acute Coping Parameters',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Adjust patient-facing timer durations and pacing cycles.',
                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 20),

                  // Delay Duration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Delay Window Duration:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                      DropdownButton<int>(
                        value: _delayDurationMinutes,
                        items: [2, 3, 5, 10].map((m) => DropdownMenuItem(value: m, child: Text('$m Minutes'))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => _delayDurationMinutes = val);
                            setState(() => _delayDurationMinutes = val);
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(),

                  // Breathing Cycles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('4-7-8 Breathing Cycles:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                      DropdownButton<int>(
                        value: _breathingCycles,
                        items: [3, 4, 6, 8].map((c) => DropdownMenuItem(value: c, child: Text('$c Cycles (~${c * 19}s)'))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => _breathingCycles = val);
                            setState(() => _breathingCycles = val);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coralRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Coping parameters updated successfully!',
                              style: GoogleFonts.inter(),
                            ),
                            backgroundColor: AppColors.primaryDeepTeal,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Text(
                        'Save Parameters',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
