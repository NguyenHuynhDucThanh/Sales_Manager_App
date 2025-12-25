import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// AppListTile - ListTile với styling chuẩn
class AppListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leading,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading ??
          (leadingIcon != null
              ? Icon(leadingIcon, color: iconColor ?? AppColors.primary)
              : null),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTextStyles.bodySmall)
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    );
  }
}

/// TabSection - Section với tabs
class TabSection extends StatelessWidget {
  final TabController controller;
  final List<Tab> tabs;
  final List<Widget> children;

  const TabSection({
    super.key,
    required this.controller,
    required this.tabs,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: controller,
            tabs: tabs,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            labelStyle: AppTextStyles.label,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: controller,
            children: children,
          ),
        ),
      ],
    );
  }
}

/// PriceDisplay - Hiển thị giá tiền với format chuẩn
class PriceDisplay extends StatelessWidget {
  final double amount;
  final String? label;
  final bool isLarge;
  final Color? color;

  const PriceDisplay({
    super.key,
    required this.amount,
    this.label,
    this.isLarge = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.bodySmall),
          SizedBox(height: AppSpacing.xs),
        ],
        Text(
          '${amount.toStringAsFixed(0).replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              )}đ',
          style: isLarge
              ? AppTextStyles.h2.copyWith(
                  color: color ?? AppColors.error,
                  fontWeight: FontWeight.bold,
                )
              : AppTextStyles.price.copyWith(color: color),
        ),
      ],
    );
  }
}

/// QuantitySelector - Selector cho số lượng
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max = 999,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: quantity > min ? () => onChanged(quantity - 1) : null,
            icon: const Icon(Icons.remove, size: 18),
            padding: EdgeInsets.all(AppSpacing.xs),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 40),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: quantity < max ? () => onChanged(quantity + 1) : null,
            icon: const Icon(Icons.add, size: 18),
            padding: EdgeInsets.all(AppSpacing.xs),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
