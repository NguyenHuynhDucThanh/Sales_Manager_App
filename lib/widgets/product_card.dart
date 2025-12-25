import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../core/models/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// ProductCard - Card hiển thị sản phẩm (tái sử dụng)
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.md),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.surfaceVariant,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surfaceVariant,
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: AppColors.textHint,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceVariant,
                        child: Icon(
                          Icons.image,
                          size: 48,
                          color: AppColors.textHint,
                        ),
                      ),
              ),
            ),
            
            // Product Info
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    
                    // Price
                    Text(
                      currencyFormat.format(product.price),
                      style: AppTextStyles.priceSmall,
                    ),
                    
                    // Stock Badge (if needed)
                    if (trailing != null) ...[
                      SizedBox(height: AppSpacing.xs),
                      trailing!,
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ProductListTile - List item hiển thị sản phẩm (cho admin)
class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProductListTile({
    super.key,
    required this.product,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    Widget tile = Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            color: AppColors.surfaceVariant,
          ),
          child: product.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                  ),
                )
              : const Icon(Icons.image, color: AppColors.textHint),
        ),
        title: Text(
          product.name,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Text(
              product.stock > 0
                  ? 'Kho: ${product.stock}'
                  : 'HẾT HÀNG (${product.stock})',
              style: AppTextStyles.caption.copyWith(
                color: product.stock > 0 ? AppColors.textSecondary : AppColors.error,
                fontWeight:
                    product.stock > 0 ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Text(
          currencyFormat.format(product.price),
          style: AppTextStyles.priceSmall,
        ),
        onTap: onTap,
      ),
    );

    if (onDelete != null) {
      return Dismissible(
        key: Key(product.id),
        direction: DismissDirection.endToStart,
        background: Container(
          color: AppColors.error,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: const Icon(Icons.delete, color: AppColors.textWhite),
        ),
        onDismissed: (_) => onDelete?.call(),
        child: tile,
      );
    }

    return tile;
  }
}
