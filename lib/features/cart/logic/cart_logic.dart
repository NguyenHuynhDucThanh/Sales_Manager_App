import '../../../core/models/cart_item.dart';
import '../../../core/models/product.dart';

/// CartLogic - Business logic cho giỏ hàng
class CartLogic {
  /// Thêm sản phẩm vào giỏ hàng
  /// Returns: true nếu thành công, false nếu sản phẩm đã có trong giỏ
  bool addToCart(List<CartItem> cart, Product product) {
    // Kiểm tra xem sản phẩm đã có trong giỏ chưa
    final existingIndex = cart.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex != -1) {
      // Sản phẩm đã có, tăng số lượng
      final existingItem = cart[existingIndex];
      cart[existingIndex] = CartItem(
        product: existingItem.product,
        quantity: existingItem.quantity + 1,
      );
      return false; // Không thêm mới, chỉ tăng số lượng
    } else {
      // Sản phẩm chưa có, thêm mới
      cart.add(CartItem(product: product, quantity: 1));
      return true;
    }
  }

  /// Xóa sản phẩm khỏi giỏ hàng
  void removeFromCart(List<CartItem> cart, String productId) {
    cart.removeWhere((item) => item.product.id == productId);
  }

  /// Cập nhật số lượng sản phẩm trong giỏ
  void updateQuantity(List<CartItem> cart, String productId, int newQuantity) {
    final index = cart.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (newQuantity <= 0) {
        cart.removeAt(index);
      } else {
        cart[index] = CartItem(
          product: cart[index].product,
          quantity: newQuantity,
        );
      }
    }
  }

  /// Tính tổng tiền giỏ hàng
  double calculateTotal(List<CartItem> cart) {
    return cart.fold(0.0, (sum, item) => sum + item.total);
  }
}
