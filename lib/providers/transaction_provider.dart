import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindwealth_ai/models/transaction_model.dart';
import 'package:mindwealth_ai/providers/auth_provider.dart';

final transactionsStreamProvider = StreamProvider<List<TransactionModel>>((
  ref,
) {
  final service = ref.watch(firebaseServiceProvider);
  return service.transactionsStream().map((list) {
    // Deduplicate transactions by id to prevent double-counting
    final seen = <String>{};
    return list.where((t) {
      if (seen.contains(t.id)) return false;
      seen.add(t.id);
      return true;
    }).toList();
  });
});

// Filtered transactions
enum TransactionFilter { all, income, expense }

class TransactionFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => TransactionFilter.all;
  void set(TransactionFilter value) => state = value;
}

final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilter>(
      TransactionFilterNotifier.new,
    );

class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();
  void set(DateTime value) => state = value;
}

final selectedMonthProvider = NotifierProvider<SelectedMonthNotifier, DateTime>(
  SelectedMonthNotifier.new,
);

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
      SelectedCategoryNotifier.new,
    );

final filteredTransactionsProvider =
    Provider<AsyncValue<List<TransactionModel>>>((ref) {
      final txns = ref.watch(transactionsStreamProvider);
      final filter = ref.watch(transactionFilterProvider);
      final month = ref.watch(selectedMonthProvider);
      final category = ref.watch(selectedCategoryProvider);

      return txns.whenData((list) {
        var filtered = list.where((t) {
          if (t.date.month != month.month || t.date.year != month.year) {
            return false;
          }
          return true;
        }).toList();

        if (filter == TransactionFilter.income) {
          filtered = filtered.where((t) => t.isIncome).toList();
        } else if (filter == TransactionFilter.expense) {
          filtered = filtered.where((t) => t.isExpense).toList();
        }

        if (category != null) {
          filtered = filtered.where((t) => t.category == category).toList();
        }

        return filtered;
      });
    });

final monthlyIncomeProvider = Provider<double>((ref) {
  final txns = ref.watch(transactionsStreamProvider).value ?? [];
  final month = ref.watch(selectedMonthProvider);
  return txns
      .where(
        (t) =>
            t.isIncome &&
            t.date.month == month.month &&
            t.date.year == month.year,
      )
      .fold(0.0, (sum, t) => sum + t.amount);
});

final monthlyExpenseProvider = Provider<double>((ref) {
  final txns = ref.watch(transactionsStreamProvider).value ?? [];
  final month = ref.watch(selectedMonthProvider);
  return txns
      .where(
        (t) =>
            t.isExpense &&
            t.date.month == month.month &&
            t.date.year == month.year,
      )
      .fold(0.0, (sum, t) => sum + t.amount);
});

final categorySpendingProvider = Provider<Map<String, double>>((ref) {
  final txns = ref.watch(transactionsStreamProvider).value ?? [];
  final month = ref.watch(selectedMonthProvider);
  final spending = <String, double>{};
  for (final t in txns.where(
    (t) =>
        t.isExpense && t.date.month == month.month && t.date.year == month.year,
  )) {
    spending[t.category] = (spending[t.category] ?? 0) + t.amount;
  }
  return spending;
});

final monthlyTrendProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final txns = ref.watch(transactionsStreamProvider).value ?? [];
  final now = DateTime.now();
  final trends = <Map<String, dynamic>>[];

  for (int i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i);
    final monthIncome = txns
        .where(
          (t) =>
              t.isIncome &&
              t.date.month == month.month &&
              t.date.year == month.year,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
    final monthExpense = txns
        .where(
          (t) =>
              t.isExpense &&
              t.date.month == month.month &&
              t.date.year == month.year,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
    trends.add({
      'month': month,
      'income': monthIncome,
      'expense': monthExpense,
    });
  }
  return trends;
});
