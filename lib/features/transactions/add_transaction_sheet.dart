import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mindwealth_ai/core/constants/app_colors.dart';
import 'package:mindwealth_ai/core/constants/app_strings.dart';
import 'package:mindwealth_ai/core/constants/category_helper.dart';
import 'package:mindwealth_ai/core/utils/formatters.dart';
import 'package:mindwealth_ai/models/transaction_model.dart';
import 'package:mindwealth_ai/providers/auth_provider.dart';
import 'package:mindwealth_ai/services/database_service.dart';
import 'package:uuid/uuid.dart';

void showAddTransactionSheet(
  BuildContext context,
  WidgetRef ref,
  bool isDark, [
  TransactionModel? existingTxn,
]) {
  final titleCtrl = TextEditingController(text: existingTxn?.title ?? '');
  final amountCtrl = TextEditingController(
    text: existingTxn != null ? existingTxn.amount.toString() : '',
  );
  String selectedType = existingTxn?.type ?? 'expense';
  String selectedCategory = existingTxn?.category ?? 'Food';
  DateTime selectedDate = existingTxn?.date ?? DateTime.now();
  bool isSaved = false;

  showCupertinoModalPopup(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) {
        final categories = selectedType == 'expense'
            ? AppStrings.expenseCategories
            : AppStrings.incomeCategories;
        if (!categories.contains(selectedCategory)) {
          selectedCategory = categories.first;
        }

        if (isSaved) {
          // Success animation view
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.85,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg : AppColors.lightBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: selectedType == 'income'
                            ? [const Color(0xFF69F0AE), AppColors.income]
                            : [AppColors.primaryLight, AppColors.primary],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(60),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.checkmark_alt,
                      color: CupertinoColors.white,
                      size: 40,
                    ),
                  ).animate().scale(
                    begin: const Offset(0.0, 0.0),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  ),
                  const SizedBox(height: 20),
                  Text(
                        selectedType == 'income'
                            ? 'Income Added! 🎉'
                            : 'Expense Recorded! ✅',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, duration: 400.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Transaction saved successfully',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkSubtext
                          : AppColors.lightSubtext,
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                  // Confetti-like emoji bursts
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ['🎊', '💰', '✨', '🎉', '⭐'].map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(e, style: const TextStyle(fontSize: 28))
                            .animate()
                            .fadeIn(
                              delay: Duration(
                                milliseconds:
                                    400 +
                                    ['🎊', '💰', '✨', '🎉', '⭐'].indexOf(e) *
                                        100,
                              ),
                              duration: 300.ms,
                            )
                            .slideY(begin: 0.5, end: 0, duration: 400.ms)
                            .then()
                            .shake(hz: 2, duration: 500.ms),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBg : AppColors.lightBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 36,
                height: 5,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.glassBorder
                      : AppColors.lightSubtext.withAlpha(80),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    Text(
                      existingTxn != null
                          ? 'Edit Transaction'
                          : AppStrings.addTransaction,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        if (titleCtrl.text.isNotEmpty &&
                            amountCtrl.text.isNotEmpty) {
                          final txn = TransactionModel(
                            id: existingTxn?.id ?? const Uuid().v4(),
                            title: titleCtrl.text.trim(),
                            amount: double.tryParse(amountCtrl.text) ?? 0,
                            category: selectedCategory,
                            date: selectedDate,
                            type: selectedType,
                          );
                          // Save to both Firebase and SQLite
                          if (existingTxn != null) {
                            ref
                                .read(firebaseServiceProvider)
                                .updateTransaction(existingTxn, txn);
                            DatabaseService.updateTransaction(txn);
                          } else {
                            ref
                                .read(firebaseServiceProvider)
                                .addTransaction(txn);
                            DatabaseService.insertTransaction(txn);
                          }
                          HapticFeedback.heavyImpact();
                          // Show success animation
                          setModalState(() => isSaved = true);
                          Future.delayed(
                            const Duration(milliseconds: 1800),
                            () {
                              if (ctx.mounted && Navigator.canPop(ctx)) {
                                Navigator.pop(ctx);
                              }
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type selector
                      CupertinoSlidingSegmentedControl<String>(
                        groupValue: selectedType,
                        children: const {
                          'expense': Text('Expense'),
                          'income': Text('Income'),
                        },
                        onValueChanged: (v) {
                          setModalState(() => selectedType = v!);
                        },
                      ),
                      const SizedBox(height: 20),
                      CupertinoTextField(
                        controller: titleCtrl,
                        placeholder: AppStrings.title,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 14),
                      CupertinoTextField(
                        controller: amountCtrl,
                        placeholder: AppStrings.amount,
                        keyboardType: TextInputType.number,
                        prefix: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            '₹',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.map((cat) {
                          final isSelected = cat == selectedCategory;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setModalState(() => selectedCategory = cat);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : CategoryHelper.getColor(
                                        cat,
                                      ).withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withAlpha(
                                            40,
                                          ),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                '${CategoryHelper.getIcon(cat)} $cat',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? CupertinoColors.white
                                      : isDark
                                      ? AppColors.darkText
                                      : AppColors.lightText,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      // Date — card-based picker
                      Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          _showDatePicker(ctx, selectedDate, isDark, (d) {
                            setModalState(() => selectedDate = d);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.calendar,
                                size: 20,
                                color: isDark
                                    ? AppColors.darkSubtext
                                    : AppColors.lightSubtext,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                Formatters.date(selectedDate),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.lightText,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                CupertinoIcons.chevron_right,
                                size: 16,
                                color: isDark
                                    ? AppColors.darkSubtext
                                    : AppColors.lightSubtext,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

void _showDatePicker(
  BuildContext context,
  DateTime current,
  bool isDark,
  ValueChanged<DateTime> onChanged,
) {
  DateTime picked = current;
  showCupertinoModalPopup(
    context: context,
    builder: (ctx) => Container(
      height: 280,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.lightBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(ctx),
                ),
                CupertinoButton(
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    onChanged(picked);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: current,
              maximumDate: DateTime.now(),
              onDateTimeChanged: (d) => picked = d,
            ),
          ),
        ],
      ),
    ),
  );
}
