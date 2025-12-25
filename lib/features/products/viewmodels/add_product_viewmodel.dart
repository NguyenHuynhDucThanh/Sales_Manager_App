import '../../../core/base/base_viewmodel.dart';
import '../../../core/repositories/firestore_product_repository.dart';
import '../../../core/utils/currency_input_formatter.dart';
import '../logic/add_product_logic.dart';

/// AddProductViewModel - ViewModel cho thêm sản phẩm mới
class AddProductViewModel extends BaseViewModel {
  final AddProductLogic _logic = AddProductLogic(FirestoreProductRepository());

  String _name = '';
  String _price = '';
  String _stock = '';
  String? _imageUrl;

  String get name => _name;
  String get price => _price;
  String get stock => _stock;
  String? get imageUrl => _imageUrl;

  /// Set name
  void setName(String value) {
    if (_name != value) {
      _name = value;
      clearError();
    }
  }

  /// Set price
  void setPrice(String value) {
    if (_price != value) {
      _price = value;
      clearError();
    }
  }

  /// Set stock
  void setStock(String value) {
    if (_stock != value) {
      _stock = value;
      clearError();
    }
  }

  /// Set image URL
  void setImageUrl(String? value) {
    if (_imageUrl != value) {
      _imageUrl = value;
      notifyListeners();
    }
  }

  /// Validate form
  String? validateForm() {
    return _logic.validateProduct(
      name: _name,
      price: _price,
      stock: _stock,
    );
  }

  /// Thêm sản phẩm
  Future<bool> addProduct() async {
    try {
      // Validate
      final validationError = validateForm();
      if (validationError != null) {
        setError(validationError);
        return false;
      }

      setLoading(true);
      clearError();

      // Parse price từ formatted string (có thể có dấu phẩy)
      final priceValue = parseCurrencyInput(_price).toDouble();
      final stockValue = int.parse(_stock);

      await _logic.addProduct(
        name: _name,
        price: priceValue,
        stock: stockValue,
        imageUrl: _imageUrl,
      );

      // Reset form
      _name = '';
      _price = '';
      _stock = '';
      _imageUrl = null;

      return true;
    } catch (e) {
      setError('Không thể thêm sản phẩm: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Reset form
  void reset() {
    _name = '';
    _price = '';
    _stock = '';
    _imageUrl = null;
    clearError();
    notifyListeners();
  }
}

