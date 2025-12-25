import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/models/product.dart';
import '../logic/cart_logic.dart';

/// CartState - State cho cart bao gồm items và selected items
class CartState {
  final List<CartItem> items;
  final Set<String> selectedProductIds; // IDs của products được chọn

  CartState({
    required this.items,
    required this.selectedProductIds,
  });

  CartState copyWith({
    List<CartItem>? items,
    Set<String>? selectedProductIds,
  }) {
    return CartState(
      items: items ?? this.items,
      selectedProductIds: selectedProductIds ?? this.selectedProductIds,
    );
  }
}

/// CartNotifier - State management cho giỏ hàng với selection
class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => CartState(items: [], selectedProductIds: {});

  /// Thêm sản phẩm vào giỏ
  bool addToCart(Product product) {
    final logic = CartLogic();
    final success = logic.addToCart(state.items, product);
    
    // Auto-select item mới thêm
    final newSelected = Set<String>.from(state.selectedProductIds)..add(product.id);
    
    state = state.copyWith(
      items: [...state.items],
      selectedProductIds: newSelected,
    );
    return success;
  }

  /// Xóa sản phẩm khỏi giỏ
  void removeFromCart(String productId) {
    final logic = CartLogic();
    logic.removeFromCart(state.items, productId);
    
    final newSelected = Set<String>.from(state.selectedProductIds)..remove(productId);
    
    state = state.copyWith(
      items: [...state.items],
      selectedProductIds: newSelected,
    );
  }

  /// Cập nhật số lượng
  void updateQuantity(String productId, int newQuantity) {
    final logic = CartLogic();
    logic.updateQuantity(state.items, productId, newQuantity);
    state = state.copyWith(items: [...state.items]);
  }

  /// Toggle selection của 1 item
  void toggleSelection(String productId) {
    final newSelected = Set<String>.from(state.selectedProductIds);
    if (newSelected.contains(productId)) {
      newSelected.remove(productId);
    } else {
      newSelected.add(productId);
    }
    state = state.copyWith(selectedProductIds: newSelected);
  }

  /// Select tất cả items
  void selectAll() {
    final allIds = state.items.map((item) => item.product.id).toSet();
    state = state.copyWith(selectedProductIds: allIds);
  }

  /// Deselect tất cả
  void deselectAll() {
    state = state.copyWith(selectedProductIds: {});
  }

  /// Xóa toàn bộ giỏ hàng
  void clearCart() {
    state = CartState(items: [], selectedProductIds: {});
  }

  /// Remove chỉ selected items (sau khi checkout)
  void removeSelectedItems() {
    final newItems = state.items
        .where((item) => !state.selectedProductIds.contains(item.product.id))
        .toList();
    state = CartState(items: newItems, selectedProductIds: {});
  }
}

/// Provider cho giỏ hàng
final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});

/// Provider tính tổng tiền CHỈ cho selected items
final cartTotalProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartProvider);
  final logic = CartLogic();
  
  // Chỉ tính items được chọn
  final selectedItems = cartState.items
      .where((item) => cartState.selectedProductIds.contains(item.product.id))
      .toList();
  
  return logic.calculateTotal(selectedItems);
});

/// Provider lấy selected items
final selectedCartItemsProvider = Provider<List<CartItem>>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.items
      .where((item) => cartState.selectedProductIds.contains(item.product.id))
      .toList();
});
