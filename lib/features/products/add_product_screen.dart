import 'dart:io';
import 'package:flutter/foundation.dart'; // Để check kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/product.dart';
import 'product_provider.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Các biến lưu dữ liệu nhập
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  
  // Biến lưu ảnh đã chọn
  XFile? _pickedImage;
  bool _isUploading = false;

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
     // Thêm imageQuality và maxWidth
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Giảm chất lượng xuống còn 70% (mắt thường không thấy khác)
      maxWidth: 800,    // Giới hạn chiều rộng ảnh tối đa 800px
    );
    
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  // Hàm upload ảnh lên Firebase Storage
  Future<String?> _uploadImageToStorage() async {
    if (_pickedImage == null) return null;

    try {
      // 1. Tạo tên file duy nhất (dùng uuid)
      final String fileName = "${const Uuid().v4()}.jpg";
      
      // 2. Tham chiếu đến vị trí lưu trên Storage (thư mục product_images)
      final storageRef = FirebaseStorage.instance.ref().child("product_images/$fileName");

      // 3. Upload (Xử lý khác nhau giữa Web và Mobile)
      if (kIsWeb) {
        // Trên Web: Upload bằng bytes (dữ liệu thô)
        final bytes = await _pickedImage!.readAsBytes();
        await storageRef.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        // Trên Mobile: Upload bằng đường dẫn file
        await storageRef.putFile(File(_pickedImage!.path));
      }

      // 4. Lấy đường dẫn tải về (Download URL)
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Lỗi upload ảnh: $e");
      return null;
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isUploading = true);

    try {
      String? imageUrl;
      
      // 1. Cố gắng Upload ảnh (nếu máy bạn nào hên thì được, không thì bỏ qua)
      if (_pickedImage != null) {
        try {
          imageUrl = await _uploadImageToStorage();
        } catch (e) {
          print("Storage lỗi: $e");
        }
      }

      // 2. LOGIC MỚI: Tạo ảnh tự động dựa theo Tên Sản Phẩm
      // Nếu không upload được ảnh, ta sẽ tạo link ảnh dựa trên tên
      // ...
      if (imageUrl == null) {
        final name = _nameController.text.trim();
        
        // CÁCH MỚI: Chỉ lấy chữ cái đầu tiên và viết hoa (Ví dụ: "Gà rán" -> "G")
        // Cách này an toàn tuyệt đối 100%
        final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'P';
        
        imageUrl = "https://ui-avatars.com/api/?size=200&background=random&color=fff&font-size=0.6&name=$firstLetter";
      }
      // ...

      // 3. Tạo object Product
      final newProduct = Product(
        id: const Uuid().v4(),
        name: _nameController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        imageUrl: imageUrl, 
        createdAt: DateTime.now(),
      );

      // 4. Lưu vào Firestore
      await ref.read(productListProvider.notifier).addProduct(newProduct);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm sản phẩm thành công!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm sản phẩm mới')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. Khu vực chọn ảnh
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
                  child: _pickedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          // Hiển thị ảnh preview (Web dùng Network, Mobile dùng File)
                          child: kIsWeb 
                              ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
                              : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                            Text("Chọn ảnh"),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Các ô nhập liệu
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
                      decoration: const InputDecoration(labelText: 'Giá bán', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
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

              // 3. Nút Lưu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isUploading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('LƯU SẢN PHẨM', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}