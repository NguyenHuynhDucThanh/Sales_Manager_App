import '../../../core/models/product.dart';
import '../../../core/repositories/product_repository.dart';

/// EditProductLogic - Business logic cho cập nhật sản phẩm
class EditProductLogic {
  final ProductRepository repository;

  EditProductLogic(this.repository);

  /// Validate product data
  String? validateProduct({
    required String name,
    required String price,
    required String stock,
  }) {
    if (name.trim().isEmpty) return 'Tên sản phẩm không được rỗng';
    
    final priceValue = double.tryParse(price);
    if (priceValue == null || priceValue <= 0) {
      return 'Giá phải là số dương';
    }

    final stockValue = int.tryParse(stock);
    if (stockValue == null || stockValue < 0) {
      return 'Số lượng phải là số không âm';
    }

    return null; // Valid
  }

  /// Cập nhật sản phẩm
  Future<void> updateProduct({
    required String id,
    required String name,
    required double price,
    required int stock,
    String? imageUrl,
    DateTime? createdAt,
  }) async {
    final product = Product(
      id: id,
      name: name.trim(),
      price: price,
      stock: stock,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );

    await repository.updateProduct(product);
  }
}
