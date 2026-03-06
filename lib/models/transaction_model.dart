import 'package:mindwealth_ai/core/utils/formatters.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String title;
  final String type; // 'expense' | 'income'

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.title,
    required this.type,
  });

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';

  factory TransactionModel.fromMap(Map<String, dynamic> data) {
    return TransactionModel(
      id: data['id'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] as String? ?? 'Other',
      date: data['date'] != null
          ? Formatters.parseApiDate(data['date'] as String)
          : DateTime.now(),
      title: data['title'] as String? ?? '',
      type: data['type'] as String? ?? 'expense',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': Formatters.apiDate(date),
      'title': title,
      'type': type,
    };
  }

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? category,
    DateTime? date,
    String? title,
    String? type,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      title: title ?? this.title,
      type: type ?? this.type,
    );
  }
}
