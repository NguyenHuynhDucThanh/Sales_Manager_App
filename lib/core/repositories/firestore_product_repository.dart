import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'product_repository.dart';

class FirestoreProductRepository implements ProductRepository {
  // CÁCH CŨ: final _firestore = FirebaseFirestore.instance; (Dễ gây lỗi nếu Firebase chưa load xong)
  
  // CÁCH MỚI: Dùng getter hoặc gọi trực tiếp bên trong hàm
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  Future<List<Product>> getProducts() async {
    try {
      // Gọi _firestore ở đây thì an toàn hơn vì lúc này chắc chắn App đã chạy xong main()
      final snapshot = await _firestore.collection('products').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Gán ID của document vào object để sau này còn xóa được
        // Lưu ý: data trả về từ Firestore là Map<String, dynamic>, không có sẵn field 'id' nếu bạn không lưu
        // Cách xử lý chuẩn: Clone data ra map mới rồi nhét id vào
        final productData = Map<String, dynamic>.from(data);
        productData['id'] = doc.id; 
        
        return Product.fromJson(productData);
      }).toList();
    } catch (e) {
      print("Lỗi lấy danh sách: $e");
      return [];
    }
  }

  @override
  Future<void> addProduct(Product product) async {
    // Dùng _firestore ở đây
    await _firestore.collection('products').doc(product.id).set(product.toJson());
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

   @override
  Future<void> updateProduct(Product product) async {
    try {
      // update: Chỉ cập nhật các trường thay đổi, giữ nguyên các trường khác
      await _firestore.collection('products').doc(product.id).update(product.toJson());
      print("Đã cập nhật sản phẩm: ${product.name}");
    } catch (e) {
      print("Lỗi cập nhật sản phẩm: $e");
      rethrow;
    }
  } // Kết thúc class
}