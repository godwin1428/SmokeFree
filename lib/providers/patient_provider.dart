import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_config.dart';
import '../core/session_manager.dart';
import '../models/daily_checkin_result.dart';
import '../models/reward_result.dart';
import '../services/ai_behavioral_service.dart';
import '../ip.dart' as legacy;

class HealthMilestone {
  final String title;
  final String description;
  final double progress; // 0.0 to 1.0
  final String timeFrame;
  final IconData icon;

  HealthMilestone({
    required this.title,
    required this.description,
    required this.progress,
    required this.timeFrame,
    required this.icon,
  });
}

class PatientProvider extends ChangeNotifier {
  Timer? _tickerTimer;

  // Real-time metrics
  int _totalSecondsSmokeFree = 0;
  int _points = 0;
  double _moneySaved = 0.0;
  double _costPerCigarette = 15.0; // Default ₹15
  int _cigarettesPerDay = 10;
  String _doctorMessage = '';
  String _logDate = '';
  String _dqDate = '';
  String _bwkDate = '';
  bool _isLoading = false;
  String? _errorMessage;

  // AI Insights & Biweekly Reports
  AIDailyInsight? _latestAiInsight;
  AIBiweeklyReport? _latestBiweeklyReport;
  CravingAiRecommendations? _currentCravingAi;

  CravingAiRecommendations? get currentCravingAi => _currentCravingAi;

  // Language & Theme
  String _language = '1'; // 1 = Tamil, 2 = English
  ThemeMode _themeMode = ThemeMode.light;

  // Wishlist target
  String _wishlistName = 'Smartwatch';
  double _wishlistTarget = 5000.0;

  // Cooldown / Throttling timestamps by activityKey
  final Map<String, DateTime> _activityLastClaimed = {};

  PatientProvider({bool autoStartTicker = true}) {
    _initFromLegacy();
    if (autoStartTicker) {
      _startTicker();
    }
  }

  // Getters
  int get totalSecondsSmokeFree => _totalSecondsSmokeFree;
  int get days => _totalSecondsSmokeFree ~/ 86400;
  int get hours => (_totalSecondsSmokeFree % 86400) ~/ 3600;
  int get minutes => (_totalSecondsSmokeFree % 3600) ~/ 60;
  int get seconds => _totalSecondsSmokeFree % 60;

  int get points => _points;
  double get moneySaved => _moneySaved;
  int get cigarettesAvoided => ((days + (hours / 24.0)) * _cigarettesPerDay).round();
  int get lifeRegainedMinutes => cigarettesAvoided * 11; // ~11 mins per cigarette
  String get doctorMessage => _doctorMessage;
  String get userName => legacy.user_name;
  String get language => _language;
  bool get isTamil => _language == '1';
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get logDate => _logDate;
  String get dqDate => _dqDate;
  String get bwkDate => _bwkDate;
  AIDailyInsight? get latestAiInsight => _latestAiInsight;
  AIBiweeklyReport? get latestBiweeklyReport => _latestBiweeklyReport;

  String get wishlistName => _wishlistName;
  double get wishlistTarget => _wishlistTarget;
  double get wishlistProgress => (_wishlistTarget > 0)
      ? (_moneySaved / _wishlistTarget).clamp(0.0, 1.0)
      : 0.0;

  double get dailySavingsRate => _cigarettesPerDay * _costPerCigarette;

  String get projectedWishlistDate => AIBehavioralService().calculateProjectedWishlistDate(
        currentSavings: _moneySaved,
        targetPrice: _wishlistTarget,
        dailySavingsRate: dailySavingsRate,
      );

