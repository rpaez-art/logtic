import 'package:flutter/material.dart';

/// A drop-in replacement for [AnimatedSwitcher] that applies a polished
/// slide + scale + fade transition whenever the [child] widget changes.
///
/// Pass a positive [direction] (+1) to make the new child slide in from the
/// right, or a negative direction (−1) to slide in from the left.
class AnimatedLayoutSwitcher extends StatelessWidget {
  /// The widget to display (should have a stable [ValueKey] so the
  /// transition fires when the layout changes).
  final Widget child;

  /// Slide direction: `-1.0` = in from left, `+1.0` = in from right.
  final double direction;

  /// Duration of the full transition. Defaults to 400 ms.
  final Duration duration;

  /// Curve used for both the incoming and outgoing animations.
  /// Defaults to [Curves.easeInOutCubic].
  final Curve curve;

  /// Horizontal offset fraction of the screen width to slide.
  /// Defaults to `0.3` (30 % of the screen).
  final double slideFraction;

  /// Initial scale of the incoming child. Defaults to `0.95`.
  final double initialScale;

  const AnimatedLayoutSwitcher({
    super.key,
    required this.child,
    required this.direction,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOutCubic,
    this.slideFraction = 0.3,
    this.initialScale = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(direction * slideFraction, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: curve)),
          child: ScaleTransition(
            scale: Tween<double>(begin: initialScale, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: curve),
            ),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
