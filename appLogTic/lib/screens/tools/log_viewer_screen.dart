import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/log_service.dart';

/// Screen that displays the in-memory ring buffer of structured logs
/// and allows filtering / exporting.
class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  LogLevel _filterMin = LogLevel.debug;

  @override
  Widget build(BuildContext context) {
    final logs = LogService.instance.filterByLevel(_filterMin);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Logs',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.corpGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            tooltip: 'Abrir archivo de logs',
            onPressed: () => LogService.instance.openLogFile(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Limpiar logs',
            onPressed: () {
              LogService.instance.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter chips ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('Nivel: ',
                    style: TextStyle(fontSize: 13, color: AppColors.gray600)),
                const SizedBox(width: 4),
                ...LogLevel.values.map((level) {
                  final selected = level == _filterMin;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(level.label.trim(),
                          style: TextStyle(
                              fontSize: 12,
                              color: selected
                                  ? AppColors.white
                                  : AppColors.gray700)),
                      selected: selected,
                      onSelected: (_) => setState(() => _filterMin = level),
                      selectedColor: _chipColor(level),
                      checkmarkColor: AppColors.white,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                }),
              ],
            ),
          ),

          // ── Log list ──
          Expanded(
            child: logs.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.article_outlined,
                            size: 56, color: AppColors.gray300),
                        SizedBox(height: 12),
                        Text('Sin registros',
                            style: TextStyle(
                                fontSize: 16,
                                color: AppColors.gray500,
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: 4),
                        Text(
                            'Los logs aparecerán aquí\na medida que ocurran eventos.',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 13, color: AppColors.gray400)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: logs.length,
                    itemBuilder: (_, i) {
                      final entry = logs[i];
                      final color = _levelColor(entry.level);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: color.withValues(alpha: 0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(entry.level.emoji,
                                        style: const TextStyle(fontSize: 11)),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.gray500,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      entry.tag,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.message,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gray800,
                                  fontFamily: 'monospace',
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // ── Footer count ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${logs.length} entradas',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.gray500)),
                TextButton.icon(
                  onPressed: () => LogService.instance.openLogFile(),
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Exportar', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _levelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return AppColors.accent;
      case LogLevel.info:
        return AppColors.primary;
      case LogLevel.warn:
        return AppColors.warning;
      case LogLevel.error:
        return AppColors.error;
    }
  }

  Color _chipColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return AppColors.accentDark;
      case LogLevel.info:
        return AppColors.primaryLight;
      case LogLevel.warn:
        return AppColors.warning;
      case LogLevel.error:
        return AppColors.errorLight;
    }
  }
}
