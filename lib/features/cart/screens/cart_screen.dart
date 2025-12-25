import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/widgets.dart';
import '../viewmodels/cart_viewmodel.dart';
import 'checkout_screen.dart';
import '../../products/screens/product_catalog_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    
    return Consumer<CartViewModel>(
      builder: (context, viewModel, child) {
        final cart = viewModel.items;
        final selectedIds = viewModel.selectedProductIds;
        final total = viewModel.total;
        final selectedCount = viewModel.selectedCount;

        return Scaffold(
          appBar: AppBar(
            title: Text('Giỏ hàng (${cart.length})'),
            actions: [
              if (cart.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    viewModel.clearCart();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xóa toàn bộ giỏ hàng')),
                    );
                  },
                  icon: const Icon(Icons.delete_sweep, color: Colors.white),
                  label: const Text('Xóa hết', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
      body: cart.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              message: 'Giỏ hàng trống',
              actionLabel: 'Tiếp tục mua sắm',
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductCatalogScreen(),
                  ),
                );
              },
            )
          : Column(
              children: [
                // Select All checkbox
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  color: AppColors.surfaceVariant,
                  child: Row(
                    children: [
                      Checkbox(
                        value: viewModel.isAllSelected,
                        tristate: true,
                        onChanged: (value) {
                          if (value == true) {
                            viewModel.selectAll();
                          } else {
                            viewModel.deselectAll();
                          }
                        },
                      ),
                      Text(
                        'Chọn tất cả',
                        style: AppTextStyles.label,
                      ),
                      const Spacer(),
                      Text(
                        '$selectedCount/${cart.length} đã chọn',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                
                // Cart items list
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.all(AppSpacing.md),
                    itemCount: cart.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      final isSelected = selectedIds.contains(item.product.id);
                      
                      return Card(
                        color: isSelected ? AppColors.primaryLight.withOpacity(0.1) : AppColors.surface,
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              // Checkbox
                              Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  viewModel.toggleSelection(item.product.id);
                                },
                              ),
                              
                              // Product image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                child: item.product.imageUrl != null && item.product.imageUrl!.isNotEmpty
                                    ? Image.network(
                                        item.product.imageUrl!,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 70,
                                          height: 70,
                                          color: AppColors.surfaceVariant,
                                          child: const Icon(Icons.image_not_supported),
                                        ),
                                      )
                                    : Container(
                                        width: 70,
                                        height: 70,
                                        color: AppColors.surfaceVariant,
                                        child: const Icon(Icons.inventory_2, size: 35),
                                      ),
                              ),
                              SizedBox(width: AppSpacing.md),
                              
                              // Product info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: AppSpacing.xs),
                                    Text(
                                      currencyFormat.format(item.product.price),
                                      style: AppTextStyles.bodySmall,
                                    ),
                                    SizedBox(height: AppSpacing.sm),
                                    
                                    // Quantity controls
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            if (item.quantity > 1) {
                                              viewModel.updateQuantity(
                                                item.product.id,
                                                item.quantity - 1,
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                                          color: Colors.red,
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            if (item.quantity < item.product.stock) {
                                              viewModel.updateQuantity(
                                                item.product.id,
                                                item.quantity + 1,
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Chỉ còn ${item.product.stock} sản phẩm trong kho',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.add_circle_outline, size: 20),
                                          color: Colors.green,
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Price & delete button
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currencyFormat.format(item.total),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  IconButton(
                                    onPressed: () {
                                      viewModel.removeFromCart(item.product.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Đã xóa ${item.product.name}'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.delete_outline, size: 20),
                                    color: Colors.red,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Bottom checkout bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tổng cộng:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(total),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '($selectedCount sản phẩm)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: selectedCount > 0
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const CheckoutScreen(),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              selectedCount > 0
                                  ? 'Thanh toán ($selectedCount sản phẩm)'
                                  : 'Chọn sản phẩm để thanh toán',
                              style: const TextStyle(fontSize: 17),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        );
      },
    );
  }
}
