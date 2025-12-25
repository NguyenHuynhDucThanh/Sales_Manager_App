import '../../../core/models/cart_item.dart';
import '../../../core/repositories/order_repository.dart';

/// CheckoutLogic - Business logic for checkout process
class CheckoutLogic {
  final OrderRepository repository;

  CheckoutLogic(this.repository);

  /// Validate shipping address
  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ giao hàng';
    }
    if (value.trim().length < 10) {
      return 'Địa chỉ quá ngắn, vui lòng nhập đầy đủ';
    }
    return null;
  }

  /// Submit order
  Future<void> submitOrder({
    required List<CartItem> cartItems,
    required double total,
    required String shippingAddress,
    String? note,
  }) async {
    if (cartItems.isEmpty) {
      throw Exception('Giỏ hàng trống');
    }

    await repository.createOrder(
      cartItems,
      total,
      shippingAddress: shippingAddress.trim(),
      note: note?.trim().isEmpty == true ? null : note?.trim(),
    );
  }
}
