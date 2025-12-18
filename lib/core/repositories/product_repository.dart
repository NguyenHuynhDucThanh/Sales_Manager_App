import '../models/product.dart';

// 1. Định nghĩa các hành động (Interface)
abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<void> addProduct(Product product);
  Future<void> deleteProduct(String id);
  // 👇 QUAN TRỌNG: Thêm dòng này để Provider gọi được hàm update
  Future<void> updateProduct(Product product); 
}

// 2. Phiên bản Dữ liệu giả (Mock)
class MockProductRepository implements ProductRepository {
  final List<Product> _mockProducts = [
    Product(id: '1', name: 'Cà phê đá', price: 25000, stock: 100, imageUrl: 'https://via.placeholder.com/150'),
    Product(id: '2', name: 'Trà sữa trân châu', price: 30000, stock: 50, imageUrl: 'https://via.placeholder.com/150'),
    Product(id: '3', name: 'Bánh mì', price: 15000, stock: 20, imageUrl: 'https://via.placeholder.com/150'),
  ];

  @override
  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(seconds: 1)); 
    return _mockProducts;
  }

  @override
  Future<void> addProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockProducts.add(product);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockProducts.removeWhere((p) => p.id == id);
  }

  // 👇 Phải thêm hàm này vào Mock để không bị lỗi thiếu Override
  @override
  Future<void> updateProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _mockProducts[index] = product;
    }
  }
}