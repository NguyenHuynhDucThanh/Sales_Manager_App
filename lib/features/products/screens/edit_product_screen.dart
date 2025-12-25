import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/models/product.dart';
import '../viewmodels/edit_product_viewmodel.dart';
import '../viewmodels/product_list_viewmodel.dart';
import '../../../core/utils/currency_input_formatter.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    // Format giá theo định dạng VN
    final formatter = NumberFormat.decimalPattern('vi_VN');
    _priceController = TextEditingController(text: formatter.format(widget.product.price.toInt()));
    _stockController = TextEditingController(text: widget.product.stock.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate(EditProductViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;
    final productListViewModel = context.read<ProductListViewModel>();

    // Set values to ViewModel
    viewModel.setName(_nameController.text.trim());
    
    // Parse price
    final price = parseCurrencyInput(_priceController.text).toDouble();
    viewModel.setPrice(price.toStringAsFixed(0));
    
    viewModel.setStock(_stockController.text);

    viewModel.setStock(_stockController.text);
    // Image URL is updated via onChanged

    final success = await viewModel.updateProduct();

    if (success && mounted) {
      // Refresh product list
      await productListViewModel.loadProducts();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thành công!')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${viewModel.errorMessage ?? "Không thể cập nhật sản phẩm"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditProductViewModel(widget.product),
      child: Scaffold(
        appBar: AppBar(title: const Text('Sửa sản phẩm')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                  // Image Preview
                  Consumer<EditProductViewModel>(
                    builder: (context, viewModel, child) {
                      return Container(
                        width: 150,
                        height: 150,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: viewModel.imageUrl != null && viewModel.imageUrl!.isNotEmpty
                              ? Image.network(
                                  viewModel.imageUrl!, 
                                  fit: BoxFit.cover, 
                                  errorBuilder: (_, __, ___) => const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                      Text("Lỗi ảnh", style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                )
                              : const Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  ),

                  // Image URL Input for Edit
                  Consumer<EditProductViewModel>(
                    builder: (context, viewModel, child) {
                      return TextFormField(
                        initialValue: viewModel.imageUrl,
                        decoration: const InputDecoration(
                          labelText: 'Link ảnh sản phẩm',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                        ),
                        onChanged: (value) {
                          viewModel.setImageUrl(value);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Tên sản phẩm', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Nhập tên' : null,
                    onChanged: (value) => context.read<EditProductViewModel>().setName(value),
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
                          validator: (v) => v!.isEmpty ? 'Nhập giá' : null,
                          onChanged: (value) => context.read<EditProductViewModel>().setPrice(value),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stockController,
                          decoration: const InputDecoration(labelText: 'Tồn kho', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Nhập số' : null,
                          onChanged: (value) => context.read<EditProductViewModel>().setStock(value),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
                Consumer<EditProductViewModel>(
                  builder: (context, viewModel, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : () => _handleUpdate(viewModel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: viewModel.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('CẬP NHẬT', style: TextStyle(fontSize: 18)),
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
