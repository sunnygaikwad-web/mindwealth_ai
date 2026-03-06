import 'package:flutter/cupertino.dart';
import 'package:mindwealth_ai/core/constants/app_colors.dart';

class GlassContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.color,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    Widget container = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        padding: widget.padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              widget.color ??
              (isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8F7FC)),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: isDark
                ? AppColors.glassBorder
                : AppColors.glassDark.withAlpha(20),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0xFF000000).withAlpha(40)
                  : const Color(0xFF6C5CE7).withAlpha(8),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: widget.child,
      ),
    );

    if (widget.margin != null) {
      container = Padding(padding: widget.margin!, child: container);
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: container,
    );
  }
}
