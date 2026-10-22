import 'package:flutter_test/flutter_test.dart';
import 'package:smokefree/models/ai_chat_message.dart';
import 'package:smokefree/services/ai_behavioral_service.dart';

void main() {
  group('Aria AI Cessation Counselor Tests', () {
    final aiService = AIBehavioralService();

    test('AIChatMessage model creates and serializes properly', () {
      final now = DateTime.now();
      final msg = AIChatMessage(
        id: 'msg_1',
        text: 'Take three deep breaths.',
        isUser: false,
        timestamp: now,
        actionType: 'breathe',
        actionLabel: 'Start 4-7-8 Breathing',
      );

      final json = msg.toJson();
      expect(json['id'], 'msg_1');
      expect(json['isUser'], false);
      expect(json['actionType'], 'breathe');

      final fromJson = AIChatMessage.fromJson(json);
      expect(fromJson.text, 'Take three deep breaths.');
      expect(fromJson.actionLabel, 'Start 4-7-8 Breathing');
    });

    test('Aria responds to craving trigger with breathing or delay tool', () async {
      final response = await aiService.chatWithAria(
        userMessage: 'I have a strong craving right now, help me!',
        history: [],
        userName: 'Ravi',
        smokeFreeDays: 5,
        moneySaved: 750,
        cigarettesAvoided: 50,
        isTamil: false,
      );

      expect(response.isUser, isFalse);
      expect(response.text.isNotEmpty, isTrue);
      expect(response.text.contains('Ravi'), isTrue);
      expect(response.actionType, isNotNull);
      expect(['breathe', 'delay', 'water', 'distract'].contains(response.actionType), isTrue);
    });

    test('Aria responds in Tamil when isTamil is true', () async {
      final response = await aiService.chatWithAria(
        userMessage: 'எனக்கு மிகவும் புகைபிடிக்க ஆசையாக உள்ளது',
        history: [],
        userName: 'கார்த்திக்',
        smokeFreeDays: 7,
        moneySaved: 1050,
        cigarettesAvoided: 70,
        isTamil: true,
      );

      expect(response.isUser, isFalse);
      expect(response.text.isNotEmpty, isTrue);
      expect(response.text.contains('கார்த்திக்'), isTrue);
      expect(response.actionLabel, isNotNull);
    });

    test('Aria handles relapse / slip guilt constructively without shame', () async {
      final response = await aiService.chatWithAria(
        userMessage: 'I slipped up and smoked one cigarette today',
        history: [],
        userName: 'Alex',
        smokeFreeDays: 12,
        moneySaved: 1800,
        cigarettesAvoided: 120,
        isTamil: false,
      );

      expect(response.isUser, isFalse);
      expect(response.text.toLowerCase().contains('slip') || response.text.toLowerCase().contains('relapse') || response.text.toLowerCase().contains('shame'), isTrue);
    });
  });
}
