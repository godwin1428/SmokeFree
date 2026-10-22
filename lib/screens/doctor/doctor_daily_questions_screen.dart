import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smokefree/theme/app_colors.dart';

class DoctorDailyQuestionsScreen extends StatefulWidget {
  const DoctorDailyQuestionsScreen({super.key});

  @override
  State<DoctorDailyQuestionsScreen> createState() => _DoctorDailyQuestionsScreenState();
}

class _DoctorDailyQuestionsScreenState extends State<DoctorDailyQuestionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Active AI Intervention Rules state
  bool _autoSosBreathing = true;
  bool _autoEmpathyChat = true;
  bool _alertDoctorOnSlip = true;
  bool _adaptivePacing = true;

  // AI Generated Daily Prompts
  final List<Map<String, dynamic>> _activePrompts = [
    {
      'id': '1',
      'title': 'Morning Craving & Urge Scale',
      'category': 'Urge Assessment',
      'frequency': 'Daily (8:00 AM)',
      'badge': 'Core Protocol',
      'color': AppColors.primaryTeal,
      'aiGenerated': true,
      'promptEn': 'How intense is your morning craving on a scale from 1 (None) to 5 (Overwhelming)?',
      'promptTa': 'உங்கள் காலை நேர புகைபிடிக்கும் ஆசை 1 முதல் 5 வரை எவ்வளவு தீவிரமாக உள்ளது?',
    },
    {
      'id': '2',
      'title': 'Mid-Day Mood & Stress Telemetry',
      'category': 'Emotional Trigger',
      'frequency': 'Daily (2:00 PM)',
      'badge': 'CBT Monitored',
      'color': AppColors.amberGold,
      'aiGenerated': true,
      'promptEn': 'Select your current emotional state: Joyful, Calm, Neutral, Anxious, or Frustrated.',
      'promptTa': 'உங்கள் தற்போதைய மனநிலையைத் தேர்ந்தெடுக்கவும்: மகிழ்ச்சி, அமைதி, சாதாரண, கவலை அல்லது விரக்தி.',
    },
    {
      'id': '3',
      'title': 'Evening Smoke-Free Adherence & Slip Audit',
      'category': 'Relapse Prevention',
      'frequency': 'Daily (8:30 PM)',
      'badge': 'Clinical Audit',
      'color': AppColors.mintFresh,
      'aiGenerated': false,
      'promptEn': 'Did you maintain your smoke-free commitment today, or did any slip occur?',
      'promptTa': 'இன்று நீங்கள் புகைபிடிக்காமல் இருந்தீர்களா அல்லது ஏதேனும் சறுக்கல் ஏற்பட்டதா?',
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
              'Daily Questionnaires AI Hub',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDeepTeal,
              ),
            ),
            Text(
              'AI Adaptive Prompts & Relapse Telemetry',
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
                indicatorColor: AppColors.primaryTeal,
                indicatorWeight: 3,
                labelColor: AppColors.primaryTeal,
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'AI Prompts'),
                  Tab(text: 'Risk Telemetry'),
                  Tab(text: 'Smart Triggers'),
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
            _buildAiPromptsTab(),
            _buildRiskTelemetryTab(),
            _buildSmartTriggersTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryTeal,
        elevation: 4,
        onPressed: _showAiPromptGeneratorDialog,
        icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
        label: Text(
          'Generate AI Prompt',
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
  // TAB 1: AI Prompts Management
  // -------------------------------------------------------------
  Widget _buildAiPromptsTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      children: [
        // AI Header Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryTeal, AppColors.primaryDeepTeal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withValues(alpha: 0.2),
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
                        'ADAPTIVE QUESTIONNAIRE ENGINE',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mintFresh,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI-Personalized Daily Check-ins',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Questions automatically calibrate to patient withdrawal milestones and psychological craving profiles.',
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
                child: const Icon(Icons.psychology_rounded, size: 36, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Clinical Check-in Prompts',
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
                '${_activePrompts.length} Active',
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

        ..._activePrompts.map((prompt) => _buildPromptCard(prompt)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildPromptCard(Map<String, dynamic> prompt) {
    final Color color = prompt['color'] as Color;
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.quiz_rounded, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prompt['title'],
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${prompt['category']} • ${prompt['frequency']}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (prompt['aiGenerated'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 10, color: Color(0xFF7C3AED)),
                      const SizedBox(width: 3),
                      Text(
                        'AI Active',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7C3AED),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'English: ',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF334155)),
                    ),
                    Expanded(
                      child: Text(
                        prompt['promptEn'],
                        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'தமிழ்: ',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF334155)),
                    ),
                    Expanded(
                      child: Text(
                        prompt['promptTa'],
                        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: AI Risk Telemetry & Cohort Trends
  // -------------------------------------------------------------
  Widget _buildRiskTelemetryTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      children: [
        // AI Synthesis Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.insights_rounded, color: AppColors.mintFresh, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Cohort Synthesis (Today)',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF166534),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '84% completed today\'s questionnaires. 3 patients flagged for moderate cravings; automated breathwork protocols were successfully dispatched.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF15803D),
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
          'Real-Time Relapse Risk Distribution',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        // Distribution stats
        Row(
          children: [
            Expanded(
              child: _buildRiskBadge(
                title: 'Low Risk',
                count: '18 Patients',
                percent: '62%',
                color: AppColors.mintFresh,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildRiskBadge(
                title: 'Moderate',
                count: '8 Patients',
                percent: '28%',
                color: AppColors.amberGold,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildRiskBadge(
                title: 'High Alert',
                count: '3 Patients',
                percent: '10%',
                color: AppColors.coralRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Text(
          'Top AI-Identified Relapse Triggers',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),

        _buildTriggerBar(trigger: 'Work & Deadline Stress', percentage: 0.42, count: '42%'),
        _buildTriggerBar(trigger: 'Social Gatherings / Tea Breaks', percentage: 0.28, count: '28%'),
        _buildTriggerBar(trigger: 'Post-Meal Nicotine Urges', percentage: 0.18, count: '18%'),
        _buildTriggerBar(trigger: 'Solitary Boredom / Evening Downtime', percentage: 0.12, count: '12%'),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildRiskBadge({
    required String title,
    required String count,
    required String percent,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            percent,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerBar({
    required String trigger,
    required double percentage,
    required String count,
  }) {
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
                trigger,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                count,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
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
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: Smart Triggers & Clinical Interventions
  // -------------------------------------------------------------
  Widget _buildSmartTriggersTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      children: [
        Text(
          'Automated AI Intervention Thresholds',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'When patients complete daily questionnaires, AI automatically executes these clinical protocols in real-time.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 16),

        _buildTriggerToggle(
          title: 'Auto-Dispatch 4-7-8 Breathing on Craving ≥ 4',
          description: 'If a patient logs craving score 4 or 5, immediately launch breathing pacer on their dashboard.',
          icon: Icons.air_rounded,
          color: AppColors.primaryTeal,
          value: _autoSosBreathing,
          onChanged: (val) => setState(() => _autoSosBreathing = val),
        ),

        _buildTriggerToggle(
          title: 'Trigger AI Empathy Bot on Anxious Mood',
          description: 'Engage psychological de-escalation dialogue when patient selects Anxious or Frustrated.',
          icon: Icons.psychology_alt_rounded,
          color: const Color(0xFF7C3AED),
          value: _autoEmpathyChat,
          onChanged: (val) => setState(() => _autoEmpathyChat = val),
        ),

        _buildTriggerToggle(
          title: 'Instant Clinical Alert on Reported Slip',
          description: 'Push priority push notification to doctor dashboard if a patient admits to smoking today.',
          icon: Icons.notifications_active_rounded,
          color: AppColors.coralRed,
          value: _alertDoctorOnSlip,
          onChanged: (val) => setState(() => _alertDoctorOnSlip = val),
        ),

        _buildTriggerToggle(
          title: 'Adaptive Milestone-Based Question Pacing',
          description: 'Auto-adjust check-in frequency (3x/day for first 7 days, tapering to 1x/day after Day 30).',
          icon: Icons.tune_rounded,
          color: AppColors.mintFresh,
          value: _adaptivePacing,
          onChanged: (val) => setState(() => _adaptivePacing = val),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTriggerToggle({
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
  // AI Prompt Generator Modal Dialog
  // -------------------------------------------------------------
  void _showAiPromptGeneratorDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 20,
          ),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Color(0xFF7C3AED), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generate AI Clinical Prompt',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Select clinical focus for adaptive check-in generation',
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildAiFocusOption('Day 1-3 Acute Withdrawal & Nicotine Hunger', Icons.flash_on_rounded, AppColors.coralRed),
              _buildAiFocusOption('Day 7-14 Emotional Habit De-coupling', Icons.psychology_rounded, AppColors.amberGold),
              _buildAiFocusOption('Day 30+ Relapse Prevention & Identity Affirmation', Icons.verified_user_rounded, AppColors.mintFresh),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'AI Generated new check-in prompt: "Night-time Cortisol & Sleep Relaxation Check"',
                          style: GoogleFonts.inter(),
                        ),
                        backgroundColor: AppColors.primaryTeal,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  label: Text(
                    'Generate & Add Prompt',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAiFocusOption(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
