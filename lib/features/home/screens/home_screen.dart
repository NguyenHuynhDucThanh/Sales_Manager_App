import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/product.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/widgets.dart';
import '../../products/screens/product_detail_screen.dart';
import '../../products/providers/product_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh data khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(productListProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner - Responsive height
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.width < 600 ? 180 : 250,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Stack(
                children: [
                  // Background pattern overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.05),
                            AppColors.accent.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 16.0 : 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shopping_bag, color: AppColors.textWhite, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              'Shop Online',
                              style: AppTextStyles.h1.copyWith(
                                fontSize: MediaQuery.of(context).size.width < 600 ? 24 : 32,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mua sắm dễ dàng, giao hàng nhanh chóng',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 18,
                            color: AppColors.textWhite.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to products tab (index 1 for user)
                            // This will be handled by parent DashboardScreen
                          },
                          icon: const Icon(Icons.shopping_bag, size: 18),
                          label: const Text('Xem sản phẩm'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textWhite,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.lg),

            // Features Section - Horizontal scroll on small screens
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  _buildFeatureCard(
                    Icons.local_shipping,
                    'Giao hàng nhanh',
                    AppColors.warning,
                  ),
                  SizedBox(width: AppSpacing.md),
                  _buildFeatureCard(
                    Icons.verified_user,
                    'Hàng chính hãng',
                    AppColors.success,
                  ),
                  SizedBox(width: AppSpacing.md),
                  _buildFeatureCard(
                    Icons.support_agent,
                    'Hỗ trợ 24/7',
                    AppColors.info,
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.lg),

            // Featured Products Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: AppColors.warning),
                      SizedBox(width: AppSpacing.sm),
                      Text('Sản phẩm nổi bật', style: AppTextStyles.h3),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Những sản phẩm được yêu thích nhất',
                    style: AppTextStyles.caption,
                  ),
                  SizedBox(height: AppSpacing.md),
                  // Responsive grid with real data
                  productsAsync.when(
                    loading: () => const LoadingState(message: 'Đang tải sản phẩm...'),
                    error: (err, stack) => ErrorState(
                      message: 'Không thể tải sản phẩm: $err',
                      onRetry: () => ref.invalidate(productListProvider),
                    ),
                    data: (products) {
                      // Hiển thị tối đa 4 sản phẩm
                      final displayProducts = products.take(4).toList();
                      if (displayProducts.isEmpty) {
                        return const EmptyState(
                          icon: Icons.inventory_2_outlined,
                          message: 'Chưa có sản phẩm nào',
                        );
                      }
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.68,
                            ),
                            itemCount: displayProducts.length,
                            itemBuilder: (context, index) {
                              final product = displayProducts[index];
                              return _buildProductCard(context, product);
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String label, Color color) {
    return Container(
      width: 140,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return ProductCard(
      product: product,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
    );
  }
}
