import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/medication_model.dart';

class StatusBadge extends StatelessWidget {
  final MedicationStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case MedicationStatus.available:
        bg = AppColors.successLight;
        fg = AppColors.success;
      case MedicationStatus.lowStock:
        bg = const Color(0xFFDDEFFB);
        fg = AppColors.info;
      case MedicationStatus.veryRare:
        bg = AppColors.warningLight;
        fg = AppColors.warning;
      case MedicationStatus.outOfStock:
        bg = AppColors.dangerLight;
        fg = AppColors.danger;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class CategoryBadge extends StatelessWidget {
  final MedicationCategory category;

  const CategoryBadge({super.key, required this.category});

  Color get _color {
    switch (category) {
      case MedicationCategory.antibioticsAntibacterials:
        return const Color(0xFF7C3AED);
      case MedicationCategory.analgesicsAntiInflammatory:
        return const Color(0xFFEA580C);
      case MedicationCategory.metabolicDisorders:
        return const Color(0xFFDC2626);
      case MedicationCategory.h1Antihistamines:
        return const Color(0xFF059669);
      case MedicationCategory.cardiologie:
        return const Color(0xFF0EA5E9);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: _color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
