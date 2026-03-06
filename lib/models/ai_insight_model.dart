class AiInsightModel {
  final String id;
  final String type; // 'emotional', 'prediction', 'personality', 'tip'
  final String title;
  final String message;
  final String severity; // 'info', 'warning', 'critical'
  final DateTime generatedAt;
  final Map<String, dynamic>? metadata;

  AiInsightModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.severity = 'info',
    DateTime? generatedAt,
    this.metadata,
  }) : generatedAt = generatedAt ?? DateTime.now();

  factory AiInsightModel.fromMap(Map<String, dynamic> data) {
    return AiInsightModel(
      id: data['id'] as String? ?? '',
      type: data['type'] as String? ?? 'tip',
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      severity: data['severity'] as String? ?? 'info',
      generatedAt: data['generatedAt'] != null
          ? DateTime.parse(data['generatedAt'] as String)
          : DateTime.now(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'severity': severity,
      'generatedAt': generatedAt.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  String get icon {
    switch (type) {
      case 'emotional':
        return '🧠';
      case 'prediction':
        return '📊';
      case 'personality':
        return '🎭';
      case 'tip':
        return '💡';
      default:
        return '🤖';
    }
  }
}

class FinancialPersonality {
  static const String impulseBuyer = 'Impulse Buyer';
  static const String safeSaver = 'Safe Saver';
  static const String socialSpender = 'Social Spender';
  static const String riskTaker = 'Risk Taker';

  static const Map<String, String> personalityIcons = {
    impulseBuyer: '⚡',
    safeSaver: '🛡️',
    socialSpender: '🤝',
    riskTaker: '🎲',
  };

  static const Map<String, String> personalityDescriptions = {
    impulseBuyer: 'You tend to make spontaneous purchases driven by emotion.',
    safeSaver: 'You prioritize saving and rarely overspend.',
    socialSpender: 'You spend more in social settings and events.',
    riskTaker: 'You make bold financial moves with high risk/reward.',
  };
}
