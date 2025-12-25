class OrderModel {
  final String id;
  final double total;
  final DateTime createdAt;
  final int itemsCount;
  final String paymentMethod;
  final String? userId;
  
  // Order status workflow fields
  final String status;              // 'pending', 'confirmed', 'cancelled'
  final String? shippingAddress;    // Địa chỉ giao hàng
  final String? note;               // Ghi chú của user
  final String? cancellationReason; // Lý do hủy (admin nhập)
  final DateTime? updatedAt;        // Thời điểm update status

  OrderModel({
    required this.id,
    required this.total,
    required this.createdAt,
    required this.itemsCount,
    this.paymentMethod = 'cash',
    this.userId,
    this.status = 'pending',         // Default: pending
    this.shippingAddress,
    this.note,
    this.cancellationReason,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      itemsCount: json['itemsCount'] as int,
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      userId: json['userId'] as String?,
      status: json['status'] as String? ?? 'confirmed', // Old orders default to confirmed
      shippingAddress: json['shippingAddress'] as String?,
      note: json['note'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'itemsCount': itemsCount,
      'paymentMethod': paymentMethod,
      'userId': userId,
      'status': status,
      'shippingAddress': shippingAddress,
      'note': note,
      'cancellationReason': cancellationReason,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Helper method to check status
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
}