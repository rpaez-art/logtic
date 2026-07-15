import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

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
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 1),
                        
                        // Logo
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.corpGold.withValues(alpha: 0.3),
                          ),
                          child: const Center(
                            child: Text(
                              '🚚',
                              style: TextStyle(fontSize: 56),
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
                        
                        // Login Card
                        Card(
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
                                
                                // Username field
                                TextFormField(
                                  initialValue: auth.username,
                                  decoration: InputDecoration(
                                    labelText: 'Usuario',
                                    labelStyle: const TextStyle(color: AppColors.gray600),
                                    prefixIcon: const Icon(
                                      Icons.person,
                                      color: AppColors.corpGreen,
                                    ),
                                  ),
                                  onChanged: (value) => auth.updateUsername(value),
                                ),
                                const SizedBox(height: 16),
                                
                                // Password field
                                TextFormField(
                                  initialValue: auth.password,
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
                                
                                // Error message
                                if (auth.errorMessage.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        auth.errorMessage,
                                        style: const TextStyle(
                                          color: AppColors.error,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
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
                                            final success = await auth.login();
                                            if (success && mounted) {
                                              Navigator.of(context).pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (_) => const DashboardScreen(),
                                                ),
                                              );
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
                                        : const Text(
                                            'INICIAR SESIÓN',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                              color: AppColors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const Spacer(flex: 2),
                        
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
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}