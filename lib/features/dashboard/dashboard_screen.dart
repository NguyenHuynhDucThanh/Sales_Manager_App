import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart'; // Import Provider lấy thông tin User
import '../sales/sales_screen.dart';
import '../products/product_list_screen.dart';
import '../orders/order_history_screen.dart';
import '../reports/report_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lắng nghe dữ liệu User từ Firestore (để biết role)
    final userDataAsync = ref.watch(currentUserDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop Online"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Đăng xuất",
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      // 2. Xử lý trạng thái tải dữ liệu User
      body: userDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Lỗi: $err")),
        data: (userModel) {
          // Nếu không lấy được info (ví dụ lỗi mạng hoặc chưa tạo user trong firestore)
          if (userModel == null) return const Center(child: Text("Không tải được thông tin người dùng"));

          // 3. Kiểm tra quyền Admin
          final bool isAdmin = userModel.role == 'admin';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner chào mừng (Đổi màu và chữ theo Role)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isAdmin ? Colors.blue : Colors.green, // Admin xanh dương, Khách xanh lá
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAdmin ? "Xin chào, Admin! 👨‍💼" : "Xin chào, Quý khách! 🛒",
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isAdmin ? "Quản lý cửa hàng của bạn." : "Chúc bạn mua sắm vui vẻ.",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Lưới chức năng (Hiển thị có điều kiện)
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      // Nút 1: Bán hàng / Mua hàng (Ai cũng thấy, nhưng tên khác nhau)
                      _buildMenuButton(
                        context,
                        isAdmin ? "Bán Hàng (POS)" : "Mua Hàng",
                        Icons.shopping_bag,
                        Colors.orange,
                        const SalesScreen(),
                      ),

                      // Nút 2: Lịch sử đơn hàng (Ai cũng thấy)
                      _buildMenuButton(
                        context,
                        "Lịch sử Đơn",
                        Icons.history,
                        Colors.blue,
                        const OrderHistoryScreen(),
                      ),

                      // Nút 3: Quản lý Sản phẩm (CHỈ ADMIN MỚI THẤY)
                      if (isAdmin)
                        _buildMenuButton(
                          context,
                          "Quản lý Sản phẩm",
                          Icons.inventory_2,
                          Colors.purple,
                          const ProductListScreen(),
                        ),

                      // Nút 4: Báo cáo (CHỈ ADMIN MỚI THẤY)
                      if (isAdmin)
                        _buildMenuButton(
                          context,
                          "Báo Cáo",
                          Icons.bar_chart,
                          Colors.green,
                          const ReportScreen(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Color color, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}