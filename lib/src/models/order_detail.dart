class OrderDetail {
  final String id;
  final String orderId;
  final DateTime createdAt;
  final String method;
  final double amount;
  final String status;
  // Add other fields if necessary

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.createdAt,
    required this.method,
    required this.amount,
    required this.status,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      orderId: json['orderId'],
      createdAt: DateTime.parse(json['createdAt']),
      method: json['method'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
    );
  }
}
