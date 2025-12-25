import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/product.dart';
import '../../../core/repositories/product_repository.dart';
import '../../../core/repositories/firestore_product_repository.dart';
import '../logic/product_list_logic.dart';

// Provider cung cấp Repository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return FirestoreProductRepository();
});

// Provider quản lý Danh sách sản phẩm
final productListProvider = AsyncNotifierProvider<ProductListNotifier, List<Product>>(() {
  return ProductListNotifier();
});

class ProductListNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final repo = ref.read(productRepositoryProvider);
    final logic = ProductListLogic(repo);
    return await logic.getAllProducts();
  }

  Future<void> addProduct(Product p) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(productRepositoryProvider);
      await repo.addProduct(p);
      final logic = ProductListLogic(repo);
      return await logic.getAllProducts();
    });
  }
  
  Future<void> updateProduct(Product p) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(productRepositoryProvider);
      await repo.updateProduct(p);
      final logic = ProductListLogic(repo);
      return await logic.getAllProducts();
    });
  }

  Future<void> deleteProduct(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(productRepositoryProvider);
      final logic = ProductListLogic(repo);
      await logic.deleteProduct(id);
      return await logic.getAllProducts();
    });
  }
}

// Provider lưu từ khóa tìm kiếm
final productSearchQueryProvider = NotifierProvider<ProductSearchQueryNotifier, String>(() {
  return ProductSearchQueryNotifier();
});

class ProductSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setSearch(String query) {
    state = query;
  }
}

// Provider trả về danh sách ĐÃ LỌC
final filteredProductListProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productState = ref.watch(productListProvider);
  final query = ref.watch(productSearchQueryProvider);
  final repo = ref.read(productRepositoryProvider);
  final logic = ProductListLogic(repo);

  return productState.whenData((products) {
    return logic.searchProducts(products, query);
  });
});
