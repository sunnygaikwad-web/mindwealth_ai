import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindwealth_ai/core/constants/app_colors.dart';
import 'package:mindwealth_ai/core/constants/app_strings.dart';
import 'package:mindwealth_ai/core/utils/glass_container.dart';
import 'package:mindwealth_ai/providers/auth_provider.dart';
import 'package:mindwealth_ai/providers/transaction_provider.dart';
import 'package:mindwealth_ai/providers/goal_provider.dart';
import 'package:mindwealth_ai/providers/ai_provider.dart';
import 'package:mindwealth_ai/providers/theme_provider.dart';
import 'package:mindwealth_ai/services/export_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeNotifierProvider);
    final profile = ref.watch(userProfileProvider).value;

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text(AppStrings.settings),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile card
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Text(
                              profile?.name.isNotEmpty == true
                                  ? profile!.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile?.name ?? 'User',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.lightText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile?.email ?? '',
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Theme toggle
                  _sectionTitle('Preferences', isDark),
                  const SizedBox(height: 12),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isDark
                                  ? CupertinoIcons.moon_fill
                                  : CupertinoIcons.sun_max_fill,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppStrings.darkMode,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText,
                              ),
                            ),
                          ],
                        ),
                        CupertinoSwitch(
                          value: isDark,
                          activeTrackColor: AppColors.primary,
                          onChanged: (_) {
                            HapticFeedback.lightImpact();
                            ref
                                .read(themeNotifierProvider.notifier)
                                .toggleTheme();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Export center
                  _sectionTitle('Export Center', isDark),
                  const SizedBox(height: 12),
                  _buildExportTile(
                    '📄',
                    AppStrings.exportPdf,
                    'Monthly summary with charts',
                    isDark,
                    () => _exportPdf(context, ref),
                  ),
                  const SizedBox(height: 8),
                  _buildExportTile(
                    '📊',
                    AppStrings.exportExcel,
                    'Full transaction data',
                    isDark,
                    () => _exportExcel(context, ref),
                  ),
                  const SizedBox(height: 8),
                  _buildExportTile(
                    '📝',
                    AppStrings.exportWord,
                    'Financial insights report',
                    isDark,
                    () => _exportWord(context, ref),
                  ),
                  const SizedBox(height: 24),

                  // AI Analysis
                  _sectionTitle('AI Engine', isDark),
                  const SizedBox(height: 12),
                  GlassContainer(
                    onTap: () => _runAiAnalysis(context, ref),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text('🤖', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Run AI Analysis',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.lightText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Analyze spending patterns and get insights',
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
                        const Icon(
                          CupertinoIcons.chevron_right,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign out
                  CupertinoButton(
                    color: AppColors.expense.withAlpha(30),
                    borderRadius: BorderRadius.circular(14),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref.read(authNotifierProvider.notifier).signOut();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.square_arrow_left,
                          color: AppColors.expense,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          AppStrings.logout,
                          style: TextStyle(
                            color: AppColors.expense,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) => Text(
    title,
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.darkText : AppColors.lightText,
    ),
  );

  Widget _buildExportTile(
    String icon,
    String title,
    String subtitle,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GlassContainer(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
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
          const Icon(CupertinoIcons.share, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    try {
      final export = ExportService();
      final profile = ref.read(userProfileProvider).value;
      final txns = ref.read(transactionsStreamProvider).value ?? [];
      final goals = ref.read(goalsStreamProvider).value ?? [];
      final insights = ref.read(aiInsightsStreamProvider).value ?? [];
      final income = ref.read(monthlyIncomeProvider);
      final expense = ref.read(monthlyExpenseProvider);
      final catSpending = ref.read(categorySpendingProvider);

      final file = await export.exportPdf(
        userName: profile?.name ?? 'User',
        totalIncome: income,
        totalExpense: expense,
        transactions: txns,
        goals: goals,
        insights: insights,
        categorySpending: catSpending,
      );
      await export.shareFile(file);
    } catch (e) {
      if (context.mounted) _showError(context, e.toString());
    }
  }

  Future<void> _exportExcel(BuildContext context, WidgetRef ref) async {
    try {
      final export = ExportService();
      final txns = ref.read(transactionsStreamProvider).value ?? [];
      final income = ref.read(monthlyIncomeProvider);
      final expense = ref.read(monthlyExpenseProvider);
      final catSpending = ref.read(categorySpendingProvider);

      final file = await export.exportExcel(
        transactions: txns,
        totalIncome: income,
        totalExpense: expense,
        categorySpending: catSpending,
      );
      await export.shareFile(file);
    } catch (e) {
      if (context.mounted) _showError(context, e.toString());
    }
  }

  Future<void> _exportWord(BuildContext context, WidgetRef ref) async {
    try {
      final export = ExportService();
      final profile = ref.read(userProfileProvider).value;
      final goals = ref.read(goalsStreamProvider).value ?? [];
      final insights = ref.read(aiInsightsStreamProvider).value ?? [];
      final income = ref.read(monthlyIncomeProvider);
      final expense = ref.read(monthlyExpenseProvider);

      final file = await export.exportWord(
        userName: profile?.name ?? 'User',
        totalIncome: income,
        totalExpense: expense,
        insights: insights,
        goals: goals,
      );
      await export.shareFile(file);
    } catch (e) {
      if (context.mounted) _showError(context, e.toString());
    }
  }

  Future<void> _runAiAnalysis(BuildContext context, WidgetRef ref) async {
    try {
      ref.read(aiAnalysisLoadingProvider.notifier).set(true);
      final aiService = ref.read(aiServiceProvider);
      final txns = ref.read(transactionsStreamProvider).value ?? [];
      final profile = ref.read(userProfileProvider).value;
      await aiService.analyzeTransactions(
        txns,
        profile?.income ?? 0,
        profile?.budgets,
      );
      ref.read(aiAnalysisLoadingProvider.notifier).set(false);
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Analysis Complete 🤖'),
            content: const Text(
              'AI insights have been generated. Check your dashboard!',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ref.read(aiAnalysisLoadingProvider.notifier).set(false);
      if (context.mounted) _showError(context, e.toString());
    }
  }

  void _showError(BuildContext context, String msg) {
    if (context.mounted) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(msg),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
    }
  }
}
