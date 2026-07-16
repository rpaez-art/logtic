import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic));

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // Shake keyframes: left-right oscillation that dampens
    _shakeAnimation = _shakeController.drive(
      TweenSequence<Offset>([
        TweenSequenceItem(tween: Tween(begin: const Offset(0, 0), end: const Offset(-12, 0)), weight: 1),
        TweenSequenceItem(tween: Tween(begin: const Offset(-12, 0), end: const Offset(10, 0)), weight: 1),
        TweenSequenceItem(tween: Tween(begin: const Offset(10, 0), end: const Offset(-8, 0)), weight: 1),
        TweenSequenceItem(tween: Tween(begin: const Offset(-8, 0), end: const Offset(6, 0)), weight: 1),
        TweenSequenceItem(tween: Tween(begin: const Offset(6, 0), end: const Offset(-4, 0)), weight: 1),
        TweenSequenceItem(tween: Tween(begin: const Offset(-4, 0), end: const Offset(2, 0)), weight: 1),
        TweenSequenceItem(tween: Tween(begin: const Offset(2, 0), end: Offset.zero), weight: 1),
      ]),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _shakeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }
    // Accept emails (user@domain.com) or alphanumeric usernames (admin)
    final isEmail = value.contains('@');
    if (isEmail) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Ingresa un correo válido';
      }
    } else if (value.length < 3) {
      return 'El usuario debe tener al menos 3 caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            
                            // Logo with scale animation
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.corpGold.withValues(alpha: 0.3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.corpGold.withValues(alpha: 0.3),
                                      blurRadius: 25,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    '🚚',
                                    style: TextStyle(fontSize: 56),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                        
                        const Text(
                          'LOGTIC',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                            letterSpacing: 4,
                            shadows: [
                              Shadow(
                                color: AppColors.black,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.only(top: 4, bottom: 8),
                          child: Text(
                            'Gestión de Rutas Inteligente',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.corpGold,
                            ),
                          ),
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.only(bottom: 48),
                          child: Text(
                            'Corporación Crea 21, CA',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.corpLightBlue,
                            ),
                          ),
                        ),
                        
                        // Login Card with shake animation
                        AnimatedBuilder(
                          animation: _shakeAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: _shakeAnimation.value,
                              child: child,
                            );
                          },
                          child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.corpDarkGray,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // Email field
                                TextFormField(
                                  controller: _usernameController,
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  validator: _validateEmail,
                                  decoration: InputDecoration(
                                    labelText: 'Correo electrónico',
                                    hintText: 'usuario@correo.com',
                                    labelStyle: const TextStyle(color: AppColors.gray600),
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                      color: AppColors.corpGreen,
                                    ),
                                  ),
                                  onChanged: (value) => auth.updateUsername(value),
                                ),
                                const SizedBox(height: 16),
                                
                                // Password field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_passwordVisible,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    labelStyle: const TextStyle(color: AppColors.gray600),
                                    prefixIcon: const Icon(
                                      Icons.lock,
                                      color: AppColors.corpGreen,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: AppColors.gray600,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  onChanged: (value) => auth.updatePassword(value),
                                ),
                                
                                // Error message with slide-in animation
                                if (auth.errorMessage.isNotEmpty)
                                  AnimatedSlide(
                                    duration: const Duration(milliseconds: 400),
                                    offset: Offset.zero,
                                    child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.error.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                auth.errorMessage,
                                                style: const TextStyle(
                                                  color: AppColors.error,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ),
                                  ),
                                
                                const SizedBox(height: 16),
                                
                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: auth.isLoading
                                        ? null
                                        : () async {
                                            if (!_formKey.currentState!.validate()) return;
                                            final success = await auth.login();
                                            if (success && mounted) {
                                              final pending = auth.consumePendingDeepLink();
                                              if (pending != null) {
                                                context.go(pending);
                                              } else {
                                                context.go('/dashboard');
                                              }
                                            } else if (!success && mounted) {
                                              _triggerShake();
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.corpGold,
                                      disabledBackgroundColor: AppColors.corpGold.withValues(alpha: 0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: auth.isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.white,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.login, size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                'INICIAR SESIÓN',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1,
                                                  color: AppColors.white,
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
                        ),
                        
                        const SizedBox(height: 48),
                        
                        // Footer
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            'v1.0.0 • © 2025 Corpocrea',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.corpLightBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },      // builder
              ),        // Consumer
            ),          // SlideTransition
          ),            // FadeTransition
        ),              // SingleChildScrollView
      ),                // Center
    ),                  // SafeArea
  ),                    // Container
);                      // Scaffold
  }
}