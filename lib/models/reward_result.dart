/// Result of attempting to claim / award points with cooldown / throttling validation.
class RewardResult {
  final bool awarded;
  final int pointsAdded;
  final int currentTotalPoints;
  final Duration remainingCooldown;
  final String message;
  final String? activityKey;

  const RewardResult({
    required this.awarded,
    required this.pointsAdded,
    required this.currentTotalPoints,
    this.remainingCooldown = Duration.zero,
    required this.message,
    this.activityKey,
  });

  bool get isCooldownActive => !awarded && remainingCooldown > Duration.zero;

  /// Returns user-friendly remaining time string (e.g. "14m 20s" or "8s").
  String get formattedRemainingTime {
    if (remainingCooldown <= Duration.zero) return '0s';
    final minutes = remainingCooldown.inMinutes;
    final seconds = remainingCooldown.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Returns localized cooldown notice message.
  String getLocalizedCooldownMessage(bool isTamil) {
    if (isTamil) {
      return 'குளிர்விப்பு நேரம் செயலில் உள்ளது! ($formattedRemainingTime பிறகு மீண்டும் பெறலாம்)';
    } else {
      return 'Activity cooldown active! You can claim again in $formattedRemainingTime.';
    }
  }
}

/// Standardized activity keys for cooldown throttling.
class ActivityCooldownKeys {
  static const String copingBreathing = 'coping_breathing';
  static const String copingDelay = 'coping_delay';
  static const String copingDistract = 'coping_distract';
  static const String copingDisgust = 'coping_disgust';
  static const String copingGeneral = 'coping_general';
  static const String cravingIntervention = 'craving_intervention';
  static const String motivationAction = 'motivation_action';
  static const String checkIn = 'daily_checkin';
}
