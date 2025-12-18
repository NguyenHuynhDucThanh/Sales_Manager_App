import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/product.dart';
import '../../core/models/cart_item.dart';

// 1. Provider quản lý danh sách trong giỏ
final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

// 2. Provider tính tổng tiền (CÁI BẠN ĐANG THIẾU)
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  // Hàm fold giúp cộng dồn tổng tiền của từng món
  return cart.fold(0, (sum, item) => sum + item.total);
});

// 3. Logic xử lý
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [];
  }

  // Hàm thêm vào giỏ có trả về kết quả (True/False)
  bool addToCart(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    
    int currentQtyInCart = 0;
    if (index != -1) {
      currentQtyInCart = state[index].quantity;
    }

    // Kiểm tra tồn kho
    if (currentQtyInCart >= product.stock) {
      return false; 
    }

    if (index != -1) {
      state[index].quantity++;
      state = [...state]; 
    } else {
      state = [...state, CartItem(product: product)];
    }
    
    return true;
  }

  void decreaseQuantity(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index == -1) return;

    if (state[index].quantity > 1) {
      state[index].quantity--;
      state = [...state];
    } else {
      removeFromCart(product);
    }
  }

  void removeFromCart(Product product) {
    state = state.where((item) => item.product.id != product.id).toList();
  }

  void clearCart() {
    state = [];
  }
}