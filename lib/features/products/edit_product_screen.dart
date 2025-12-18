import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/product.dart';
import 'product_provider.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final Product product; // Nhận sản phẩm cần sửa từ màn hình trước

  const EditProductScreen({super.key, required this.product});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  
  XFile? _pickedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Điền sẵn dữ liệu cũ vào các ô
    _nameController = TextEditingController(text: widget.product.name);
    // Lưu ý: price là double, stock là int -> phải chuyển sang String
    _priceController = TextEditingController(text: widget.product.price.toStringAsFixed(0)); // Bỏ số thập phân nếu cần
    _stockController = TextEditingController(text: widget.product.stock.toString());
  }

  // Hàm chọn ảnh (Giống hệt bên Add)
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 800);
    if (image != null) setState(() => _pickedImage = image);
  }

  // Hàm upload ảnh (Giống hệt bên Add)
  Future<String?> _uploadImageToStorage() async {
    if (_pickedImage == null) return null;
    try {
      final String fileName = "${const Uuid().v4()}.jpg";
      final storageRef = FirebaseStorage.instance.ref().child("product_images/$fileName");
      if (kIsWeb) {
        await storageRef.putData(await _pickedImage!.readAsBytes(), SettableMetadata(contentType: 'image/jpeg'));
      } else {
        await storageRef.putFile(File(_pickedImage!.path));
      }
      return await storageRef.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // Xử lý Cập nhật
  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isUploading = true);

    try {
      String? imageUrl = widget.product.imageUrl; // Mặc định dùng link ảnh cũ

      // 1. Nếu người dùng chọn ảnh mới -> Upload ảnh mới
      if (_pickedImage != null) {
        try {
          imageUrl = await _uploadImageToStorage();
        } catch (e) {
          print("Lỗi upload: $e");
        }
      }

      // 2. Nếu vẫn không có ảnh (và ảnh cũ cũng null), tạo ảnh tự động theo tên mới
      if (imageUrl == null) {
        final name = _nameController.text.trim();
        final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'P';
        imageUrl = "https://ui-avatars.com/api/?size=200&background=random&color=fff&font-size=0.6&name=$firstLetter";
      }

      // 3. Tạo object Product mới (Giữ nguyên ID cũ)
      final updatedProduct = Product(
        id: widget.product.id, // QUAN TRỌNG: Phải giữ nguyên ID
        name: _nameController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        imageUrl: imageUrl,
        createdAt: widget.product.createdAt, // Giữ ngày tạo cũ
        updatedAt: DateTime.now(), // Cập nhật ngày sửa
      );

      // 4. Gọi Provider update
      await ref.read(productListProvider.notifier).updateProduct(updatedProduct);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Giao diện y hệt AddProductScreen, chỉ đổi title và nút
    return Scaffold(
      appBar: AppBar(title: const Text('Sửa sản phẩm')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _pickedImage != null
                        ? (kIsWeb ? Image.network(_pickedImage!.path, fit: BoxFit.cover) : Image.file(File(_pickedImage!.path), fit: BoxFit.cover))
                        : (widget.product.imageUrl != null 
                            ? Image.network(widget.product.imageUrl!, fit: BoxFit.cover) // Hiện ảnh cũ
                            : const Icon(Icons.camera_alt, size: 40, color: Colors.grey)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Nhập tên' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Giá bán', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Nhập giá' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(labelText: 'Tồn kho', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Nhập số' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _handleUpdate,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                  child: _isUploading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('CẬP NHẬT', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}