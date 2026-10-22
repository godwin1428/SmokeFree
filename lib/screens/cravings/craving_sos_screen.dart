import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/daily_checkin_result.dart';
import '../../models/reward_result.dart';
import '../../providers/patient_provider.dart';
import '../../theme/app_colors.dart';
import '../../distract.dart';
import '../../disgust.dart';
import '../../emp.dart';
import 'ai_counselor_screen.dart';

class CravingTriggerOption {
  final String id;
  final String labelEn;
  final String labelTa;
  final IconData icon;

  const CravingTriggerOption({
    required this.id,
    required this.labelEn,
    required this.labelTa,
    required this.icon,
  });

  String getLabel(bool isTamil) => isTamil ? labelTa : labelEn;
}

class MindfulReflection {
  final String textEn;
  final String textTa;
  final IconData icon;

  const MindfulReflection({
    required this.textEn,
    required this.textTa,
    required this.icon,
  });

  String getText(bool isTamil) => isTamil ? textTa : textEn;
}

class CravingSosScreen extends StatefulWidget {
  const CravingSosScreen({super.key});

  @override
  State<CravingSosScreen> createState() => _CravingSosScreenState();
}

class _CravingSosScreenState extends State<CravingSosScreen> with SingleTickerProviderStateMixin {
  int _selectedIntensity = 5;
  final Set<String> _selectedTriggerIds = {'stress'};
  int _activeTabIndex = 0; // 0: Breathe, 1: Delay, 2: Water, 3: Distract

  // Dynamic AI Empathy & Aversion State
  int _empathyVariant = 0;
  int _aversionVariant = 0;
  bool _isLoadingAi = false;
  CravingAiRecommendations? _aiRecommendations;

  // Breathing Pacer Variables (4-7-8 Technique)
  late AnimationController _breathController;
  late Animation<double> _breathScaleAnimation;
  String _currentPhaseKey = 'ready'; // Dynamic multi-language phase tracking
  int _breathSecondsLeft = 4;
  int _cyclesCompleted = 0;
  Timer? _phaseTimer;
  bool _isBreathingActive = false;

  // Delay Challenge Timer (3 minutes = 180s)
  int _delaySeconds = 180;
  Timer? _delayTimer;
  bool _delayActive = false;

  // Hydration glasses drank
  int _waterGlasses = 1;

  // Dynamic Canonical Triggers with Bilingual Labels & Clinical Icons
  static const List<CravingTriggerOption> _triggerOptions = [
    CravingTriggerOption(
      id: 'stress',
      labelEn: 'Stress',
      labelTa: 'அழுத்தம்',
      icon: Icons.psychology_rounded,
    ),
    CravingTriggerOption(
      id: 'anxiety',
      labelEn: 'Anxiety',
      labelTa: 'கவலை',
      icon: Icons.healing_rounded,
    ),
    CravingTriggerOption(
      id: 'frustration',
      labelEn: 'Frustration',
      labelTa: 'விரக்தி',
      icon: Icons.sentiment_dissatisfied_rounded,
    ),
    CravingTriggerOption(
      id: 'boredom',
      labelEn: 'Boredom',
      labelTa: 'சலிப்பு',
      icon: Icons.hourglass_empty_rounded,
    ),
    CravingTriggerOption(
      id: 'post_meal',
      labelEn: 'Post-Meal',
      labelTa: 'உணவுக்குப் பின்',
      icon: Icons.restaurant_rounded,
    ),
    CravingTriggerOption(
      id: 'social_pressure',
      labelEn: 'Social',
      labelTa: 'சமூக அழுத்தம்',
      icon: Icons.people_alt_rounded,
    ),
    CravingTriggerOption(
      id: 'coffee_tea',
      labelEn: 'Coffee / Tea',
      labelTa: 'காபி / தேநீர்',
      icon: Icons.coffee_rounded,
    ),
    CravingTriggerOption(
      id: 'driving',
      labelEn: 'Driving',
      labelTa: 'பயணம்',
      icon: Icons.directions_car_rounded,
    ),
  ];

