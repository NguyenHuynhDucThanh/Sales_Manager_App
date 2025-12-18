import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'cart_provider.dart';
import '../../core/repositories/order_repository.dart';
import '../products/product_provider.dart'; // Import để làm mới danh sách sản phẩm

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isProcessing = false; // Biến để hiện vòng quay khi đang xử lý

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết đơn hàng")),
      body: cart.isEmpty
          ? const Center(child: Text("Giỏ hàng đang trống"))
          : Column(
              children: [
                // 1. Danh sách các món đã chọn
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${currencyFormat.format(item.product.price)} x ${item.quantity}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currencyFormat.format(item.total), 
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () {
                                ref.read(cartProvider.notifier).decreaseQuantity(item.product);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 2. Khu vực thanh toán
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tổng cộng:", style: TextStyle(fontSize: 18)),
                          Text(
                            currencyFormat.format(total), 
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : () async {
                            // BẮT ĐẦU QUÁ TRÌNH THANH TOÁN
                            setState(() => _isProcessing = true);
                            
                            try {
                              // 1. Gọi Repo lưu đơn hàng (Dùng Transaction)
                              // Nếu kho không đủ, hàm này sẽ ném ra lỗi (Exception) và nhảy xuống catch
                              await ref.read(orderRepositoryProvider).createOrder(cart, total);
                              
                              // 2. Nếu thành công: Xóa sạch giỏ hàng
                              ref.read(cartProvider.notifier).clearCart();

                              // 3. QUAN TRỌNG: Bắt buộc tải lại danh sách sản phẩm để cập nhật số tồn kho mới
                              ref.invalidate(productListProvider); 

                              // 4. Thông báo & Quay về màn hình bán hàng
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Thanh toán thành công!"),
                                    backgroundColor: Colors.green,
                                  )
                                );
                                Navigator.pop(context); // Đóng màn hình giỏ
                              }
                            } catch (e) {
                              // 5. Xử lý lỗi (Ví dụ: Không đủ hàng)
                              if (mounted) {
                                // Xóa chữ "Exception: " cho thông báo đẹp hơn
                                final errorMessage = e.toString().replaceAll("Exception: ", "");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage), // Hiện lỗi cụ thể từ Repository
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
                                  )
                                );
                              }
                            } finally {
                              // Dù thành công hay thất bại cũng tắt vòng quay
                              if (mounted) setState(() => _isProcessing = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, 
                            foregroundColor: Colors.white
                          ),
                          child: _isProcessing 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("XÁC NHẬN THANH TOÁN", style: TextStyle(fontSize: 18)),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}