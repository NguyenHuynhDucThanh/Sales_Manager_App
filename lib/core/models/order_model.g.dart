// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: json['id'] as String,
  total: (json['total'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  itemsCount: (json['itemsCount'] as num).toInt(),
  paymentMethod: json['paymentMethod'] as String,
  userId: json['userId'] as String?,
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'total': instance.total,
      'createdAt': instance.createdAt.toIso8601String(),
      'itemsCount': instance.itemsCount,
      'paymentMethod': instance.paymentMethod,
      'userId': instance.userId,
    };
