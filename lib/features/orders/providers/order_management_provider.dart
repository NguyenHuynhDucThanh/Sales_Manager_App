import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/order_model.dart';
import '../../../core/repositories/order_repository.dart';

// StreamProvider cho pending orders (REAL-TIME)
final pendingOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final repo = ref.read(orderRepositoryProvider);
  return repo.getOrdersByStatusStream('pending');
});

// StreamProvider cho confirmed orders (REAL-TIME)
final confirmedOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final repo = ref.read(orderRepositoryProvider);
  return repo.getOrdersByStatusStream('confirmed');
});

// StreamProvider cho cancelled orders (REAL-TIME)
final cancelledOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final repo = ref.read(orderRepositoryProvider);
  return repo.getOrdersByStatusStream('cancelled');
});
