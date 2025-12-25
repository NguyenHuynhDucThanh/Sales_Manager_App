import '../../../core/base/base_viewmodel.dart';
import '../../../core/models/product.dart';
import '../../../core/repositories/product_repository.dart';
import '../../../core/repositories/firestore_product_repository.dart';
import '../logic/product_list_logic.dart';

/// ProductListViewModel - ViewModel cho danh sách sản phẩm
class ProductListViewModel extends BaseViewModel {
  final ProductRepository _repository = FirestoreProductRepository();
  final ProductListLogic _logic = ProductListLogic(FirestoreProductRepository());

  List<Product> _products = [];
  String _searchQuery = '';

  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products;
  String get searchQuery => _searchQuery;

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _logic.searchProducts(_products, _searchQuery);
  }

  /// Load danh sách sản phẩm
  Future<void> loadProducts() async {
    try {
      setLoading(true);
      clearError();
      _products = await _logic.getAllProducts();
      notifyListeners();
    } catch (e) {
      setError('Không thể tải danh sách sản phẩm: ${e.toString()}');
      _products = [];
    } finally {
      setLoading(false);
    }
  }

  /// Thêm sản phẩm mới
  Future<bool> addProduct(Product product) async {
    try {
      setLoading(true);
      clearError();
      await _repository.addProduct(product);
      await loadProducts(); // Reload danh sách
      return true;
    } catch (e) {
      setError('Không thể thêm sản phẩm: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Cập nhật sản phẩm
  Future<bool> updateProduct(Product product) async {
    try {
      setLoading(true);
      clearError();
      await _repository.updateProduct(product);
      await loadProducts(); // Reload danh sách
      return true;
    } catch (e) {
      setError('Không thể cập nhật sản phẩm: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Xóa sản phẩm
  Future<bool> deleteProduct(String id) async {
    try {
      setLoading(true);
      clearError();
      await _logic.deleteProduct(id);
      await loadProducts(); // Reload danh sách
      return true;
    } catch (e) {
      setError('Không thể xóa sản phẩm: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Tìm kiếm sản phẩm
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  /// Clear search
  void clearSearch() {
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      notifyListeners();
    }
  }
}

