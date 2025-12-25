import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/order_model.dart';
import '../../../core/repositories/order_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../logic/order_history_logic.dart';

// Provider lấy tất cả đơn hàng (USER ONLY - filters by userId)
final orderListProvider = FutureProvider<List<OrderModel>>((ref) async {
  final repo = ref.read(orderRepositoryProvider);
  final logic = OrderHistoryLogic(repo);
  
  // Get current user
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) return [];
  
  final authRepo = ref.read(authRepositoryProvider);
  final userModel = await authRepo.getUserData(user.uid);
  if (userModel == null) return [];
  
  return await logic.getOrders(userModel.id);
});

// Family provider - lấy đơn hàng theo ngày (USER ONLY)
final ordersByDateProvider = FutureProvider.family<List<OrderModel>, DateTime>((ref, date) async {
  final repo = ref.read(orderRepositoryProvider);
  final logic = OrderHistoryLogic(repo);
  
  // Get current user
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) return [];
  
  final authRepo = ref.read(authRepositoryProvider);
  final userModel = await authRepo.getUserData(user.uid);
  if (userModel == null) return [];
  
  return await logic.getOrdersByDate(date, userModel.id);
});

// Provider lấy chi tiết đơn hàng
final orderItemsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, orderId) async {
  final repo = ref.read(orderRepositoryProvider);
  return await repo.getOrderItems(orderId);
});
