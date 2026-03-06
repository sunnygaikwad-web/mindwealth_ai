import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show LinearProgressIndicator, AlwaysStoppedAnimation;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mindwealth_ai/core/constants/app_colors.dart';
import 'package:mindwealth_ai/core/constants/app_strings.dart';
import 'package:mindwealth_ai/core/utils/formatters.dart';
import 'package:mindwealth_ai/core/utils/glass_container.dart';
import 'package:mindwealth_ai/core/utils/interactive_card.dart';
import 'package:mindwealth_ai/models/goal_model.dart';
import 'package:mindwealth_ai/providers/auth_provider.dart';
import 'package:mindwealth_ai/providers/goal_provider.dart';
import 'package:mindwealth_ai/providers/theme_provider.dart';
import 'package:uuid/uuid.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeNotifierProvider);
    final goalsAsync = ref.watch(goalsStreamProvider);

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
                          AppStrings.goals,
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
                              _showAddGoalSheet(context, ref, isDark);
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
                                    'Add Goal',
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
              goalsAsync.when(
                data: (goals) {
                  if (goals.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child:
                            Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      '🎯',
                                      style: TextStyle(fontSize: 48),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No goals yet\nCreate your first financial goal!',
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
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final goal = goals[index];
                      return _buildGoalCard(context, ref, goal, isDark, index);
                    }, childCount: goals.length),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CupertinoActivityIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(child: Text('Error: $e')),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    WidgetRef ref,
    GoalModel goal,
    bool isDark,
    int index,
  ) {
    final isCompleted = goal.progressPercent >= 100;
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: InteractiveCard(
            onTap: () {
              HapticFeedback.lightImpact();
              _showFundGoalSheet(context, ref, goal, isDark);
            },
            child: GlassContainer(
              padding: const EdgeInsets.all(18),
              borderRadius: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(goal.icon, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText,
                              ),
                            ),
                            Text(
                              Formatters.daysRemaining(goal.deadline),
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
                      if (isCompleted) ...[
                        const Text('🎉', style: TextStyle(fontSize: 24))
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.2, 1.2),
                              duration: 1000.ms,
                              curve: Curves.easeInOut,
                            ),
                      ] else
                        Text(
                          '${goal.progressPercent.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: goal.progress.clamp(0.0, 1.0),
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
                            isCompleted ? AppColors.income : AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${Formatters.compactCurrency(goal.saved)} saved',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkSubtext
                              : AppColors.lightSubtext,
                        ),
                      ),
                      Text(
                        'Target: ${Formatters.compactCurrency(goal.target)}',
                        style: TextStyle(
                          fontSize: 13,
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

  void _showFundGoalSheet(
    BuildContext context,
    WidgetRef ref,
    GoalModel goal,
    bool isDark,
  ) {
    final amountCtrl = TextEditingController();
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg : AppColors.lightBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Fund "${goal.name}" ${goal.icon}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${Formatters.compactCurrency(goal.saved)} / ${Formatters.compactCurrency(goal.target)}',
              style: TextStyle(
                color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              ),
            ),
            const SizedBox(height: 20),
            CupertinoTextField(
              controller: amountCtrl,
              placeholder: 'Amount to add (₹)',
              keyboardType: TextInputType.number,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              style: TextStyle(
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
              onPressed: () {
                final amount = double.tryParse(amountCtrl.text) ?? 0;
                if (amount > 0) {
                  final updated = goal.copyWith(saved: goal.saved + amount);
                  ref.read(firebaseServiceProvider).updateGoal(goal, updated);
                  HapticFeedback.heavyImpact();
                  Navigator.pop(ctx);
                }
              },
              child: const Text(
                'Add Funds',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context, WidgetRef ref, bool isDark) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    DateTime deadline = DateTime.now().add(const Duration(days: 90));
    String icon = '🎯';
    final icons = ['🎯', '🏠', '🚗', '✈️', '📱', '💎', '🎓', '💰', '🏋️', '🎮'];

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.8,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg : AppColors.lightBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
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
                        'New Goal',
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
                          if (nameCtrl.text.isNotEmpty &&
                              amountCtrl.text.isNotEmpty) {
                            final goal = GoalModel(
                              id: const Uuid().v4(),
                              name: nameCtrl.text.trim(),
                              target: double.tryParse(amountCtrl.text) ?? 0,
                              saved: 0,
                              icon: icon,
                              deadline: deadline,
                            );
                            ref.read(firebaseServiceProvider).addGoal(goal);
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
                        // Icon selector
                        Text(
                          'Choose Icon',
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
                          spacing: 10,
                          runSpacing: 10,
                          children: icons.map((e) {
                            final isSelected = e == icon;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setModalState(() => icon = e);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withAlpha(30)
                                      : isDark
                                      ? AppColors.darkSurface
                                      : AppColors.lightSurface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                          color: AppColors.primary,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    e,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        CupertinoTextField(
                          controller: nameCtrl,
                          placeholder: 'Goal Name',
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
                          placeholder: 'Target Amount (₹)',
                          keyboardType: TextInputType.number,
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
                          'Deadline',
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
                            _showDeadlinePicker(ctx, deadline, isDark, (d) {
                              setModalState(() => deadline = d);
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
                                  Formatters.date(deadline),
                                  style: TextStyle(
                                    fontSize: 15,
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
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeadlinePicker(
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
                minimumDate: DateTime.now(),
                onDateTimeChanged: (d) => picked = d,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
