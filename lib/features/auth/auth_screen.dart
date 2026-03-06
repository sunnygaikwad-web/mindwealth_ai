import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:mindwealth_ai/features/auth/login_screen.dart';
import 'package:mindwealth_ai/features/auth/register_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        // 3D flip effect
        final rotateAnim = Tween<double>(begin: pi / 2, end: 0.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );
        return AnimatedBuilder(
          animation: rotateAnim,
          builder: (context, child) {
            final isUnder = (ValueKey(_showLogin) != child?.key);
            var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
            tilt *= isUnder ? -1 : 1;
            return Transform(
              transform: Matrix4.rotationY(rotateAnim.value)
                ..setEntry(3, 0, tilt),
              alignment: Alignment.center,
              child: child,
            );
          },
          child: child,
        );
      },
      child: _showLogin
          ? LoginScreen(
              key: const ValueKey('login'),
              onToggleRegister: () => setState(() => _showLogin = false),
            )
          : RegisterScreen(
              key: const ValueKey('register'),
              onToggleLogin: () => setState(() => _showLogin = true),
            ),
    );
  }
}
