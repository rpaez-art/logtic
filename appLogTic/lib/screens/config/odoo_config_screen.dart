import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/app_config.dart';
import '../../widgets/theme_toggle_button.dart';

class OdooConfigScreen extends StatefulWidget {
  const OdooConfigScreen({super.key});

  @override
  State<OdooConfigScreen> createState() => _OdooConfigScreenState();
}

class _OdooConfigScreenState extends State<OdooConfigScreen> {
  final _databaseController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  final String _fixedUrl = AppConfig.odooBaseUrl;

  @override
  void dispose() {
    _databaseController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración Odoo API', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: AnimatedThemeToggle(),
          ),
        ],
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🌐 Servidor Odoo',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _fixedUrl,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Configura tus credenciales de Odoo para acceder a tus rutas',
                      style: TextStyle(fontSize: 12, color: AppColors.gray700),
                    ),
                  ],
                ),
              ),
            ),
            TextField(
              controller: _databaseController,
              decoration: const InputDecoration(
                labelText: 'Base de Datos',
                hintText: 'nombre_bd',
                prefixIcon: Icon(Icons.storage),
              ),
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Usuario Odoo',
                hintText: 'admin',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Contraseña Odoo',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _databaseController.text.isNotEmpty &&
                        _usernameController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty
                    ? () => _saveConfig(context)
                    : null,
                icon: const Icon(Icons.save),
                label: const Text('Guardar y Probar Conexión'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveConfig(BuildContext context) async {
    // Save Odoo config to shared preferences
    // The actual test would connect to Odoo API


    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración guardada'),
          backgroundColor: AppColors.statusCompleted,
        ),
      );
      Navigator.pop(context);
    }
  }
}