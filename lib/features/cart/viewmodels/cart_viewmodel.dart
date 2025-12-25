import '../../../core/base/base_viewmodel.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/models/product.dart';
import '../logic/cart_logic.dart';

/// CartViewModel - ViewModel cho giỏ hàng
class CartViewModel extends BaseViewModel {
  final CartLogic _logic = CartLogic();

  List<CartItem> _items = [];
  Set<String> _selectedProductIds = {};

  List<CartItem> get items => _items;
  Set<String> get selectedProductIds => _selectedProductIds;
  
  /// Lấy danh sách selected items
  List<CartItem> get selectedItems {
    return _items
        .where((item) => _selectedProductIds.contains(item.product.id))
        .toList();
  }

  /// Tính tổng tiền CHỈ cho selected items
  double get total {
    return _logic.calculateTotal(selectedItems);
  }

  /// Số lượng items đã chọn
  int get selectedCount => _selectedProductIds.length;

  /// Kiểm tra item có được chọn không
  bool isSelected(String productId) {
    return _selectedProductIds.contains(productId);
  }

  /// Kiểm tra tất cả items đã được chọn chưa
  bool get isAllSelected {
    return _items.isNotEmpty && _selectedProductIds.length == _items.length;
  }

  /// Thêm sản phẩm vào giỏ hàng
  bool addToCart(Product product) {
    try {
      final success = _logic.addToCart(_items, product);
      
      // Auto-select item mới thêm
      _selectedProductIds = Set<String>.from(_selectedProductIds)..add(product.id);
      
      notifyListeners();
      return success;
    } catch (e) {
      setError('Không thể thêm sản phẩm vào giỏ hàng: ${e.toString()}');
      return false;
    }
  }

  /// Xóa sản phẩm khỏi giỏ hàng
  void removeFromCart(String productId) {
    try {
      _logic.removeFromCart(_items, productId);
      _selectedProductIds = Set<String>.from(_selectedProductIds)..remove(productId);
      notifyListeners();
    } catch (e) {
      setError('Không thể xóa sản phẩm: ${e.toString()}');
    }
  }

  /// Cập nhật số lượng
  void updateQuantity(String productId, int newQuantity) {
    try {
      if (newQuantity <= 0) {
        removeFromCart(productId);
        return;
      }
      
      _logic.updateQuantity(_items, productId, newQuantity);
      notifyListeners();
    } catch (e) {
      setError('Không thể cập nhật số lượng: ${e.toString()}');
    }
  }

  /// Toggle selection của 1 item
  void toggleSelection(String productId) {
    final newSelected = Set<String>.from(_selectedProductIds);
    if (newSelected.contains(productId)) {
      newSelected.remove(productId);
    } else {
      newSelected.add(productId);
    }
    _selectedProductIds = newSelected;
    notifyListeners();
  }

  /// Select tất cả items
  void selectAll() {
    _selectedProductIds = _items.map((item) => item.product.id).toSet();
    notifyListeners();
  }

  /// Deselect tất cả
  void deselectAll() {
    _selectedProductIds = {};
    notifyListeners();
  }

  /// Xóa toàn bộ giỏ hàng
  void clearCart() {
    _items = [];
    _selectedProductIds = {};
    notifyListeners();
  }

  /// Remove chỉ selected items (sau khi checkout)
  void removeSelectedItems() {
    _items = _items
        .where((item) => !_selectedProductIds.contains(item.product.id))
        .toList();
    _selectedProductIds = {};
    notifyListeners();
  }
}

