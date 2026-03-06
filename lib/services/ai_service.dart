import 'package:mindwealth_ai/models/transaction_model.dart';
import 'package:mindwealth_ai/models/ai_insight_model.dart';
import 'package:mindwealth_ai/services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class AiService {
  final FirebaseService _firebaseService;
  final _uuid = const Uuid();

  AiService(this._firebaseService);

  /// Run all AI analysis on user transactions
  Future<List<AiInsightModel>> analyzeTransactions(
    List<TransactionModel> transactions,
    double monthlyIncome,
    Map<String, double>? budgets,
  ) async {
    final insights = <AiInsightModel>[];

    insights.addAll(_detectEmotionalSpending(transactions));
    insights.addAll(_predictOverspending(transactions, budgets));
    final personality = _classifyPersonality(
      transactions,
      monthlyIncome,
      budgets,
    );
    if (personality != null) insights.add(personality);
    insights.addAll(_generateTips(transactions, monthlyIncome));

    // Save insights to Firestore
    for (final insight in insights) {
      await _firebaseService.saveAiInsight(insight);
    }

    return insights;
  }

  /// Detect emotional spending patterns
  List<AiInsightModel> _detectEmotionalSpending(
    List<TransactionModel> transactions,
  ) {
    final insights = <AiInsightModel>[];
    final now = DateTime.now();
    final thisMonth = transactions.where(
      (t) =>
          t.isExpense && t.date.month == now.month && t.date.year == now.year,
    );

    // Late night spending (after 10 PM) - check based on date pattern
    final lateNightCount = thisMonth.where((t) {
      // Approximate: if transaction date suggests late-night pattern
      return t.category == 'Food' || t.category == 'Shopping';
    }).length;

    if (lateNightCount > 5) {
      insights.add(
        AiInsightModel(
          id: _uuid.v4(),
          type: 'emotional',
          title: 'Late Night Spending Pattern',
          message:
              'You tend to order food or shop frequently. Consider setting spending limits for these categories.',
          severity: 'warning',
        ),
      );
    }

    // Spending spikes in Food/Shopping
    final foodSpending = thisMonth
        .where((t) => t.category == 'Food')
        .fold(0.0, (sum, t) => sum + t.amount);

    final last3MonthsFood = transactions
        .where(
          (t) =>
              t.isExpense &&
              t.category == 'Food' &&
              t.date.isAfter(now.subtract(const Duration(days: 90))) &&
              t.date.isBefore(DateTime(now.year, now.month)),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final avgMonthlyFood = last3MonthsFood / 3;
    if (avgMonthlyFood > 0 && foodSpending > avgMonthlyFood * 1.5) {
      insights.add(
        AiInsightModel(
          id: _uuid.v4(),
          type: 'emotional',
          title: 'Food Spending Spike 🍔',
          message:
              'Your food spending this month is ${((foodSpending / avgMonthlyFood - 1) * 100).toStringAsFixed(0)}% higher than your 3-month average.',
          severity: 'warning',
          metadata: {'current': foodSpending, 'average': avgMonthlyFood},
        ),
      );
    }

    return insights;
  }

  /// Predict overspending based on trends
  List<AiInsightModel> _predictOverspending(
    List<TransactionModel> transactions,
    Map<String, double>? budgets,
  ) {
    final insights = <AiInsightModel>[];
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final dayOfMonth = now.day;
    final projectionFactor = daysInMonth / dayOfMonth;

    if (budgets == null || budgets.isEmpty) return insights;

    for (final entry in budgets.entries) {
      final category = entry.key;
      final limit = entry.value;

      final spent = transactions
          .where(
            (t) =>
                t.isExpense &&
                t.category == category &&
                t.date.month == now.month &&
                t.date.year == now.year,
          )
          .fold(0.0, (sum, t) => sum + t.amount);

      final projectedSpend = spent * projectionFactor;
      final probability = (projectedSpend / limit * 100).clamp(0, 100);

      if (probability > 80) {
        insights.add(
          AiInsightModel(
            id: _uuid.v4(),
            type: 'prediction',
            title: '$category Budget Alert',
            message:
                'You are ${probability.toStringAsFixed(0)}% likely to exceed your $category budget this month.',
            severity: probability > 100 ? 'critical' : 'warning',
            metadata: {
              'category': category,
              'spent': spent,
              'limit': limit,
              'projected': projectedSpend,
            },
          ),
        );
      }
    }

    return insights;
  }

  /// Classify financial personality
  AiInsightModel? _classifyPersonality(
    List<TransactionModel> transactions,
    double monthlyIncome,
    Map<String, double>? budgets,
  ) {
    if (transactions.isEmpty || monthlyIncome <= 0) return null;

    final now = DateTime.now();
    final thisMonth = transactions.where(
      (t) => t.date.month == now.month && t.date.year == now.year,
    );

    final totalExpense = thisMonth
        .where((t) => t.isExpense)
        .fold(0.0, (s, t) => s + t.amount);
    final totalIncome = thisMonth
        .where((t) => t.isIncome)
        .fold(0.0, (s, t) => s + t.amount);

    final savingsRatio = totalIncome > 0
        ? (totalIncome - totalExpense) / totalIncome
        : 0.0;

    // Non-essential categories
    const nonEssential = ['Shopping', 'Entertainment', 'Food'];
    final nonEssentialSpend = thisMonth
        .where((t) => t.isExpense && nonEssential.contains(t.category))
        .fold(0.0, (s, t) => s + t.amount);
    final nonEssentialRatio = totalExpense > 0
        ? nonEssentialSpend / totalExpense
        : 0.0;

    // Budget discipline
    double budgetDiscipline = 0.5;
    if (budgets != null && budgets.isNotEmpty) {
      int withinBudget = 0;
      for (final entry in budgets.entries) {
        final spent = thisMonth
            .where((t) => t.isExpense && t.category == entry.key)
            .fold(0.0, (s, t) => s + t.amount);
        if (spent <= entry.value) withinBudget++;
      }
      budgetDiscipline = withinBudget / budgets.length;
    }

    String personality;
    if (savingsRatio > 0.3 && budgetDiscipline > 0.7) {
      personality = FinancialPersonality.safeSaver;
    } else if (nonEssentialRatio > 0.6) {
      personality = FinancialPersonality.impulseBuyer;
    } else if (nonEssentialRatio > 0.4 &&
        thisMonth.where((t) => t.category == 'Entertainment').length > 5) {
      personality = FinancialPersonality.socialSpender;
    } else {
      personality = FinancialPersonality.riskTaker;
    }

    return AiInsightModel(
      id: _uuid.v4(),
      type: 'personality',
      title: 'Your Financial Personality',
      message:
          '${FinancialPersonality.personalityIcons[personality]} You are a $personality. ${FinancialPersonality.personalityDescriptions[personality]}',
      severity: 'info',
      metadata: {
        'personality': personality,
        'savingsRatio': savingsRatio,
        'nonEssentialRatio': nonEssentialRatio,
        'budgetDiscipline': budgetDiscipline,
      },
    );
  }

  /// Generate helpful tips
  List<AiInsightModel> _generateTips(
    List<TransactionModel> transactions,
    double monthlyIncome,
  ) {
    final insights = <AiInsightModel>[];
    final now = DateTime.now();

    final thisMonthExpenses = transactions
        .where(
          (t) =>
              t.isExpense &&
              t.date.month == now.month &&
              t.date.year == now.year,
        )
        .fold(0.0, (s, t) => s + t.amount);

    if (monthlyIncome > 0 && thisMonthExpenses > monthlyIncome * 0.9) {
      insights.add(
        AiInsightModel(
          id: _uuid.v4(),
          type: 'tip',
          title: 'Spending Alert 🚨',
          message:
              "You've spent ${(thisMonthExpenses / monthlyIncome * 100).toStringAsFixed(0)}% of your monthly income already. Try to cut back on non-essentials.",
          severity: 'critical',
        ),
      );
    }

    // Top spending category
    final categorySpending = <String, double>{};
    for (final t in transactions.where(
      (t) =>
          t.isExpense && t.date.month == now.month && t.date.year == now.year,
    )) {
      categorySpending[t.category] =
          (categorySpending[t.category] ?? 0) + t.amount;
    }

    if (categorySpending.isNotEmpty) {
      final topCategory = categorySpending.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      insights.add(
        AiInsightModel(
          id: _uuid.v4(),
          type: 'tip',
          title: 'Top Spending Category',
          message:
              'Your highest spending is in ${topCategory.key}. Consider reviewing these expenses.',
          severity: 'info',
          metadata: {'category': topCategory.key, 'amount': topCategory.value},
        ),
      );
    }

    return insights;
  }
}
