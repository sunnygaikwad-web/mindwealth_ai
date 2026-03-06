import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show LinearProgressIndicator, AlwaysStoppedAnimation;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mindwealth_ai/core/constants/app_colors.dart';
import 'package:mindwealth_ai/core/constants/app_strings.dart';
import 'package:mindwealth_ai/core/constants/category_helper.dart';
import 'package:mindwealth_ai/core/utils/formatters.dart';
import 'package:mindwealth_ai/core/utils/glass_container.dart';
import 'package:mindwealth_ai/core/utils/interactive_card.dart';
import 'package:mindwealth_ai/models/budget_model.dart';
import 'package:mindwealth_ai/providers/auth_provider.dart';
import 'package:mindwealth_ai/providers/budget_provider.dart';
import 'package:mindwealth_ai/providers/theme_provider.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeNotifierProvider);
    final budgets = ref.watch(budgetsProvider);

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.budget,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                            letterSpacing: -1.0,
                          ),
                        ),
                        GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              _showAddBudgetSheet(context, ref, isDark);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.accent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(60),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.add,
                                    color: CupertinoColors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Add Budget',
                                    style: TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                          .scaleXY(begin: 1.0, end: 1.02, duration: 2.seconds)
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .slideX(
                            begin: 0.2,
                            end: 0,
                            duration: 400.ms,
                            curve: Curves.easeOutBack,
                          ),
                    ],
                  ),
                ),
              ),
              if (budgets.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child:
                        Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '💳',
                                  style: TextStyle(fontSize: 48),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No budgets set\nSet your first monthly budget!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkSubtext
                                        : AppColors.lightSubtext,
                                  ),
                                ),
                              ],
                            )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1.0, 1.0),
                              duration: 500.ms,
                            ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final budget = budgets[index];
                    return _buildBudgetCard(
                      context,
                      ref,
                      budget,
                      isDark,
                      index,
                    );
                  }, childCount: budgets.length),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    WidgetRef ref,
    BudgetModel budget,
    bool isDark,
    int index,
  ) {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: InteractiveCard(
            onTap: () {
              HapticFeedback.lightImpact();
            },
            child: GlassContainer(
              padding: const EdgeInsets.all(18),
              borderRadius: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: CategoryHelper.getColor(
                            budget.category,
                          ).withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            CategoryHelper.getIcon(budget.category),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budget.category,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText,
                              ),
                            ),
                            Text(
                              '${Formatters.compactCurrency(budget.spent)} / ${Formatters.compactCurrency(budget.limit)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkSubtext
                                    : AppColors.lightSubtext,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (budget.isOverBudget)
                        Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.expense.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Over Budget!',
                                style: TextStyle(
                                  color: AppColors.expense,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.08, 1.08),
                              duration: 800.ms,
                              curve: Curves.easeInOut,
                            ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: budget.progress.clamp(0.0, 1.0),
                      ),
                      duration: Duration(milliseconds: 800 + index * 200),
                      curve: Curves.easeOutCubic,
                      builder: (context, val, _) {
                        return LinearProgressIndicator(
                          value: val,
                          minHeight: 8,
                          backgroundColor: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightBg,
                          valueColor: AlwaysStoppedAnimation(
                            budget.isOverBudget
                                ? AppColors.expense
                                : budget.isNearLimit
                                ? AppColors.warning
                                : AppColors.income,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(budget.progress * 100).toStringAsFixed(0)}% used',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: budget.isOverBudget
                              ? AppColors.expense
                              : isDark
                              ? AppColors.darkSubtext
                              : AppColors.lightSubtext,
                        ),
                      ),
                      Text(
                        'Remaining: ${Formatters.compactCurrency((budget.limit - budget.spent).clamp(0, double.infinity))}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkSubtext
                              : AppColors.lightSubtext,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 + index * 80),
          duration: 400.ms,
        )
        .slideY(begin: 0.08, end: 0, duration: 400.ms);
  }

  void _showAddBudgetSheet(BuildContext context, WidgetRef ref, bool isDark) {
    final amountCtrl = TextEditingController();
    String selectedCategory = AppStrings.expenseCategories.first;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.7,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg : AppColors.lightBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
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
                        'Set Budget',
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
                          if (amountCtrl.text.isNotEmpty) {
                            final profile = ref.read(userProfileProvider).value;
                            final existing = Map<String, double>.from(
                              profile?.budgets ?? {},
                            );
                            existing[selectedCategory] =
                                double.tryParse(amountCtrl.text) ?? 0;
                            ref
                                .read(firebaseServiceProvider)
                                .updateBudgets(existing);
                            HapticFeedback.heavyImpact();
                            Navigator.pop(ctx);
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
                          children: AppStrings.expenseCategories.map((cat) {
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
                        const SizedBox(height: 24),
                        Text(
                          'Monthly Limit',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CupertinoTextField(
                          controller: amountCtrl,
                          placeholder: 'Budget amount (₹)',
                          keyboardType: TextInputType.number,
                          padding: const EdgeInsets.all(16),
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
}
