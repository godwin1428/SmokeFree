import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';
import '../models/daily_checkin_result.dart';
import '../models/ai_chat_message.dart';
import 'cross_role_sync_service.dart';

class AIBehavioralService {
  static final AIBehavioralService _instance = AIBehavioralService._internal();
  factory AIBehavioralService() => _instance;
  AIBehavioralService._internal();

  /// Analyzes daily check-in input and generates an actionable AI insight
  Future<AIDailyInsight> analyzeDailyCheckIn({
    required DailyCheckIn checkIn,
    required String userName,
    required int smokeFreeDays,
    required double totalMoneySaved,
    bool isTamil = false,
  }) async {
    // If Gemini API Key is configured, attempt intelligent cloud generation
    if (AppConfig.geminiApiKey.isNotEmpty) {
      try {
        final cloudInsight = await _callGeminiApi(
          checkIn: checkIn,
          userName: userName,
          smokeFreeDays: smokeFreeDays,
          isTamil: isTamil,
        );
        if (cloudInsight != null) return cloudInsight;
      } catch (_) {
        // Fall back seamlessly to Clinical Heuristic Engine
      }
    }

    // Clinical Heuristic Cognitive Behavioral Engine (Always reliable, works 100% offline)
    return _generateClinicalCbtInsight(
      checkIn: checkIn,
      userName: userName,
      smokeFreeDays: smokeFreeDays,
      isTamil: isTamil,
    );
  }

  /// Clinical Heuristic Engine implementing ACT & CBT Cessation Protocols
  AIDailyInsight _generateClinicalCbtInsight({
    required DailyCheckIn checkIn,
    required String userName,
    required int smokeFreeDays,
    required bool isTamil,
  }) {
    final name = userName.isNotEmpty ? userName : (isTamil ? 'நண்பரே' : 'Friend');
    final moodLower = checkIn.mood.toLowerCase();
    final craving = checkIn.cravingScale;
    final smoked = checkIn.cigarettesSmoked;

    // CASE 1: Minor Slip (1-2 cigarettes) - Resiliency Protocol
    if (smoked > 0 && smoked <= 2) {
      return AIDailyInsight(
        riskLevel: RelapseRiskLevel.moderate,
        headline: isTamil ? 'மீட்சி கேடயம் இயக்கப்பட்டது' : 'Resilience Shield Activated',
        message: isTamil
            ? '$name, ஒரு சிறிய சறுக்கல் உங்கள் முழுப் பயணத்தையும் அழிக்காது. நீங்கள் $smokeFreeDays நாட்கள் புகைக்காமல் இருந்துள்ளீர்கள். உடனே ஆழ்ந்த சுவாசம் எடுத்து மீண்டும் தொடங்குங்கள்.'
            : '$name, a single slip does not undo $smokeFreeDays days of lung repair. Don’t fall into the all-or-nothing trap. Take 3 deep breaths and protect your streak right now.',
        recommendedTool: 'delay',
        actionLabel: isTamil ? '3 நிமிட சவாலை தொடங்கு' : 'Start 3-Min Delay Challenge',
        pointsAwarded: 10,
        adherenceRate: 92.0,
      );
    }

    // CASE 2: Heavy Slip (3+ cigarettes) - Urgent Intervention
    if (smoked > 2) {
      return AIDailyInsight(
        riskLevel: RelapseRiskLevel.high,
        headline: isTamil ? 'மருத்துவ ஆலோசனை தேவை' : 'Clinical Support Alert',
        message: isTamil
            ? 'இன்று $smoked சிகரெட்டுகள் பதிவாகியுள்ளன. நிக்கோடின் ஏற்பிகள் மீண்டும் தீவிரமடைந்துள்ளன. உங்கள் மருத்துவரிடம் ஆலோசனை பெறுங்கள் அல்லது அவசர SOS கேடயத்தை பயன்படுத்துங்கள்.'
            : '$smoked cigarettes reported today. Your dopamine pathways are vulnerable to a full relapse. Contact your clinician or activate your emergency SOS Craving shield immediately.',
        recommendedTool: 'doctor',
        actionLabel: isTamil ? 'மருத்துவருக்கு செய்தி அனுப்பு' : 'Message Doctor / Clinic',
        pointsAwarded: 5,
        adherenceRate: 75.0,
      );
    }

    // CASE 3: Clean Streak (0 cigarettes) - Dynamic Mood & Craving Calibration
    if (craving >= 7 || moodLower.contains('stress') || moodLower.contains('anxious') || moodLower.contains('அழுத்தம்')) {
      return AIDailyInsight(
        riskLevel: RelapseRiskLevel.high,
        headline: isTamil ? 'ஆசை எச்சரிக்கை: நரம்புத்தளர்ச்சி தணிப்பு' : 'High Craving Alert: De-escalate Stress',
        message: isTamil
            ? '$name, உங்கள் இன்றைய மனநிலை அழுத்தம் மற்றும் ஆசை ($craving/10) உயர்ந்துள்ளது. இது உளவியல் ரீதியான நிக்கோடின் ஏமாற்று வேலை. 4-7-8 சுவாச பயிற்சி உங்கள் இதயத் துடிப்பை உடனே சீராக்கும்.'
            : '$name, elevated stress and craving ($craving/10) detected. This is a false dopamine spike. Your parasympathetic nervous system needs 4-7-8 breathing right now to reset your pulse.',
        recommendedTool: 'breathe',
        actionLabel: isTamil ? '4-7-8 சுவாசத்தை தொடங்கு' : 'Start 4-7-8 Breathing Pacer',
        pointsAwarded: 25,
        adherenceRate: 100.0,
      );
    }

    if (craving >= 4 || moodLower.contains('sad') || moodLower.contains('frustrat') || moodLower.contains('சலிப்பு')) {
      return AIDailyInsight(
        riskLevel: RelapseRiskLevel.moderate,
        headline: isTamil ? 'கவனம் திசைதிருப்பும் நேரம்' : 'Mid-Level Craving: Divert Focus',
        message: isTamil
            ? 'வாயின் வறட்சியைப் போக்க ஒரு குவளை குளிர்ந்த நீர் குடியுங்கள். நிக்கோடின் நச்சுகள் சிறுநீர் வழியாக வேகமாக வெளியேறும்.'
            : 'Sip a glass of cool water right now. It satisfies the oral fixation circuit while flushing residual nicotine metabolites out through your kidneys.',
        recommendedTool: 'water',
        actionLabel: isTamil ? 'குளிர்ந்த நீர் அருந்து' : 'Log Glass of Water (+10 Pts)',
        pointsAwarded: 25,
        adherenceRate: 100.0,
      );
    }

    // Pristine, Happy, Low Craving
    return AIDailyInsight(
      riskLevel: RelapseRiskLevel.low,
      headline: isTamil ? 'அருமையான முன்னேற்றம்! மூளை புதுப்பிக்கப்படுகிறது' : 'Peak Neurochemical Stability',
      message: isTamil
          ? '$name, அருமை! நீங்கள் 0 சிகரெட்டுகளுடன் அமைதியான மனநிலையில் உள்ளீர்கள். உங்கள் மூளையின் டோபமைன் உணர்விகள் முற்றிலும் இயற்கையான சமநிலையை அடைகின்றன.'
          : '$name, extraordinary resilience! You are smoke-free with low craving ($craving/10). Your brain’s nicotinic acetylcholine receptors are down-regulating to non-smoker levels.',
      recommendedTool: 'distract',
      actionLabel: isTamil ? 'வெற்றியை கொண்டாடு' : 'Keep Breathing Free (+25 Pts)',
      pointsAwarded: 25,
      adherenceRate: 100.0,
    );
  }

