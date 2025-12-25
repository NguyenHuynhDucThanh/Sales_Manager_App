import '../../../core/models/order_model.dart';
import '../../../core/repositories/order_repository.dart';

/// OrderManagementLogic - Business logic cho admin quản lý đơn hàng
class OrderManagementLogic {
  final OrderRepository repository;

  OrderManagementLogic(this.repository);

  /// Xác nhận đơn hàng (pending → confirmed)
  /// Sẽ trừ kho tự động
  Future<void> confirmOrder(String orderId) async {
    await repository.updateOrderStatus(orderId, 'confirmed');
  }

  /// Hủy đơn hàng (pending → cancelled)
  /// Requires cancellation reason
  Future<void> cancelOrder(String orderId, String reason) async {
    if (reason.trim().isEmpty) {
      throw Exception('Vui lòng nhập lý do hủy đơn');
    }
    await repository.updateOrderStatus(
      orderId, 
      'cancelled', 
      cancellationReason: reason,
    );
  }

  /// Lấy đơn hàng pending
  Future<List<OrderModel>> getPendingOrders() async {
    return await repository.getOrdersByStatus('pending');
  }

  /// Lấy đơn hàng confirmed  
  Future<List<OrderModel>> getConfirmedOrders() async {
    return await repository.getOrdersByStatus('confirmed');
  }

  /// Lấy đơn hàng cancelled
  Future<List<OrderModel>> getCancelledOrders() async {
    return await repository.getOrdersByStatus('cancelled');
  }
}
