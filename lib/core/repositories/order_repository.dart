import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';
import '../models/order_model.dart';

class OrderRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // 1. Tạo đơn hàng (Checkout)
  Future<void> createOrder(
    List<CartItem> cartItems, 
    double totalAmount,
    {required String shippingAddress, String? note}
  ) async {
    final orderId = const Uuid().v4();
    final now = DateTime.now();
    final userId = _auth.currentUser?.uid;

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
        userId: userId,
        status: 'pending',                  // Mặc định: pending
        shippingAddress: shippingAddress,
        note: note,
      );
      transaction.set(orderRef, newOrder.toJson());

      // C. Lưu chi tiết (KHÔNG trừ kho - chờ admin confirm)
      for (var item in cartItems) {
        final itemRef = orderRef.collection('order_items').doc();
        transaction.set(itemRef, {
          'productId': item.product.id,
          'name': item.product.name,
          'price': item.product.price,
          'quantity': item.quantity,
          'subtotal': item.total,
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

  // 2b. Lấy TẤT CẢ đơn hàng (cho báo cáo tổng)
  Future<List<OrderModel>> getAllOrders() async {
    return getOrders(); // Gọi getOrders không có userId = lấy tất cả
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

  // 5. Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(
    String orderId, 
    String status, 
    {String? cancellationReason}
  ) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (cancellationReason != null) {
        updateData['cancellationReason'] = cancellationReason;
      }

      // Nếu confirm đơn, trừ kho sản phẩm TRONG CÙNG TRANSACTION
      if (status == 'confirmed') {
        final orderItems = await getOrderItems(orderId);
        
        await _firestore.runTransaction((transaction) async {
          // 1. Trừ stock cho từng sản phẩm
          for (var item in orderItems) {
            final productId = item['productId'] as String;
            final quantity = item['quantity'] as int;
            final productRef = _firestore.collection('products').doc(productId);
            
            // Kiểm tra stock trước khi trừ
            final productSnap = await transaction.get(productRef);
            if (!productSnap.exists) {
              throw Exception('Sản phẩm $productId không tồn tại');
            }
            
            final currentStock = productSnap.get('stock') as int;
            if (currentStock < quantity) {
              final productName = productSnap.get('name') as String;
              throw Exception('Sản phẩm "$productName" không đủ hàng (còn $currentStock)');
            }
            
            transaction.update(productRef, {
              'stock': FieldValue.increment(-quantity),
            });
          }
          
          // 2. Update order status trong cùng transaction
          final orderRef = _firestore.collection('orders').doc(orderId);
          transaction.update(orderRef, updateData);
        });
        
        print("✅ Đã xác nhận đơn $orderId và trừ kho thành công");
      } else {
        // Nếu chỉ update status (cancel, etc), không cần transaction
        await _firestore.collection('orders').doc(orderId).update(updateData);
        print("✅ Đã cập nhật trạng thái đơn $orderId → $status");
      }
    } catch (e) {
      print("❌ Lỗi cập nhật trạng thái: $e");
      rethrow;
    }
  }

  // 6. Lấy đơn hàng theo trạng thái (Future - one-time fetch)
  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        if (data['updatedAt'] is Timestamp) {
          data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
        }
        return OrderModel.fromJson(data);
      }).toList();
    } catch (e) {
      print("❌ Lỗi lấy đơn theo status: $e");
      return [];
    }
  }

  // 7. Lấy đơn hàng theo trạng thái (Stream - real-time)
  Stream<List<OrderModel>> getOrdersByStatusStream(String status) {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        if (data['updatedAt'] is Timestamp) {
          data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
        }
        return OrderModel.fromJson(data);
      }).toList();
    }).handleError((error) {
      print("❌ Lỗi stream orders theo status: $error");
      return <OrderModel>[];
    });
  }
}

final orderRepositoryProvider = Provider((ref) => OrderRepository());