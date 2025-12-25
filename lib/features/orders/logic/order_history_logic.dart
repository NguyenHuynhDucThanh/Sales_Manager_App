import '../../../core/models/order_model.dart';
import '../../../core/repositories/order_repository.dart';

/// OrderHistoryLogic - Business logic cho lịch sử đơn hàng (USER ONLY)
/// Admin uses OrderManagementLogic instead
class OrderHistoryLogic {
  final OrderRepository repository;

  OrderHistoryLogic(this.repository);

  /// Lấy danh sách đơn hàng của user
  Future<List<OrderModel>> getOrders(String userId) async {
    return await repository.getOrders(userId: userId);
  }

  /// Lấy danh sách đơn hàng của user theo ngày
  Future<List<OrderModel>> getOrdersByDate(DateTime date, String userId) async {
    final allOrdersOnDate = await repository.getOrdersByDate(date);
    return allOrdersOnDate.where((order) => order.userId == userId).toList();
  }
}
