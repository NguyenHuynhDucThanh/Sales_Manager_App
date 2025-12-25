import 'dart:async';
import '../../../core/base/base_viewmodel.dart';
import '../../../core/models/order_model.dart';
import '../../../core/repositories/order_repository.dart';
import '../logic/order_history_logic.dart';

/// OrderHistoryViewModel - ViewModel cho lịch sử đơn hàng (USER)
class OrderHistoryViewModel extends BaseViewModel {
  late final OrderRepository _repository;
  late final OrderHistoryLogic _logic;

  OrderHistoryViewModel() {
    _repository = OrderRepository();
    _logic = OrderHistoryLogic(_repository);
  }

  List<OrderModel> _pendingOrders = [];
  List<OrderModel> _confirmedOrders = [];
  List<OrderModel> _cancelledOrders = [];
  
  StreamSubscription<List<OrderModel>>? _pendingSubscription;
  StreamSubscription<List<OrderModel>>? _confirmedSubscription;
  StreamSubscription<List<OrderModel>>? _cancelledSubscription;

  List<OrderModel> get pendingOrders => _pendingOrders;
  List<OrderModel> get confirmedOrders => _confirmedOrders;
  List<OrderModel> get cancelledOrders => _cancelledOrders;

  /// Load orders for user
  Future<void> loadOrders(String userId) async {
    try {
      setLoading(true);
      clearError();
      
      // Load all orders for user
      final allOrders = await _logic.getOrders(userId);

      // Filter by status
      _pendingOrders = allOrders.where((o) => o.status == 'pending').toList();
      _confirmedOrders = allOrders.where((o) => o.status == 'confirmed').toList();
      _cancelledOrders = allOrders.where((o) => o.status == 'cancelled').toList();

      notifyListeners();
    } catch (e) {
      setError('Không thể tải đơn hàng: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Listen to real-time updates
  void listenToOrders(String userId) {
    // Cancel existing subscriptions
    _pendingSubscription?.cancel();
    _confirmedSubscription?.cancel();
    _cancelledSubscription?.cancel();

    // Listen to streams
    _pendingSubscription = _repository.getOrdersByStatusStream('pending').listen((allOrders) {
      _pendingOrders = allOrders.where((o) => o.userId == userId).toList();
      notifyListeners();
    });

    _confirmedSubscription = _repository.getOrdersByStatusStream('confirmed').listen((allOrders) {
      _confirmedOrders = allOrders.where((o) => o.userId == userId).toList();
      notifyListeners();
    });

    _cancelledSubscription = _repository.getOrdersByStatusStream('cancelled').listen((allOrders) {
      _cancelledOrders = allOrders.where((o) => o.userId == userId).toList();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _pendingSubscription?.cancel();
    _confirmedSubscription?.cancel();
    _cancelledSubscription?.cancel();
    super.dispose();
  }
}

