import '../../../core/base/base_viewmodel.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/repositories/order_repository.dart';
import '../logic/checkout_logic.dart';

/// CheckoutViewModel - ViewModel cho checkout process
class CheckoutViewModel extends BaseViewModel {
  final CheckoutLogic _logic = CheckoutLogic(OrderRepository());

  String _shippingAddress = '';
  String _note = '';

  String get shippingAddress => _shippingAddress;
  String get note => _note;

  /// Set shipping address
  void setShippingAddress(String value) {
    if (_shippingAddress != value) {
      _shippingAddress = value;
      clearError();
    }
  }

  /// Set note
  void setNote(String value) {
    if (_note != value) {
      _note = value;
    }
  }

  /// Validate address
  String? validateAddress(String? value) {
    return _logic.validateAddress(value);
  }

  /// Submit order
  Future<bool> submitOrder({
    required List<CartItem> cartItems,
    required double total,
  }) async {
    try {
      // Validate
      final addressError = validateAddress(_shippingAddress);
      if (addressError != null) {
        setError(addressError);
        return false;
      }

      if (cartItems.isEmpty) {
        setError('Vui lòng chọn sản phẩm để thanh toán');
        return false;
      }

      setLoading(true);
      clearError();

      await _logic.submitOrder(
        cartItems: cartItems,
        total: total,
        shippingAddress: _shippingAddress,
        note: _note.isEmpty ? null : _note,
      );

      return true;
    } catch (e) {
      setError('Không thể đặt hàng: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }
}

