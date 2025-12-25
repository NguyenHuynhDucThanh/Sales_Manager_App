import '../../../core/models/product.dart';
import '../../../core/repositories/product_repository.dart';

/// ProductListLogic - Business logic cho quản lý danh sách sản phẩm
class ProductListLogic {
  final ProductRepository repository;

  ProductListLogic(this.repository);

  /// Lấy tất cả sản phẩm
  Future<List<Product>> getAllProducts() async {
    return await repository.getProducts();
  }

  /// Xóa sản phẩm
  Future<void> deleteProduct(String id) async {
    await repository.deleteProduct(id);
  }

  /// Tìm kiếm sản phẩm theo tên
  List<Product> searchProducts(List<Product> products, String query) {
    if (query.isEmpty) return products;
    return products.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
  }
}
