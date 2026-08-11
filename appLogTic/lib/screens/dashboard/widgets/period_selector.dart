import 'package:flutter/material.dart';
import '../../../config/theme.dart';

/// Selector de período (Hoy, Semana, Mes, Todo)
class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodSelected;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final periods = [
      ('today', 'Hoy', Icons.today),
      ('week', 'Semana', Icons.date_range),
      ('month', 'Mes', Icons.calendar_month),
      ('all', 'Todo', Icons.inbox),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map((period) {
          final isSelected = selectedPeriod == period.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              selected: isSelected,
              onSelected: (_) => onPeriodSelected(period.$1),
              avatar: Icon(period.$3, size: 16, color: isSelected ? AppColors.white : context.onSurfaceColor),
              label: Text(
                period.$2,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.white : context.onSurfaceColor,
                  fontSize: 13,
                ),
              ),
              selectedColor: AppColors.corpGreen,
              checkmarkColor: AppColors.white,
              backgroundColor: context.containerColor,
              side: BorderSide(
                color: isSelected ? AppColors.corpGreen : context.borderColor,
                width: isSelected ? 1.5 : 1,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}