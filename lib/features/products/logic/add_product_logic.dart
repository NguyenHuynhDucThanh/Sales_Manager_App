import 'package:uuid/uuid.dart';
import '../../../core/models/product.dart';
import '../../../core/repositories/product_repository.dart';

/// AddProductLogic - Business logic cho thêm sản phẩm mới
class AddProductLogic {
  final ProductRepository repository;

  AddProductLogic(this.repository);

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

  /// Tạo và lưu sản phẩm mới
  Future<void> addProduct({
    required String name,
    required double price,
    required int stock,
    String? imageUrl,
  }) async {
    final product = Product(
      id: const Uuid().v4(),
      name: name.trim(),
      price: price,
      stock: stock,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await repository.addProduct(product);
  }
}
