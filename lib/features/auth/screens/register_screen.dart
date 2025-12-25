import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/widgets.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
      // Pop RegisterScreen to return to the root (which AuthWrapper will update to Dashboard)
      Navigator.of(context).pop();
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add, size: 80, color: AppColors.primary),
                SizedBox(height: AppSpacing.md),
                Text(
                  "TẠO TÀI KHOẢN",
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
                SizedBox(height: AppSpacing.md),

                 AppTextField(
                  controller: _confirmPasswordController,
                  labelText: "Nhập lại Mật khẩu",
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (val) {
                    if (val!.isEmpty) return "Nhập lại mật khẩu";
                    if (val != _passwordController.text) return "Mật khẩu không khớp";
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.lg),

                Consumer<AuthViewModel>(
                  builder: (context, viewModel, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: AppButton(
                        label: "ĐĂNG KÝ NGAY",
                        isLoading: viewModel.isLoading,
                        onPressed: _handleSignUp,
                      ),
                    );
                  },
                ),
                
                SizedBox(height: AppSpacing.md),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Đã có tài khoản? "),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Đăng nhập", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
