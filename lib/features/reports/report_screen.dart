import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/repositories/order_repository.dart';
import '../../core/models/order_model.dart';

// Provider lấy báo cáo hôm nay
final todayReportProvider = FutureProvider<List<OrderModel>>((ref) async {
  final repo = ref.read(orderRepositoryProvider);
  return await repo.getOrdersByDate(DateTime.now());
});

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(todayReportProvider);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(title: const Text("Báo cáo Doanh thu")),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Lỗi: $err")),
        data: (orders) {
          // Tính toán số liệu
          double totalRevenue = 0;
          for (var order in orders) {
            totalRevenue += order.total;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "KẾT QUẢ HÔM NAY",
                  style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                // Thẻ Doanh thu
                _buildStatCard(
                  title: "Doanh thu",
                  value: currencyFormat.format(totalRevenue),
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                
                // Thẻ Số đơn
                _buildStatCard(
                  title: "Số đơn hàng",
                  value: "${orders.length} đơn",
                  icon: Icons.receipt,
                  color: Colors.blue,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey.withOpacity(0.2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            ],
          )
        ],
      ),
    );
  }
}