import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/checkout_viewmodel.dart';
import '../../orders/screens/order_history_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout(
    CheckoutViewModel checkoutViewModel,
    CartViewModel cartViewModel,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    // Set values to ViewModel
    checkoutViewModel.setShippingAddress(_addressController.text);
    checkoutViewModel.setNote(_noteController.text);

    final selectedItems = cartViewModel.selectedItems;
    final total = cartViewModel.total;

    final success = await checkoutViewModel.submitOrder(
      cartItems: selectedItems,
      total: total,
    );

    if (success && mounted) {
      // Clear ONLY selected items on success
      cartViewModel.removeSelectedItems();

      // Success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt hàng thành công! Vui lòng chờ admin xác nhận.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to order history
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const OrderHistoryScreen(),
        ),
        (route) => route.isFirst,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đặt hàng: ${checkoutViewModel.errorMessage ?? "Không thể đặt hàng"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy CartViewModel từ parent context trước
    final cartViewModel = Provider.of<CartViewModel>(context, listen: true);
    
    return ChangeNotifierProvider(
      create: (_) => CheckoutViewModel(),
      child: Consumer<CheckoutViewModel>(
        builder: (context, checkoutViewModel, child) {
          final selectedItems = cartViewModel.selectedItems;
          final total = cartViewModel.total;
          final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

          // Debug: Log để kiểm tra
          print('CheckoutScreen - selectedItems count: ${selectedItems.length}');
          print('CheckoutScreen - total: $total');
          print('CheckoutScreen - cart items count: ${cartViewModel.items.length}');
          print('CheckoutScreen - selectedIds: ${cartViewModel.selectedProductIds}');

          return Scaffold(
            appBar: AppBar(
              title: const Text('Xác nhận đặt hàng'),
            ),
            body: selectedItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Không có sản phẩm nào được chọn',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tổng số sản phẩm trong giỏ: ${cartViewModel.items.length}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Quay lại giỏ hàng'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cart items summary
                    const Text(
                      'Sản phẩm đã chọn',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    ...selectedItems.map((item) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: item.product.imageUrl != null && item.product.imageUrl!.isNotEmpty
                                  ? NetworkImage(item.product.imageUrl!)
                                  : null,
                              child: item.product.imageUrl == null || item.product.imageUrl!.isEmpty
                                  ? const Icon(Icons.inventory_2)
                                  : null,
                            ),
                            title: Text(item.product.name),
                            subtitle: Text('SL: ${item.quantity}'),
                            trailing: Text(
                              currencyFormat.format(item.total),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        )),

                    const Divider(height: 32),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng tiền:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Shipping Address
                    const Text(
                      'Địa chỉ giao hàng *',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Nhập địa chỉ chi tiết (số nhà, đường, phường/xã, quận/huyện, tỉnh/thành)',
                        border: OutlineInputBorder(),
                      ),
                      validator: checkoutViewModel.validateAddress,
                      onChanged: (value) {
                        checkoutViewModel.setShippingAddress(value);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Note
                    const Text(
                      'Ghi chú (không bắt buộc)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Ghi chú thêm cho đơn hàng (ví dụ: giao giờ hành chính, gọi trước khi giao...)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        checkoutViewModel.setNote(value);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: checkoutViewModel.isLoading
                          ? null
                          : () => _handleCheckout(checkoutViewModel, cartViewModel),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: checkoutViewModel.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Xác nhận đặt hàng',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
