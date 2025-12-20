import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/product.dart';
import '../../core/repositories/product_repository.dart';
import '../../core/repositories/firestore_product_repository.dart';

// 1. Provider cung cấp Repository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return FirestoreProductRepository();
});

// 2. Provider quản lý Danh sách sản phẩm (Gốc)
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
  
  Future<void> updateProduct(Product p) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(productRepositoryProvider);
      await repo.updateProduct(p);
      return _fetchProducts();
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

// 3. Provider lưu từ khóa tìm kiếm (Dùng Notifier thay cho StateProvider)
final productSearchQueryProvider = NotifierProvider<ProductSearchQueryNotifier, String>(() {
  return ProductSearchQueryNotifier();
});

class ProductSearchQueryNotifier extends Notifier<String> {
  @override
  String build() {
    return ''; // Giá trị mặc định là rỗng
  }

  // Hàm để cập nhật từ khóa
  void setSearch(String query) {
    state = query;
  }
}

// 4. Provider trả về danh sách ĐÃ LỌC (Filtered List)
// (Đoạn này giữ nguyên, không cần sửa gì cả)
final filteredProductListProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productState = ref.watch(productListProvider); // Lấy list gốc
  
  // Lưu ý: ref.watch(productSearchQueryProvider) vẫn trả về String như cũ
  final query = ref.watch(productSearchQueryProvider).toLowerCase(); 

  return productState.whenData((products) {
    if (query.isEmpty) {
      return products; 
    }
    return products.where((p) => p.name.toLowerCase().contains(query)).toList();
  });
});