  void toggleTheme() {
    _themeMode = (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleLanguage() {
    setLanguage(_language == '1' ? '2' : '1');
  }

  void setLanguage(String lang) async {
    _language = lang;
    legacy.lang = lang;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(SessionManager.keyLang, lang);
    } catch (_) {}
    notifyListeners();
  }

  void setWishlist(String name, double target) {
    _wishlistName = name;
    _wishlistTarget = target;
    notifyListeners();
  }

  Future<void> _initFromLegacy() async {
    _points = int.tryParse(legacy.user_pnts) ?? 0;
    _moneySaved = double.tryParse(legacy.user_monsav) ?? 0.0;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString(SessionManager.keyLang);
      if (savedLang != null && savedLang.isNotEmpty) {
        _language = savedLang;
        legacy.lang = savedLang;
      } else {
        _language = legacy.lang.isNotEmpty ? legacy.lang : '2';
      }
    } catch (_) {
      _language = legacy.lang.isNotEmpty ? legacy.lang : '2';
    }

    // Load cached AI insight if available
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedInsight = prefs.getString('cached_ai_insight');
      if (cachedInsight != null) {
        _latestAiInsight = AIDailyInsight.fromJson(jsonDecode(cachedInsight));
      }
      final cachedWishlistName = prefs.getString('wishlist_name');
      final cachedWishlistTarget = prefs.getDouble('wishlist_target');
      if (cachedWishlistName != null) _wishlistName = cachedWishlistName;
      if (cachedWishlistTarget != null) _wishlistTarget = cachedWishlistTarget;

      // Load cached activity cooldown timestamps
      final cachedCooldowns = prefs.getString('activity_cooldown_timestamps');
      if (cachedCooldowns != null) {
        final decoded = jsonDecode(cachedCooldowns) as Map<String, dynamic>;
        decoded.forEach((key, val) {
          final dt = DateTime.tryParse(val.toString());
          if (dt != null) {
            _activityLastClaimed[key] = dt;
          }
        });
      }
    } catch (_) {}
    notifyListeners();
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalSecondsSmokeFree > 0) {
        _totalSecondsSmokeFree++;
        // Continuous fractional money accumulation
        _moneySaved += dailySavingsRate / 86400.0;
        legacy.user_monsav = _moneySaved.toStringAsFixed(0);
        notifyListeners();
      }
    });
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apiUrl = '${AppConfig.baseUrl}home.php';
      final username = legacy.userid;

      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({'username': username}),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] != 'failure') {
          _points = int.tryParse(data['points']?.toString() ?? '0') ?? 0;
          _moneySaved = double.tryParse(data['moneySaved']?.toString() ?? '0') ?? 0.0;
          _doctorMessage = data['docMsg']?.toString() ?? '';
          _logDate = data['logDate']?.toString() ?? '';
          _dqDate = data['dqDate']?.toString() ?? '';
          _bwkDate = data['bwkDate']?.toString() ?? '';

          final daysCount = int.tryParse(data['days']?.toString() ?? '0') ?? 0;
          _totalSecondsSmokeFree = daysCount * 86400;

          // Sync legacy globals
          legacy.user_pnts = _points.toString();
          legacy.user_monsav = _moneySaved.toStringAsFixed(0);
          legacy.user_ind = data['ind']?.toString() ?? '0';

          SessionManager().saveUserSession(
            username: username,
            role: 'patient',
            lang: _language,
            points: _points.toString(),
            moneySaved: _moneySaved.toStringAsFixed(0),
          );
        }
      }
    } catch (e) {
      _errorMessage = 'Using cached offline data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// AI-Powered Daily Check-in submission handler
  Future<AIDailyInsight> submitDailyCheckIn(DailyCheckIn checkIn) async {
    // 1. Analyze with AI Behavioral Service
    final insight = await AIBehavioralService().analyzeDailyCheckIn(
      checkIn: checkIn,
      userName: legacy.user_name.isNotEmpty ? legacy.user_name : legacy.userid,
      smokeFreeDays: days,
      totalMoneySaved: _moneySaved,
      isTamil: isTamil,
    );

    _latestAiInsight = insight;

    // 2. Adjust points and money based on real performance
    _points += insight.pointsAwarded;
    legacy.user_pnts = _points.toString();

    // If slips occurred, deduct only the real cost of those cigarettes
    if (checkIn.cigarettesSmoked > 0) {
      final double slipCost = checkIn.cigarettesSmoked * _costPerCigarette;
      _moneySaved = (_moneySaved - slipCost).clamp(0.0, double.infinity);
      legacy.user_monsav = _moneySaved.toStringAsFixed(0);
    }

    // 3. Mark check-in date as today
    final now = DateTime.now();
    _dqDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // 4. Cache AI Insight locally
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_ai_insight', jsonEncode(insight.toJson()));
    } catch (_) {}

    notifyListeners();
    return insight;
  }

  /// AI Biweekly Audit submission
  Future<AIBiweeklyReport> submitBiweeklyAudit({int slipsLogged = 0}) async {
    final report = AIBehavioralService().generateBiweeklyReport(
      patientName: legacy.user_name.isNotEmpty ? legacy.user_name : legacy.userid,
      smokeFreeDays: days,
      moneySaved: _moneySaved,
      slipsLogged: slipsLogged,
      isTamil: isTamil,
    );

    _latestBiweeklyReport = report;
    _doctorMessage = report.nextProtocolRecommendation;

    final now = DateTime.now();
    _bwkDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    notifyListeners();
    return report;
  }

  /// Returns remaining cooldown duration for an activity. If 0, activity can be claimed.
  Duration getRemainingCooldown(String activityKey, {Duration cooldown = const Duration(minutes: 15)}) {
    final lastTime = _activityLastClaimed[activityKey];
    if (lastTime == null) return Duration.zero;
    final elapsed = DateTime.now().difference(lastTime);
    if (elapsed >= cooldown) return Duration.zero;
    return cooldown - elapsed;
  }

  /// Checks if an activity is currently on cooldown / throttle.
  bool isActivityOnCooldown(String activityKey, {Duration cooldown = const Duration(minutes: 15)}) {
    return getRemainingCooldown(activityKey, cooldown: cooldown) > Duration.zero;
  }

  /// Returns user-friendly formatted remaining cooldown time (e.g. "14m 20s" or "Ready").
  String getFormattedRemainingCooldown(String activityKey, {Duration cooldown = const Duration(minutes: 15)}) {
    final remaining = getRemainingCooldown(activityKey, cooldown: cooldown);
    if (remaining <= Duration.zero) return 'Ready';
    final m = remaining.inMinutes;
    final s = remaining.inSeconds % 60;
    if (m > 0) return '${m}m ${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }

  /// Awards points with cooldown / throttling validation.
  /// If the activity is triggered before [cooldown] expires, reward is blocked.
  RewardResult awardPointsWithCooldown({
    required String activityKey,
    required int amount,
    Duration cooldown = const Duration(minutes: 15),
    String? customSuccessMessage,
    String? customCooldownMessage,
  }) {
    final remaining = getRemainingCooldown(activityKey, cooldown: cooldown);
    if (remaining > Duration.zero) {
      final m = remaining.inMinutes;
      final s = remaining.inSeconds % 60;
      final timeStr = m > 0 ? '${m}m ${s.toString().padLeft(2, '0')}s' : '${s}s';
      final message = customCooldownMessage ??
          (isTamil
              ? 'குளிர்விப்பு நேரம் செயலில் உள்ளது! ($timeStr பிறகு மீண்டும் பெறலாம்)'
              : 'Cooldown active! You can claim this reward again in $timeStr.');

      return RewardResult(
        awarded: false,
        pointsAdded: 0,
        currentTotalPoints: _points,
        remainingCooldown: remaining,
        activityKey: activityKey,
        message: message,
      );
    }

    _activityLastClaimed[activityKey] = DateTime.now();
    _saveCooldownTimestamps();

    _points += amount;
    legacy.user_pnts = _points.toString();
    notifyListeners();

    final message = customSuccessMessage ??
        (isTamil
            ? 'வெற்றி! +$amount புள்ளிகள் சேர்க்கப்பட்டன'
            : 'Awesome! +$amount points awarded');

    return RewardResult(
      awarded: true,
      pointsAdded: amount,
      currentTotalPoints: _points,
      remainingCooldown: cooldown,
      activityKey: activityKey,
      message: message,
    );
  }

  Future<void> _saveCooldownTimestamps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mapToSave = _activityLastClaimed.map((k, v) => MapEntry(k, v.toIso8601String()));
      await prefs.setString('activity_cooldown_timestamps', jsonEncode(mapToSave));
    } catch (_) {}
  }

  /// Universal points adder supporting optional activity cooldown / throttle validation.
  RewardResult addPoints(
    int amount, {
    String? activityKey,
    Duration cooldown = const Duration(minutes: 15),
  }) {
    if (activityKey != null) {
      return awardPointsWithCooldown(
        activityKey: activityKey,
        amount: amount,
        cooldown: cooldown,
      );
    }
    _points += amount;
    legacy.user_pnts = _points.toString();
    notifyListeners();
    return RewardResult(
      awarded: true,
      pointsAdded: amount,
      currentTotalPoints: _points,
      message: 'Points added successfully',
    );
  }

  /// Records an active craving coping event with cooldown throttling, awards +10 XP, and recalibrates AI protocol
  RewardResult logCravingIntervention({required int intensity, required List<String> triggers}) {
    final result = awardPointsWithCooldown(
      activityKey: ActivityCooldownKeys.cravingIntervention,
      amount: 10,
      cooldown: const Duration(minutes: 15),
    );

    if (intensity >= 7) {
      _doctorMessage = isTamil
          ? 'தீவிர ஆசை வெற்றிகரமாக சமாளிக்கப்பட்டது ($intensity/10): AI சுவாசப் பயிற்சி மற்றும் குளிர்ந்த நீர் அருந்துதல் பரிந்துரைக்கப்படுகிறது.'
          : 'High urge confronted ($intensity/10): Parasympathetic breathing and hydration activated.';
    }
    notifyListeners();
    return result;
  }

  /// Generates dynamic real-time Empathy & Aversion AI recommendations
  Future<CravingAiRecommendations> fetchCravingRecommendations({
    required int intensity,
    required List<String> triggers,
    int empathyVariant = 0,
    int aversionVariant = 0,
  }) async {
    final recs = await AIBehavioralService().generateCravingRecommendations(
      intensity: intensity,
      triggers: triggers,
      userName: legacy.user_name.isNotEmpty ? legacy.user_name : legacy.userid,
      smokeFreeDays: days,
      moneySaved: _moneySaved,
      isTamil: isTamil,
      empathyVariant: empathyVariant,
      aversionVariant: aversionVariant,
    );
    _currentCravingAi = recs;
    notifyListeners();
    return recs;
  }

  // Health Recovery Milestones based on scientific medical data
  List<HealthMilestone> get healthMilestones {
    final hoursTotal = _totalSecondsSmokeFree / 3600.0;

    return [
      HealthMilestone(
        title: isTamil ? 'இரத்த அழுத்தம் இயல்பு நிலை' : 'Blood Pressure Normalizes',
        description: isTamil
            ? 'இதயத் துடிப்பு மற்றும் இரத்த அழுத்தம் இயல்பு நிலைக்கு திரும்புகிறது'
            : 'Pulse rate & blood pressure settle down to healthy baseline',
        progress: (hoursTotal / 0.33).clamp(0.0, 1.0), // 20 mins
        timeFrame: isTamil ? '20 நிமிடங்கள்' : '20 Minutes',
        icon: Icons.favorite,
      ),
      HealthMilestone(
        title: isTamil ? 'கார்பன் மோனாக்சைடு வெளியேற்றம்' : 'Carbon Monoxide Drops',
        description: isTamil
            ? 'இரத்தத்தில் ஆக்ஸிஜன் அளவு வழக்கமான நிலையை அடைகிறது'
            : 'Blood oxygen levels return to normal, CO levels drop by 50%',
        progress: (hoursTotal / 8.0).clamp(0.0, 1.0),
        timeFrame: isTamil ? '8 மணி நேரம்' : '8 Hours',
        icon: Icons.air,
      ),
      HealthMilestone(
        title: isTamil ? 'சுவை மற்றும் வாசனை உணர்வு' : 'Taste & Smell Heighten',
        description: isTamil
            ? 'நரம்பு முனைகள் மீண்டும் வளரத் தொடங்குகின்றன'
            : 'Damaged nerve endings heal; sense of taste & smell sharpen',
        progress: (hoursTotal / 48.0).clamp(0.0, 1.0),
        timeFrame: isTamil ? '48 மணி நேரம்' : '48 Hours',
        icon: Icons.restaurant,
      ),
      HealthMilestone(
        title: isTamil ? 'சுவாசப்பாதை மற்றும் நுரையீரல்' : 'Bronchial Relaxation',
        description: isTamil
            ? 'சுவாசம் எளிதாகிறது, ஆற்றல் அளவு அதிகரிக்கிறது'
            : 'Breathing becomes noticeably easier; overall lung capacity expands',
        progress: (hoursTotal / 72.0).clamp(0.0, 1.0),
        timeFrame: isTamil ? '72 மணி நேரம்' : '72 Hours',
        icon: Icons.wind_power,
      ),
      HealthMilestone(
        title: isTamil ? 'நுரையீரல் திசு புதுப்பித்தல்' : 'Cilia Regeneration',
        description: isTamil
            ? 'நுரையீரல் சுத்திகரிப்பு திறன் வியத்தகு முறையில் மேம்படுகிறது'
            : 'Lungs clean out mucus; coughs and shortness of breath diminish',
        progress: (hoursTotal / (30 * 24.0)).clamp(0.0, 1.0),
        timeFrame: isTamil ? '1 மாதம்' : '1 Month',
        icon: Icons.health_and_safety,
      ),
    ];
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}
