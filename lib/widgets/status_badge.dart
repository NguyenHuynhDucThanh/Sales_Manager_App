import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// StatusBadge - Badge hiển thị trạng thái (pending, confirmed, cancelled)
class StatusBadge extends StatelessWidget {
  final String status;
  final String label;

  const StatusBadge({
    super.key,
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    BoxDecoration decoration;

    switch (status.toLowerCase()) {
      case 'pending':
        color = AppColors.pending;
        icon = Icons.pending_actions;
        decoration = AppDecoration.statusPending;
        break;
      case 'confirmed':
        color = AppColors.confirmed;
        icon = Icons.check_circle;
        decoration = AppDecoration.statusConfirmed;
        break;
      case 'cancelled':
        color = AppColors.cancelled;
        icon = Icons.cancel;
        decoration = AppDecoration.statusCancelled;
        break;
      default:
        color = AppColors.textSecondary;
        icon = Icons.help;
        decoration = BoxDecoration(
          color: AppColors.textSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.textSecondary),
        );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: decoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// StockBadge - Badge hiển thị trạng thái còn hàng/hết hàng
class StockBadge extends StatelessWidget {
  final bool inStock;
  final String? customLabel;

  const StockBadge({
    super.key,
    required this.inStock,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final color = inStock ? AppColors.success : AppColors.error;
    final icon = inStock ? Icons.check_circle : Icons.cancel;
    final label = customLabel ?? (inStock ? 'Còn hàng' : 'Hết hàng');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: color),
        ),
      ],
    );
  }
}
