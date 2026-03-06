import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mindwealth_ai/core/constants/app_colors.dart';
import 'package:mindwealth_ai/core/theme/app_theme.dart';
import 'package:mindwealth_ai/providers/auth_provider.dart';
import 'package:mindwealth_ai/providers/theme_provider.dart';
import 'package:mindwealth_ai/features/auth/auth_screen.dart';
import 'package:mindwealth_ai/features/dashboard/dashboard_screen.dart';
import 'package:mindwealth_ai/features/transactions/transactions_screen.dart';
import 'package:mindwealth_ai/features/goals/goals_screen.dart';
import 'package:mindwealth_ai/features/budgets/budgets_screen.dart';
import 'package:mindwealth_ai/features/settings/settings_screen.dart';

class MindWealthApp extends ConsumerWidget {
  const MindWealthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeNotifierProvider);
    final authState = ref.watch(authStateProvider);

    return CupertinoApp(
      title: 'MindWealth AI',
      debugShowCheckedModeBanner: false,
      theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: authState.when(
        data: (user) {
          if (user == null) return const AuthScreen();
          return const MainTabScreen();
        },
        loading: () => CupertinoPageScaffold(
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App logo on splash
                Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(60),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Text('🧠', style: TextStyle(fontSize: 64)),
                        ),
                      ),
                    )
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 20),
                Text(
                  'MindWealth AI',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                    decoration: TextDecoration.none,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                const SizedBox(height: 24),
                const CupertinoActivityIndicator(radius: 14),
              ],
            ),
          ),
        ),
        error: (e, s) => const AuthScreen(),
      ),
    );
  }
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: isDark
            ? AppColors.darkBg.withAlpha(240)
            : AppColors.lightBg.withAlpha(240),
        activeColor: AppColors.primary,
        inactiveColor: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF262626) : const Color(0xFFEFEFEF),
            width: 0.5,
          ),
        ),
        iconSize: 26,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            activeIcon: Icon(CupertinoIcons.house_fill),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.arrow_right_arrow_left_square),
            activeIcon: Icon(CupertinoIcons.arrow_right_arrow_left_square_fill),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.flag),
            activeIcon: Icon(CupertinoIcons.flag_fill),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_pie),
            activeIcon: Icon(CupertinoIcons.chart_pie_fill),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            activeIcon: Icon(CupertinoIcons.person_solid),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return const DashboardScreen();
              case 1:
                return const TransactionsScreen();
              case 2:
                return const GoalsScreen();
              case 3:
                return const BudgetsScreen();
              case 4:
                return const SettingsScreen();
              default:
                return const DashboardScreen();
            }
          },
        );
      },
    );
  }
}
