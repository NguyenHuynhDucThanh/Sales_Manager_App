import '../../../core/models/order_model.dart';
import '../../../core/repositories/order_repository.dart';

/// ReportLogic - Business logic cho báo cáo
class ReportLogic {
  final OrderRepository repository;

  ReportLogic(this.repository);

  /// Lấy báo cáo hôm nay
  Future<Map<String, dynamic>> getTodayReport() async {
    final orders = await repository.getOrdersByDate(DateTime.now());
    
    double totalRevenue = 0;
    for (var order in orders) {
      totalRevenue += order.total;
    }

    return {
      'totalRevenue': totalRevenue,
      'orderCount': orders.length,
      'orders': orders,
    };
  }

  /// Lấy báo cáo tất cả thời gian
  Future<Map<String, dynamic>> getAllTimeReport() async {
    final orders = await repository.getAllOrders();
    
    double totalRevenue = 0;
    for (var order in orders) {
      totalRevenue += order.total;
    }

    return {
      'totalRevenue': totalRevenue,
      'orderCount': orders.length,
      'orders': orders,
    };
  }

  /// Lấy báo cáo theo ngày cụ thể
  Future<Map<String, dynamic>> getReportByDate(DateTime date) async {
    final orders = await repository.getOrdersByDate(date);
    
    double totalRevenue = 0;
    for (var order in orders) {
      totalRevenue += order.total;
    }

    return {
      'totalRevenue': totalRevenue,
      'orderCount': orders.length,
      'orders': orders,
    };
  }

  /// Tính tổng doanh thu
  double calculateRevenue(List<OrderModel> orders) {
    return orders.fold(0, (sum, order) => sum + order.total);
  }
}
