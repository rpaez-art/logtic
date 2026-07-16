import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// An animated icon button that toggles between light (sun) and dark (moon)
/// themes with a smooth rotation + scale transition.
/// Responds to both local taps and external theme changes (e.g. from drawer).
class AnimatedThemeToggle extends StatefulWidget {
  final double iconSize;
  final Color? color;

  const AnimatedThemeToggle({
    super.key,
    this.iconSize = 22,
    this.color,
  });

  @override
  State<AnimatedThemeToggle> createState() => _AnimatedThemeToggleState();
}

class _AnimatedThemeToggleState extends State<AnimatedThemeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _scale;

  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _rotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    _scale = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Sync controller with initial theme state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncWithProvider();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncWithProvider() {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    if (isDark != _isDark) {
      setState(() => _isDark = isDark);
      _controller.value = isDark ? 1.0 : 0.0;
    }
  }

  void _toggle() {
    final themeProvider = context.read<ThemeProvider>();
    final newIsDark = !_isDark;

    setState(() => _isDark = newIsDark);

    if (newIsDark) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    themeProvider.toggle();
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider so we react to external theme changes
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    if (isDark != _isDark) {
      // Schedule animation update after build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _isDark = isDark);
          if (isDark) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        }
      });
    }

    final color = widget.color ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.amber
            : Colors.white70);

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_scale.value * 0.2),
            child: Transform.rotate(
              angle: _rotation.value * 3.14159,
              child: Opacity(
                opacity: 1.0 - (_scale.value * 0.3),
                child: Icon(
                  _isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  size: widget.iconSize,
                  color: color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
