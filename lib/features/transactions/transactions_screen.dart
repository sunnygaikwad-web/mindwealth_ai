import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mindwealth_ai/core/constants/app_colors.dart';
import 'package:mindwealth_ai/core/constants/app_strings.dart';
import 'package:mindwealth_ai/core/constants/category_helper.dart';
import 'package:mindwealth_ai/core/utils/formatters.dart';
import 'package:mindwealth_ai/core/utils/glass_container.dart';
import 'package:mindwealth_ai/models/transaction_model.dart';
import 'package:mindwealth_ai/providers/auth_provider.dart';
import 'package:mindwealth_ai/providers/transaction_provider.dart';
import 'package:mindwealth_ai/providers/theme_provider.dart';
import 'package:mindwealth_ai/core/utils/interactive_card.dart';
import 'package:mindwealth_ai/features/transactions/add_transaction_sheet.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeNotifierProvider);
    final filteredTxns = ref.watch(filteredTransactionsProvider);
    final filter = ref.watch(transactionFilterProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    return CupertinoPageScaffold(
      child: CustomScrollView(
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
                children: [
                  Text(
                      AppStrings.transactions,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                        letterSpacing: -1.0,
                      ),
                    ),
                    InteractiveCard(
                        onTap: () {
                          showAddTransactionSheet(context, ref, isDark);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(80),
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
                                'Add Transaction',
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
          ),

          // Month selector — styled card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child:
                  GlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        borderRadius: 14,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                ref
                                    .read(selectedMonthProvider.notifier)
                                    .set(
                                      DateTime(
                                        selectedMonth.year,
                                        selectedMonth.month - 1,
                                      ),
                                    );
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  CupertinoIcons.chevron_left,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.calendar,
                                  size: 18,
                                  color: isDark
                                      ? AppColors.darkSubtext
                                      : AppColors.lightSubtext,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  Formatters.monthYear(selectedMonth),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkText
                                        : AppColors.lightText,
                                  ),
                                ),
                              ],
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                ref
                                    .read(selectedMonthProvider.notifier)
                                    .set(
                                      DateTime(
                                        selectedMonth.year,
                                        selectedMonth.month + 1,
                                      ),
                                    );
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  CupertinoIcons.chevron_right,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.05, end: 0, duration: 400.ms),
            ),
          ),

          // Filter chips with slide-in animation
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: TransactionFilter.values.asMap().entries.map((
                    entry,
                  ) {
                    final i = entry.key;
                    final f = entry.value;
                    final isSelected = filter == f;
                    return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ref
                                  .read(transactionFilterProvider.notifier)
                                  .set(f);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : isDark
                                    ? AppColors.darkSurface
                                    : AppColors.lightSurface,
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: isDark
                                            ? AppColors.glassBorder
                                            : AppColors.lightSubtext.withAlpha(
                                                51,
                                              ),
                                      ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withAlpha(
                                            40,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                f.name[0].toUpperCase() + f.name.substring(1),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? CupertinoColors.white
                                      : isDark
                                      ? AppColors.darkSubtext
                                      : AppColors.lightSubtext,
                                ),
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 100 + i * 60),
                          duration: 350.ms,
                        )
                        .slideX(
                          begin: -0.3,
                          end: 0,
                          delay: Duration(milliseconds: 100 + i * 60),
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Transaction list — deduplicated + staggered animations
          filteredTxns.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child:
                        Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '📭',
                                  style: TextStyle(fontSize: 48),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No transactions yet',
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
                );
              }
              // Deduplicate by id
              final seen = <String>{};
              final unique = transactions.where((t) {
                if (seen.contains(t.id)) return false;
                seen.add(t.id);
                return true;
              }).toList();

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final txn = unique[index];
                  return _buildTransactionTile(context, ref, txn, isDark, index)
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 30 * index),
                        duration: 350.ms,
                      )
                      .slideX(
                        begin: 0.15,
                        end: 0,
                        delay: Duration(milliseconds: 30 * index),
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      )
                      .scale(
                        begin: const Offset(0.92, 0.92),
                        end: const Offset(1.0, 1.0),
                        delay: Duration(milliseconds: 30 * index),
                        duration: 350.ms,
                        curve: Curves.easeOutCubic,
                      );
                }, childCount: unique.length),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator()),
            ),
            error: (e, _) =>
                SliverFillRemaining(child: Center(child: Text('Error: $e'))),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    WidgetRef ref,
    TransactionModel txn,
    bool isDark,
    int index,
  ) {
    return Dismissible(
      key: ValueKey(txn.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.expense.withAlpha(50),
        child: const Icon(CupertinoIcons.trash, color: AppColors.expense),
      ),
      confirmDismiss: (_) async {
        return await showCupertinoDialog<bool>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Delete Transaction'),
            content: Text('Delete "${txn.title}"?'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(ctx, false),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Delete'),
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref.read(firebaseServiceProvider).deleteTransaction(txn.id);
        HapticFeedback.mediumImpact();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InteractiveCard(
          onTap: () => showAddTransactionSheet(context, ref, isDark, txn),
          child:
              GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 14,
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: CategoryHelper.getColor(
                              txn.category,
                            ).withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              CategoryHelper.getIcon(txn.category),
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                txn.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.lightText,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${txn.category} • ${Formatters.date(txn.date)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkSubtext
                                      : AppColors.lightSubtext,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${txn.isExpense ? "-" : "+"}${Formatters.currency(txn.amount)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: txn.isExpense
                                ? AppColors.expense
                                : AppColors.income,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate(key: ValueKey(txn.id))
                  .fadeIn(delay: (index * 50).ms, duration: 400.ms)
                  .slideX(
                    begin: 0.2,
                    end: 0,
                    delay: (index * 50).ms,
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  )
                  .scaleXY(
                    begin: 0.9,
                    end: 1.0,
                    delay: (index * 50).ms,
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),
        ),
      ),
    );
  }
}
