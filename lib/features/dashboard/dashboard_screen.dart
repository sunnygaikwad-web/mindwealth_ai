import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        LinearProgressIndicator,
        AlwaysStoppedAnimation,
        ScaffoldMessenger,
        SnackBar,
        SnackBarBehavior,
        Colors,
        RoundedRectangleBorder,
        BorderRadius;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mindwealth_ai/core/constants/app_colors.dart';
import 'package:mindwealth_ai/core/constants/app_strings.dart';
import 'package:mindwealth_ai/core/constants/category_helper.dart';
import 'package:mindwealth_ai/core/utils/formatters.dart';
import 'package:mindwealth_ai/core/utils/glass_container.dart';
import 'package:mindwealth_ai/core/utils/animated_counter.dart';
import 'package:mindwealth_ai/models/gamification_model.dart';
import 'package:mindwealth_ai/providers/auth_provider.dart';
import 'package:mindwealth_ai/providers/transaction_provider.dart';
import 'package:mindwealth_ai/providers/goal_provider.dart';
import 'package:mindwealth_ai/providers/ai_provider.dart';
import 'package:mindwealth_ai/providers/gamification_provider.dart';
import 'package:mindwealth_ai/providers/budget_provider.dart';
import 'package:mindwealth_ai/providers/theme_provider.dart';
import 'package:mindwealth_ai/features/transactions/add_transaction_sheet.dart';
import 'package:mindwealth_ai/services/sms_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int touchedPieIndex = -1;
  int touchedBarIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeNotifierProvider);
    final profile = ref.watch(userProfileProvider).value;
    final income = ref.watch(monthlyIncomeProvider);
    final expense = ref.watch(monthlyExpenseProvider);
    final categorySpending = ref.watch(categorySpendingProvider);
    final goals = ref.watch(goalsStreamProvider).value ?? [];
    final insights = ref.watch(aiInsightsStreamProvider).value ?? [];
    final gamification =
        ref.watch(gamificationStreamProvider).value ?? GamificationModel();
    final budgets = ref.watch(budgetsProvider);
    final trends = ref.watch(monthlyTrendProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Nav bar
              CupertinoSliverNavigationBar(
                largeTitle: Text(
                  'Hi, ${profile?.name.split(' ').first ?? 'there'} 👋',
                ),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.add_circled_solid, size: 28),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    showAddTransactionSheet(context, ref, isDark);
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth > 600 ? 32 : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ─── Balance Card ───
                      RepaintBoundary(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (context, val, child) {
                            return Opacity(
                              opacity: val,
                              child: Transform.scale(
                                scale: 0.95 + (0.05 * val),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryDark,
                                  AppColors.primary,
                                  AppColors.primaryLight,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(100),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      AppStrings.totalBalance,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xCCFFFFFF),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Theme toggle — pill button
                                        GestureDetector(
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            ref
                                                .read(
                                                  themeNotifierProvider
                                                      .notifier,
                                                )
                                                .toggleTheme();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0x33FFFFFF),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isDark
                                                      ? CupertinoIcons
                                                            .sun_max_fill
                                                      : CupertinoIcons
                                                            .moon_fill,
                                                  color: CupertinoColors.white,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isDark ? 'Light' : 'Dark',
                                                  style: const TextStyle(
                                                    color:
                                                        CupertinoColors.white,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Auto Sync
                                        GestureDetector(
                                          onTap: () async {
                                            HapticFeedback.mediumImpact();
                                            try {
                                              final txns =
                                                  await SmsService.syncBankTransactions();
                                              if (txns.isNotEmpty) {
                                                for (var txn in txns) {
                                                  ref
                                                      .read(
                                                        firebaseServiceProvider,
                                                      )
                                                      .addTransaction(txn);
                                                }
                                              }
                                            } catch (e) {
                                              // Ignore permission denied
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0x33FFFFFF),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  CupertinoIcons
                                                      .arrow_2_circlepath,
                                                  color: CupertinoColors.white,
                                                  size: 14,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'Sync',
                                                  style: TextStyle(
                                                    color:
                                                        CupertinoColors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // AI Analysis Button
                                    GestureDetector(
                                          onTap: () async {
                                            HapticFeedback.mediumImpact();
                                            try {
                                              ref
                                                  .read(
                                                    aiAnalysisLoadingProvider
                                                        .notifier,
                                                  )
                                                  .set(true);
                                              final aiService = ref.read(
                                                aiServiceProvider,
                                              );
                                              final txns =
                                                  ref
                                                      .read(
                                                        transactionsStreamProvider,
                                                      )
                                                      .value ??
                                                  [];
                                              final profile = ref
                                                  .read(userProfileProvider)
                                                  .value;
                                              await aiService
                                                  .analyzeTransactions(
                                                    txns,
                                                    profile?.income ?? 0,
                                                    profile?.budgets,
                                                  );
                                              ref
                                                  .read(
                                                    aiAnalysisLoadingProvider
                                                        .notifier,
                                                  )
                                                  .set(false);
                                              if (context.mounted) {
                                                // Show success toast instead of dialog so it's less intrusive
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: const Text(
                                                      'AI Analysis complete. Insights updated! 🤖',
                                                    ),
                                                    backgroundColor:
                                                        AppColors.primary,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              ref
                                                  .read(
                                                    aiAnalysisLoadingProvider
                                                        .notifier,
                                                  )
                                                  .set(false);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0x33FFFFFF),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  CupertinoIcons.sparkles,
                                                  color: CupertinoColors.white,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  ref.watch(
                                                        aiAnalysisLoadingProvider,
                                                      )
                                                      ? 'Analyzing...'
                                                      : 'Run Analysis',
                                                  style: const TextStyle(
                                                    color:
                                                        CupertinoColors.white,
                                                    fontSize: 12,
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
                                        .shimmer(
                                          duration: 3.seconds,
                                          color: Colors.white24,
                                        ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                AnimatedCounter(
                                  value: income - expense,
                                  prefix: '₹',
                                  style: const TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w800,
                                    color: CupertinoColors.white,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Income & Expense blocks with vibrant gradients
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildGradientMiniCard(
                                        icon: CupertinoIcons.arrow_down_right,
                                        label: AppStrings.income,
                                        amount: income,
                                        gradientColors: const [
                                          Color(0xFF0D9488),
                                          Color(0xFF14B8A6),
                                        ],
                                        isDark: isDark,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildGradientMiniCard(
                                        icon: CupertinoIcons.arrow_up_right,
                                        label: AppStrings.expense,
                                        amount: expense,
                                        gradientColors: const [
                                          Color(0xFFE11D48),
                                          Color(0xFFFB7185),
                                        ],
                                        isDark: isDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ─── Category Spending Bar Chart ───
                      if (categorySpending.isNotEmpty) ...[
                        _sectionTitle(AppStrings.monthlySpending, isDark)
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: -0.05, end: 0, duration: 400.ms),
                        const SizedBox(height: 12),
                        RepaintBoundary(
                          child:
                              GlassContainer(
                                    padding: const EdgeInsets.all(20),
                                    child: SizedBox(
                                      height: 220,
                                      child: BarChart(
                                        BarChartData(
                                          alignment:
                                              BarChartAlignment.spaceAround,
                                          maxY:
                                              categorySpending.values.fold(
                                                0.0,
                                                (a, b) => a > b ? a : b,
                                              ) *
                                              1.2,
                                          barTouchData: BarTouchData(
                                            enabled: true,
                                            touchCallback:
                                                (
                                                  FlTouchEvent event,
                                                  barTouchResponse,
                                                ) {
                                                  setState(() {
                                                    if (!event
                                                            .isInterestedForInteractions ||
                                                        barTouchResponse ==
                                                            null ||
                                                        barTouchResponse.spot ==
                                                            null) {
                                                      touchedBarIndex = -1;
                                                      return;
                                                    }
                                                    touchedBarIndex =
                                                        barTouchResponse
                                                            .spot!
                                                            .touchedBarGroupIndex;
                                                  });
                                                },
                                            touchTooltipData: BarTouchTooltipData(
                                              getTooltipItem:
                                                  (
                                                    group,
                                                    groupIndex,
                                                    rod,
                                                    rodIndex,
                                                  ) {
                                                    final entry =
                                                        categorySpending.entries
                                                            .elementAt(
                                                              groupIndex,
                                                            );
                                                    return BarTooltipItem(
                                                      '${entry.key}\n${Formatters.compactCurrency(entry.value)}',
                                                      const TextStyle(
                                                        color: CupertinoColors
                                                            .white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    );
                                                  },
                                            ),
                                          ),
                                          titlesData: FlTitlesData(
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  final idx = value.toInt();
                                                  if (idx >= 0 &&
                                                      idx <
                                                          categorySpending
                                                              .length) {
                                                    final cat = categorySpending
                                                        .keys
                                                        .elementAt(idx);
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 8,
                                                          ),
                                                      child: Text(
                                                        CategoryHelper.getIcon(
                                                          cat,
                                                        ),
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return const SizedBox();
                                                },
                                              ),
                                            ),
                                            leftTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            topTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                          ),
                                          gridData: const FlGridData(
                                            show: false,
                                          ),
                                          borderData: FlBorderData(show: false),
                                          barGroups: categorySpending.entries
                                              .toList()
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                                final color =
                                                    CategoryHelper.getColor(
                                                      entry.value.key,
                                                    );
                                                final isTouched =
                                                    entry.key ==
                                                    touchedBarIndex;
                                                return BarChartGroupData(
                                                  x: entry.key,
                                                  barRods: [
                                                    BarChartRodData(
                                                      toY: entry.value.value,
                                                      gradient: LinearGradient(
                                                        colors: isTouched
                                                            ? [
                                                                color.withAlpha(
                                                                  200,
                                                                ),
                                                                color,
                                                              ]
                                                            : [
                                                                color,
                                                                color.withAlpha(
                                                                  180,
                                                                ),
                                                              ],
                                                        begin: Alignment
                                                            .bottomCenter,
                                                        end:
                                                            Alignment.topCenter,
                                                      ),
                                                      width: isTouched
                                                          ? 28
                                                          : 22,
                                                      borderRadius:
                                                          const BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                  6,
                                                                ),
                                                          ),
                                                    ),
                                                  ],
                                                );
                                              })
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: 200.ms, duration: 600.ms)
                                  .slideY(begin: 0.1, end: 0, duration: 600.ms),
                        ),
                        const SizedBox(height: 8),
                        // Category legend
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: categorySpending.entries.map((entry) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: CategoryHelper.getColor(entry.key),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${CategoryHelper.getIcon(entry.key)} ${entry.key}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkSubtext
                                        : AppColors.lightSubtext,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // ─── Expense Distribution (Pie Chart) ───
                        _sectionTitle('Expense Distribution', isDark)
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideX(
                              begin: -0.1,
                              end: 0,
                              duration: 500.ms,
                              curve: Curves.easeOutCubic,
                            ),
                        const SizedBox(height: 12),
                        RepaintBoundary(
                          child: GlassContainer(
                            padding: const EdgeInsets.all(20),
                            child: SizedBox(
                              height: 220,
                              child:
                                  PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 40,
                                      sections: categorySpending.entries
                                          .toList()
                                          .asMap()
                                          .entries
                                          .map((entryMapped) {
                                            final index = entryMapped.key;
                                            final entry = entryMapped.value;
                                            final isTouched =
                                                index == touchedPieIndex;
                                            final total = categorySpending
                                                .values
                                                .fold(0.0, (a, b) => a + b);
                                            final percentage =
                                                (entry.value / total) * 100;
                                            return PieChartSectionData(
                                              color: CategoryHelper.getColor(
                                                entry.key,
                                              ),
                                              value: entry.value,
                                              title: isTouched
                                                  ? '${entry.key}\n${percentage.toStringAsFixed(0)}%'
                                                  : '${percentage.toStringAsFixed(0)}%',
                                              radius: isTouched ? 60 : 50,
                                              titleStyle: TextStyle(
                                                fontSize: isTouched ? 14 : 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                shadows: isTouched
                                                    ? const [
                                                        Shadow(
                                                          color: Colors.black45,
                                                          blurRadius: 2,
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                            );
                                          })
                                          .toList(),
                                      pieTouchData: PieTouchData(
                                        touchCallback:
                                            (
                                              FlTouchEvent event,
                                              pieTouchResponse,
                                            ) {
                                              if (!event
                                                      .isInterestedForInteractions ||
                                                  pieTouchResponse == null ||
                                                  pieTouchResponse
                                                          .touchedSection ==
                                                      null) {
                                                setState(
                                                  () => touchedPieIndex = -1,
                                                );
                                                return;
                                              }
                                              setState(() {
                                                touchedPieIndex =
                                                    pieTouchResponse
                                                        .touchedSection!
                                                        .touchedSectionIndex;
                                              });
                                            },
                                      ),
                                    ),
                                  ).animate().scale(
                                    duration: 600.ms,
                                    curve: Curves.easeOutBack,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ─── Monthly Trend (Line Chart) ───
                      _sectionTitle(AppStrings.spendingTrend, isDark)
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(
                            begin: -0.1,
                            end: 0,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 12),
                      RepaintBoundary(
                        child:
                            GlassContainer(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Legend with dot indicators
                                      Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: const BoxDecoration(
                                              color: AppColors.income,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Income',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? AppColors.darkSubtext
                                                  : AppColors.lightSubtext,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: const BoxDecoration(
                                              color: AppColors.expense,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Expense',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? AppColors.darkSubtext
                                                  : AppColors.lightSubtext,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        height: 220,
                                        child: LineChart(
                                          LineChartData(
                                            minY: 0,
                                            maxY:
                                                _getMaxTrendValue(trends) * 1.3,
                                            lineTouchData: LineTouchData(
                                              enabled: true,
                                              touchTooltipData: LineTouchTooltipData(
                                                getTooltipItems: (touchedSpots) {
                                                  return touchedSpots.map((
                                                    spot,
                                                  ) {
                                                    final isIncome =
                                                        spot.barIndex == 0;
                                                    return LineTooltipItem(
                                                      '${isIncome ? "Income" : "Expense"}\n${Formatters.compactCurrency(spot.y)}',
                                                      TextStyle(
                                                        color: isIncome
                                                            ? AppColors.income
                                                            : AppColors.expense,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    );
                                                  }).toList();
                                                },
                                              ),
                                              handleBuiltInTouches: true,
                                            ),
                                            gridData: FlGridData(
                                              show: true,
                                              drawHorizontalLine: true,
                                              drawVerticalLine: false,
                                              horizontalInterval:
                                                  _getMaxTrendValue(trends) > 0
                                                  ? _getMaxTrendValue(trends) *
                                                        1.3 /
                                                        4
                                                  : 25,
                                              getDrawingHorizontalLine:
                                                  (value) {
                                                    return FlLine(
                                                      color: isDark
                                                          ? const Color(
                                                              0x15FFFFFF,
                                                            )
                                                          : const Color(
                                                              0x15000000,
                                                            ),
                                                      strokeWidth: 1,
                                                    );
                                                  },
                                            ),
                                            titlesData: FlTitlesData(
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 30,
                                                  getTitlesWidget: (value, meta) {
                                                    final idx = value.toInt();
                                                    if (idx >= 0 &&
                                                        idx < trends.length) {
                                                      final m =
                                                          trends[idx]['month']
                                                              as DateTime;
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 8,
                                                            ),
                                                        child: Text(
                                                          Formatters.shortDate(
                                                            m,
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: isDark
                                                                ? AppColors
                                                                      .darkSubtext
                                                                : AppColors
                                                                      .lightSubtext,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return const SizedBox();
                                                  },
                                                ),
                                              ),
                                              leftTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              topTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              rightTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                              show: false,
                                            ),
                                            lineBarsData: [
                                              // Income line
                                              LineChartBarData(
                                                isCurved: true,
                                                curveSmoothness: 0.35,
                                                color: AppColors.income,
                                                barWidth: 3,
                                                isStrokeCapRound: true,
                                                dotData: FlDotData(
                                                  show: true,
                                                  getDotPainter:
                                                      (
                                                        spot,
                                                        percent,
                                                        bar,
                                                        index,
                                                      ) {
                                                        return FlDotCirclePainter(
                                                          radius: 4,
                                                          color:
                                                              AppColors.income,
                                                          strokeWidth: 2,
                                                          strokeColor:
                                                              CupertinoColors
                                                                  .white,
                                                        );
                                                      },
                                                ),
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      AppColors.income
                                                          .withAlpha(80),
                                                      AppColors.income
                                                          .withAlpha(10),
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                ),
                                                spots: trends
                                                    .asMap()
                                                    .entries
                                                    .map((entry) {
                                                      return FlSpot(
                                                        entry.key.toDouble(),
                                                        (entry.value['income']
                                                            as double),
                                                      );
                                                    })
                                                    .toList(),
                                              ),
                                              // Expense line
                                              LineChartBarData(
                                                isCurved: true,
                                                curveSmoothness: 0.35,
                                                color: AppColors.expense,
                                                barWidth: 3,
                                                isStrokeCapRound: true,
                                                dotData: FlDotData(
                                                  show: true,
                                                  getDotPainter:
                                                      (
                                                        spot,
                                                        percent,
                                                        bar,
                                                        index,
                                                      ) {
                                                        return FlDotCirclePainter(
                                                          radius: 4,
                                                          color:
                                                              AppColors.expense,
                                                          strokeWidth: 2,
                                                          strokeColor:
                                                              CupertinoColors
                                                                  .white,
                                                        );
                                                      },
                                                ),
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      AppColors.expense
                                                          .withAlpha(60),
                                                      AppColors.expense
                                                          .withAlpha(8),
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                ),
                                                spots: trends
                                                    .asMap()
                                                    .entries
                                                    .map((entry) {
                                                      return FlSpot(
                                                        entry.key.toDouble(),
                                                        (entry.value['expense']
                                                            as double),
                                                      );
                                                    })
                                                    .toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 300.ms, duration: 700.ms)
                                .slideY(
                                  begin: 0.15,
                                  end: 0,
                                  duration: 700.ms,
                                  curve: Curves.easeOutCubic,
                                ),
                      ),
                      const SizedBox(height: 20),

                      // ─── Budget Overview ───
                      if (budgets.isNotEmpty) ...[
                        _sectionTitle(
                          'Budget Overview',
                          isDark,
                        ).animate().fadeIn(duration: 400.ms),
                        const SizedBox(height: 12),
                        ...budgets.asMap().entries.map((entry) {
                          final b = entry.value;
                          return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GlassContainer(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${CategoryHelper.getIcon(b.category)} ${b.category}',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? AppColors.darkText
                                                  : AppColors.lightText,
                                            ),
                                          ),
                                          Text(
                                            '${Formatters.compactCurrency(b.spent)} / ${Formatters.compactCurrency(b.limit)}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: b.isOverBudget
                                                  ? AppColors.expense
                                                  : isDark
                                                  ? AppColors.darkSubtext
                                                  : AppColors.lightSubtext,
                                              fontWeight: b.isOverBudget
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: b.progress.clamp(0.0, 1.0),
                                          minHeight: 8,
                                          backgroundColor: isDark
                                              ? AppColors.darkSurface
                                              : AppColors.lightBg,
                                          valueColor: AlwaysStoppedAnimation(
                                            b.isOverBudget
                                                ? AppColors.expense
                                                : b.isNearLimit
                                                ? AppColors.warning
                                                : AppColors.income,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(
                                delay: Duration(
                                  milliseconds: 400 + entry.key * 100,
                                ),
                                duration: 400.ms,
                              )
                              .slideY(begin: 0.1, end: 0, duration: 400.ms);
                        }),
                        const SizedBox(height: 12),
                      ],

                      // ─── Goals ───
                      if (goals.isNotEmpty) ...[
                        _sectionTitle(
                          AppStrings.yourGoals,
                          isDark,
                        ).animate().fadeIn(duration: 400.ms),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 140,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: goals.length,
                            separatorBuilder: (c, i) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final goal = goals[index];
                              return GlassContainer(
                                    width: 160,
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${goal.icon} ${goal.name}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? AppColors.darkText
                                                : AppColors.lightText,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: goal.progress,
                                            minHeight: 6,
                                            backgroundColor: isDark
                                                ? AppColors.darkSurface
                                                : AppColors.lightBg,
                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                                  AppColors.primary,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${goal.progressPercent.toStringAsFixed(0)}% • ${Formatters.daysRemaining(goal.deadline)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark
                                                ? AppColors.darkSubtext
                                                : AppColors.lightSubtext,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(
                                    delay: Duration(
                                      milliseconds: 300 + index * 100,
                                    ),
                                    duration: 400.ms,
                                  )
                                  .slideX(begin: 0.1, end: 0, duration: 400.ms);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ─── AI Insights ───
                      if (insights.isNotEmpty) ...[
                        _sectionTitle(
                          AppStrings.aiInsights,
                          isDark,
                        ).animate().fadeIn(duration: 400.ms),
                        const SizedBox(height: 12),
                        ...insights.take(3).toList().asMap().entries.map((
                          entry,
                        ) {
                          final insight = entry.value;
                          return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GlassContainer(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Text(
                                        insight.icon,
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              insight.title,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? AppColors.darkText
                                                    : AppColors.lightText,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              insight.message,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark
                                                    ? AppColors.darkSubtext
                                                    : AppColors.lightSubtext,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(
                                delay: Duration(
                                  milliseconds: 400 + entry.key * 120,
                                ),
                                duration: 400.ms,
                              )
                              .slideX(begin: 0.05, end: 0, duration: 400.ms);
                        }),
                        const SizedBox(height: 12),
                      ],

                      // ─── Badges ───
                      if (gamification.badges.isNotEmpty) ...[
                        _sectionTitle(
                          'Your Badges 🏅',
                          isDark,
                        ).animate().fadeIn(duration: 400.ms),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: gamification.badges.map((badge) {
                            return GlassContainer(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              borderRadius: 14,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    BadgeDefinition.getIcon(badge),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    badge,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.darkText
                                          : AppColors.lightText,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Points
                      if (gamification.points > 0)
                        GlassContainer(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '⭐',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${gamification.points} Points',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.darkText
                                          : AppColors.lightText,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 500.ms, duration: 500.ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1.0, 1.0),
                              duration: 500.ms,
                            ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradientMiniCard({
    required IconData icon,
    required String label,
    required double amount,
    required List<Color> gradientColors,
    required bool isDark,
  }) {
    return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors
                  .map((c) => c.withAlpha(isDark ? 50 : 35))
                  .toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: gradientColors.first.withAlpha(isDark ? 60 : 40),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: gradientColors.first, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: gradientColors.first,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedCounter(
                value: amount,
                prefix: '₹',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: gradientColors.first,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  double _getMaxTrendValue(List<Map<String, dynamic>> trends) {
    double maxVal = 0;
    for (final t in trends) {
      final inc = t['income'] as double;
      final exp = t['expense'] as double;
      if (inc > maxVal) maxVal = inc;
      if (exp > maxVal) maxVal = exp;
    }
    return maxVal == 0 ? 100 : maxVal;
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkText : AppColors.lightText,
      ),
    );
  }
}
