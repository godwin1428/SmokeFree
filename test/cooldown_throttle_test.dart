import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smokefree/models/reward_result.dart';
import 'package:smokefree/providers/patient_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cooldown / Throttle Timer Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial reward succeeds and awards points', () {
      final provider = PatientProvider(autoStartTicker: false);
      final initialPoints = provider.points;

      final result = provider.addPoints(
        15,
        activityKey: ActivityCooldownKeys.copingBreathing,
        cooldown: const Duration(minutes: 15),
      );

      expect(result.awarded, isTrue);
      expect(result.pointsAdded, 15);
      expect(provider.points, initialPoints + 15);
      expect(provider.isActivityOnCooldown(ActivityCooldownKeys.copingBreathing), isTrue);
    });

    test('Immediate second claim within 15-minute window is throttled', () {
      final provider = PatientProvider(autoStartTicker: false);

      // First claim
      final res1 = provider.addPoints(
        15,
        activityKey: ActivityCooldownKeys.copingBreathing,
        cooldown: const Duration(minutes: 15),
      );
      expect(res1.awarded, isTrue);
      final pointsAfterFirst = provider.points;

      // Second claim within 15 minutes
      final res2 = provider.addPoints(
        15,
        activityKey: ActivityCooldownKeys.copingBreathing,
        cooldown: const Duration(minutes: 15),
      );

      expect(res2.awarded, isFalse);
      expect(res2.pointsAdded, 0);
      expect(provider.points, pointsAfterFirst); // Points did not increase!
      expect(res2.remainingCooldown.inMinutes, inInclusiveRange(14, 15));
      expect(res2.message.contains('Cooldown active') || res2.message.contains('குளிர்விப்பு'), isTrue);
    });

    test('Different activities have independent cooldown timers', () {
      final provider = PatientProvider(autoStartTicker: false);

      // Claim breathing
      final res1 = provider.addPoints(
        10,
        activityKey: ActivityCooldownKeys.copingBreathing,
        cooldown: const Duration(minutes: 15),
      );
      expect(res1.awarded, isTrue);

      // Claim delay (different activity)
      final res2 = provider.addPoints(
        20,
        activityKey: ActivityCooldownKeys.copingDelay,
        cooldown: const Duration(minutes: 15),
      );
      expect(res2.awarded, isTrue);

      // Re-claiming breathing fails
      final res3 = provider.addPoints(
        10,
        activityKey: ActivityCooldownKeys.copingBreathing,
        cooldown: const Duration(minutes: 15),
      );
      expect(res3.awarded, isFalse);
    });
  });
}
