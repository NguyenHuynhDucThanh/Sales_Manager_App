import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/product.dart';
import '../../core/models/cart_item.dart';
import '../products/product_provider.dart';
import 'cart_provider.dart';
import 'cart_screen.dart';
import '../orders/order_history_screen.dart'; // Đã có import này là chuẩn rồi

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productListProvider);
    final cart = ref.watch(cartProvider);
    final totalAmount = ref.watch(cartTotalProvider);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      // 👇 ĐÃ SỬA PHẦN APPBAR TẠI ĐÂY 👇
      appBar: AppBar(
        title: const Text('Bán Hàng (POS)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history), // Icon hình cái đồng hồ
            tooltip: 'Lịch sử đơn hàng',
            onPressed: () {
              // Chuyển sang màn hình Lịch sử đơn hàng
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
              );
            },
          ),
        ],
      ),
      // 👆 KẾT THÚC PHẦN SỬA 👆
      
      body: Column(
        children: [
          Expanded(
            child: productState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
              data: (products) {
                 if (products.isEmpty) return const Center(child: Text("Chưa có sản phẩm nào"));
                 
                 return GridView.builder(
                   padding: const EdgeInsets.all(10),
                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                     crossAxisCount: 2, 
                     childAspectRatio: 0.8, 
                     crossAxisSpacing: 10,
                     mainAxisSpacing: 10,
                   ),
                   itemCount: products.length,
                   itemBuilder: (context, index) {
                     return _buildProductCard(context, ref, products[index]);
                   },
                 );
              },
            ),
          ),
          if (cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.1))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text(
                    '${cart.length} món',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  Text(
                    currencyFormat.format(totalAmount),
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Chuyển sang màn hình Giỏ hàng
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartScreen()),
                      );
                    }, 
                    child: const Text("Xem Giỏ"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, WidgetRef ref, Product product) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    
    final cart = ref.watch(cartProvider);
    final inCartItem = cart.firstWhere(
      (item) => item.product.id == product.id, 
      orElse: () => CartItem(product: product, quantity: 0)
    );

    // Kiểm tra hết hàng
    final bool isOutOfStock = product.stock <= 0;

    return Card(
      elevation: 2,
      // Nếu hết hàng thì làm mờ thẻ đi
      color: isOutOfStock ? Colors.grey[200] : Colors.white,
      child: InkWell(
        // Nếu hết hàng thì không cho bấm (onTap = null)
        onTap: isOutOfStock ? null : () {
          // Gọi hàm thêm vào giỏ và nhận kết quả
          final success = ref.read(cartProvider.notifier).addToCart(product);
          
          if (!success) {
            // Nếu trả về false -> Hiện thông báo
            ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Ẩn cái cũ nếu có
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Chỉ còn ${product.stock} sản phẩm trong kho!"),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    child: ColorFiltered(
                      // Nếu hết hàng thì chuyển ảnh sang trắng đen
                      colorFilter: isOutOfStock 
                          ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                          : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                      child: product.imageUrl != null
                          ? (kIsWeb
                              ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                              : CachedNetworkImage(imageUrl: product.imageUrl!, fit: BoxFit.cover))
                          : Container(color: Colors.grey[300], child: const Icon(Icons.fastfood)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name, 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis, 
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          // Nếu hết hàng thì gạch ngang tên
                          decoration: isOutOfStock ? TextDecoration.lineThrough : null,
                          color: isOutOfStock ? Colors.grey : Colors.black,
                        )
                      ),
                      Text(currencyFormat.format(product.price), style: const TextStyle(color: Colors.green)),
                      
                      if (inCartItem.quantity > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            "Đã chọn: ${inCartItem.quantity}", 
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
            
            // Dán nhãn "HẾT HÀNG" đè lên trên ảnh
            if (isOutOfStock)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.6),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "HẾT HÀNG",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}