  /// Cloud Gemini API Integration (when key is present)
  Future<AIDailyInsight?> _callGeminiApi({
    required DailyCheckIn checkIn,
    required String userName,
    required int smokeFreeDays,
    required bool isTamil,
  }) async {
    final prompt = '''
You are "Aria", a certified clinical Cognitive Behavioral Therapy (CBT) smoking cessation physician.
Patient Name: $userName
Smoke-Free Days: $smokeFreeDays
Today's Mood: ${checkIn.mood}
Craving Scale (1-10): ${checkIn.cravingScale}
Cigarettes Smoked Today: ${checkIn.cigarettesSmoked}
Triggers: ${checkIn.triggers.join(', ')}
Language: ${isTamil ? 'Tamil' : 'English'}

Output STRICTLY JSON with this structure:
{
  "riskLevel": 0 for low or 1 for moderate or 2 for high,
  "headline": "concise 4-word title",
  "message": "compassionate 2-sentence clinical guidance referencing their specific mood and craving",
  "recommendedTool": "breathe" or "water" or "delay" or "distract" or "doctor",
  "actionLabel": "short button label"
}
''';

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${AppConfig.geminiApiKey}',
    );

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [{'text': prompt}]
          }
        ],
        'generationConfig': {'response_mime_type': 'application/json'}
      }),
    ).timeout(const Duration(seconds: 4));

    if (res.statusCode == 200) {
      final jsonResponse = jsonDecode(res.body);
      final rawText = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      final parsed = jsonDecode(rawText);

      return AIDailyInsight(
        riskLevel: RelapseRiskLevel.values[(parsed['riskLevel'] as int).clamp(0, 2)],
        headline: parsed['headline'] ?? 'Clinical Daily Guidance',
        message: parsed['message'] ?? '',
        recommendedTool: parsed['recommendedTool'] ?? 'breathe',
        actionLabel: parsed['actionLabel'] ?? 'Open Coping Tool',
        pointsAwarded: checkIn.cigarettesSmoked == 0 ? 25 : 10,
      );
    }
    return null;
  }

  /// AI Biweekly Clinical Audit Generator for Patients & Doctors
  AIBiweeklyReport generateBiweeklyReport({
    required String patientName,
    required int smokeFreeDays,
    required double moneySaved,
    required int slipsLogged,
    required bool isTamil,
  }) {
    final coughReduction = (smokeFreeDays * 2.5).clamp(15, 85).toInt();
    final sleepImprovement = (smokeFreeDays * 3.0).clamp(20, 90).toInt();

    final patientSummary = isTamil
        ? 'கடந்த 14 நாட்களில், உங்கள் இருமல் $coughReduction% குறைந்துள்ளது, தூக்கத்தின் தரம் $sleepImprovement% உயர்ந்துள்ளது. சேமித்த தொகை ₹${moneySaved.toStringAsFixed(0)}.'
        : 'Over the last 14 days, respiratory coughing dropped by $coughReduction% and deep REM sleep improved by $sleepImprovement%. Total monetary savings: ₹${moneySaved.toStringAsFixed(0)}.';

    final doctorClinicalBriefing =
        'SOAP PROGRESS NOTE: Patient $patientName completed biweekly evaluation. '
        'Abstinence adherence: ${(100 - (slipsLogged * 5)).clamp(70, 100)}%. '
        'Bronchial clearance active ($coughReduction% reduction in dyspnea/cough). '
        'Withdrawal severity stabilized. Clinical recommendation: Maintain current nicotine tapering and daily behavioral check-ins.';

    return AIBiweeklyReport(
      generatedDate: DateTime.now(),
      patientProgressSummary: patientSummary,
      doctorClinicalBriefing: doctorClinicalBriefing,
      coughReductionPercent: coughReduction,
      sleepImprovementPercent: sleepImprovement,
      nextProtocolRecommendation: 'Continue 4-7-8 breathing and weekly spirometry curve monitoring.',
    );
  }

  /// Projects the exact calendar date when the patient will afford their wishlist goal
  String calculateProjectedWishlistDate({
    required double currentSavings,
    required double targetPrice,
    required double dailySavingsRate,
  }) {
    if (targetPrice <= currentSavings) {
      return 'Goal Achieved! Ready to purchase 🎉';
    }
    if (dailySavingsRate <= 0) {
      return 'Calculating timeline...';
    }

    final double amountRemaining = targetPrice - currentSavings;
    final int daysNeeded = (amountRemaining / dailySavingsRate).ceil();
    final targetDate = DateTime.now().add(Duration(days: daysNeeded));

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${months[targetDate.month - 1]} ${targetDate.day}, ${targetDate.year} ($daysNeeded days)';
  }

  /// AI-Powered Real-Time Empathy and Aversion Recommendation Generator
  Future<CravingAiRecommendations> generateCravingRecommendations({
    required int intensity,
    required List<String> triggers,
    required String userName,
    required int smokeFreeDays,
    required double moneySaved,
    bool isTamil = false,
    int empathyVariant = 0,
    int aversionVariant = 0,
  }) async {
    // Attempt Gemini Cloud Generation if API key is configured
    if (AppConfig.geminiApiKey.isNotEmpty) {
      try {
        final cloudResult = await _callGeminiCravingApi(
          intensity: intensity,
          triggers: triggers,
          userName: userName,
          smokeFreeDays: smokeFreeDays,
          moneySaved: moneySaved,
          isTamil: isTamil,
          empathyVariant: empathyVariant,
          aversionVariant: aversionVariant,
        );
        if (cloudResult != null) return cloudResult;
      } catch (_) {
        // Fall back gracefully to clinical heuristic engine
      }
    }

    // Clinical Heuristic Cognitive Behavioral Engine (100% offline, highly personalized)
    var empathy = _generateClinicalEmpathy(
      intensity: intensity,
      triggers: triggers,
      userName: userName,
      smokeFreeDays: smokeFreeDays,
      isTamil: isTamil,
      variant: empathyVariant,
    );

    // Cross-Role Sync: Weave active Admin Therapeutic Directives
    try {
      final activeDirectives = await CrossRoleSyncService().getActiveAiDirectives();
      for (final d in activeDirectives) {
        if ((d['category'] == 'Craving SOS' || d['category'] == 'Mindfulness') &&
            d['text'] != null &&
            d['text']!.isNotEmpty) {
          empathy = EmpathyRecommendation(
            headline: empathy.headline,
            message: '${d['text']!}\n\n${empathy.message}',
            emotionalInsight: empathy.emotionalInsight,
            actionLabel: empathy.actionLabel,
            actionType: empathy.actionType,
            stepByStepGuide: empathy.stepByStepGuide,
          );
          break;
        }
      }
    } catch (_) {}

    final aversion = _generateClinicalAversion(
      intensity: intensity,
      triggers: triggers,
      moneySaved: moneySaved,
      smokeFreeDays: smokeFreeDays,
      isTamil: isTamil,
      variant: aversionVariant,
    );

    return CravingAiRecommendations(
      empathy: empathy,
      aversion: aversion,
      intensity: intensity,
      triggers: triggers,
      timestamp: DateTime.now(),
    );
  }

  EmpathyRecommendation _generateClinicalEmpathy({
    required int intensity,
    required List<String> triggers,
    required String userName,
    required int smokeFreeDays,
    required bool isTamil,
    required int variant,
  }) {
    final name = userName.isNotEmpty ? userName : (isTamil ? 'நண்பரே' : 'Friend');
    final primaryTrigger = triggers.isNotEmpty ? triggers.first : 'Urge';
    final modVariant = variant % 2;

    // TIER 1: Low Intensity (1-3)
    if (intensity <= 3) {
      if (modVariant == 0) {
        return EmpathyRecommendation(
          headline: isTamil ? 'மன அமைதி மற்றும் விழிப்புணர்வு' : 'Gentle Mindful Observation',
          message: isTamil
              ? '$name, இந்த லேசான ஆசை ($intensity/10) உங்கள் மூளை பழைய பழக்கத்தை மறந்து குணமடைந்து வருவதன் அறிகுறி. நீங்கள் $smokeFreeDays நாட்கள் வெற்றிகரமாக புகைக்காமல் இருந்துள்ளீர்கள்.'
              : '$name, this mild urge ($intensity/10) is merely an echo of an old habit fading away. You have built $smokeFreeDays smoke-free days of pure strength.',
          emotionalInsight: isTamil
              ? 'இந்த லேசான தூண்டுதலுடன் சண்டையிட வேண்டாம்; அதை அமைதியாக கவனித்து கடந்து செல்லுங்கள்.'
              : 'Mild cravings do not require resistance—they simply need peaceful observation until they dissipate.',
          stepByStepGuide: isTamil
              ? [
                  '1. உங்கள் உடலின் நிலையை உணருங்கள்; தோள்களை தளர்வாக்குங்கள்.',
                  '2. மூக்கின் வழியாக 3 முறை மெதுவாக ஆழமாக சுவாசியுங்கள்.',
                  '3. ஒரு டம்ளர் குளிர்ந்த நீர் அருந்தி உற்சாகமடையுங்கள்.',
                ]
              : [
                  '1. Scan your body and release tension in your shoulders and jaw.',
                  '2. Take 3 slow, restorative diaphragmatic breaths.',
                  '3. Acknowledge your inner control and continue your routine.',
                ],
          actionLabel: isTamil ? '2 நிமிட சுவாச பயிற்சி' : 'Start 2-Min Breathing',
          actionType: 'breathe',
          pointsReward: 10,
        );
      } else {
        return EmpathyRecommendation(
          headline: isTamil ? 'வெற்றியை உறுதிப்படுத்தும் நேரம்' : 'Positive Habit Reinforcement',
          message: isTamil
              ? 'மிகச்சிறிய உந்துதல் மட்டுமே உள்ளது. உங்கள் சுயக்கட்டுப்பாடு இன்று உச்சத்தில் உள்ளது!'
              : 'You are firmly in the driver’s seat. Your brain’s natural dopamine system is taking charge.',
          emotionalInsight: isTamil
              ? 'ஒவ்வொரு முறை சிறிய ஆசையை வெல்லும் போதும் உங்கள் தன்னம்பிக்கை இரட்டிப்பாகிறது.'
              : 'Every minor craving surfed without resistance physically strengthens your prefrontal cortex.',
          stepByStepGuide: isTamil
              ? [
                  '1. உங்கள் கண்களை மூடி 1 நிமிடம் அமைதியாக இருங்கள்.',
                  '2. உங்கள் இலக்கை நினைத்து பெருமிதம் கொள்ளுங்கள்.',
                  '3. சுத்தமான குளிர்ந்த நீரை மெதுவாக குடியுங்கள்.',
                ]
              : [
                  '1. Close your eyes for 60 seconds of complete silence.',
                  '2. Affirm: "My lungs and body are healing with every clean breath."',
                  '3. Sip a glass of cool water to refresh your senses.',
                ],
          actionLabel: isTamil ? 'குளிர்ந்த நீர் அருந்து' : 'Drink Fresh Water',
          actionType: 'water',
          pointsReward: 10,
        );
      }
    }

    // TIER 2: Moderate Intensity (4-6)
    if (intensity <= 6) {
      if (modVariant == 0) {
        return EmpathyRecommendation(
          headline: isTamil ? 'உளவியல் தூண்டுதல் மாற்றம் ($primaryTrigger)' : 'Targeted Trigger Reframe ($primaryTrigger)',
          message: isTamil
              ? '$name, $primaryTrigger காரணமாக உங்கள் நரம்பு மண்டலம் அமைதியை நாடுகிறது. ஆனால் சிகரெட் தற்காலிக ஏமாற்று வேலை மட்டுமே செய்யும். உண்மையான அமைதி உங்கள் சுவாசத்தில் உள்ளது.'
              : '$name, feeling this moderate pull during "$primaryTrigger" is normal. Your brain learned to pair this moment with nicotine. Let’s uncouple that connection right now.',
          emotionalInsight: isTamil
              ? 'இது நிக்கோடினின் தேவை அல்ல; உங்கள் மூளைக்கு ஒரு சிறிய கவனச்சிதறல் மட்டுமே தேவை.'
              : 'This is not a chemical emergency—it is a conditioned behavioral loop that breaks in 3 minutes.',
          stepByStepGuide: isTamil
              ? [
                  '1. சூழ்நிலையை உடனடியாக மாற்றுங்கள் (எழுந்து வெளியே வாருங்கள்).',
                  '2. 3 நிமிட தாமத சவாலை செயல்படுத்தி ஆசையின் அலையைக் கடக்கவும்.',
                  '3. நாவை ஈரப்படுத்த குளிர்ந்த நீர் அருந்துங்கள்.',
                ]
              : [
                  '1. Physically change your posture or step into a different room.',
                  '2. Activate the 3-minute delay challenge to surf the wave.',
                  '3. Sip ice-cold water to engage the vagus nerve.',
                ],
          actionLabel: isTamil ? '3 நிமிட தாமத சவால்' : 'Start 3-Min Delay Timer',
          actionType: 'delay',
          pointsReward: 15,
        );
      } else {
        return EmpathyRecommendation(
          headline: isTamil ? 'நரம்பு மண்டல சமநிலை பயிற்சி' : 'Emotional De-escalation Protocol',
          message: isTamil
              ? 'மிதமான ஆசை ($intensity/10) ஏற்பட்டாலும் உங்கள் வலிமை அதைவிட பெரியது. உங்கள் சுவாசத்தை சீராக்குவோம்.'
              : 'A level $intensity urge feels uncomfortable, but discomfort is the feeling of old neural connections dissolving.',
          emotionalInsight: isTamil
              ? 'விரக்தி அடையாதீர்கள்; இந்த உணர்வு அடுத்த 5 நிமிடங்களில் தானாகவே தணிந்துவிடும்.'
              : 'You do not have to fight the urge with willpower; simply outlast the 3-minute dopamine half-life.',
          stepByStepGuide: isTamil
              ? [
                  '1. கண்களை மூடி மூச்சை 4 வினாடி உள்ளிழுத்து 8 வினாடி வெளிவிடுங்கள்.',
                  '2. நீங்கள் உணரும் 5 வெவ்வேறு ஒலிகளை கவனியுங்கள்.',
                  '3. ஒரு சிற்றுண்டி அல்லது புதினா மிட்டாய் சுவையுங்கள்.',
                ]
              : [
                  '1. Inhale for 4 seconds, exhale slowly through pursed lips for 8 seconds.',
                  '2. Identify 3 tactile textures around you (grounding exercise).',
                  '3. Sip cool water and remind yourself: "This feeling will pass."',
                ],
          actionLabel: isTamil ? '4-7-8 சுவாசத்தை தொடங்கு' : 'Start 4-7-8 Breathing',
          actionType: 'breathe',
          pointsReward: 15,
        );
      }
    }

    // TIER 3: High Intensity (7-10)
    return EmpathyRecommendation(
      headline: isTamil ? 'அவசர அமைதி கேடயம் ($intensity/10)' : 'Urgent Craving Rescue Protocol',
      message: isTamil
          ? '$name, தீவிரமான ஆசை ($intensity/10) உங்கள் மேல் மோதுகிறது. ஆனால் நீங்கள் பாதுகாப்பாக இருக்கிறீர்கள்! இந்த அலை அடுத்த 180 வினாடிகளில் உடையும். எந்த முடிவும் எடுக்காதீர்கள்; சுவாசியுங்கள்.'
          : '$name, you are in the peak storm right now ($intensity/10). Your nervous system is flooded with false urgency, but you are completely safe. The wave peaks at 3 minutes and then drops sharply. Breathe through it.',
      emotionalInsight: isTamil
          ? 'இது அவசர எச்சரிக்கை உணர்வு மட்டுமே; சிகரெட் உங்களை அமைதிப்படுத்தாது, அது உங்கள் இதயத்தை மேலும் வேகமாக துடிக்க வைக்கும்.'
          : 'A craving is merely a biological sensation, not a command. Do not negotiate with the urge right now.',
      stepByStepGuide: isTamil
          ? [
              '1. உடனே அமருங்கள், இரு கால்களையும் தரையில் உறுதியாக வையுங்கள்.',
              '2. 4-7-8 சுவாச பயிற்சியை உடனே தொடங்கி இதயத் துடிப்பை குறைக்கவும்.',
              '3. முகத்தில் குளிர்ந்த நீரை தெளித்து அதிர்ச்சியை தணிக்கவும்.',
              '4. அடுத்த 3 நிமிடங்களுக்கு சிகரெட் பற்றி எந்த முடிவும் எடுக்க வேண்டாம்.',
            ]
          : [
              '1. Sit down and plant both feet firmly on the ground.',
              '2. Launch the 4-7-8 breathing pacer to physically reset your pulse.',
              '3. Splash cold water on your face to trigger the mammalian dive reflex.',
              '4. Commit to just 3 minutes of delay—the peak will collapse.',
            ],
      actionLabel: isTamil ? 'அவசர 4-7-8 சுவாசத்தை தொடங்கு' : 'Emergency 4-7-8 Breathing',
      actionType: 'breathe',
      pointsReward: 20,
    );
  }

  AversionRecommendation _generateClinicalAversion({
    required int intensity,
    required List<String> triggers,
    required double moneySaved,
    required int smokeFreeDays,
    required bool isTamil,
    required int variant,
  }) {
    final primaryTrigger = triggers.isNotEmpty ? triggers.first : 'Urge';
    final modVariant = variant % 2;

    // TIER 1: Low Intensity (1-3)
    if (intensity <= 3) {
      return AversionRecommendation(
        headline: isTamil ? 'நுரையீரல் குணமடைதல் பாதுகாப்பு' : 'Endothelial & Cilia Defense',
        biologicalReality: isTamil
            ? 'புகைபிடிக்காத $smokeFreeDays நாட்களில், உங்கள் இரத்தத்தில் கார்பன் மோனாக்சைடு அளவு முற்றிலும் பூஜ்ஜியமாகிவிட்டது. ஒரு சிறிய இழுப்பு கூட 48 மணி நேரத்திற்கு உங்கள் மூச்சுக்குழாய் முடிகளை (cilia) முடக்கிவிடும்.'
            : 'During your $smokeFreeDays smoke-free days, blood carbon monoxide dropped to normal and bronchial cilia regenerated. A single puff paralyzes these microscopic sweepers for 48 hours.',
        financialOrGoalImpact: isTamil
            ? 'நீங்கள் இதுவரை சேமித்துள்ள ₹${moneySaved.toStringAsFixed(0)} உங்கள் இலக்கை நோக்கி பாதுகாக்கப்பட்டுள்ளது. சிகரெட் உங்கள் உழைப்பை சாம்பலாக்க விடாதீர்கள்.'
            : 'Your accumulated savings of ₹${moneySaved.toStringAsFixed(0)} represent freedom. Don’t burn hard-earned cash back into tobacco industry profits.',
        addictionCycleInsight: isTamil
            ? 'லேசான ஆசை என்பது உங்கள் மூளையின் பழைய நிக்கோடின் ஏற்பிகள் பசியால் அழியும் செயல்முறை. அவற்றுக்கு உணவளிக்காதீர்கள்.'
            : 'Mild cravings are the dying gasps of desensitized nicotinic receptors. Starving them now accelerates full receptor reset.',
        evidencePoints: isTamil
            ? [
                '• இரத்தத்தில் ஆக்ஸிஜன் அளவு 98-99% உச்சத்தில் உள்ளது.',
                '• இரத்த நாளங்களின் நெகிழ்வுத்தன்மை வேகமாக திரும்புகிறது.',
                '• இன்று உங்கள் உடலுக்குள் எந்த நச்சுத்தன்மையும் நுழையவில்லை.',
              ]
            : [
                '• Blood oxygen saturation is at an optimal 98–99%.',
                '• Arterial endothelial elasticity is actively recovering.',
                '• Zero toxic aldehydes or benzene crossed your blood-brain barrier today.',
              ],
        actionLabel: isTamil ? 'உடல்நல மீட்பை ஆய்வு செய்' : 'Inspect Health Milestones',
        actionType: 'lungs_audit',
        pointsReward: 10,
      );
    }

    // TIER 2: Moderate Intensity (4-6)
    if (intensity <= 6) {
      if (modVariant == 0) {
        return AversionRecommendation(
          headline: isTamil ? 'நிக்கோடின் பொறி ($primaryTrigger சூழல்)' : 'The Nicotine Illusion Trap ($primaryTrigger)',
          biologicalReality: isTamil
              ? 'சிகரெட் பிடித்த 10 வினாடிகளில் நிக்கோடின் உங்கள் இதயத் துடிப்பை 15-20 துடிப்புகள் அதிகரித்து இரத்தக் குழாய்களை 25% சுருக்குகிறது. சிகரெட் அமைதி தருவதில்லை, அது உடலுக்கு கூடுதல் ரசாயன அழுத்தத்தை உருவாக்குகிறது.'
              : 'Within 10 seconds of inhaling, nicotine constricts coronary arteries by up to 25% and spikes heart rate by 15–20 bpm. Smoking does NOT relieve stress—it chemically causes acute cardiovascular stress.',
          financialOrGoalImpact: isTamil
              ? 'ஒரே ஒரு சிகரெட் பழைய பழக்கத்தை தூண்டி மாதம் ₹3,000 முதல் ₹6,000 வரை வீண் விரயத்திற்கு வழிவகுக்கும்.'
              : 'Relapsing costs an average of ₹3,000–₹6,000 every month, actively depleting your goal savings and delaying your dreams.',
          addictionCycleInsight: isTamil
              ? 'சிகரெட் தரும் "நிம்மதி" என்பது அதுவே உருவாக்கிய நிக்கோடின் பசியை தற்காலிகமாக தணிப்பது மட்டுமே. அது சுதந்திரம் அல்ல, தொடர் அடிமைத்தனம்.'
              : 'Smoking only relieves the chemical withdrawal created by the previous cigarette. It cures nothing—it perpetuates the cycle of craving.',
          evidencePoints: isTamil
              ? [
                '• புகையில் 7,000 ரசாயனங்கள் மற்றும் 69 புற்றுநோய் காரணிகள் உள்ளன.',
                '• நிக்கோடின் இரத்த அழுத்தத்தை 30 வினாடிகளில் உயர்த்துகிறது.',
                '• நுரையீரல் செல்களில் உடனடியாக தார் படிவு ஏற்படுகிறது.',
              ]
            : [
                '• Each cigarette deposits sticky, carcinogenic tar directly on delicate lung alveoli.',
                '• Carbon monoxide irreversibly blocks oxygen transport in red blood cells.',
                '• Vasospasm starves facial skin and heart tissue of clean blood flow.',
              ],
          actionLabel: isTamil ? 'தாமத கேடயத்தை செயல்படுத்து' : 'Activate 3-Min Delay Shield',
          actionType: 'delay',
          pointsReward: 15,
        );
      } else {
        return AversionRecommendation(
          headline: isTamil ? 'இரத்த நாளங்கள் மற்றும் தார் எச்சரிக்கை' : 'Cardiovascular & Tar Reality',
          biologicalReality: isTamil
              ? 'சிகரெட் புகையில் உள்ள தார், ஈயம், ஆர்சனிக் மற்றும் கார்பன் மோனாக்சைடு உங்கள் இரத்த ஓட்டத்தில் கலந்து நரம்புகளை சுருக்குகிறது.'
              : 'Inhaling cigarette smoke floods arterial walls with heavy metals, benzene, and carbon monoxide, triggering immediate arterial inflammation.',
          financialOrGoalImpact: isTamil
              ? 'சிகரெட்டுக்கு செலவிடும் பணம் மருத்துவமனை செலவுகளாக மாறுவதைத் தடுக்கும் ஒரே கேடயம் உங்கள் கட்டுப்பாடு.'
              : 'Every rupee diverted from cigarettes is direct investment into your health and financial independence.',
          addictionCycleInsight: isTamil
              ? 'நீங்கள் இப்போது இந்த ஆசையை முறியடித்தால், அடுத்த ஆசை பாதியாகக் குறையும்.'
              : 'Resisting this exact urge weakens the dopamine reward cue permanently. Surrender resets the clock to day zero.',
          evidencePoints: isTamil
              ? [
                '• ஒரு சிகரெட் கூட நுரையீரல் மூச்சுப்பாதையை அழற்சி அடையச் செய்யும்.',
                '• நச்சுப்புகை பற்கள் மற்றும் சுவாசத்தில் துர்நாற்றத்தை ஏற்படுத்துகிறது.',
                '• 3 நிமிடங்களில் இந்த ஆசை தானாகவே மடியும்.',
              ]
            : [
                '• 95% of peak cravings evaporate within 3 to 5 minutes without smoking.',
                '• Nicotine leaves behind acidic metabolites that irritate gastric lining.',
                '• One slip demands another within 45 minutes—break the chain now.',
              ],
          actionLabel: isTamil ? 'குளிர்ந்த நீர் அதிர்ச்சி முறை' : 'Drink Ice Water Reset',
          actionType: 'water',
          pointsReward: 15,
        );
      }
    }

    // TIER 3: High Intensity (7-10)
    return AversionRecommendation(
      headline: isTamil ? 'உச்சக்கட்ட ரசாயன உண்மை ($intensity/10)' : 'Acute Addiction Reality Check ($intensity/10)',
      biologicalReality: isTamil
          ? 'இந்த தீவிர ஆசை நிக்கோடின் ஏற்பிகள் பசியில் கூச்சலிடுவதால் ஏற்படுகிறது. நீங்கள் சிகரெட்டை தொட்டால், 10 வினாடிகளில் அசிட்டோன், அம்மோனியா மற்றும் தார் உங்கள் நுரையீரலில் படிந்து இதயத் துடிப்பை 25 bpm வரை எகிற வைக்கும்.'
          : 'This intense urge ($intensity/10) is your nicotinic receptors screaming for an artificial dopamine dump. Giving in injects arsenic, formaldehyde, and carbon monoxide, spiking resting heart rate by 25 bpm and triggering acute arterial spasm.',
      financialOrGoalImpact: isTamil
          ? 'நீங்கள் கஷ்டப்பட்டு சேர்த்த ₹${moneySaved.toStringAsFixed(0)} சேமிப்பை இழக்காதீர்கள். ஒரு நிமிடம் சிந்தியுங்கள்!'
          : 'You have protected ₹${moneySaved.toStringAsFixed(0)} in hard-won savings. Relapsing directly surrenders your financial target to tobacco corporations.',
      addictionCycleInsight: isTamil
          ? 'சிகரெட் ஒரு பொய் வாக்குறுதி. அது தரும் 5 நிமிட போலி திருப்தி அடுத்த 40 நிமிடத்தில் மீண்டும் அதே தீவிர ஆசையை இரட்டிப்பாக்கும். இந்த சங்கிலியை இப்போதே உடையுங்கள்!'
          : 'The cigarette promises relief, but it is an absolute biochemical lie. It leaves the exact same craving waiting for you 45 minutes later. Break the chain right now—the peak is already dissolving.',
      evidencePoints: isTamil
          ? [
              '• 180 வினாடிகளுக்குள் இந்த ஆசை தன் தீவிரத்தை இழக்கும்.',
              '• நிக்கோடின் இரத்த அழுத்தத்தை உடனே ஆபத்தான நிலைக்கு உயர்த்தும்.',
              '• புகைபிடிப்பது மன அழுத்தத்தை குறைப்பதில்லை, உடலின் நச்சு அழுத்தத்தை அதிகரிக்கிறது.',
            ]
          : [
              '• 95% of peak cravings crash and dissolve within 180 to 300 seconds.',
              '• Inhaling introduces 69 known carcinogens into your bloodstream.',
              '• You are completely in control—a craving is a physical sensation, not an order.',
            ],
      actionLabel: isTamil ? 'குளிர்ந்த நீர் மற்றும் தாமதம்' : 'Ice Water Shock & 5m Delay',
      actionType: 'delay',
      pointsReward: 20,
    );
  }

  /// Cloud Gemini API generator for personalized Empathy and Aversion
  Future<CravingAiRecommendations?> _callGeminiCravingApi({
    required int intensity,
    required List<String> triggers,
    required String userName,
    required int smokeFreeDays,
    required double moneySaved,
    required bool isTamil,
    required int empathyVariant,
    required int aversionVariant,
  }) async {
    final prompt = '''
You are a dual-mode clinical smoking cessation AI engine.
Patient Name: $userName
Smoke-Free Days: $smokeFreeDays
Money Saved: ₹$moneySaved
Craving Intensity (1-10): $intensity
Triggers: ${triggers.join(', ')}
Language: ${isTamil ? 'Tamil' : 'English'}
Empathy Strategy Variant: $empathyVariant
Aversion Strategy Variant: $aversionVariant

Generate strictly valid JSON with TWO personalized recommendation objects:
{
  "empathy": {
    "headline": "concise 3-word title",
    "message": "compassionate 2-sentence emotional validation and reassurance tailored to the craving intensity and triggers",
    "emotionalInsight": "1 sentence on why the patient is experiencing this emotional urge",
    "stepByStepGuide": ["step 1", "step 2", "step 3"],
    "actionLabel": "short actionable button text (e.g. Start 4-7-8 Breathing)",
    "actionType": "breathe" or "delay" or "water"
  },
  "aversion": {
    "headline": "concise 3-word clinical title",
    "biologicalReality": "2 sentences of objective, non-shaming, evidence-based physiological reality of smoking",
    "financialOrGoalImpact": "1 sentence connecting smoking cost to their ₹$moneySaved saved",
    "addictionCycleInsight": "1 sentence explaining why smoking does not cure stress",
    "evidencePoints": ["fact 1", "fact 2", "fact 3"],
    "actionLabel": "short action text (e.g. Activate 3-Min Delay Shield)",
    "actionType": "delay" or "water" or "lungs_audit"
  }
}
''';

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${AppConfig.geminiApiKey}',
    );

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [{'text': prompt}]
          }
        ],
        'generationConfig': {'response_mime_type': 'application/json'}
      }),
    ).timeout(const Duration(seconds: 4));

    if (res.statusCode == 200) {
      final jsonResponse = jsonDecode(res.body);
      final rawText = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      final parsed = jsonDecode(rawText);

      return CravingAiRecommendations(
        empathy: EmpathyRecommendation.fromJson(parsed['empathy']),
        aversion: AversionRecommendation.fromJson(parsed['aversion']),
        intensity: intensity,
        triggers: triggers,
        timestamp: DateTime.now(),
      );
    }
    return null;
  }

  /// AI-Powered Behavioral Motivation Generator
  /// Adapts content across 4 pillars (Self Motivation, Leverage, Seduction, Social)
  /// and 3 timeframes (Today, 1 Week, 1 Month) based on Daily Check-in & Craving Intensity.
  MotivationContent generateMotivationContent({
    required MotivationPillar pillar,
    required MotivationTimeframe timeframe,
    required int cravingIntensity,
    required String mood,
    required int smokeFreeDays,
    required double moneySaved,
    required String wishlistName,
    required double wishlistTarget,
    required bool isTamil,
  }) {
    final isHighUrge = cravingIntensity >= 7;
    final isNegativeMood = mood == 'Stressed' || mood == 'Anxious' || mood == 'Frustrated' || mood == 'Sad';

    switch (pillar) {
      // ----------------------------------------------------
      // 1. SELF MOTIVATION: Internal Identity & Willpower
      // ----------------------------------------------------
      case MotivationPillar.selfMotivation:
        if (timeframe == MotivationTimeframe.today) {
          if (isHighUrge || isNegativeMood) {
            return MotivationContent(
              pillar: pillar,
              timeframe: timeframe,
              headline: isTamil ? 'உடனடி சுய உறுதி: ஆசை ஒரு கட்டளை அல்ல' : 'Immediate Self-Command: Cravings Are Not Orders',
              mantra: isTamil ? '“ஆசை உடலின் தற்காலிக உணர்வு மட்டுமே, அது என் எஜமான் அல்ல.”' : '“A craving is a temporary sensation, not an order from a master.”',
              insight: isTamil
                  ? 'உங்கள் தற்போதைய மனநிலை ($mood) மற்றும் தீவிர ஆசை ($cravingIntensity/10) நிக்கோடின் பசியின் இறுதி கூச்சல். நிக்கோடின் ஏற்பிகள் உணவின்றி அழிகின்றன. அவற்றுக்கு உணவளிக்காதீர்கள்!'
                  : 'Your current state ($mood) with craving level ($cravingIntensity/10) is your brain’s dopamine receptors starving. Starving them right now permanently weakens their grip.',
              impactMetricLabel: isTamil ? 'இன்றைய தூய சுவாசம்' : 'Today’s Lungs Protected',
              impactMetricValue: isTamil ? '100% தூய்மை' : '100% Clean Air',
              actionStep: isTamil ? '3 முறை ஆழ்ந்து மூச்சை இழுத்து கால்களை தரையில் உறுதியாக வையுங்கள்.' : 'Take 3 deep grounding breaths and plant both feet firmly on the ground.',
              keyBullets: isTamil
                  ? [
                      '• ஆசை 180 வினாடிகளில் தானாகவே தணியும்.',
                      '• நீங்கள் ஒரு சிகரெட்டுக்கு அடிமையல்ல, உங்கள் உடலின் எஜமான்.',
                      '• இன்றைய ஒரு நாளை மட்டும் வெல்லுங்கள்—முழு வாழ்வும் வெல்லப்படும்.',
                    ]
                  : [
                      '• Cravings naturally crest and collapse within 180 seconds.',
                      '• You are not a slave to tobacco; you are in full command of your body.',
                      '• Win just this single 24-hour block—tomorrow takes care of itself.',
                    ],
              pointsReward: 15,
            );
          } else {
            return MotivationContent(
              pillar: pillar,
              timeframe: timeframe,
              headline: isTamil ? 'இன்றைய சுதந்திரத்தின் முழு கட்டுப்பாடு' : 'Sovereign Control of Today',
              mantra: isTamil ? '“புகை இல்லாத சுதந்திரம் எந்த சிகரெட்டையும் விட இனிமையானது.”' : '“Freedom from smoking feels better than any cigarette ever tasted.”',
              insight: isTamil
                  ? 'இன்று நீங்கள் அமைதியான ($mood) மனநிலையில் உள்ளீர்கள். சிகரெட் இல்லாத ஒவ்வொரு மணிநேரமும் உங்கள் இரத்த ஓட்டத்தை புதுப்பிக்கிறது.'
                  : 'You are feeling $mood today. Every smoke-free hour cleanses your vascular system and cements your new non-smoker identity.',
              impactMetricLabel: isTamil ? 'புகைக்காத நாட்கள்' : 'Smoke-Free Days',
              impactMetricValue: '$smokeFreeDays Days',
              actionStep: isTamil ? 'ஒரு நிமிடம் உங்கள் நுரையீரலின் தூய காற்றை உணருங்கள்.' : 'Spend 60 seconds feeling clean, untainted oxygen filling your chest.',
              keyBullets: isTamil
                  ? [
                      '• நீங்கள் புகையிலையின் பொய்யை முறியடித்துவிட்டீர்கள்.',
                      '• இன்று உங்கள் உடலுக்குள் எந்த நச்சுத்தன்மையும் நுழையவில்லை.',
                      '• அமைதி சிகரெட்டில் இல்லை, உங்கள் தெளிவான மனதில் உள்ளது.',
                    ]
                  : [
                      '• You have actively dismantled the tobacco trap today.',
                      '• Zero toxic carcinogens entered your bloodstream today.',
                      '• Genuine peace comes from clear lungs, not burning chemical paper.',
                    ],
              pointsReward: 10,
            );
          }
        } else if (timeframe == MotivationTimeframe.oneWeek) {
          return MotivationContent(
            pillar: pillar,
            timeframe: timeframe,
            headline: isTamil ? '7 நாள் நரம்பியல் மறுசீரமைப்பு மைல்கல்' : '7-Day Neuro-Plasticity Breakthrough',
            mantra: isTamil ? '“7 நாட்கள் என்பது வெறும் நேரம் அல்ல—அது மூளையின் புதிய வடிவம்.”' : '“7 days is not just time—it is biological brain rewiring in action.”',
            insight: isTamil
                ? 'ஒரு வாரத்தில் உங்கள் மூளையின் அசிடைல்கோலின் ஏற்பிகள் இயல்பு நிலைக்கு திரும்புகின்றன. ஆசையின் தீவிரம் ($cravingIntensity/10) இனி வேகமாக சரியும்.'
                : 'In 7 smoke-free days, desensitized nicotinic receptors drop significantly. Your urge threshold ($cravingIntensity/10) is entering a permanent downturn.',
            impactMetricLabel: isTamil ? 'தவிர்க்கப்பட்ட சிகரெட்டுகள்' : 'Weekly Cigarettes Avoided',
            impactMetricValue: '~70 Sticks',
            actionStep: isTamil ? 'இந்த வாரத்தில் நீங்கள் ஆசையை முறியடித்த 3 தருணங்களை நினைவுகூருங்கள்.' : 'Reflect on 3 high-temptation moments this week where you firmly chose clean health.',
            keyBullets: isTamil
                ? [
                      '• நிக்கோடின் உடலை விட்டு முற்றிலும் வெளியேறிவிட்டது.',
                      '• சுவை மற்றும் வாசனை நரம்புகள் வேகமாக புத்துயிர் பெற்றுள்ளன.',
                      '• 7 நாள் மன உறுதி உங்கள் முழுமையான வெற்றியின் சான்று.',
                    ]
                : [
                      '• 100% of chemical nicotine has vacated your bloodstream.',
                      '• Damaged olfactory and taste nerve endings have regenerated.',
                      '• 7 days of discipline proves you possess unbreakable self-governance.',
                    ],
            pointsReward: 20,
          );
        } else {
          return MotivationContent(
            pillar: pillar,
            timeframe: timeframe,
            headline: isTamil ? '1 மாத முழுமையான அடையாள மாற்றம்' : '30-Day Permanent Identity Transmutation',
            mantra: isTamil ? '“நான் புகைபிடிப்பதை நிறுத்துபவன் அல்ல; நான் புகைபிடிக்காத மனிதன்!”' : '“I am no longer someone trying to quit; I am permanently a non-smoker!”',
            insight: isTamil
                ? '30 நாட்களில் பழக்கம் உளவியல் ரீதியாக முறிந்துவிட்டது. சிகரெட் உங்கள் அடையாளத்திலிருந்து முற்றிலுமாக நீக்கப்பட்டு புதிய மனிதராக மலர்ந்துள்ளீர்கள்.'
                : 'After 30 days, behavioral conditioning is shattered. You have crossed the psychological divide from an addict fighting urges to an empowered non-smoker.',
            impactMetricLabel: isTamil ? 'மீட்கப்பட்ட வாழ்நாள்' : 'Reclaimed Life Time',
            impactMetricValue: '55+ Hours',
            actionStep: isTamil ? 'உங்கள் புதிய நல்வாழ்வு அடையாளத்தை கொண்டாடுங்கள்.' : 'Celebrate your smoke-free transformation and share your pride with your family.',
            keyBullets: isTamil
                ? [
                      '• நுரையீரல் மூச்சுப்பாதை முடிகள் (cilia) முற்றிலும் புத்துயிர் பெற்றுள்ளன.',
                      '• மாரடைப்பு மற்றும் பக்கவாத அபாயம் 50% குறைந்துள்ளது.',
                      '• நீங்கள் ஒரு புதிய, ஆரோக்கியமான வாழ்க்கையை வென்றுள்ளீர்கள்.',
                    ]
                : [
                      '• Bronchial cilia have fully regenerated to clear deep lung mucus.',
                      '• Coronary artery attack risks have crashed by over 50%.',
                      '• You are living proof that total freedom is completely achievable.',
                    ],
            pointsReward: 30,
          );
        }

      // ----------------------------------------------------
      // 2. LEVERAGE: Pain vs Pleasure & Financial Mastery
      // ----------------------------------------------------
      case MotivationPillar.leverage:
        if (timeframe == MotivationTimeframe.today) {
          final dailyCost = 150.0;
          return MotivationContent(
            pillar: pillar,
            timeframe: timeframe,
            headline: isTamil ? 'இன்றைய இழப்பும் லாபமும்: ₹$dailyCost சேமிப்பு' : 'The Daily Exchange Rate: ₹${dailyCost.toStringAsFixed(0)} Protected',
            mantra: isTamil ? '“5 நிமிட போலி திருப்திக்காக முழு நாள் உழைப்பை எரிக்காதீர்கள்.”' : '“Never trade an entire day of clean lungs for 5 minutes of toxic ash.”',
            insight: isTamil
                ? 'இன்று நீங்கள் ஒரு சிகரெட்டை தொட்டால், உங்கள் இன்றைய ₹$dailyCost சேமிப்பு சாம்பலாகி, 24 மணி நேர ஆக்ஸிஜன் சுத்திகரிப்பு அழிக்கப்படும்.'
                : 'Lighting up today doesn’t just burn ₹${dailyCost.toStringAsFixed(0)}—it erases today’s clean blood oxygen and resets your chemical withdrawal clock back to zero.',
            impactMetricLabel: isTamil ? 'இன்றைய சேமிப்பு' : 'Today’s Savings',
            impactMetricValue: '₹${dailyCost.toStringAsFixed(0)}',
            actionStep: isTamil ? 'இன்றைய ₹150 பணத்தை உங்கள் $wishlistName கனவு நிதிக்கு ஒதுக்குங்கள்.' : 'Mentally deposit today’s ₹150 directly into your $wishlistName dream target.',
            keyBullets: isTamil
                ? [
                      '• ₹150 புகையிலை நிறுவனங்களின் லாபமாக மாறாமல் உங்கள் கையில் உள்ளது.',
                      '• இன்று இரத்த நாளங்களில் நச்சு சுருக்கம் ஏற்படவில்லை.',
                      '• உங்கள் இலக்கு ($wishlistName) இன்று ஒரு படி நெருங்கியுள்ளது.',
                    ]
                : [
                      '• Today’s ₹150 remains in your pocket, not corporate tobacco profits.',
                      '• Coronary vasospasm avoided—heart beats with effortless vitality.',
                      '• Your target ($wishlistName) is one solid day closer to reality.',
                    ],
            pointsReward: 15,
          );
        } else if (timeframe == MotivationTimeframe.oneWeek) {
          final weeklyCost = 1050.0;
          return MotivationContent(
            pillar: pillar,
            timeframe: timeframe,
            headline: isTamil ? '1 வார கூட்டு லாபம்: ₹$weeklyCost & 15 மணி நேரம்' : '7-Day Compounding Freedom: ₹${weeklyCost.toStringAsFixed(0)} & 15 Clean Hours',
            mantra: isTamil ? '“சிறு ஒழுக்கங்கள் வாழ்நாள் முழுவதும் மாபெரும் சுதந்திரமாக மாறும்.”' : '“Daily micro-disciplines compound into unstoppable financial freedom.”',
            insight: isTamil
                ? 'ஒரு வாரத்தில் நீங்கள் ₹$weeklyCost பணத்தை பாதுகாத்துள்ளீர்கள். இந்த பணம் உங்கள் $wishlistName இலக்கின் கணிசமான பகுதியை அடைந்துவிட்டது.'
                : 'In 7 days, you’ve kept ₹${weeklyCost.toStringAsFixed(0)} safe and spared your lungs 70 toxic doses. That’s tangible capital advancing your $wishlistName target.',
            impactMetricLabel: isTamil ? 'வாராந்திர சேமிப்பு' : '7-Day Capital Guarded',
            impactMetricValue: '₹${weeklyCost.toStringAsFixed(0)}',
            actionStep: isTamil ? 'உங்கள் $wishlistName சேமிப்பு இலக்கின் முன்னேற்றத்தை பாருங்கள்.' : 'Open your wishlist progress tracker and witness your financial discipline paying off.',
            keyBullets: isTamil
                ? [
                      '• வாரத்திற்கு ₹1,000+ சேமிப்பு என்பது ஆண்டுக்கு ₹50,000+ நிதி விடுதலை.',
                      '• 70 சிகரெட்டுகளின் தார் உங்கள் நுரையீரலில் படியாமல் தடுக்கப்பட்டது.',
                      '• உங்கள் உடலின் ஆற்றல் மட்டம் வியத்தகு முறையில் உயர்ந்துள்ளது.',
                    ]
                : [
                      '• Saving ₹1,000+/week translates to ₹52,000+ per year in sovereign wealth.',
                      '• Over 70 doses of tar and benzene prevented from entering delicate alveoli.',
                      '• Daily physical stamina and morning energy have rebounded.',
                    ],
            pointsReward: 20,
          );
        } else {
          final monthlyCost = 4500.0;
          return MotivationContent(
            pillar: pillar,
            timeframe: timeframe,
            headline: isTamil ? '1 மாத நிதி விடுதலை: ₹$monthlyCost & புதிய இலக்கு' : '30-Day True Independence: ₹${monthlyCost.toStringAsFixed(0)} & Peak Longevity',
            mantra: isTamil ? '“நான் என் கனவுகளுக்கு முதலீடு செய்கிறேன், நச்சுக்கு அல்ல.”' : '“I invest in my family and dreams, never in toxic corporate poison.”',
            insight: isTamil
                ? '30 நாட்களில் நீங்கள் ₹$monthlyCost பணத்தை பாதுகாத்துள்ளீர்கள். இதுவரை உங்கள் மொத்த சேமிப்பு ₹${moneySaved.toStringAsFixed(0)}. இது உங்கள் உழைப்பின் வெற்றி!'
                : 'In 30 smoke-free days, you protect ₹${monthlyCost.toStringAsFixed(0)}. With total savings reaching ₹${moneySaved.toStringAsFixed(0)}, you have proven absolute fiscal and biological control.',
            impactMetricLabel: isTamil ? 'மொத்த சேமிப்பு' : 'Cumulative Protected',
            impactMetricValue: '₹${moneySaved.toStringAsFixed(0)}',
            actionStep: isTamil ? 'உங்கள் சேமித்த பணத்தில் ஒரு பகுதியை குடும்பத்தினருக்கு செலவிடுங்கள்.' : 'Allocate a reward from your smoke-free savings to celebrate with those you love.',
            keyBullets: isTamil
                ? [
                      '• ₹4,500+ மாத சேமிப்பு உங்கள் குடும்பத்தின் எதிர்கால பாதுகாப்பு.',
                      '• 300 சிகரெட்டுகள் தவிர்க்கப்பட்டு நுரையீரல் புற்றுநோய் ஆபத்து சரிந்துள்ளது.',
                      '• நீங்கள் உங்கள் குடும்பத்திற்கான பாதுகாப்பான நிழலாக மாறியுள்ளீர்கள்.',
                    ]
                : [
                      '• Over ₹4,500/month preserved directly for high-value life investments.',
                      '• 300+ sticks avoided—pulmonary infection vulnerabilities eradicated.',
                      '• You are building generational health and financial wealth.',
                    ],
            pointsReward: 30,
          );
        }

      // ----------------------------------------------------
      // 3. SEDUCTION: De-glamorizing the Trap & Risk Radar
      // ----------------------------------------------------
      case MotivationPillar.seduction:
        if (timeframe == MotivationTimeframe.today) {
          return MotivationContent(
            pillar: pillar,
            timeframe: timeframe,
            headline: isTamil ? '“ஒரே ஒரு இழுப்பு” என்ற மாய வலையை உடைத்தல்' : 'Exposing the “Just One Puff” Seduction Trap',
            mantra: isTamil ? '“ஒரே ஒரு சிகரெட் என்று ஒன்று கிடையாது; அது முழு அடிமைத்தனத்தின் மீள் வருகை.”' : '“There is no such thing as ‘just one puff.’ One puff is the entire relapse cycle returning.”',
            insight: isTamil
                ? 'இன்று உங்கள் மூளை “மன அழுத்தம் அதிகமாக உள்ளது, ஒரே ஒரு சிகரெட் அமைதி தரும்” என்று ஏமாற்றக்கூடும். சிகரெட் அமைதி தருவதில்லை—அது உருவாக்கிய பசியை அதுவே தீர்ப்பதாக நாடகமாடுகிறது!'
                : 'Today your brain might whisper: “You are stressed ($mood), just one puff will calm you down.” Realize this is a chemical lie: cigarettes don’t relieve stress; they only relieve the withdrawal distress they engineered!',
            impactMetricLabel: isTamil ? 'மாயை நிலை' : 'Risk Factor',
            impactMetricValue: isHighUrge ? (isTamil ? 'அதி தீவிர பொறி' : 'Acute Trick') : (isTamil ? 'விழிப்புணர்வு' : 'Under Radar'),
            actionStep: isTamil ? 'சத்தமாக சொல்லுங்கள்: “இது நிக்கோடினின் ஏமாற்று வேலை, என் குரல் அல்ல.”' : 'Voice aloud: “This urge is chemical manipulation, not my authentic desire.”',
            keyBullets: isTamil
                ? [
                      '• சிகரெட் எந்த பிரச்சனையையும் தீர்ப்பதில்லை—அதுவே மிகப்பெரிய பிரச்சனை.',
                      '• ஒரு இழுப்பு மூளையின் பழைய நிக்கோடின் பசியை மீண்டும் பற்றவைத்துவிடும்.',
                      '• 3 நிமிடங்கள் பொறுத்திருங்கள்—மாயை தானாகவே உடையும்.',
                    ]
                : [
                      '• Smoking never solves your stress—it only compounds it with self-disappointment.',
                      '• A single puff re-sensitizes dormant dopamine receptors within 10 seconds.',
                      '• Outlast the 180-second deceptive wave and witness the illusion fade.',
                    ],
            pointsReward: 15,
          );
        } else if (timeframe == MotivationTimeframe.oneWeek) {
          return MotivationContent(
            pillar: pillar,
            timeframe: timeframe,
            headline: isTamil ? '7-ஆம் நாள் “நான் கட்டுப்படுத்திவிட்டேன்” என்ற போலி நம்பிக்கை' : 'The 7-Day “I Can Control It Now” Complacency Trap',
            mantra: isTamil ? '“நம்பிக்கை நல்லது; ஆனால் அலட்சியம் ஆபத்தானது.”' : '“Confidence is healthy; complacency is the number one catalyst for relapse.”',
            insight: isTamil
                ? 'ஒரு வாரம் புகைக்காமல் இருந்த பிறகு, “நான் கட்டுப்படுத்திவிட்டேன், இப்போது நண்பர்களுடன் ஒரு சிகரெட் பிடித்தால் ஒன்றும் ஆகாது” என்ற மாயை தோன்றும். இதுவே மறுபிறவியின் மிகப்பெரிய பொறி!'
                : 'At day 7, quitters often feel proud and erroneously think: “I proved I can stop, so having one casual smoke won’t hurt.” That exact thought causes 80% of first-week relapses.',
            impactMetricLabel: isTamil ? 'பொறி எச்சரிக்கை' : 'Trap Probability',
            impactMetricValue: isTamil ? '80% எச்சரிக்கை' : 'High Alert',
            actionStep: isTamil ? 'அடுத்த 7 நாட்களுக்கு “பூஜ்ஜிய சகிப்புத்தன்மை” விதியை உறுதி செய்யுங்கள்.' : 'Recommit to a strict Zero-Compromise pact for the upcoming week.',
            keyBullets: isTamil
                ? [
                      '• உங்கள் நரம்பு மண்டலம் இன்னும் முழுமையாக குணமடையவில்லை.',
                      '• ஒரு முறை என்ற எண்ணம் பழைய சுழற்சியை முழுமையாக மீட்கும்.',
                      '• உங்கள் விழிப்புணர்வை எப்போதும் உச்சத்தில் வைத்திருங்கள்.',
                    ]
                : [
                      '• Your dopamine reward pathways are healing but still fragile.',
                      '• Casual smoking does not exist for an ex-smoker—stay 100% clean.',
                      '• True control means choosing not to take the bait.',
                    ],
            pointsReward: 20,
          );
        } else {
          return MotivationContent(
            pillar: pillar,
            timeframe: timeframe,
            headline: isTamil ? 'கடந்த கால பொய் ஏக்கம் vs உண்மை யதார்த்தம்' : 'Romanticized Nostalgia vs Biological Reality',
            mantra: isTamil ? '“சாம்பல், துர்நாற்றம் மற்றும் இருமலை நினைவுகூருங்கள்—சினிமா மாயையை அல்ல.”' : '“Remember the ash, the coughing, and the shame—not the romanticized delusion.”',
            insight: isTamil
                ? '1 மாதத்திற்குப் பிறகு, பழைய புகைபிடித்த தருணங்கள் அழகாக தோன்றும். காலை நேர நெஞ்சு சளி, வாய் துர்நாற்றம், படபடப்பு மற்றும் குற்ற உணர்வை உங்கள் நினைவகம் மறைக்கக்கூடும். உண்மையை மறக்காதீர்கள்!'
                : 'After 30 days, selective amnesia sets in. Your brain forgets the chronic morning phlegm, the burning throat, the bad breath, and the panic of running out of smokes. Ground yourself in medical reality.',
            impactMetricLabel: isTamil ? 'நினைவக உண்மை' : 'Reality Factor',
            impactMetricValue: isTamil ? 'உண்மை நிலை' : 'Crystal Clear',
            actionStep: isTamil ? 'நீங்கள் புகைபிடித்த காலத்தில் உணர்ந்த மிக மோசமான தருணத்தை நினைத்துப் பாருங்கள்.' : 'Contrast your worst smoking memory with how pristine and light your lungs feel right now.',
            keyBullets: isTamil
                ? [
                      '• புகையிலை விளம்பரங்கள் காட்டியது பொய், மருத்துவமனைகள் காண்பது உண்மை.',
                      '• புகை உங்களை ஸ்டைலாக்கவில்லை; அது உங்கள் உறுப்புகளை மெதுவாக சிதைத்தது.',
                      '• தூய்மையான சுவாசத்தின் பெருமிதத்தை என்றும் விட்டுக்கொடுக்காதீர்கள்.',
                    ]
                : [
                      '• Tobacco advertising sold an illusion; cancer wards treat the reality.',
                      '• Smoking never gave you charisma—it only stole your vitality and breath.',
                      '• Never trade the pride of clean breathing for stale chemical fumes.',
                    ],
            pointsReward: 30,
          );
        }

      // ----------------------------------------------------
      // 4. SOCIAL: Boundary Setting & Role Model Influence
      // ----------------------------------------------------
      case MotivationPillar.social:
        if (timeframe == MotivationTimeframe.today) {
          return MotivationContent(
            pillar: pillar,
            timeframe: timeframe,
            headline: isTamil ? 'இன்றைய சமூக கவசம்: “நான் புகைபிடிப்பதில்லை”' : 'Today’s Social Armor: “I Don’t Smoke”',
            mantra: isTamil ? '“மற்றவர்களை திருப்திப்படுத்த என் ஆரோக்கியத்தை நான் சமரசம் செய்ய மாட்டேன்.”' : '“My health is never open for negotiation to please someone else.”',
            insight: isTamil
                ? 'இன்று யாராவது உங்களுக்கு சிகரெட் கொடுத்தால், “நான் நிறுத்த முயற்சி செய்கிறேன்” என்று தயங்காதீர்கள். “நன்றி, நான் புகைபிடிப்பதில்லை!” என்று உறுதியாகக் கூறுங்கள்.'
                : 'If someone offers you a cigarette today, never say “I’m trying to quit” (which invites persuasion). Say clearly and firmly: “No thanks, I don’t smoke.” Own your non-smoker identity.',
            impactMetricLabel: isTamil ? 'சமூக எல்லை' : 'Social Boundary',
            impactMetricValue: isTamil ? 'உறுதியானது' : 'Unshakeable',
            actionStep: isTamil ? '“நான் புகைபிடிப்பதில்லை” என்று ஒரு முறை மனதிற்குள் சொல்லிப் பழகுங்கள்.' : 'Rehearse saying “No thanks, I’m clean” with unwavering eye contact.',
            keyBullets: isTamil
                ? [
                      '• உண்மையான நண்பர்கள் உங்கள் உடல்நலத்தை மதிப்பார்கள்.',
                      '• மற்றவர்களின் வற்புறுத்தலுக்காக உங்கள் ஆரோக்கியத்தை பணயம் வைக்காதீர்கள்.',
                      '• நீங்கள் ஒரு பலவீனமான நபர் அல்ல, சமூக அழுத்தத்தை வெல்லும் வீரன்.',
                    ]
                : [
                      '• True friends respect your discipline; unsupportive peers reveal their own trap.',
                      '• Social pressure has zero power unless you willingly surrender your authority.',
                      '• You are transforming into a social leader who refuses to be poisoned.',
                    ],
            pointsReward: 15,
          );
        } else if (timeframe == MotivationTimeframe.oneWeek) {
          return MotivationContent(
            pillar: pillar,
            timeframe: timeframe,
            headline: isTamil ? 'நண்பர்கள் வட்டத்தை நேர்மறையாக மாற்றுதல்' : 'Navigating High-Risk Social Situations',
            mantra: isTamil ? '“என் மாற்றம் மற்றவர்களுக்கும் வழிகாட்டியாக அமையும்.”' : '“My personal standard elevates those around me.”',
            insight: isTamil
                ? '7 நாட்களாக நீங்கள் புகைபிடிக்கும் நண்பர்களுடன் இருந்தும் சிகரெட்டை தொடவில்லை. நீங்கள் புகைபிடிக்காமல் மகிழ்ச்சியாக இருப்பதை பார்த்து அவர்களும் ஆச்சரியப்படுகிறார்கள்.'
                : 'For 7 days you have attended coffee breaks and social gatherings without inhaling smoke. Your calm discipline quietly demonstrates that socializing without poisoning oneself is completely possible.',
            impactMetricLabel: isTamil ? 'சமூக தாக்கம்' : 'Social Influence',
            impactMetricValue: isTamil ? 'முன்மாதிரி' : 'Pacesetter',
            actionStep: isTamil ? 'உங்கள் 7 நாள் வெற்றியை குடும்பத்தினர் அல்லது ஒரு நல்ல நண்பரிடம் பகிருங்கள்.' : 'Share your 7-day smoke-free milestone with someone who genuinely champions your success.',
            keyBullets: isTamil
                ? [
                      '• தேநீர் மற்றும் உணவு இடைவேளைகளில் சிகரெட் தேவையில்லை என்பதை நிரூபித்துள்ளீர்கள்.',
                      '• உங்கள் திடமான உறுதி மற்றவர்களுக்கும் உத்வேகம் அளிக்கிறது.',
                      '• உங்கள் ஆரோக்கியமான எல்லைகள் நண்பர்கள் மத்தியில் மரியாதையை பெற்றுத்தரும்.',
                    ]
                : [
                      '• You’ve uncoupled coffee breaks and meals from automatic smoking rituals.',
                      '• Your quiet resilience serves as silent permission for others to quit too.',
                      '• Setting boundaries earns long-term respect from peers.',
                    ],
            pointsReward: 20,
          );
        } else {
          return MotivationContent(
            pillar: pillar,
            timeframe: timeframe,
            headline: isTamil ? 'குடும்பத்தின் பாதுகாவலன்: 30 நாள் இரண்டாவது புகை பாதுகாப்பு' : 'The Family Guardian: 30 Days of Clean Air Gifted',
            mantra: isTamil ? '“என் குடும்பத்திற்கு நான் தரும் சிறந்த பரிசு என் நீண்ட ஆயுள்.”' : '“The greatest gift I give my loved ones is my vibrant, smoke-free presence.”',
            insight: isTamil
                ? '30 நாட்களில் உங்கள் குழந்தைகள், பெற்றோர் மற்றும் வாழ்க்கைத்துணை 30 நாட்களாக சிகரெட்டின் நச்சுப் புகையை (second-hand smoke) சுவாசிக்காமல் பாதுகாக்கப்பட்டுள்ளனர்.'
                : 'Over 30 smoke-free days, your children and family have been spared 30 continuous days of dangerous secondhand carcinogens. Your clothes, home, and hugs carry pure life.',
            impactMetricLabel: isTamil ? 'தூய காற்று பரிசு' : 'Clean Air Gifted',
            impactMetricValue: '30 Full Days',
            actionStep: isTamil ? 'உங்கள் குடும்பத்தினருடன் இந்த 1 மாத சுதந்திரத்தை இனிப்புடன் கொண்டாடுங்கள்.' : 'Hug your loved ones and let them feel the clean, fresh heartbeat of a healthy protector.',
            keyBullets: isTamil
                ? [
                      '• குடும்பத்தினர் மத்தியில் ஆஸ்துமா மற்றும் நுரையீரல் தொற்று ஆபத்து குறைந்துள்ளது.',
                      '• உங்கள் வீட்டில் புகையிலை துர்நாற்றம் நீங்கி புத்துணர்ச்சி மலர்ந்துள்ளது.',
                      '• நீங்கள் உங்கள் அடுத்த தலைமுறைக்கு சிறந்த வழிகாட்டியாக திகழ்கிறீர்கள்.',
                    ]
                : [
                      '• Secondhand smoke risks for children and partners slashed to absolute zero.',
                      '• Your home, car, and embrace smell clean, welcoming, and deeply safe.',
                      '• You have broken the generational cycle of smoking for your lineage.',
                    ],
            pointsReward: 30,
          );
        }
    }
  }

  // ===========================================================================
  // 24/7 INTERACTIVE AI CESSATION COUNSELOR ("ARIA")
  // ===========================================================================

  /// Connects patient with Aria, an AI cognitive-behavioral cessation specialist
  Future<AIChatMessage> chatWithAria({
    required String userMessage,
    required List<AIChatMessage> history,
    required String userName,
    required int smokeFreeDays,
    required double moneySaved,
    required int cigarettesAvoided,
    bool isTamil = false,
  }) async {
    // 1. Attempt Gemini 1.5 Flash Cloud Chat if API key is configured
    if (AppConfig.geminiApiKey.isNotEmpty) {
      try {
        final cloudMessage = await _callGeminiChat(
          userMessage: userMessage,
          history: history,
          userName: userName,
          smokeFreeDays: smokeFreeDays,
          moneySaved: moneySaved,
          cigarettesAvoided: cigarettesAvoided,
          isTamil: isTamil,
        );
        if (cloudMessage != null) return cloudMessage;
      } catch (_) {
        // Fall back gracefully to offline clinical heuristic engine
      }
    }

    // 2. Clinical Heuristic Cognitive Behavioral Engine (100% offline & instantaneous)
    return _generateClinicalAriaResponse(
      userMessage: userMessage,
      userName: userName,
      smokeFreeDays: smokeFreeDays,
      moneySaved: moneySaved,
      cigarettesAvoided: cigarettesAvoided,
      isTamil: isTamil,
    );
  }

  Future<AIChatMessage?> _callGeminiChat({
    required String userMessage,
    required List<AIChatMessage> history,
    required String userName,
    required int smokeFreeDays,
    required double moneySaved,
    required int cigarettesAvoided,
    required bool isTamil,
  }) async {
    final systemPrompt = '''
You are Aria, an empathetic, certified clinical Cognitive Behavioral Therapy (CBT) and pulmonology smoking cessation counselor in the SmokeFree health app.
Patient: $userName
Smoke-free streak: $smokeFreeDays days
Money saved: ₹$moneySaved
Cigarettes avoided: $cigarettesAvoided
Target Language: ${isTamil ? 'Tamil' : 'English'}

Instructions:
1. Provide compassionate, actionable, non-judgmental guidance in 2 to 3 sentences.
2. If patient feels craving or anxiety, emphasize that cravings peak in 3 minutes and subside.
3. Suggest a specific clinical tool if relevant: 'breathe' (4-7-8 breathing), 'delay' (3-minute timer), 'water' (cool water flush), or 'distract' (puzzle / grounding).
4. Strictly return JSON format:
{
  "reply": "your response in ${isTamil ? 'Tamil' : 'English'}",
  "actionType": "breathe" or "delay" or "water" or "distract" or null,
  "actionLabel": "short button label (e.g. Start 4-7-8 Breathing)" or null
}
''';

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${AppConfig.geminiApiKey}',
    );

    final contents = [
      {
        'role': 'user',
        'parts': [{'text': systemPrompt}]
      },
      ...history.take(6).map((msg) => {
            'role': msg.isUser ? 'user' : 'model',
            'parts': [{'text': msg.text}],
          }),
      {
        'role': 'user',
        'parts': [{'text': userMessage}]
      },
    ];

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': contents,
        'generationConfig': {'response_mime_type': 'application/json'},
      }),
    ).timeout(const Duration(seconds: 5));

    if (res.statusCode == 200) {
      final jsonResponse = jsonDecode(res.body);
      final rawText = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      final parsed = jsonDecode(rawText);
      return AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: parsed['reply'] ?? '',
        isUser: false,
        timestamp: DateTime.now(),
        actionType: parsed['actionType'],
        actionLabel: parsed['actionLabel'],
      );
    }
    return null;
  }

  AIChatMessage _generateClinicalAriaResponse({
    required String userMessage,
    required String userName,
    required int smokeFreeDays,
    required double moneySaved,
    required int cigarettesAvoided,
    required bool isTamil,
  }) {
    final lower = userMessage.toLowerCase();
    final name = userName.isNotEmpty ? userName : (isTamil ? 'நண்பரே' : 'Friend');

    // 1. Acute Peak Craving / Urgent Help
    if (lower.contains('urge') ||
        lower.contains('craving') ||
        lower.contains('want to smoke') ||
        lower.contains('need a smoke') ||
        lower.contains('cant resist') ||
        lower.contains('ஆசை') ||
        lower.contains('புகைக்க') ||
        lower.contains('தாங்க முடியல')) {
      return AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: isTamil
            ? '$name, உடனடியாக ஆழ்ந்த சுவாசம் எடுங்கள்! நினைவில் கொள்ளுங்கள்: நிக்கோடின் ஆசை 3 முதல் 5 நிமிடங்களில் உச்சத்தை அடைந்து தணியும். இந்த அலையை நாம் ஒன்றாக கடப்போம்.'
            : '$name, take a slow breath with me right now. Remember: a craving brain surge peaks and collapses in just 3 to 5 minutes. You do not have to fight it—simply outlast this single wave.',
        isUser: false,
        timestamp: DateTime.now(),
        actionType: 'breathe',
        actionLabel: isTamil ? '4-7-8 சுவாசத்தை தொடங்கு' : 'Launch 4-7-8 Breathing Pacer',
      );
    }

    // 2. Stress, Anxiety, Frustration, or Work
    if (lower.contains('stress') ||
        lower.contains('anxious') ||
        lower.contains('angry') ||
        lower.contains('frustrated') ||
        lower.contains('work') ||
        lower.contains('fight') ||
        lower.contains('அழுத்தம்') ||
        lower.contains('கோபம்') ||
        lower.contains('பதற்றம்')) {
      return AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: isTamil
            ? 'மன அழுத்தம் ஏற்படும் போது சிகரெட் தேடுவது ஒரு பழைய பழக்கம் மட்டுமே. ஆனால் சிகரெட் உங்கள் இதய துடிப்பை அதிகரித்து பதற்றத்தை இரட்டிப்பாக்கும். 3 நிமிடம் தாமதித்து மனதை அமைதிப்படுத்துங்கள்.'
            : 'When tension strikes, your brain erroneously pairs calm with nicotine. In truth, cigarettes spike your cortisol and heart rate. Let’s uncouple that loop—give yourself 3 minutes before making any decision.',
        isUser: false,
        timestamp: DateTime.now(),
        actionType: 'delay',
        actionLabel: isTamil ? '3 நிமிட சவாலை தொடங்கு' : 'Start 3-Minute Delay Shield',
      );
    }

    // 3. Post-Meal, Coffee, or Tea Triggers
    if (lower.contains('coffee') ||
        lower.contains('tea') ||
        lower.contains('meal') ||
        lower.contains('food') ||
        lower.contains('dinner') ||
        lower.contains('lunch') ||
        lower.contains('சாப்பாடு') ||
        lower.contains('காபி') ||
        lower.contains('தேநீர்')) {
      return AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: isTamil
            ? 'உணவு அல்லது காபிக்கு பிந்தைய ஆசை ஒரு தூண்டுதல் பழக்கம். ஒரு குவளை குளிர்ந்த நீர் அருந்தி உங்கள் வாயின் சுவையை மாற்றுங்கள்; இது நிக்கோடின் நரம்பியல் தூண்டுதலை உடனடியாக உடைக்கும்.'
            : 'Post-meal and coffee urges are conditioned oral triggers. Sipping cool water engages the vagus nerve and breaks the automatic hand-to-mouth motor loop. Refresh your palate now.',
        isUser: false,
        timestamp: DateTime.now(),
        actionType: 'water',
        actionLabel: isTamil ? 'குளிர்ந்த நீர் அருந்து' : 'Log Glass of Fresh Water',
      );
    }

    // 4. Reported Slip or Relapse Guilt
    if (lower.contains('smoke') ||
        lower.contains('smoked') ||
        lower.contains('relapse') ||
        lower.contains('slipped') ||
        lower.contains('failed') ||
        lower.contains('புகைத்துவிட்டேன்') ||
        lower.contains('தோற்றுவிட்டேன்')) {
      return AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: isTamil
            ? '$name, எந்த குற்ற உணர்வும் வேண்டாம்! நீங்கள் $smokeFreeDays நாட்கள் வெற்றிகரமாக புகைக்காமல் பாதுகாத்தீர்கள். ஒரு சிறிய சறுக்கல் உங்கள் சாதனையை அழிக்காது. உடனே விழிப்புணர்வுடன் மீண்டும் தொடங்குங்கள்.'
            : '$name, zero shame or self-blame. You built $smokeFreeDays smoke-free days of pure lung healing, and that cellular repair is still yours. A slip is just data—dust yourself off and resume control right now.',
        isUser: false,
        timestamp: DateTime.now(),
        actionType: 'breathe',
        actionLabel: isTamil ? 'மீட்பு சுவாசத்தை தொடங்கு' : 'Reset with 4-7-8 Breathing',
      );
    }

    // 5. Health, Lungs, Physical Healing
    if (lower.contains('lung') ||
        lower.contains('health') ||
        lower.contains('cough') ||
        lower.contains('breath') ||
        lower.contains('body') ||
        lower.contains('நுரையீரல்') ||
        lower.contains('உடல்நலம்') ||
        lower.contains('சுவாசம்')) {
      return AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: isTamil
            ? 'அற்புதமான செய்தி! நீங்கள் $cigarettesAvoided சிகரெட்டுகளை தவிர்த்துள்ளீர்கள். உங்கள் நுரையீரலின் சிலியா மயிர்க்கால்கள் இப்போது நச்சு தாரை சுத்தம் செய்து சுவாசிக்கும் திறனை மீட்டு வருகின்றன.'
            : 'Fascinating biological truth: by avoiding $cigarettesAvoided cigarettes, your bronchial cilia are actively clearing trapped tar and your arterial walls are restoring natural elasticity right now.',
        isUser: false,
        timestamp: DateTime.now(),
        actionType: 'distract',
        actionLabel: isTamil ? 'கவனச்சிதறல் பயிற்சி' : 'Launch 60-Sec Focus Puzzle',
      );
    }

    // 6. Financial Savings, Money
    if (lower.contains('money') ||
        lower.contains('saved') ||
        lower.contains('cost') ||
        lower.contains('rupee') ||
        lower.contains('பணம்') ||
        lower.contains('சேமிப்பு') ||
        lower.contains('ரூபாய்')) {
      return AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: isTamil
            ? 'நீங்கள் இதுவரை ₹${moneySaved.toStringAsFixed(0)} சேமித்துள்ளீர்கள்! இந்த பணம் உங்கள் மற்றும் உங்கள் குடும்பத்தின் பாதுகாப்பிற்கான முதலீடு. இதை புகைக்கரியாக எரிக்காதீர்கள்.'
            : 'You have actively preserved ₹${moneySaved.toStringAsFixed(0)} so far! That is tangible wealth diverted from tobacco conglomerates straight into your family’s security and dreams.',
        isUser: false,
        timestamp: DateTime.now(),
        actionType: null,
        actionLabel: null,
      );
    }

    // 7. Boredom, Idleness
    if (lower.contains('bored') ||
        lower.contains('idle') ||
        lower.contains('nothing to do') ||
        lower.contains('free time') ||
        lower.contains('சலிப்பு') ||
        lower.contains('நேரம்')) {
      return AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: isTamil
            ? 'சலிப்பு நிக்கோடினின் மிகப்பெரிய ஏமாற்று தோழன். உங்கள் மூளைக்கு ஒரு சிறிய சுவாரசியம் தேவை. 60 விநாடி கவனச்சிதறல் விளையாட்டை விளையாடி நரம்புகளை சுறுசுறுப்பாக்குங்கள்!'
            : 'Boredom is just your brain seeking dopamine. Instead of nicotine’s false rush, engage your prefrontal cortex with a quick mental puzzle to redirect that energy.',
        isUser: false,
        timestamp: DateTime.now(),
        actionType: 'distract',
        actionLabel: isTamil ? '60 வினாடி விளையாட்டு' : 'Play 60-Second Focus Puzzle',
      );
    }

    // Default Empathetic CBT Response
    return AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: isTamil
          ? '$name, நான் எப்போதும் உங்களுடன் இருக்கிறேன். நீங்கள் $smokeFreeDays நாட்கள் புகைக்காமல் உறுதியாக உள்ளீர்கள். உங்களுக்கு என்ன உதவி தேவை? ஆசையை வெல்ல வேண்டுமா அல்லது சுவாசிக்க வேண்டுமா?'
          : '$name, I am right here by your side 24/7. You are standing strong on Day $smokeFreeDays of freedom. How can I support you right now? Would you like a breathing exercise, delay challenge, or advice?',
      isUser: false,
      timestamp: DateTime.now(),
      actionType: 'breathe',
      actionLabel: isTamil ? 'சுவாசப் பயிற்சி' : 'Try 4-7-8 Breathing Pacer',
    );
  }
}
