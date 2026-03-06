import 'dart:ui';
import 'package:mindwealth_ai/core/constants/app_colors.dart';

class CategoryHelper {
  static const Map<String, String> categoryIcons = {
    'Food': '🍔',
    'Shopping': '🛍️',
    'Transport': '🚗',
    'Entertainment': '🎬',
    'Bills': '📄',
    'Health': '💊',
    'Education': '📚',
    'Salary': '💰',
    'Freelance': '💻',
    'Investment': '📈',
    'Gift': '🎁',
    'Other': '📦',
  };

  static const Map<String, Color> categoryColors = {
    'Food': AppColors.categoryFood,
    'Shopping': AppColors.categoryShopping,
    'Transport': AppColors.categoryTransport,
    'Entertainment': AppColors.categoryEntertainment,
    'Bills': AppColors.categoryBills,
    'Health': AppColors.categoryHealth,
    'Education': AppColors.info,
    'Salary': AppColors.categorySalary,
    'Freelance': AppColors.accent,
    'Investment': AppColors.primaryLight,
    'Gift': AppColors.warning,
    'Other': AppColors.categoryOther,
  };

  static String getIcon(String category) {
    return categoryIcons[category] ?? '📦';
  }

  static Color getColor(String category) {
    return categoryColors[category] ?? AppColors.categoryOther;
  }
}
