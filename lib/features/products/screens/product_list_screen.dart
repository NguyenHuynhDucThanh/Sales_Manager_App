import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/widgets.dart';
import '../viewmodels/product_list_viewmodel.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    // Load products khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductListViewModel>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductListViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Danh sách sản phẩm'),
            centerTitle: true,
          ),
          body: _buildBody(viewModel),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProductScreen()),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(ProductListViewModel viewModel) {
    if (viewModel.isLoading && viewModel.allProducts.isEmpty) {
      return const LoadingState();
    }

    if (viewModel.hasError) {
      return ErrorState(
        message: viewModel.errorMessage ?? 'Đã xảy ra lỗi',
        onRetry: () => viewModel.loadProducts(),
      );
    }

    final products = viewModel.products;
    if (products.isEmpty) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        message: 'Kho hàng trống!',
      );
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductListTile(
          product: product,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProductScreen(product: product),
              ),
            );
          },
          onDelete: () async {
            final success = await viewModel.deleteProduct(product.id);
            if (context.mounted) {
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa ${product.name}')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: ${viewModel.errorMessage ?? "Không thể xóa sản phẩm"}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }
}
