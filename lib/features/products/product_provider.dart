import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/product.dart';
import '../../core/repositories/product_repository.dart';
// QUAN TRỌNG: Phải có dòng này mới tìm thấy file repository mới
import '../../core/repositories/firestore_product_repository.dart'; 

// 1. Provider cung cấp Repository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  // return MockProductRepository(); // <-- Cái cũ
  return FirestoreProductRepository(); // <-- Cái mới
});

// 2. Provider quản lý Danh sách sản phẩm
final productListProvider = AsyncNotifierProvider<ProductListNotifier, List<Product>>(() {
  return ProductListNotifier();
});

class ProductListNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    return _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    final repo = ref.read(productRepositoryProvider);
    return await repo.getProducts();
  }

  Future<void> addProduct(Product p) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(productRepositoryProvider);
      await repo.addProduct(p);
      return _fetchProducts();
    });
  }

    // 👇 Thêm hàm này
  Future<void> updateProduct(Product p) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(productRepositoryProvider);
      await repo.updateProduct(p); // Gọi hàm update bên repo
      return _fetchProducts(); // Tải lại danh sách mới
    });
  }
  
  Future<void> deleteProduct(String id) async {
     state = const AsyncValue.loading();
     state = await AsyncValue.guard(() async {
       final repo = ref.read(productRepositoryProvider);
       await repo.deleteProduct(id);
       return _fetchProducts();
     });
  }
}