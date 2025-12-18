import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  // Hàm chuyển từ JSON (Firestore) sang Object
  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  // Hàm chuyển từ Object sang JSON (để lưu lên Firestore)
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}