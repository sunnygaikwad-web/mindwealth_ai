class GamificationModel {
  final int points;
  final List<String> badges;

  GamificationModel({this.points = 0, this.badges = const []});

  factory GamificationModel.fromMap(Map<String, dynamic>? data) {
    if (data == null) return GamificationModel();
    return GamificationModel(
      points: (data['points'] as num?)?.toInt() ?? 0,
      badges: data['badges'] != null
          ? List<String>.from(data['badges'] as List)
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {'points': points, 'badges': badges};
  }

  bool hasBadge(String badge) => badges.contains(badge);

  GamificationModel copyWith({int? points, List<String>? badges}) {
    return GamificationModel(
      points: points ?? this.points,
      badges: badges ?? this.badges,
    );
  }
}

class BadgeDefinition {
  static const String noSpend7Days = '7-Day No Spend';
  static const String budgetAchieved = 'Budget Master';
  static const String saved10Percent = 'Smart Saver';
  static const String first100Transactions = 'Century Club';
  static const String goalCompleted = 'Goal Getter';
  static const String earlyBird = 'Early Bird';
  static const String consistentSaver = 'Consistent Saver';

  static const Map<String, String> badgeIcons = {
    noSpend7Days: '🏆',
    budgetAchieved: '🎯',
    saved10Percent: '💎',
    first100Transactions: '💯',
    goalCompleted: '⭐',
    earlyBird: '🌅',
    consistentSaver: '🔥',
  };

  static const Map<String, String> badgeDescriptions = {
    noSpend7Days: 'No spending for 7 consecutive days',
    budgetAchieved: 'Stayed within budget for a full month',
    saved10Percent: 'Saved at least 10% of your income',
    first100Transactions: 'Logged 100 transactions',
    goalCompleted: 'Completed a financial goal',
    earlyBird: 'Started tracking finances early',
    consistentSaver: 'Saved money 3 months in a row',
  };

  static String getIcon(String badge) => badgeIcons[badge] ?? '🏅';
  static String getDescription(String badge) => badgeDescriptions[badge] ?? '';
}
