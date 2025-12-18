import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import '../../core/models/product.dart';
import 'product_provider.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe state từ Provider (Loading / Data / Error)
    final productState = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sản phẩm'),
        centerTitle: true,
      ),
      body: productState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text("Kho hàng trống!"));
          }
          
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductItem(context, ref, product);
            },
          );
        },
      ),
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
  }

  // Widget con hiển thị từng dòng sản phẩm
  Widget _buildProductItem(BuildContext context, WidgetRef ref, Product product) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Dismissible(
      key: Key(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(productListProvider.notifier).deleteProduct(product.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa ${product.name}')),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: product.imageUrl != null
                ? (kIsWeb
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      )
                    : CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ))
                : const Icon(Icons.image, color: Colors.grey),
          ),
          title: Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          
          // 👇 ĐÃ SỬA PHẦN NÀY ĐỂ CẢNH BÁO HẾT HÀNG 👇
          subtitle: Row(
            children: [
              Text(
                product.stock > 0 
                  ? 'Kho: ${product.stock}' 
                  : 'HẾT HÀNG (${product.stock})', 
                style: TextStyle(
                  // Nếu <= 0 thì chữ màu đỏ, còn lại màu xám
                  color: product.stock > 0 ? Colors.grey : Colors.red,
                  fontWeight: product.stock > 0 ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ],
          ),
          // 👆 KẾT THÚC PHẦN SỬA 👆

          trailing: Text(
            currencyFormat.format(product.price),
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            // Chuyển sang màn hình Edit và truyền object product sang
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProductScreen(product: product),
              ),
            );
          },
        ),
      ),
    );
  }
}