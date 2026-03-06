class UserModel {
  final String uid;
  final String email;
  final String name;
  final double income;
  final String theme;
  final Map<String, double>? budgets;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.income,
    this.theme = 'dark',
    this.budgets,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    final profile = data['profile'] as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: uid,
      email: profile['email'] as String? ?? '',
      name: profile['name'] as String? ?? '',
      income: (profile['income'] as num?)?.toDouble() ?? 0.0,
      theme: data['theme'] as String? ?? 'dark',
      budgets: profile['budgets'] != null
          ? Map<String, double>.from(
              (profile['budgets'] as Map).map(
                (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
              ),
            )
          : null,
    );
  }

  Map<String, dynamic> toProfileMap() {
    final map = <String, dynamic>{
      'email': email,
      'name': name,
      'income': income,
    };
    if (budgets != null) {
      map['budgets'] = budgets;
    }
    return map;
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    double? income,
    String? theme,
    Map<String, double>? budgets,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      income: income ?? this.income,
      theme: theme ?? this.theme,
      budgets: budgets ?? this.budgets,
    );
  }
}
