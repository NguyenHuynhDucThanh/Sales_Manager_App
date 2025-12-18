import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  final String id;
  final double total;
  final DateTime createdAt;
  final int itemsCount;
  final String paymentMethod; // "cash" or "transfer"
  final String? userId; // 👈 THÊM TRƯỜNG NÀY (Có thể null nếu đơn cũ chưa có)

  OrderModel({
    required this.id,
    required this.total,
    required this.createdAt,
    required this.itemsCount,
    required this.paymentMethod,
    this.userId, // 👈 Thêm vào constructor
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}