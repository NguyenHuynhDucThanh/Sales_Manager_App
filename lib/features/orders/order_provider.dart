import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/order_model.dart';
import '../../core/repositories/order_repository.dart';
import '../auth/auth_provider.dart'; // 1. Import Auth để lấy thông tin User

// 2. Provider lấy danh sách đơn hàng (THÔNG MINH HƠN)
final orderListProvider = FutureProvider<List<OrderModel>>((ref) async {
  final repo = ref.read(orderRepositoryProvider);
  
  // Lấy thông tin User hiện tại từ Provider (đã làm ở bước phân quyền)
  // ref.watch để nếu user thay đổi info thì danh sách đơn cũng tự reload
  final userModelAsync = ref.watch(currentUserDataProvider);
  final userModel = userModelAsync.value;

  // Logic phân quyền:
  if (userModel != null && userModel.role == 'admin') {
    // Nếu là Admin -> Gọi hàm lấy tất cả (không truyền userId)
    return await repo.getOrders(); 
  } else {
    // Nếu là User thường (hoặc chưa load xong) -> Chỉ lấy đơn có userId của họ
    // userModel?.id: Nếu userModel null thì truyền null, repo sẽ trả về rỗng (an toàn)
    return await repo.getOrders(userId: userModel?.id);
  }
});

// 3. Provider lấy chi tiết đơn hàng (Giữ nguyên)
final orderItemsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, orderId) async {
  final repo = ref.read(orderRepositoryProvider);
  return await repo.getOrderItems(orderId);
});