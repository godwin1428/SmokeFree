enum RelapseRiskLevel { low, moderate, high }

class DailyCheckIn {
  final DateTime timestamp;
  final String mood; // Happy, Calm, Stressed, Anxious, Sad, Frustrated
  final int cravingScale; // 1 to 10
  final int cigarettesSmoked; // 0 for none, 1, 2, 3...
  final List<String> triggers;
  final String notes;

  DailyCheckIn({
    required this.timestamp,
    required this.mood,
    required this.cravingScale,
    required this.cigarettesSmoked,
    this.triggers = const [],
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'mood': mood,
        'cravingScale': cravingScale,
        'cigarettesSmoked': cigarettesSmoked,
        'triggers': triggers,
        'notes': notes,
      };

  factory DailyCheckIn.fromJson(Map<String, dynamic> json) => DailyCheckIn(
        timestamp: DateTime.parse(json['timestamp']),
        mood: json['mood'] ?? 'Calm',
        cravingScale: json['cravingScale'] ?? 1,
        cigarettesSmoked: json['cigarettesSmoked'] ?? 0,
        triggers: List<String>.from(json['triggers'] ?? []),
        notes: json['notes'] ?? '',
      );
}

class AIDailyInsight {
  final RelapseRiskLevel riskLevel;
  final String headline;
  final String message;
  final String recommendedTool; // 'breathe', 'water', 'delay', 'distract', 'doctor'
  final String actionLabel;
  final int pointsAwarded;
  final double adherenceRate; // percentage (e.g. 95.0)

  AIDailyInsight({
    required this.riskLevel,
    required this.headline,
    required this.message,
    required this.recommendedTool,
    required this.actionLabel,
    required this.pointsAwarded,
    this.adherenceRate = 100.0,
  });

  Map<String, dynamic> toJson() => {
        'riskLevel': riskLevel.index,
        'headline': headline,
        'message': message,
        'recommendedTool': recommendedTool,
        'actionLabel': actionLabel,
        'pointsAwarded': pointsAwarded,
        'adherenceRate': adherenceRate,
      };

  factory AIDailyInsight.fromJson(Map<String, dynamic> json) => AIDailyInsight(
        riskLevel: RelapseRiskLevel.values[json['riskLevel'] ?? 0],
        headline: json['headline'] ?? '',
        message: json['message'] ?? '',
        recommendedTool: json['recommendedTool'] ?? 'breathe',
        actionLabel: json['actionLabel'] ?? 'Open Tool',
        pointsAwarded: json['pointsAwarded'] ?? 10,
        adherenceRate: (json['adherenceRate'] as num?)?.toDouble() ?? 100.0,
      );
}

class AIBiweeklyReport {
  final DateTime generatedDate;
  final String patientProgressSummary;
  final String doctorClinicalBriefing;
  final int coughReductionPercent;
  final int sleepImprovementPercent;
  final String nextProtocolRecommendation;

  AIBiweeklyReport({
    required this.generatedDate,
    required this.patientProgressSummary,
    required this.doctorClinicalBriefing,
    required this.coughReductionPercent,
    required this.sleepImprovementPercent,
    required this.nextProtocolRecommendation,
  });

  Map<String, dynamic> toJson() => {
        'generatedDate': generatedDate.toIso8601String(),
        'patientProgressSummary': patientProgressSummary,
        'doctorClinicalBriefing': doctorClinicalBriefing,
        'coughReductionPercent': coughReductionPercent,
        'sleepImprovementPercent': sleepImprovementPercent,
        'nextProtocolRecommendation': nextProtocolRecommendation,
      };

  factory AIBiweeklyReport.fromJson(Map<String, dynamic> json) =>
      AIBiweeklyReport(
        generatedDate: DateTime.parse(json['generatedDate']),
        patientProgressSummary: json['patientProgressSummary'] ?? '',
        doctorClinicalBriefing: json['doctorClinicalBriefing'] ?? '',
        coughReductionPercent: json['coughReductionPercent'] ?? 0,
        sleepImprovementPercent: json['sleepImprovementPercent'] ?? 0,
        nextProtocolRecommendation: json['nextProtocolRecommendation'] ?? '',
      );
}

class EmpathyRecommendation {
  final String headline;
  final String message;
  final String emotionalInsight;
  final List<String> stepByStepGuide;
  final String actionLabel;
  final String actionType; // 'breathe', 'delay', 'water', 'grounding'
  final int pointsReward;

