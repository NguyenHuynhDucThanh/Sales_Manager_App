import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/add_product_viewmodel.dart';
import '../viewmodels/product_list_viewmodel.dart';
import '../../../core/utils/currency_input_formatter.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct(AddProductViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    final productListViewModel = context.read<ProductListViewModel>();

    // Generate avatar URL
    final name = _nameController.text.trim();
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    final imageUrl = "https://ui-avatars.com/api/?size=200&background=random&color=fff&font-size=0.6&name=$firstLetter";
    
    // Set values to ViewModel
    viewModel.setName(name);
    viewModel.setPrice(_priceController.text);
    viewModel.setStock(_stockController.text);
    viewModel.setImageUrl(imageUrl);

    final success = await viewModel.addProduct();

    if (success && mounted) {
      // Refresh product list
      await productListViewModel.loadProducts();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm sản phẩm thành công!')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${viewModel.errorMessage ?? "Không thể thêm sản phẩm"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddProductViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Thêm sản phẩm mới')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Icon placeholder thay vì image picker
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("Avatar tự động", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tên sản phẩm', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Giá bán (VD: 10.000)',
                          border: OutlineInputBorder(),
                          suffixText: 'đ',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyInputFormatter()],
                        validator: (value) => value!.isEmpty ? 'Nhập giá' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(labelText: 'Tồn kho', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Nhập số lượng' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                Consumer<AddProductViewModel>(
                  builder: (context, viewModel, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : () => _saveProduct(viewModel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: viewModel.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('LƯU SẢN PHẨM', style: TextStyle(fontSize: 18)),
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
