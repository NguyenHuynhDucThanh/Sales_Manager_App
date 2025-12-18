import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';
import '../models/order_model.dart';

class OrderRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // 1. Tạo đơn hàng
  Future<void> createOrder(List<CartItem> cartItems, double totalAmount) async {
    final orderId = const Uuid().v4();
    final now = DateTime.now();
    final userId = _auth.currentUser?.uid; // Lấy ID user hiện tại

    await _firestore.runTransaction((transaction) async {
      // A. Kiểm tra tồn kho
      for (var item in cartItems) {
        final productRef = _firestore.collection('products').doc(item.product.id);
        final snapshot = await transaction.get(productRef);

        if (!snapshot.exists) throw Exception("Sản phẩm '${item.product.name}' không tồn tại!");
        
        final currentStock = snapshot.get('stock') as int;
        if (currentStock < item.quantity) {
          throw Exception("Sản phẩm '${item.product.name}' không đủ hàng! (Kho: $currentStock)");
        }
      }

      // B. Tạo đơn hàng chính
      final orderRef = _firestore.collection('orders').doc(orderId);
      final newOrder = OrderModel(
        id: orderId,
        total: totalAmount,
        createdAt: now,
        itemsCount: cartItems.length,
        paymentMethod: 'cash',
        userId: userId, // Lưu userId
      );
      transaction.set(orderRef, newOrder.toJson());

      // C. Lưu chi tiết và Trừ kho
      for (var item in cartItems) {
        final itemRef = orderRef.collection('order_items').doc();
        transaction.set(itemRef, {
          'productId': item.product.id,
          'name': item.product.name,
          'price': item.product.price,
          'quantity': item.quantity,
          'subtotal': item.total,
        });

        final productRef = _firestore.collection('products').doc(item.product.id);
        transaction.update(productRef, {
          'stock': FieldValue.increment(-item.quantity),
        });
      }
    });
  }

  // 2. Lấy danh sách đơn hàng
  Future<List<OrderModel>> getOrders({String? userId}) async {
    try {
      print("🔍 Đang lấy danh sách đơn hàng...");
      Query query = _firestore.collection('orders');

      // Nếu có userId -> Lọc theo user đó
      if (userId != null) {
        print("👤 Lọc theo UserID: $userId");
        query = query.where('userId', isEqualTo: userId);
      } else {
        print("👑 Admin: Lấy tất cả đơn");
      }

      // Sắp xếp ngày tạo mới nhất
      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      print("✅ Tìm thấy ${snapshot.docs.length} đơn hàng trên Firestore.");

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Fix lỗi Timestamp nếu có
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        
        return OrderModel.fromJson(data);
      }).toList();
    } catch (e) {
      print("❌ LỖI LẤY DANH SÁCH ĐƠN: $e");
      
      // Kiểm tra lỗi thiếu Index
      if (e.toString().contains('failed-precondition')) {
         print("🔗 BẤM VÀO LINK NÀY ĐỂ TẠO INDEX: ");
         // Nó sẽ in cái link dài ra console, bạn phải copy link đó dán vào trình duyệt
      }
      return [];
    }
  }

  // 3. Lấy chi tiết đơn
  Future<List<Map<String, dynamic>>> getOrderItems(String orderId) async {
    try {
      final snapshot = await _firestore.collection('orders').doc(orderId).collection('order_items').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  // 4. Lấy theo ngày (cho Báo cáo)
  Future<List<OrderModel>> getOrdersByDate(DateTime date) async {
     try {
       final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
       final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
       
       final snapshot = await _firestore.collection('orders')
           .where('createdAt', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
           .where('createdAt', isLessThanOrEqualTo: endOfDay.toIso8601String())
           .get();

       return snapshot.docs.map((doc) {
          final data = doc.data();
          if (data['createdAt'] is Timestamp) {
            data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
          }
          return OrderModel.fromJson(data);
       }).toList();
     } catch (e) {
       print("Lỗi báo cáo: $e");
       return [];
     }
  }
}

final orderRepositoryProvider = Provider((ref) => OrderRepository());