class ServiceData {
  final String id;
  final String orderId;
  final String serviceId;
  final int quantity;
  final int total;

  ServiceData({
    required this.id,
    required this.orderId,
    required this.serviceId,
    required this.quantity,
    required this.total,
  });

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    return ServiceData(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      quantity: json['quantity'] ?? 0,
      total: json['t0tal'] ?? 1,
    );
  }
}
