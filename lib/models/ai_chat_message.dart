class AIChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? actionType; // 'breathe', 'delay', 'water', 'distract'
  final String? actionLabel;

  const AIChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actionType,
    this.actionLabel,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'actionType': actionType,
        'actionLabel': actionLabel,
      };

  factory AIChatMessage.fromJson(Map<String, dynamic> json) => AIChatMessage(
        id: json['id'] ?? '',
        text: json['text'] ?? '',
        isUser: json['isUser'] ?? false,
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
        actionType: json['actionType'],
        actionLabel: json['actionLabel'],
      );
}
