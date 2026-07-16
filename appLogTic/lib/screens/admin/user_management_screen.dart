import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/user.dart';
import '../../providers/user_management_provider.dart';
import '../../widgets/theme_toggle_button.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserManagementProvider>();

    // Show create user dialog when triggered
    if (provider.showCreateDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => _CreateUserDialog(provider: provider),
          ).then((_) => provider.hideCreateUserDialog());
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.corpGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => provider.showCreateUserDialog(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.person_add, size: 22),
        label: const Text('Nuevo', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: Column(
        children: [
          if (provider.successMessage.isNotEmpty)
            _MessageCard(
              message: provider.successMessage,
              isError: false,
              onClose: () => provider.clearMessages(),
            ),
          if (provider.errorMessage.isNotEmpty)
            _MessageCard(
              message: provider.errorMessage,
              isError: true,
              onClose: () => provider.clearMessages(),
            ),
          // Users header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.people, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  '${provider.users.length} Usuarios',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.users.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline, size: 72, color: AppColors.gray300),
                        const SizedBox(height: 16),
                        const Text('No hay usuarios registrados', style: TextStyle(fontSize: 16, color: AppColors.gray600)),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => provider.showCreateUserDialog(),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Crear primer usuario'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: provider.users.length,
                    itemBuilder: (context, index) {
                      final user = provider.users[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _UserCard(
                          user: user,
                          onDelete: () { /* user will be handled by the dialog */ },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback onClose;

  const _MessageCard({required this.message, required this.isError, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        color: isError
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: isError
                        ? Theme.of(context).colorScheme.onErrorContainer
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, size: 18),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(32, 32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onDelete;

  const _UserCard({required this.user, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.username == 'admin';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: isAdmin
                    ? const LinearGradient(colors: [AppColors.secondary, AppColors.secondaryDark])
                    : const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(user.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      ),
                      if (isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('ADMIN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary, letterSpacing: 1)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('@${user.username}', style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
                  if (user.driverCode.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.badge, size: 12, color: AppColors.gray400),
                        const SizedBox(width: 4),
                        Text('ID: ${user.driverCode}', style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!isAdmin)
              IconButton(
                onPressed: () => _showDeleteConfirmation(context),
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                tooltip: 'Eliminar usuario',
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
            SizedBox(width: 12),
            Text('Confirmar Eliminación', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text('¿Estás seguro de eliminar a "${user.fullName}"?\nEsta acción no se puede deshacer.', style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () { onDelete(); Navigator.pop(ctx); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.white),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _CreateUserDialog extends StatefulWidget {
  final UserManagementProvider provider;

  const _CreateUserDialog({required this.provider});

  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_add, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          const Text('Nuevo Usuario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Completa los datos del nuevo conductor', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
              const SizedBox(height: 20),
              TextField(
                onChanged: provider.updateFullName,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  hintText: 'Ej: Juan Pérez',
                  prefixIcon: Icon(Icons.person_outline),
                  filled: true,
                  fillColor: AppColors.gray50,
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),
              TextField(
                onChanged: provider.updateUsername,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  hintText: 'Ej: juan.perez',
                  prefixIcon: Icon(Icons.account_circle_outlined),
                  filled: true,
                  fillColor: AppColors.gray50,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                onChanged: provider.updatePassword,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.gray600),
                    onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                  ),
                  filled: true,
                  fillColor: AppColors.gray50,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                onChanged: provider.updateDriverLicense,
                decoration: const InputDecoration(
                  labelText: 'Código de Conductor (Opcional)',
                  hintText: 'Ej: DRV001',
                  prefixIcon: Icon(Icons.badge_outlined),
                  filled: true,
                  fillColor: AppColors.gray50,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            provider.hideCreateUserDialog();
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            provider.createUser();
            if (provider.errorMessage.isEmpty) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Crear Usuario'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}