import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindwealth_ai/models/budget_model.dart';
import 'package:mindwealth_ai/providers/auth_provider.dart';
import 'package:mindwealth_ai/providers/transaction_provider.dart';

final budgetsProvider = Provider<List<BudgetModel>>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  final categorySpending = ref.watch(categorySpendingProvider);

  if (profile?.budgets == null || profile!.budgets!.isEmpty) {
    return [];
  }

  return profile.budgets!.entries.map((entry) {
    return BudgetModel.fromEntry(
      entry.key,
      entry.value,
      categorySpending[entry.key] ?? 0.0,
    );
  }).toList();
});

final overBudgetCountProvider = Provider<int>((ref) {
  final budgets = ref.watch(budgetsProvider);
  return budgets.where((b) => b.isOverBudget).length;
});

final totalBudgetProvider = Provider<double>((ref) {
  final budgets = ref.watch(budgetsProvider);
  return budgets.fold(0.0, (sum, b) => sum + b.limit);
});

final totalBudgetSpentProvider = Provider<double>((ref) {
  final budgets = ref.watch(budgetsProvider);
  return budgets.fold(0.0, (sum, b) => sum + b.spent);
});
