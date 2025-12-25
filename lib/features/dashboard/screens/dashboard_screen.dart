import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../products/screens/product_catalog_screen.dart';
import '../../products/screens/product_list_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../orders/screens/order_history_screen.dart';
import '../../orders/screens/order_management_screen.dart';
import '../../reports/screens/report_screen.dart';
import '../../home/screens/home_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ref.watch(currentUserDataProvider).when(
      loading: () => const Scaffold(
        body: LoadingState(),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: ErrorState(
          message: 'Đã xảy ra lỗi: $err',
          onRetry: () {
            ref.invalidate(currentUserDataProvider);
          },
        ),
      ),
      data: (userModel) {
        if (userModel == null) {
          return const Scaffold(
            body: Center(child: Text('Không tìm thấy thông tin người dùng')),
          );
        }

        final bool isAdmin = userModel.role == 'admin';

        // Define screens for each role
        final List<Widget> userScreens = [
          const HomeScreen(),
          const ProductCatalogScreen(),
          const CartScreen(),
          const OrderHistoryScreen(),
        ];

        final List<Widget> adminScreens = [
          const OrderManagementScreen(),
          const ProductListScreen(),
          const ReportScreen(),
        ];

        final screens = isAdmin ? adminScreens : userScreens;

        // Define bottom nav items for each role
        final List<BottomNavigationBarItem> userNavItems = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Sản phẩm',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Giỏ hàng',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
        ];

        final List<BottomNavigationBarItem> adminNavItems = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Đơn hàng',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Sản phẩm',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Báo cáo',
          ),
        ];

        final navItems = isAdmin ? adminNavItems : userNavItems;

        return Scaffold(
          appBar: AppBar(
            title: Text(isAdmin ? 'Quản lý' : 'Shop Online'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signOut();
                },
                tooltip: 'Đăng xuất',
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: navItems,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: isAdmin ? Colors.blue : Colors.green,
          ),
        );
      },
    );
  }
}
