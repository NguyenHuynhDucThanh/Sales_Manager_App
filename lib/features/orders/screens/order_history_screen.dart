import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../widgets/widgets.dart';
import '../../../core/models/order_model.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../viewmodels/order_history_viewmodel.dart';
import 'order_detail_screen.dart';

/// OrderHistoryScreen - Lịch sử đơn hàng (User + Admin)
/// Hiển thị 3 tabs: Chờ xác nhận, Đã xác nhận & Đã hủy
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load orders when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      final orderViewModel = context.read<OrderHistoryViewModel>();
      
      if (authViewModel.currentUserData != null) {
        final userId = authViewModel.currentUserData!.id;
        orderViewModel.loadOrders(userId);
        orderViewModel.listenToOrders(userId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, OrderHistoryViewModel>(
      builder: (context, authViewModel, orderViewModel, child) {
        final currentUserId = authViewModel.currentUserData?.id;

        if (currentUserId == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Đơn hàng của tôi')),
            body: const Center(child: Text('Vui lòng đăng nhập')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Đơn hàng của tôi'),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: [
                const Tab(icon: Icon(Icons.pending_actions), text: 'Chờ xác nhận'),
                const Tab(icon: Icon(Icons.check_circle), text: 'Đã xác nhận'),
                const Tab(icon: Icon(Icons.cancel), text: 'Đã hủy'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(orderViewModel.pendingOrders, 'pending'),
              _buildOrderList(orderViewModel.confirmedOrders, 'confirmed'),
              _buildOrderList(orderViewModel.cancelledOrders, 'cancelled'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, String status) {
    return Consumer<OrderHistoryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && orders.isEmpty) {
          return const LoadingState();
        }

        if (viewModel.hasError && orders.isEmpty) {
          return ErrorState(
            message: viewModel.errorMessage ?? 'Đã xảy ra lỗi',
            onRetry: () {
              final authViewModel = context.read<AuthViewModel>();
              if (authViewModel.currentUserData != null) {
                viewModel.loadOrders(authViewModel.currentUserData!.id);
              }
            },
          );
        }

        if (orders.isEmpty) {
          IconData emptyIcon;
          String emptyMessage;
          
          switch (status) {
            case 'pending':
              emptyIcon = Icons.pending_actions_outlined;
              emptyMessage = 'Chưa có đơn nào đang chờ xác nhận';
              break;
            case 'confirmed':
              emptyIcon = Icons.check_circle_outline;
              emptyMessage = 'Chưa có đơn nào được xác nhận';
              break;
            case 'cancelled':
              emptyIcon = Icons.cancel_outlined;
              emptyMessage = 'Chưa có đơn nào bị hủy';
              break;
            default:
              emptyIcon = Icons.inbox;
              emptyMessage = 'Không có đơn hàng';
          }
          
          return EmptyState(
            icon: emptyIcon,
            message: emptyMessage,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final authViewModel = context.read<AuthViewModel>();
            if (authViewModel.currentUserData != null) {
              await viewModel.loadOrders(authViewModel.currentUserData!.id);
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order, status);
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(OrderModel order, String status) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending_actions;
        statusText = 'Chờ xác nhận';
        break;
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Đã xác nhận';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Đã hủy';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Không xác định';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order ID + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đơn #${order.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Date
              Text(
                dateFormat.format(order.createdAt),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),

              // Shipping address
              if (order.shippingAddress != null) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.shippingAddress!,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const Divider(height: 20),

              // Total + Item count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.itemsCount} món',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  Text(
                    currencyFormat.format(order.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              // Cancellation reason for cancelled orders
              if (status == 'cancelled' && order.cancellationReason != null) ...[
                const SizedBox(height: 12),
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
                      Icon(Icons.info, size: 16, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Lý do hủy: ${order.cancellationReason}',
                          style: TextStyle(fontSize: 13, color: Colors.red.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
