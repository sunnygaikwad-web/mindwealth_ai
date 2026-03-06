import 'package:mindwealth_ai/core/utils/formatters.dart';

class GoalModel {
  final String id;
  final String name;
  final double target;
  final double saved;
  final DateTime deadline;
  final String icon;

  GoalModel({
    required this.id,
    required this.name,
    required this.target,
    required this.saved,
    required this.deadline,
    this.icon = '🎯',
  });

  double get progress => target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;
  double get progressPercent => progress * 100;
  double get remaining => (target - saved).clamp(0.0, double.infinity);
  bool get isCompleted => saved >= target;
  int get daysLeft => deadline.difference(DateTime.now()).inDays;
  bool get isOverdue => daysLeft < 0 && !isCompleted;

  factory GoalModel.fromMap(Map<String, dynamic> data) {
    return GoalModel(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      target: (data['target'] as num?)?.toDouble() ?? 0.0,
      saved: (data['saved'] as num?)?.toDouble() ?? 0.0,
      deadline: data['deadline'] != null
          ? Formatters.parseApiDate(data['deadline'] as String)
          : DateTime.now().add(const Duration(days: 30)),
      icon: data['icon'] as String? ?? '🎯',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target': target,
      'saved': saved,
      'deadline': Formatters.apiDate(deadline),
      'icon': icon,
    };
  }

  GoalModel copyWith({
    String? id,
    String? name,
    double? target,
    double? saved,
    DateTime? deadline,
    String? icon,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      target: target ?? this.target,
      saved: saved ?? this.saved,
      deadline: deadline ?? this.deadline,
      icon: icon ?? this.icon,
    );
  }
}