  // Dynamic Reflections Synthesized from Live Patient Metrics
  List<MindfulReflection> _getDynamicReflections(PatientProvider patient) {
    final days = patient.days;
    final money = patient.moneySaved;
    final avoided = patient.cigarettesAvoided;

    return [
      MindfulReflection(
        textEn: days > 0
            ? 'You have protected $days smoke-free days and saved ₹${money.toStringAsFixed(0)}. Defend your freedom!'
            : 'Every urge you defeat rewires your brain permanently toward liberation.',
        textTa: days > 0
            ? 'நீங்கள் $days நாட்கள் புகைபிடிக்காமல் ₹${money.toStringAsFixed(0)} சேமித்துள்ளீர்கள். இந்த வெற்றியைப் பாதுகாக்கவும்!'
            : 'நீங்கள் வெல்லும் ஒவ்வொரு ஆசையும் உங்கள் மூளையை நிரந்தர விடுதலைக்கு தயார்படுத்துகிறது.',
        icon: Icons.emoji_events_rounded,
      ),
      MindfulReflection(
        textEn: avoided > 0
            ? 'You have kept $avoided cigarettes out of your lungs! Your circulation and vitality are actively surging.'
            : 'A craving peak lasts only 3 to 5 minutes. Take slow deep breaths—you can outlast this wave.',
        textTa: avoided > 0
            ? 'நீங்கள் $avoided சிகரெட்டுகளை தவிர்த்துள்ளீர்கள்! உங்கள் நுரையீரலும் இரத்த ஓட்டமும் புத்துயிர் பெறுகின்றன.'
            : 'ஆசையின் உச்சம் 3 முதல் 5 நிமிடங்கள் மட்டுமே. ஆழ்ந்த சுவாசம் எடுங்கள்—இந்த அலையை நீங்கள் வெல்ல முடியும்.',
        icon: Icons.favorite_rounded,
      ),
      MindfulReflection(
        textEn: 'Take a slow sip of cool water. Feel the refreshing sensation in your throat dissolving the impulse.',
        textTa: 'ஒரு மிடறு குளிர்ந்த நீர் அருந்துங்கள். தொண்டைக்கு ஏற்படும் புத்துணர்ச்சி ஆசையை உடனே தணிக்கிறது.',
        icon: Icons.water_drop_rounded,
      ),
      MindfulReflection(
        textEn: 'Your lungs are healing with every clean breath of fresh air you inhale right now.',
        textTa: 'நீங்கள் உள்ளிழுக்கும் ஒவ்வொரு சுத்தமான பிராணவாயுவாலும் உங்கள் நுரையீரல் நலம் பெற்று வருகிறது.',
        icon: Icons.air_rounded,
      ),
      MindfulReflection(
        textEn: 'You are in sovereign control of your body and mind. The cigarette has zero power over you.',
        textTa: 'உங்கள் உடலும் மனமும் உங்கள் கட்டுப்பாட்டில் உள்ளது. சிகரெட்டுக்கு எந்த வலிமையும் இல்லை.',
        icon: Icons.shield_rounded,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _initBreathingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchRecommendations());
  }

  Future<void> _fetchRecommendations() async {
    if (!mounted) return;
    setState(() => _isLoadingAi = true);
    final provider = Provider.of<PatientProvider>(context, listen: false);
    final isTamil = provider.isTamil;

    // Resolve localized labels for the selected canonical triggers
    final resolvedTriggers = _selectedTriggerIds.map((id) {
      final opt = _triggerOptions.firstWhere(
        (t) => t.id == id,
        orElse: () => _triggerOptions.first,
      );
      return opt.getLabel(isTamil);
    }).toList();

    try {
      final recs = await provider.fetchCravingRecommendations(
        intensity: _selectedIntensity,
        triggers: resolvedTriggers,
        empathyVariant: _empathyVariant,
        aversionVariant: _aversionVariant,
      );
      if (mounted) {
        setState(() {
          _aiRecommendations = recs;
          _isLoadingAi = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingAi = false);
    }
  }

  void _initBreathingController() {
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _breathScaleAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOutQuad),
    );

    // 4-7-8 breathing pacer does not run by default until user taps Start
    _isBreathingActive = false;
    _currentPhaseKey = 'ready';
    _breathSecondsLeft = 4;
  }

  void _stopBreathingCycle() {
    _phaseTimer?.cancel();
    _breathController.stop();
    _breathController.reset();
    setState(() {
      _isBreathingActive = false;
      _currentPhaseKey = 'ready';
      _breathSecondsLeft = 4;
    });
  }

  void _startBreathingCycle() {
    _phaseTimer?.cancel();
    setState(() {
      _isBreathingActive = true;
      _currentPhaseKey = 'inhale';
      _breathSecondsLeft = 4;
    });
    _breathController.duration = const Duration(seconds: 4);
    _breathController.forward(from: 0.0);

    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_breathSecondsLeft > 1) {
          _breathSecondsLeft--;
        } else {
          // Transition phases: Inhale (4s) -> Hold (7s) -> Exhale (8s)
          if (_currentPhaseKey == 'inhale') {
            _currentPhaseKey = 'hold';
            _breathSecondsLeft = 7;
            HapticFeedback.selectionClick();
          } else if (_currentPhaseKey == 'hold') {
            _currentPhaseKey = 'exhale';
            _breathSecondsLeft = 8;
            _breathController.duration = const Duration(seconds: 8);
            _breathController.reverse(from: 1.0);
            HapticFeedback.lightImpact();
          } else {
            _cyclesCompleted++;
            _currentPhaseKey = 'inhale';
            _breathSecondsLeft = 4;
            _breathController.duration = const Duration(seconds: 4);
            _breathController.forward(from: 0.0);
            HapticFeedback.mediumImpact();
            // Reward points every 2 cycles with cooldown throttling
            if (_cyclesCompleted % 2 == 0) {
              final res = Provider.of<PatientProvider>(context, listen: false).addPoints(
                5,
                activityKey: ActivityCooldownKeys.copingBreathing,
                cooldown: const Duration(minutes: 15),
              );
              if (res.awarded) {
                HapticFeedback.lightImpact();
              }
            }
          }
        }
      });
    });
  }

  String _getBreathPhaseText(bool isTamil) {
    if (!_isBreathingActive) {
      return isTamil ? 'பயிற்சியைத் தொடங்க அழுத்தவும்' : 'Tap Start to begin 4-7-8 pacing';
    }
    switch (_currentPhaseKey) {
      case 'inhale':
        return isTamil ? 'மூச்சை உள்ளிழுக்கவும் (4 வி)' : 'Inhale through nose';
      case 'hold':
        return isTamil ? 'மூச்சை அடக்கவும் (7 வி)' : 'Hold breath gently';
      case 'exhale':
        return isTamil ? 'மூச்சை வெளியேற்றவும் (8 வி)' : 'Exhale through mouth';
      default:
        return isTamil ? 'சுவாசிக்கவும்' : 'Breathe';
    }
  }

  void _startDelayTimer() {
    setState(() {
      _delayActive = true;
      if (_delaySeconds <= 0) {
        _delaySeconds = 180;
      }
    });
    _delayTimer?.cancel();
    _delayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_delaySeconds > 0) {
          _delaySeconds--;
        } else {
          _delayActive = false;
          _delaySeconds = 180; // Reset for subsequent challenge
          _delayTimer?.cancel();
          final res = Provider.of<PatientProvider>(context, listen: false).addPoints(
            20,
            activityKey: ActivityCooldownKeys.copingDelay,
            cooldown: const Duration(minutes: 15),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: res.awarded ? AppColors.successGreen : AppColors.amberGold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Text(
                res.awarded
                    ? '🎉 Awesome! You delayed 3 minutes and defeated the craving! (+20 Points)'
                    : res.message,
              ),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    _phaseTimer?.cancel();
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patient = Provider.of<PatientProvider>(context);
    final isTamil = patient.isTamil;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTamil ? 'ஆசை மீட்பு SOS கேடயம்' : 'Craving SOS Shield',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.amberGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: AppColors.amberGold, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${patient.points} Pts',
                  style: GoogleFonts.outfit(
                    color: AppColors.amberGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Recovery Defense Telemetry Banner (Dynamic Patient Metrics)
              _buildLiveDefenseBanner(patient, isTamil),

              // Intensity & Canonical Trigger Assessment
              _buildTriggerAssessment(isTamil),
              const SizedBox(height: 20),

              // AI-Powered Empathy and Aversion Recommendation System
              _buildAiRecommendationSection(isTamil),
              const SizedBox(height: 24),

              // 4Ds Tab Selector
              _build4DsTabSelector(isTamil),
              const SizedBox(height: 20),

              // Dynamic 4Ds Content Screen
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _buildActive4DTab(isTamil, patient),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveDefenseBanner(PatientProvider patient, bool isTamil) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDeepTeal,
            AppColors.primaryTeal,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeepTeal.withValues(alpha: 0.25),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isTamil ? 'நிகழ்நேர மீட்பு கேடயம்' : 'Live Recovery Defense',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mintFresh.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.mintFresh.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
                      isTamil ? 'செயலில்' : 'ACTIVE',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildBannerStatCard(
                  icon: Icons.calendar_today_rounded,
                  value: '${patient.days}',
                  unit: isTamil ? 'நாட்கள்' : 'Days',
                  label: isTamil ? 'புகை இல்லை' : 'Smoke-Free',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBannerStatCard(
                  icon: Icons.currency_rupee_rounded,
                  value: '₹${patient.moneySaved.toStringAsFixed(0)}',
                  unit: isTamil ? 'சேமிப்பு' : 'Saved',
                  label: isTamil ? 'நிதி பாதுகாப்பு' : 'Protected',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBannerStatCard(
                  icon: Icons.smoke_free_rounded,
                  value: '${patient.cigarettesAvoided}',
                  unit: isTamil ? 'தவிர்த்தவை' : 'Avoided',
                  label: isTamil ? 'தூய நுரையீரல்' : 'Clean Lungs',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerStatCard({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.mintFresh, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  unit,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 9,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getIntensityLabel(bool isTamil) {
    if (_selectedIntensity <= 3) {
      return isTamil ? 'லேசானது ($_selectedIntensity/10)' : 'Mild ($_selectedIntensity/10)';
    } else if (_selectedIntensity <= 6) {
      return isTamil ? 'மிதமானது ($_selectedIntensity/10)' : 'Moderate ($_selectedIntensity/10)';
    } else {
      return isTamil ? 'தீவிரமானது ($_selectedIntensity/10)' : 'Peak Storm ($_selectedIntensity/10)';
    }
  }

  Widget _buildTriggerAssessment(bool isTamil) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              Expanded(
                child: Text(
                  isTamil ? 'ஆசையின் தீவிரம் (1-10)' : 'Craving Intensity (1-10)',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getIntensityColor().withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getIntensityColor().withValues(alpha: 0.3)),
                ),
                child: Text(
                  _getIntensityLabel(isTamil),
                  style: GoogleFonts.outfit(
                    color: _getIntensityColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _getIntensityColor(),
              thumbColor: _getIntensityColor(),
              overlayColor: _getIntensityColor().withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: _selectedIntensity.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (val) {
                setState(() {
                  _selectedIntensity = val.round();
                });
                HapticFeedback.selectionClick();
                _fetchRecommendations();
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isTamil ? 'ஆசைக்கான காரணங்கள்:' : 'What triggered this craving?',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _triggerOptions.map((option) {
              final isSelected = _selectedTriggerIds.contains(option.id);
              return FilterChip(
                avatar: Icon(
                  option.icon,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.primaryDeepTeal,
                ),
                label: Text(option.getLabel(isTamil)),
                selected: isSelected,
                selectedColor: AppColors.primaryTeal,
                checkmarkColor: Colors.white,
                backgroundColor: Theme.of(context).cardColor,
                labelStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryTeal : AppColors.lightCardBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTriggerIds.add(option.id);
                    } else {
                      if (_selectedTriggerIds.length > 1) {
                        _selectedTriggerIds.remove(option.id);
                      }
                    }
                  });
                  HapticFeedback.selectionClick();
                  _fetchRecommendations();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAiRecommendationSection(bool isTamil) {
    final provider = Provider.of<PatientProvider>(context);
    final recs = _aiRecommendations ?? provider.currentCravingAi;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTamil ? 'AI உளவியல் & மருத்துவ கேடயம்' : 'AI Coping Intelligence',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDeepTeal,
                    ),
                  ),
                  Text(
                    isTamil
                        ? 'நிகழ்நேர பரிவு & எச்சரிக்கை ஆலோசனைகள்'
                        : 'Real-time empathy & aversion recommendations',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSubtle,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (_isLoadingAi)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTeal),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getIntensityColor().withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getIntensityColor().withValues(alpha: 0.3)),
                ),
                child: Text(
                  _selectedIntensity <= 3
                      ? (isTamil ? 'லேசானது' : 'Low (1-3)')
                      : _selectedIntensity <= 6
                          ? (isTamil ? 'மிதமானது' : 'Moderate (4-6)')
                          : (isTamil ? 'தீவிரமானது' : 'High (7-10)'),
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getIntensityColor(),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (recs != null) ...[
          // Card 1: Empathy AI Card
          _buildEmpathyCard(isTamil, recs.empathy),
          const SizedBox(height: 16),

          // Card 2: Aversion AI Card
          _buildAversionCard(isTamil, recs.aversion),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.lightCardBorder),
            ),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(color: AppColors.primaryTeal),
          ),
        ],
      ],
    );
  }

  Widget _buildEmpathyCard(bool isTamil, EmpathyRecommendation empathy) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.mintFresh, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.mintFresh.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.mintFresh.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volunteer_activism_rounded, color: AppColors.primaryTeal, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTamil ? 'பரிவு AI • உணர்வு ஆதரவு' : 'Empathy AI • Emotional Shield',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                    Text(
                      isTamil ? 'குற்ற உணர்வற்ற ஆதரவு & மறுசீரமைப்பு' : 'Non-judgmental compassionate guidance',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _cycleEmpathy,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.refresh_rounded, size: 14, color: AppColors.primaryTeal),
                      const SizedBox(width: 4),
                      Text(
                        isTamil ? 'மாற்று' : 'Alternative',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Headline
          Text(
            empathy.headline,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDeepTeal,
            ),
          ),
          const SizedBox(height: 6),

          // Empathetic Message
          Text(
            empathy.message,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textDark,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),

          // Emotional Insight Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.mintFresh.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.psychology_outlined, size: 18, color: AppColors.primaryTeal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    empathy.emotionalInsight,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDeepTeal,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Step-by-Step Action Plan
          Text(
            isTamil ? 'படிப்படியான செயல் திட்டம்:' : 'Actionable Step-by-Step Plan:',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDeepTeal,
            ),
          ),
          const SizedBox(height: 6),
          ...empathy.stepByStepGuide.map((step) => _buildStepItem(step, AppColors.primaryTeal)),
          const SizedBox(height: 14),

          // Live Delay Timer Display inside Empathy Card
          if (empathy.actionType == 'delay' && _delayActive) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.amberGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.amberGold.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.hourglass_top_rounded, color: AppColors.amberGold, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    '${(_delaySeconds ~/ 60).toString().padLeft(2, '0')}:${(_delaySeconds % 60).toString().padLeft(2, '0')}',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.amberGold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      isTamil ? 'தாமத நேரம் இயங்குகிறது...' : 'Delay challenge running...',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDeepTeal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Interactive Action Button
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 48),
            child: ElevatedButton.icon(
              icon: Icon(
                empathy.actionType == 'breathe'
                    ? Icons.spa_rounded
                    : empathy.actionType == 'water'
                        ? Icons.water_drop_rounded
                        : (_delayActive ? Icons.hourglass_top_rounded : Icons.timer_rounded),
                size: 18,
                color: Colors.white,
              ),
              label: Flexible(
                child: Text(
                  (empathy.actionType == 'delay' && _delayActive)
                      ? (isTamil
                          ? 'டைமர் இயங்குகிறது (${(_delaySeconds ~/ 60).toString().padLeft(2, '0')}:${(_delaySeconds % 60).toString().padLeft(2, '0')})'
                          : 'Timer Running (${(_delaySeconds ~/ 60).toString().padLeft(2, '0')}:${(_delaySeconds % 60).toString().padLeft(2, '0')})')
                      : '${empathy.actionLabel} (+${empathy.pointsReward} Pts)',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: (empathy.actionType == 'delay' && _delayActive)
                    ? AppColors.textMuted
                    : AppColors.primaryTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onPressed: (empathy.actionType == 'delay' && _delayActive)
                  ? null
                  : () => _handleAction(empathy.actionType, empathy.pointsReward),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAversionCard(bool isTamil, AversionRecommendation aversion) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.coralRed.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.coralRed.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.coralRed.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.biotech_rounded, color: AppColors.coralRed, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTamil ? 'எச்சரிக்கை AI • உண்மை கேடயம்' : 'Aversion AI • Clinical Reality',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.coralRed,
                      ),
                    ),
                    Text(
                      isTamil ? 'சான்றுகள் & உடல்நல யதார்த்தம்' : 'Evidence-based physiological truth',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _cycleAversion,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.refresh_rounded, size: 14, color: AppColors.coralRed),
                      const SizedBox(width: 4),
                      Text(
                        isTamil ? 'மாற்று' : 'Alternative',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.coralRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Headline
          Text(
            aversion.headline,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.coralRed,
            ),
          ),
          const SizedBox(height: 6),

          // Biological Reality
          Text(
            aversion.biologicalReality,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textDark,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),

          // Financial & Goal Impact Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.amberGold.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.savings_outlined, size: 18, color: AppColors.amberGold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    aversion.financialOrGoalImpact,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Addiction Cycle Insight Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.coralRed.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.loop_rounded, size: 18, color: AppColors.coralRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    aversion.addictionCycleInsight,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Clinical Evidence Points
          Text(
            isTamil ? 'உறுதிப்படுத்தப்பட்ட மருத்துவ சான்றுகள்:' : 'Clinical Evidence & Reality Facts:',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.coralRed,
            ),
          ),
          const SizedBox(height: 6),
          ...aversion.evidencePoints.map((pt) => _buildEvidenceItem(pt, AppColors.coralRed)),
        ],
      ),
    );
  }

  Widget _buildStepItem(String step, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 10, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              step,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textDark,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_rounded, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textDark,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _cycleEmpathy() {
    HapticFeedback.selectionClick();
    setState(() => _empathyVariant++);
    _fetchRecommendations();
  }

  void _cycleAversion() {
    HapticFeedback.selectionClick();
    setState(() => _aversionVariant++);
    _fetchRecommendations();
  }

  void _handleAction(String actionType, int pointsReward) {
    HapticFeedback.mediumImpact();
    final provider = Provider.of<PatientProvider>(context, listen: false);
    final result = provider.addPoints(
      pointsReward,
      activityKey: 'craving_action_$actionType',
      cooldown: const Duration(minutes: 15),
    );
    final isTamil = provider.isTamil;

    if (actionType == 'breathe') {
      setState(() => _activeTabIndex = 0);
      _startBreathingCycle();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: result.awarded ? AppColors.primaryTeal : AppColors.amberGold,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            result.awarded
                ? (isTamil
                    ? '4-7-8 சுவாசப் பயிற்சி தொடங்கியது! (+${pointsReward} புள்ளிகள்)'
                    : '4-7-8 Breathing Pacer started! (+${pointsReward} Pts added)')
                : '${result.message} (Exercise started)',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
      );
    } else if (actionType == 'delay') {
      _startDelayTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.amberGold,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            isTamil
                ? '3 நிமிட தாமத சவால் தொடங்கியது! டைமரை இங்கே பார்க்கலாம்.'
                : '3-Minute Delay Challenge started! Watch the timer right here.',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
      );
    } else if (actionType == 'water') {
      setState(() {
        _activeTabIndex = 2;
        _waterGlasses++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: result.awarded ? AppColors.skyBlue : AppColors.amberGold,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            result.awarded
                ? (isTamil
                    ? 'குளிர்ந்த நீர் பதிவு செய்யப்பட்டது! (+${pointsReward} புள்ளிகள்)'
                    : 'Fresh cold water logged! (+${pointsReward} Pts added)')
                : result.message,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
      );
    } else if (actionType == 'lungs_audit') {
      _showHealthMilestonesModal(isTamil);
    } else if (actionType == 'tar_reality') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => DisgustPage()));
    }
  }

  void _showHealthMilestonesModal(bool isTamil) {
    final provider = Provider.of<PatientProvider>(context, listen: false);
    final milestones = provider.healthMilestones;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isTamil ? 'உடல்நல மீட்பு மைல்கற்கள்' : 'Biological Recovery Milestones',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isTamil
                      ? 'புகைபிடிக்காத ஒவ்வொரு மணிநேரமும் உங்கள் உடல் அமைதியாக குணமடைகிறது.'
                      : 'Scientific milestones showing how your body actively recovers right now.',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: milestones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ms = milestones[index];
                      final isComplete = ms.progress >= 1.0;
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isComplete ? AppColors.mintFresh : AppColors.lightCardBorder,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(ms.icon, size: 18, color: isComplete ? AppColors.mintFresh : AppColors.primaryTeal),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ms.title,
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
                                    color: isComplete ? AppColors.mintFresh : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    ms.timeFrame,
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isComplete ? Colors.white : AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ms.description,
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: ms.progress,
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isComplete ? AppColors.mintFresh : AppColors.primaryTeal,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getIntensityColor() {
    if (_selectedIntensity <= 3) return AppColors.mintFresh;
    if (_selectedIntensity <= 7) return AppColors.amberGold;
    return AppColors.coralRed;
  }

  Widget _build4DsTabSelector(bool isTamil) {
    final tabs = [
      {'title': isTamil ? 'ஆழ்ந்த சுவாசம்' : 'Deep Breathe', 'icon': Icons.air},
      {'title': isTamil ? '3 நிமிடம் தாமதிக்க' : 'Delay 3m', 'icon': Icons.timer_outlined},
      {'title': isTamil ? 'குளிர்ந்த நீர் அருந்த' : 'Drink Water', 'icon': Icons.water_drop_outlined},
      {'title': isTamil ? 'கவனத்தை திசைதிருப்ப' : 'Distract', 'icon': Icons.videogame_asset_outlined},
    ];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _activeTabIndex == index;
          return InkWell(
            onTap: () {
              setState(() {
                _activeTabIndex = index;
              });
              HapticFeedback.selectionClick();
            },
            borderRadius: BorderRadius.circular(24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryTeal
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppColors.primaryTeal : const Color(0xFFE2E8F0),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryTeal.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tabs[index]['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tabs[index]['title'] as String,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActive4DTab(bool isTamil, PatientProvider patient) {
    switch (_activeTabIndex) {
      case 0:
        return _buildBreathingWidget(isTamil);
      case 1:
        return _buildDelayWidget(isTamil, patient);
      case 2:
        return _buildWaterWidget(isTamil);
      case 3:
      default:
        return _buildDistractWidget(isTamil);
    }
  }

  Widget _buildBreathingWidget(bool isTamil) {
    return Container(
      key: const ValueKey(0),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isTamil ? '4-7-8 சுவாசப் பயிற்சி' : '4-7-8 Breathing Pacer',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isTamil ? 'சுழற்சிகள்: $_cyclesCompleted' : 'Cycles: $_cyclesCompleted',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Animated Multi-Layer Concentric Pulsing Breathing Orb
          _isBreathingActive
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    // Concentric outer ripple 2
                    ScaleTransition(
                      scale: _breathScaleAnimation,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Concentric outer ripple 1
                    ScaleTransition(
                      scale: _breathScaleAnimation,
                      child: Container(
                        width: 195,
                        height: 195,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.mintFresh.withValues(alpha: 0.12),
                          border: Border.all(
                            color: AppColors.mintFresh.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    // Core breathing orb
                    ScaleTransition(
                      scale: _breathScaleAnimation,
                      child: Container(
                        width: 165,
                        height: 165,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              Colors.white,
                              AppColors.mintFresh,
                            ],
                            stops: [0.2, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mintFresh.withValues(alpha: 0.6),
                              blurRadius: 35,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_breathSecondsLeft',
                              style: GoogleFonts.outfit(
                                fontSize: 46,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDeepTeal,
                              ),
                            ),
                            Text(
                              isTamil ? 'விநாடிகள்' : 'seconds',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDeepTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  width: 175,
                  height: 175,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.spa_rounded, size: 48, color: AppColors.mintFresh),
                      const SizedBox(height: 6),
                      Text(
                        '4-7-8',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        isTamil ? 'தொடங்க தயார்' : 'Ready to begin',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

          const SizedBox(height: 30),
          Text(
            _getBreathPhaseText(isTamil),
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            isTamil
                ? 'இதயத் துடிப்பை அமைதிப்படுத்தி ஆசையைத் தணிக்கிறது'
                : 'Oxygenates your blood and deactivates craving impulses',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),

          // Start / Pause Control Button
          Container(
            constraints: const BoxConstraints(minHeight: 48),
            child: ElevatedButton.icon(
              onPressed: _isBreathingActive ? _stopBreathingCycle : _startBreathingCycle,
              icon: Icon(
                _isBreathingActive ? Icons.pause_circle_rounded : Icons.play_circle_fill_rounded,
                color: _isBreathingActive ? Colors.white : AppColors.primaryDeepTeal,
                size: 22,
              ),
              label: Text(
                _isBreathingActive
                    ? (isTamil ? 'பயிற்சியை நிறுத்து' : 'Pause Pacer')
                    : (isTamil ? 'பயிற்சியைத் தொடங்கு' : 'Start 4-7-8 Breathing'),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _isBreathingActive ? Colors.white : AppColors.primaryDeepTeal,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isBreathingActive ? Colors.white.withValues(alpha: 0.25) : AppColors.mintFresh,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDelayWidget(bool isTamil, PatientProvider patient) {
    int mins = _delaySeconds ~/ 60;
    int secs = _delaySeconds % 60;
    final reflections = _getDynamicReflections(patient);
    final reflection = reflections[_delaySeconds % reflections.length];

    return Container(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.lightCardBorder),
      ),
      child: Column(
        children: [
          Text(
            isTamil ? '3 நிமிட சவால்: தாமதிக்கவும்' : 'The 3-Minute Delay Challenge',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isTamil
                ? 'புகைபிடிக்கும் ஆசை 3-5 நிமிடங்களுக்குள் உச்சத்தை அடைந்து தணியும்.'
                : 'Craving brain surges fade naturally within 3 minutes. Hold on.',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.amberGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
              style: GoogleFonts.outfit(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.amberGold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _delayActive ? null : _startDelayTimer,
            icon: Icon(_delayActive ? Icons.hourglass_top : Icons.play_arrow),
            label: Text(
              _delayActive
                  ? (isTamil ? 'டைமர் இயங்குகிறது...' : 'Timer Active...')
                  : (isTamil ? '3 நிமிட டைமரைத் தொடங்கு' : 'Start 3-Minute Timer'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amberGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 16),
          // Dynamic personalized reflection card
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Container(
              key: ValueKey(reflection.getText(isTamil)),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightCardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.amberGold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(reflection.icon, color: AppColors.amberGold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      reflection.getText(isTamil),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterWidget(bool isTamil) {
    return Container(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.lightCardBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.water_drop, color: AppColors.skyBlue, size: 50)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 1.seconds),
          const SizedBox(height: 12),
          Text(
            isTamil ? 'ஒரு குவளை தண்ணீர் குடிக்கவும்' : 'Drink a Glass of Cool Water',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isTamil
                ? 'தண்ணீர் குடிப்பது உங்கள் வாயின் வறட்சியைப் போக்கி நிக்கோடின் ஆசையை உடனடியாக திசைதிருப்புகிறது.'
                : 'Sipping water flushes nicotine metabolites and satisfies oral fixation impulses.',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final filled = index < _waterGlasses;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  filled ? Icons.local_drink : Icons.local_drink_outlined,
                  color: filled ? AppColors.skyBlue : AppColors.textSubtle,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                if (_waterGlasses < 4) _waterGlasses++;
              });
              final result = Provider.of<PatientProvider>(context, listen: false).addPoints(
                10,
                activityKey: 'hydration_log',
                cooldown: const Duration(minutes: 15),
              );
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: result.awarded ? AppColors.skyBlue : AppColors.amberGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Text(
                    result.awarded
                        ? (isTamil ? '💧 குடிநீர் அருந்தியது பதிவு செய்யப்பட்டது! (+10 புள்ளிகள்)' : '💧 Hydration logged! (+10 Health Points)')
                        : result.message,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: Text(isTamil ? 'குடித்ததை பதிவு செய் (+10 Pts)' : 'Log Glass Drank (+10 Pts)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.skyBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistractWidget(bool isTamil) {
    return Container(
      key: const ValueKey(3),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.lightCardBorder),
      ),
      child: Column(
        children: [
          Text(
            isTamil ? 'மனதை மாற்ற விரைவு குறுக்குவழிகள்' : 'Instant Cognitive Distractions',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: AppColors.primaryTeal),
            ),
            title: Text(
              isTamil ? '24/7 AI உளவியல் ஆலோசகர் ஆரியா' : '24/7 AI Cessation Counselor (Aria)',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              isTamil
                  ? 'நிகழ்நேர உளவியல் ஆலோசனை மற்றும் உடனடி ஆதரவு அரட்டை'
                  : 'CBT conversational coping, craving de-escalation & guidance',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AICounselorScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.volunteer_activism_rounded, color: AppColors.primaryTeal),
            ),
            title: Text(isTamil ? 'பரிவு AI • உளவியல் அரவணைப்பு' : 'Empathy AI • Emotional Safehouse', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text(isTamil ? '4-7-8 சுவாசப் பயிற்சி மற்றும் குற்ற உணர்வற்ற ஆலோசனை' : 'Animated vagus nerve reset & cognitive behavioral reassurance', style: GoogleFonts.inter(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => EmpPage()));
            },
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.mintFresh.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.sports_esports, color: AppColors.mintFresh),
            ),
            title: Text(isTamil ? '60 வினாடி நரம்பியல் விளையாட்டு' : '60-Second Focus Puzzle', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text(isTamil ? 'விரைவான கவனச்சிதறல் விளையாட்டு மற்றும் 5-4-3-2-1 பயிற்சி' : 'Engage prefrontal cortex & 5-4-3-2-1 sensory grounding', style: GoogleFonts.inter(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DistractPage()));
            },
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.coralRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.shield, color: AppColors.coralRed),
            ),
            title: Text(isTamil ? 'எச்சரிக்கை AI • மருத்துவ உண்மை' : 'Aversion AI • Clinical Reality Shield', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text(isTamil ? 'நச்சு தார், இதய ரத்த நாளங்கள் மற்றும் நிதி சேமிப்பு' : 'Tar toxicity, arterial spasm facts & financial drain comparison', style: GoogleFonts.inter(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DisgustPage()));
            },
          ),
        ],
      ),
    );
  }
}
