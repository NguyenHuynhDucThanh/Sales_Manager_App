import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';

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
    return MaterialApp(
      title: 'Sales Manager MVP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // THAY ĐỔI Ở ĐÂY: Gọi AuthWrapper thay vì màn hình cụ thể
      home: const AuthWrapper(),
    );
  }
}

// Widget điều hướng thông minh
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe trạng thái đăng nhập từ Firebase
    final authState = ref.watch(authStateProvider);

    return authState.when(
      // 1. Đang kiểm tra -> Hiện màn hình chờ (Splash)
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      
      // 2. Có lỗi -> Hiện thông báo
      error: (e, stack) => Scaffold(body: Center(child: Text("Lỗi: $e"))),
      
      // 3. Có dữ liệu (User)
      data: (user) {
        if (user != null) {
          // Nếu user tồn tại -> Vào Dashboard
          return const DashboardScreen();
        } else {
          // Nếu user null -> Ra màn hình Login
          return const LoginScreen();
        }
      },
    );
  }
}