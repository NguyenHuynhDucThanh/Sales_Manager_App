import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'order_provider.dart';
import 'order_detail_screen.dart'; // Ta sẽ tạo file này ở bước 4

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderListProvider);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử đơn hàng")),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text("Chưa có đơn hàng nào"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                elevation: 2,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long, color: Colors.blue),
                  ),
                  title: Text(
                    "Đơn #${order.id.substring(0, 5).toUpperCase()}", // Chỉ hiện 5 ký tự đầu mã đơn cho gọn
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(dateFormat.format(order.createdAt)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(order.total),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
                      ),
                      Text(
                        "${order.itemsCount} món",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Chuyển sang màn hình chi tiết
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(order: order),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}