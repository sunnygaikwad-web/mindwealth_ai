import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mindwealth_ai/core/constants/app_colors.dart';
import 'package:mindwealth_ai/core/constants/app_strings.dart';
import 'package:mindwealth_ai/core/utils/validators.dart';
import 'package:mindwealth_ai/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final VoidCallback onToggleLogin;

  const RegisterScreen({super.key, required this.onToggleLogin});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  bool _isLoading = false;
  String? _error;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late AnimationController _glowController;
  late AnimationController _shimmerController;
  double _btnScale = 1.0;
  bool _nameFocused = false;
  bool _emailFocused = false;
  bool _passwordFocused = false;
  bool _confirmFocused = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
          ),
        );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _animController.forward();

    _nameFocus.addListener(
      () => setState(() => _nameFocused = _nameFocus.hasFocus),
    );
    _emailFocus.addListener(
      () => setState(() => _emailFocused = _emailFocus.hasFocus),
    );
    _passwordFocus.addListener(
      () => setState(() => _passwordFocused = _passwordFocus.hasFocus),
    );
    _confirmFocus.addListener(
      () => setState(() => _confirmFocused = _confirmFocus.hasFocus),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _animController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final nameError = Validators.name(_nameController.text);
    final emailError = Validators.email(_emailController.text);
    final passError = Validators.password(_passwordController.text);

    if (nameError != null) {
      setState(() => _error = nameError);
      return;
    }
    if (emailError != null) {
      setState(() => _error = emailError);
      return;
    }
    if (passError != null) {
      setState(() => _error = passError);
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    HapticFeedback.lightImpact();

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .registerWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      child: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              Color.lerp(
                                const Color(0xFF000000),
                                const Color(0xFF0A0015),
                                _glowController.value,
                              )!,
                              const Color(0xFF1E002B),
                              Color.lerp(
                                const Color(0xFF0f001c),
                                const Color(0xFF15002A),
                                _glowController.value,
                              )!,
                            ]
                          : [
                              const Color(0xFFFFFFFF),
                              const Color(0xFFFFF0F5),
                              const Color(0xFFFFF8E1),
                            ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                );
              },
            ),
          ),
          // Floating animated particles
          ..._buildFloatingParticles(isDark),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        // App Logo with pulsing glow ring
                        Center(
                              child: AnimatedBuilder(
                                animation: _glowController,
                                builder: (context, child) {
                                  return Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.accent.withAlpha(
                                            (30 + 50 * _glowController.value)
                                                .toInt(),
                                          ),
                                          blurRadius:
                                              18 + 15 * _glowController.value,
                                          spreadRadius:
                                              2 + 8 * _glowController.value,
                                        ),
                                        BoxShadow(
                                          color: AppColors.primaryDark
                                              .withAlpha(
                                                (20 +
                                                        30 *
                                                            _glowController
                                                                .value)
                                                    .toInt(),
                                              ),
                                          blurRadius:
                                              28 + 18 * _glowController.value,
                                          spreadRadius:
                                              3 + 5 * _glowController.value,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(22),
                                      child: Image.asset(
                                        'assets/images/app_logo.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                            .animate()
                            .scale(
                              begin: const Offset(0.3, 0.3),
                              end: const Offset(1.0, 1.0),
                              duration: 800.ms,
                              curve: Curves.elasticOut,
                            )
                            .fadeIn(duration: 500.ms)
                            .rotate(
                              begin: 0.05,
                              end: 0,
                              duration: 800.ms,
                              curve: Curves.easeOut,
                            ),
                        const SizedBox(height: 16),
                        // App Name
                        Text(
                              AppStrings.appName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1.2,
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 500.ms)
                            .slideY(begin: -0.3, end: 0, duration: 500.ms)
                            .blurXY(
                              begin: 8,
                              end: 0,
                              duration: 500.ms,
                              delay: 200.ms,
                            ),
                        const SizedBox(height: 12),
                        // Typewriter-style subtitle
                        Text(
                              'Sign up to manage your wealth',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark
                                    ? AppColors.darkSubtext
                                    : AppColors.lightSubtext,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 350.ms, duration: 600.ms)
                            .slideY(
                              begin: 0.2,
                              end: 0,
                              delay: 350.ms,
                              duration: 400.ms,
                            )
                            .shimmer(
                              delay: 800.ms,
                              duration: 1500.ms,
                              color: AppColors.primary.withAlpha(60),
                            ),
                        const SizedBox(height: 40),

                        // Form Fields — staggered with glow
                        _buildGlowField(
                              controller: _nameController,
                              focusNode: _nameFocus,
                              placeholder: 'Full Name',
                              isDark: isDark,
                              isFocused: _nameFocused,
                            )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 400.ms)
                            .slideX(
                              begin: 0.15,
                              end: 0,
                              duration: 500.ms,
                              delay: 400.ms,
                              curve: Curves.easeOutCubic,
                            ),
                        const SizedBox(height: 16),
                        _buildGlowField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              placeholder: AppStrings.email,
                              isDark: isDark,
                              isFocused: _emailFocused,
                              keyboardType: TextInputType.emailAddress,
                            )
                            .animate()
                            .fadeIn(delay: 500.ms, duration: 400.ms)
                            .slideX(
                              begin: 0.15,
                              end: 0,
                              duration: 500.ms,
                              delay: 500.ms,
                              curve: Curves.easeOutCubic,
                            ),
                        const SizedBox(height: 16),
                        _buildGlowField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              placeholder: AppStrings.password,
                              isDark: isDark,
                              isFocused: _passwordFocused,
                              obscure: true,
                            )
                            .animate()
                            .fadeIn(delay: 600.ms, duration: 400.ms)
                            .slideX(
                              begin: 0.15,
                              end: 0,
                              duration: 500.ms,
                              delay: 600.ms,
                              curve: Curves.easeOutCubic,
                            ),
                        const SizedBox(height: 16),
                        _buildGlowField(
                              controller: _confirmPasswordController,
                              focusNode: _confirmFocus,
                              placeholder: AppStrings.confirmPassword,
                              isDark: isDark,
                              isFocused: _confirmFocused,
                              obscure: true,
                            )
                            .animate()
                            .fadeIn(delay: 700.ms, duration: 400.ms)
                            .slideX(
                              begin: 0.15,
                              end: 0,
                              duration: 500.ms,
                              delay: 700.ms,
                              curve: Curves.easeOutCubic,
                            ),

                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.expense,
                              fontSize: 14,
                            ),
                          ).animate().shakeX(
                            hz: 3,
                            amount: 4,
                            duration: 400.ms,
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Shimmer sign up button
                        GestureDetector(
                              onTapDown: (_) =>
                                  setState(() => _btnScale = 0.93),
                              onTapUp: (_) {
                                setState(() => _btnScale = 1.0);
                                if (!_isLoading) _register();
                              },
                              onTapCancel: () =>
                                  setState(() => _btnScale = 1.0),
                              child: AnimatedScale(
                                scale: _btnScale,
                                duration: const Duration(milliseconds: 120),
                                curve: Curves.easeOut,
                                child: Container(
                                  height: 54,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.accent,
                                        AppColors.primaryLight,
                                        AppColors.primary,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withAlpha(100),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Shimmer overlay
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: AnimatedBuilder(
                                          animation: _shimmerController,
                                          builder: (context, child) {
                                            return ShaderMask(
                                              shaderCallback: (bounds) {
                                                return LinearGradient(
                                                  colors: const [
                                                    Color(0x00FFFFFF),
                                                    Color(0x44FFFFFF),
                                                    Color(0x00FFFFFF),
                                                  ],
                                                  stops: const [0.0, 0.5, 1.0],
                                                  begin: Alignment(
                                                    -2.0 +
                                                        4.0 *
                                                            _shimmerController
                                                                .value,
                                                    0,
                                                  ),
                                                  end: Alignment(
                                                    -1.0 +
                                                        4.0 *
                                                            _shimmerController
                                                                .value,
                                                    0,
                                                  ),
                                                ).createShader(bounds);
                                              },
                                              blendMode: BlendMode.srcATop,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  color: const Color(
                                                    0x22FFFFFF,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Center(
                                        child: _isLoading
                                            ? const CupertinoActivityIndicator(
                                                color: CupertinoColors.white,
                                              )
                                            : const Text(
                                                'Sign Up',
                                                style: TextStyle(
                                                  color: CupertinoColors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 800.ms, duration: 400.ms)
                            .slideY(begin: 0.2, end: 0, duration: 400.ms)
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1.0, 1.0),
                              delay: 800.ms,
                              duration: 400.ms,
                            ),
                        const SizedBox(height: 24),

                        // Switch to login
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onToggleLogin();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkSubtext
                                      : AppColors.lightSubtext,
                                  fontSize: 15,
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Log in.',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingParticles(bool isDark) {
    final rng = Random(99);
    return List.generate(10, (i) {
      final size = 20.0 + rng.nextDouble() * 100;
      final left = rng.nextDouble() * 400;
      final top = rng.nextDouble() * 800;
      final moveXRange = 15.0 + rng.nextDouble() * 25;
      final moveYRange = 15.0 + rng.nextDouble() * 25;
      final durationMs = 2500 + rng.nextInt(3000);
      final isCircle = rng.nextBool();
      final rotationEnd = (rng.nextDouble() - 0.5) * 0.5;

      return Positioned(
        left: left,
        top: top,
        child:
            Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: isCircle
                        ? null
                        : BorderRadius.circular(size * 0.2),
                    gradient: RadialGradient(
                      colors: [
                        (i.isEven ? AppColors.accent : AppColors.primary)
                            .withAlpha(isDark ? 25 : 18),
                        (i.isEven ? AppColors.primaryDark : AppColors.accent)
                            .withAlpha(isDark ? 12 : 8),
                      ],
                    ),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                  begin: -moveYRange,
                  end: moveYRange,
                  duration: Duration(milliseconds: durationMs),
                  curve: Curves.easeInOut,
                )
                .moveX(
                  begin: -moveXRange,
                  end: moveXRange,
                  duration: Duration(milliseconds: durationMs + 500),
                  curve: Curves.easeInOut,
                )
                .rotate(
                  begin: 0,
                  end: rotationEnd,
                  duration: Duration(milliseconds: durationMs + 1000),
                  curve: Curves.easeInOut,
                )
                .scale(
                  begin: Offset(
                    0.8 + rng.nextDouble() * 0.2,
                    0.8 + rng.nextDouble() * 0.2,
                  ),
                  end: Offset(
                    1.0 + rng.nextDouble() * 0.3,
                    1.0 + rng.nextDouble() * 0.3,
                  ),
                  duration: Duration(milliseconds: durationMs),
                  curve: Curves.easeInOut,
                )
                .fadeIn(duration: 1200.ms),
      );
    });
  }

  Widget _buildGlowField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String placeholder,
    required bool isDark,
    required bool isFocused,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused
              ? AppColors.primary.withAlpha(180)
              : isDark
              ? const Color(0xFF333333)
              : const Color(0xFFDBDBDB),
          width: isFocused ? 1.5 : 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withAlpha(40),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: AppColors.accent.withAlpha(20),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: CupertinoTextField(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder,
        obscureText: obscure,
        keyboardType: keyboardType,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: null,
        style: TextStyle(
          color: isDark ? AppColors.darkText : AppColors.lightText,
          fontSize: 15,
        ),
        placeholderStyle: TextStyle(
          color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
          fontSize: 15,
        ),
      ),
    );
  }
}
