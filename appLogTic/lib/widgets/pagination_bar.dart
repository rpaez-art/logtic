import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Componente reutilizable de controles de paginación para listas y tablas.
///
/// Soporta:
/// - Selector de tamaño de página (5, 10, 20, 50)
/// - Navegación a página previa, siguiente, primera y última
/// - Botones directos con números de página
/// - Resumen de elementos y página actual
/// - Diseño responsive sin desbordamiento
class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;
  final String? itemLabel;
  final EdgeInsetsGeometry margin;
  final Color? activeColor;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    this.pageSizeOptions = const [5, 10, 20, 50],
    required this.onPageChanged,
    required this.onPageSizeChanged,
    this.itemLabel,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = activeColor ?? AppColors.primary;

    if (totalPages <= 1 && totalItems <= (pageSizeOptions.firstOrNull ?? 5)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila superior: Selector por página y resumen de elementos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Selector de cantidad por página
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mostrar:',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  DropdownButton<int>(
                    value: pageSizeOptions.contains(pageSize) ? pageSize : pageSizeOptions.first,
                    underline: const SizedBox.shrink(),
                    isDense: true,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                    items: pageSizeOptions.map((size) {
                      return DropdownMenuItem(
                        value: size,
                        child: Text('$size'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) onPageSizeChanged(val);
                    },
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // Resumen de páginas
              Flexible(
                child: Text(
                  'Pág. $currentPage de $totalPages ($totalItems ${itemLabel ?? "elementos"})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.gray300 : AppColors.gray700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),

          // Fila inferior: Controles de navegación y chips numéricos
          if (totalPages > 1) ...[
            const SizedBox(height: 6),
            const Divider(height: 1),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Primera página
                  IconButton(
                    icon: const Icon(Icons.first_page_rounded, size: 18),
                    onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
                    tooltip: 'Primera página',
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                  const SizedBox(width: 2),

                  // Anterior
                  OutlinedButton.icon(
                    onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
                    icon: const Icon(Icons.chevron_left_rounded, size: 15),
                    label: const Text('Anterior', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 28),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Chips numéricos de páginas
                  ...List.generate(totalPages > 5 ? 5 : totalPages, (i) {
                    int pageNum;
                    if (totalPages <= 5) {
                      pageNum = i + 1;
                    } else if (currentPage <= 3) {
                      pageNum = i + 1;
                    } else if (currentPage >= totalPages - 2) {
                      pageNum = totalPages - 4 + i;
                    } else {
                      pageNum = currentPage - 2 + i;
                    }

                    final isCurr = pageNum == currentPage;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        onTap: () => onPageChanged(pageNum),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isCurr ? primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isCurr
                                  ? primary
                                  : (isDark ? AppColors.gray700 : AppColors.gray300),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$pageNum',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isCurr ? FontWeight.bold : FontWeight.normal,
                                color: isCurr
                                    ? AppColors.white
                                    : (isDark ? AppColors.gray300 : AppColors.gray700),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 4),

                  // Siguiente
                  OutlinedButton.icon(
                    onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
                    icon: const Icon(Icons.chevron_right_rounded, size: 15),
                    label: const Text('Siguiente', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 28),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 2),

                  // Última página
                  IconButton(
                    icon: const Icon(Icons.last_page_rounded, size: 18),
                    onPressed: currentPage < totalPages ? () => onPageChanged(totalPages) : null,
                    tooltip: 'Última página',
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
