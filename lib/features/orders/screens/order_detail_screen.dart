import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/order_model.dart';
import '../providers/order_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(orderItemsProvider(order.id));
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết đơn hàng")),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                _buildInfoRow("Mã đơn:", "#${order.id}"),
                _buildInfoRow("Ngày tạo:", dateFormat.format(order.createdAt)),
                
                // Status badge
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildStatusBadge(order.status),
                ),
                
                // Shipping address
                if (order.shippingAddress != null) ...[
                  const Divider(),
                  _buildMultiLineInfo("Địa chỉ giao hàng:", order.shippingAddress!),
                ],
                
                // Note
                if (order.note != null) ...[
                  _buildMultiLineInfo("Ghi chú:", order.note!),
                ],
                
                // Cancellation reason
                if (order.status == 'cancelled' && order.cancellationReason != null) ...[
                  const Divider(),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info, size: 18, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lý do hủy:',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                order.cancellationReason!,
                                style: TextStyle(color: Colors.red.shade800),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
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
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value, 
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 16 : 14,
                color: color ?? Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    IconData icon;
    String text;

    switch (status) {
      case 'pending':
        badgeColor = Colors.orange;
        icon = Icons.pending_actions;
        text = 'Chờ xác nhận';
        break;
      case 'confirmed':
        badgeColor = Colors.green;
        icon = Icons.check_circle;
        text = 'Đã xác nhận';
        break;
      case 'cancelled':
        badgeColor = Colors.red;
        icon = Icons.cancel;
        text = 'Đã hủy';
        break;
      default:
        badgeColor = Colors.grey;
        icon = Icons.help;
        text = 'Không xác định';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiLineInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
