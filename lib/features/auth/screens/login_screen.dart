import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/widgets.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!success && mounted) {
      _showError(viewModel.errorMessage ?? 'Đăng nhập thất bại');
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    
    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đăng ký thành công! Đang vào App..."),
          backgroundColor: Colors.green,
        ),
      );
    } else if (!success && mounted) {
      _showError(viewModel.errorMessage ?? 'Đăng ký thất bại');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storefront, size: 100, color: AppColors.primary),
                SizedBox(height: AppSpacing.lg),
                Text(
                  "SALES MANAGER",
                  style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                ),
                SizedBox(height: AppSpacing.xl),

                AppTextField(
                  controller: _emailController,
                  labelText: "Email",
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val!.isEmpty ? "Vui lòng nhập Email" : null,
                ),
                SizedBox(height: AppSpacing.md),

                AppTextField(
                  controller: _passwordController,
                  labelText: "Mật khẩu",
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  validator: (val) => val!.length < 6 ? "Mật khẩu phải > 6 ký tự" : null,
                ),
                SizedBox(height: AppSpacing.lg),

                Consumer<AuthViewModel>(
                  builder: (context, viewModel, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: AppButton(
                        label: "ĐĂNG NHẬP",
                        isLoading: viewModel.isLoading,
                        onPressed: _handleLogin,
                      ),
                    );
                  },
                ),
                
                SizedBox(height: AppSpacing.md),

                Consumer<AuthViewModel>(
                  builder: (context, viewModel, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: AppOutlineButton(
                        label: "CHƯA CÓ TÀI KHOẢN? ĐĂNG KÝ NGAY",
                        onPressed: viewModel.isLoading ? null : _handleSignUp,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