  EmpathyRecommendation({
    required this.headline,
    required this.message,
    required this.emotionalInsight,
    required this.stepByStepGuide,
    required this.actionLabel,
    required this.actionType,
    this.pointsReward = 10,
  });

  Map<String, dynamic> toJson() => {
        'headline': headline,
        'message': message,
        'emotionalInsight': emotionalInsight,
        'stepByStepGuide': stepByStepGuide,
        'actionLabel': actionLabel,
        'actionType': actionType,
        'pointsReward': pointsReward,
      };

  factory EmpathyRecommendation.fromJson(Map<String, dynamic> json) =>
      EmpathyRecommendation(
        headline: json['headline'] ?? '',
        message: json['message'] ?? '',
        emotionalInsight: json['emotionalInsight'] ?? '',
        stepByStepGuide: List<String>.from(json['stepByStepGuide'] ?? []),
        actionLabel: json['actionLabel'] ?? 'Start Exercise',
        actionType: json['actionType'] ?? 'breathe',
        pointsReward: json['pointsReward'] ?? 10,
      );
}

class AversionRecommendation {
  final String headline;
  final String biologicalReality;
  final String financialOrGoalImpact;
  final String addictionCycleInsight;
  final List<String> evidencePoints;
  final String actionLabel;
  final String actionType; // 'delay', 'water', 'tar_reality', 'lungs_audit'
  final int pointsReward;

  AversionRecommendation({
    required this.headline,
    required this.biologicalReality,
    required this.financialOrGoalImpact,
    required this.addictionCycleInsight,
    required this.evidencePoints,
    required this.actionLabel,
    required this.actionType,
    this.pointsReward = 10,
  });

  Map<String, dynamic> toJson() => {
        'headline': headline,
        'biologicalReality': biologicalReality,
        'financialOrGoalImpact': financialOrGoalImpact,
        'addictionCycleInsight': addictionCycleInsight,
        'evidencePoints': evidencePoints,
        'actionLabel': actionLabel,
        'actionType': actionType,
        'pointsReward': pointsReward,
      };

  factory AversionRecommendation.fromJson(Map<String, dynamic> json) =>
      AversionRecommendation(
        headline: json['headline'] ?? '',
        biologicalReality: json['biologicalReality'] ?? '',
        financialOrGoalImpact: json['financialOrGoalImpact'] ?? '',
        addictionCycleInsight: json['addictionCycleInsight'] ?? '',
        evidencePoints: List<String>.from(json['evidencePoints'] ?? []),
        actionLabel: json['actionLabel'] ?? 'Disrupt Urge',
        actionType: json['actionType'] ?? 'delay',
        pointsReward: json['pointsReward'] ?? 10,
      );
}

class CravingAiRecommendations {
  final EmpathyRecommendation empathy;
  final AversionRecommendation aversion;
  final int intensity;
  final List<String> triggers;
  final DateTime timestamp;

  CravingAiRecommendations({
    required this.empathy,
    required this.aversion,
    required this.intensity,
    required this.triggers,
    required this.timestamp,
  });
}

enum MotivationPillar { selfMotivation, leverage, seduction, social }

enum MotivationTimeframe { today, oneWeek, oneMonth }

class MotivationContent {
  final MotivationPillar pillar;
  final MotivationTimeframe timeframe;
  final String headline;
  final String mantra;
  final String insight;
  final String impactMetricLabel;
  final String impactMetricValue;
  final String actionStep;
  final List<String> keyBullets;
  final int pointsReward;

  const MotivationContent({
    required this.pillar,
    required this.timeframe,
    required this.headline,
    required this.mantra,
    required this.insight,
    required this.impactMetricLabel,
    required this.impactMetricValue,
    required this.actionStep,
    required this.keyBullets,
    this.pointsReward = 15,
  });
}

