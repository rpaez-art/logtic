import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/user.dart';
import '../../providers/user_management_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  User? _showDeleteDialog;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => provider.showCreateUserDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.users.length,
              itemBuilder: (context, index) {
                final user = provider.users[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _UserCard(
                    user: user,
                    onDelete: () => setState(() => _showDeleteDialog = user),
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
      padding: const EdgeInsets.all(16),
      child: Card(
        color: isError
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: isError
                        ? Theme.of(context).colorScheme.onErrorContainer
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: Icon(
                  Icons.close,
                  color: isError
                      ? Theme.of(context).colorScheme.onErrorContainer
                      : Theme.of(context).colorScheme.onPrimaryContainer,
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
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.person, color: AppColors.primary, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Usuario: ${user.username}', style: const TextStyle(fontSize: 14, color: AppColors.gray600)),
                  if (user.driverCode.isNotEmpty)
                    Text('ID Chofer: ${user.driverCode}', style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
                ],
              ),
            ),
            if (user.username != 'admin')
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, color: AppColors.error),
              ),
          ],
        ),
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
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Crear Nuevo Usuario', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              onChanged: provider.updateFullName,
              decoration: const InputDecoration(
                labelText: 'Nombre Completo',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: provider.updateUsername,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                prefixIcon: Icon(Icons.account_circle),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: provider.updatePassword,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: provider.updateDriverLicense,
              decoration: const InputDecoration(
                labelText: 'Licencia de Conducir (Opcional)',
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => provider.hideCreateUserDialog(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => provider.createUser(),
                  child: const Text('Crear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}