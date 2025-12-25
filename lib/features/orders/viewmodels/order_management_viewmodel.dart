import 'dart:async';
import '../../../core/base/base_viewmodel.dart';
import '../../../core/models/order_model.dart';
import '../../../core/repositories/order_repository.dart';
import '../logic/order_management_logic.dart';

/// OrderManagementViewModel - ViewModel cho admin quản lý đơn hàng
class OrderManagementViewModel extends BaseViewModel {
  late final OrderRepository _repository;
  late final OrderManagementLogic _logic;

  OrderManagementViewModel() {
    _repository = OrderRepository();
    _logic = OrderManagementLogic(_repository);
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

  /// Load orders
  Future<void> loadOrders() async {
    try {
      setLoading(true);
      clearError();
      
      _pendingOrders = await _logic.getPendingOrders();
      _confirmedOrders = await _logic.getConfirmedOrders();
      _cancelledOrders = await _logic.getCancelledOrders();

      notifyListeners();
    } catch (e) {
      setError('Không thể tải đơn hàng: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Listen to real-time updates
  void listenToOrders() {
    // Cancel existing subscriptions
    _pendingSubscription?.cancel();
    _confirmedSubscription?.cancel();
    _cancelledSubscription?.cancel();

    // Listen to streams
    _pendingSubscription = _repository.getOrdersByStatusStream('pending').listen((orders) {
      _pendingOrders = orders;
      notifyListeners();
    });

    _confirmedSubscription = _repository.getOrdersByStatusStream('confirmed').listen((orders) {
      _confirmedOrders = orders;
      notifyListeners();
    });

    _cancelledSubscription = _repository.getOrdersByStatusStream('cancelled').listen((orders) {
      _cancelledOrders = orders;
      notifyListeners();
    });
  }

  /// Xác nhận đơn hàng
  Future<bool> confirmOrder(String orderId) async {
    try {
      setLoading(true);
      clearError();
      await _logic.confirmOrder(orderId);
      return true;
    } catch (e) {
      setError('Không thể xác nhận đơn hàng: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Hủy đơn hàng
  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      setLoading(true);
      clearError();
      await _logic.cancelOrder(orderId, reason);
      return true;
    } catch (e) {
      setError('Không thể hủy đơn hàng: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    _pendingSubscription?.cancel();
    _confirmedSubscription?.cancel();
    _cancelledSubscription?.cancel();
    super.dispose();
  }
}

