class BudgetModel {
  final String category;
  final double limit;
  final double spent;

  BudgetModel({required this.category, required this.limit, this.spent = 0.0});

  double get remaining => (limit - spent).clamp(0.0, double.infinity);
  double get progress => limit > 0 ? (spent / limit).clamp(0.0, 1.5) : 0.0;
  double get progressPercent => (progress * 100);
  bool get isOverBudget => spent > limit;
  bool get isNearLimit => progress >= 0.8 && !isOverBudget;

  factory BudgetModel.fromEntry(String category, double limit, double spent) {
    return BudgetModel(category: category, limit: limit, spent: spent);
  }

  BudgetModel copyWith({String? category, double? limit, double? spent}) {
    return BudgetModel(
      category: category ?? this.category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
    );
  }
}
