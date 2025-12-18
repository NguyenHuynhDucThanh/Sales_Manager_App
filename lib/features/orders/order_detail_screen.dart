import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/models/order_model.dart';
import 'order_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gọi Provider lấy items chi tiết
    final itemsAsync = ref.watch(orderItemsProvider(order.id));
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết đơn hàng")),
      body: Column(
        children: [
          // 1. Thông tin chung
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                _buildInfoRow("Mã đơn:", "#${order.id}"),
                _buildInfoRow("Ngày tạo:", dateFormat.format(order.createdAt)),
                const Divider(),
                _buildInfoRow("Tổng tiền:", currencyFormat.format(order.total), isBold: true, color: Colors.red),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft, 
              child: Text("Danh sách sản phẩm:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),

          // 2. Danh sách sản phẩm
          Expanded(
            child: itemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Lỗi: $err")),
              data: (items) {
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: const Icon(Icons.local_offer, size: 20),
                      title: Text(item['name'] ?? 'Sản phẩm lỗi'),
                      subtitle: Text("SL: ${item['quantity']} x ${currencyFormat.format(item['price'])}"),
                      trailing: Text(
                        currencyFormat.format(item['subtotal']),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value, 
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}