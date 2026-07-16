import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// Single master controller driving all chained entrance animations
  /// (logo → text → tagline → loading). Total duration = 2600ms.
  late AnimationController _controller;

  /// Separate controller for the exit fade-out (triggered asynchronously
  /// after the auth decision).
  late AnimationController _exitController;

  // ── Phase 1: Logo bounce-in (0–900ms) ──
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _logoSlide;

  // ── Phase 2: Text slide-up + fade (400–1100ms) ──
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;

  // ── Phase 3: Tagline fade-in (800–1400ms) ──
  late Animation<double> _taglineOpacity;

  // ── Phase 4: Loading spinner fade-in (1200–1700ms) ──
  late Animation<double> _loadingOpacity;

  // ── Phase 5: Exit fade-out (after decision) ──
  late Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();

    // ── Single master controller (2600 ms total) ──
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    // Helper: map milliseconds to interval fraction of 2600 ms
    double ms(double t) => t / 2600.0;

    // Phase 1: Logo bounce-in (0–900ms)
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.346, curve: Curves.elasticOut),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.173, curve: Curves.easeIn),
      ),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.346, curve: Curves.easeOutCubic),
    ));

    // Phase 2: Text slide-up + fade (400–1100ms)
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(ms(400), ms(1100), curve: Curves.easeOutCubic),
    ));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(ms(400), ms(1100), curve: Curves.easeInOut),
      ),
    );

    // Phase 3: Tagline fade-in (800–1400ms)
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(ms(800), ms(1400), curve: Curves.easeIn),
      ),
    );

    // Phase 4: Loading spinner fade-in (1200–1700ms)
    _loadingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(ms(1200), ms(1700), curve: Curves.easeIn),
      ),
    );

    // ── Exit controller (separate, triggered by auth decision) ──
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    // Start the entire chain
    _startAnimations();
  }

  void _startAnimations() {
    // Start the master controller
    _controller.forward();

    // After the full 2600ms sequence, decide where to navigate
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      _navigateAfterSplash();
    });
  }

  void _navigateAfterSplash() {
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      // Already logged in via restoreSession → go to dashboard
      _exitController.forward().then((_) {
        if (mounted) context.go('/dashboard');
      });
    } else {
      // Not logged in → go to login
      _exitController.forward().then((_) {
        if (mounted) context.go('/login');
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _exitFade,
      builder: (context, child) {
        return Opacity(
          opacity: _exitFade.value,
          child: child,
        );
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.corpGreen,
                AppColors.corpDarkGray,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Phase 1: Animated Logo
                  SlideTransition(
                    position: _logoSlide,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.corpGold.withValues(alpha: 0.3),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.corpGold.withValues(alpha: 0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '🚚',
                              style: TextStyle(fontSize: 64),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Phase 2: App title with slide-up
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          const Text(
                            'LOGTIC',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppColors.white,
                              letterSpacing: 6,
                              shadows: [
                                Shadow(
                                  color: AppColors.black,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Phase 3: Tagline fade-in
                          FadeTransition(
                            opacity: _taglineOpacity,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.corpGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Gestión de Rutas Inteligente',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.corpGold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Phase 4: Branded loading spinner
                  FadeTransition(
                    opacity: _loadingOpacity,
                    child: Column(
                      children: [
                        const _BrandSpinner(),
                        const SizedBox(height: 24),
                        const Text(
                          'Preparando tu experiencia...',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.corpLightBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Footer
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Text(
                        'Corporación Crea 21, CA',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.corpLightBlue,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Branded circular spinner with glow effect and dual-ring animation
class _BrandSpinner extends StatelessWidget {
  const _BrandSpinner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.corpGold.withValues(alpha: 0.08),
              boxShadow: [
                BoxShadow(
                  color: AppColors.corpGold.withValues(alpha: 0.2),
                  blurRadius: 25,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          // Main spinner — gold ring
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.corpGold),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Center brand dot with gradient
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.corpGold, AppColors.corpGreen],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
