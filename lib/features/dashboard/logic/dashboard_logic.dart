import '../../../core/models/user_model.dart';

/// DashboardLogic - Business logic cho Dashboard
class DashboardLogic {
  /// Kiểm tra user có phải admin không
  bool isAdmin(UserModel? user) {
    return user?.role == 'admin';
  }

  /// Format greeting message
  String getGreeting(UserModel? user) {
    if (user == null) return 'Xin chào!';
    return isAdmin(user) ? 'Xin chào, Admin!' : 'Xin chào, Quý khách!';
  }

  /// Get subtitle message
  String getSubtitle(UserModel? user) {
    return isAdmin(user) ? 'Quản lý cửa hàng của bạn.' : 'Chúc bạn mua sắm vui vẻ.';
  }
}
