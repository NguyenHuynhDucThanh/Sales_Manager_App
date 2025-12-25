import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/products/viewmodels/product_list_viewmodel.dart';
import 'features/cart/viewmodels/cart_viewmodel.dart';
import 'features/orders/viewmodels/order_history_viewmodel.dart';
import 'features/orders/viewmodels/order_management_viewmodel.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => AuthViewModel()..listenToAuthState()),
        provider.ChangeNotifierProvider(create: (_) => ProductListViewModel()),
        provider.ChangeNotifierProvider(create: (_) => CartViewModel()),
        provider.ChangeNotifierProvider(create: (_) => OrderHistoryViewModel()),
        provider.ChangeNotifierProvider(create: (_) => OrderManagementViewModel()),
      ],
      child: MaterialApp(
        title: 'Sales Manager MVP',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

// Widget điều hướng thông minh - sử dụng ViewModel
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return provider.Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        // Kiểm tra trạng thái đăng nhập
        if (viewModel.isLoading && viewModel.currentUser == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Nếu có user -> Vào Dashboard
        if (viewModel.currentUser != null) {
          return const DashboardScreen();
        }

        // Nếu không có user -> Ra màn hình Login
        return const LoginScreen();
      },
    );
  }
}