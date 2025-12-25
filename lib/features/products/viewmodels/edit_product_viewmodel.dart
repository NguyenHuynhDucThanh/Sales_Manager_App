import '../../../core/base/base_viewmodel.dart';
import '../../../core/models/product.dart';
import '../../../core/repositories/firestore_product_repository.dart';
import '../../../core/utils/currency_input_formatter.dart';
import '../logic/edit_product_logic.dart';

/// EditProductViewModel - ViewModel cho chỉnh sửa sản phẩm
class EditProductViewModel extends BaseViewModel {
  final EditProductLogic _logic = EditProductLogic(FirestoreProductRepository());

  final Product product;
  String _name = '';
  String _price = '';
  String _stock = '';
  String? _imageUrl;

  EditProductViewModel(this.product) {
    _name = product.name;
    _price = product.price.toStringAsFixed(0);
    _stock = product.stock.toString();
    _imageUrl = product.imageUrl;
  }

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

  /// Cập nhật sản phẩm
  Future<bool> updateProduct() async {
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

      await _logic.updateProduct(
        id: product.id,
        name: _name,
        price: priceValue,
        stock: stockValue,
        imageUrl: _imageUrl,
        createdAt: product.createdAt,
      );

      return true;
    } catch (e) {
      setError('Không thể cập nhật sản phẩm: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }
}

