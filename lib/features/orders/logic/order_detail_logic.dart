import '../../../core/repositories/order_repository.dart';

/// OrderDetailLogic - Business logic cho chi tiết đơn hàng
class OrderDetailLogic {
  final OrderRepository repository;

  OrderDetailLogic(this.repository);

  /// Lấy chi tiết items trong đơn hàng
  Future<List<Map<String, dynamic>>> getOrderItems(String orderId) async {
    return await repository.getOrderItems(orderId);
  }
}
