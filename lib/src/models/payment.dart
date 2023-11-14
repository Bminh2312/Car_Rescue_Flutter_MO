class Payment {
  final String id;
  final String orderId;
  final String createdAt;
  final String method;
  final int amount;
  final String status;

  Payment({
    required this.method,
    required this.id,
    required this.orderId,
    required this.createdAt,
    required this.amount,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['data'] ?? Map<String, dynamic>();
    return Payment(
      id: data['id'],
      orderId: data['orderId'],
      method: data['method'],
      createdAt: data['createdAt'],
      amount: data['amount'],
      status: data['status'],
    );
  }
}
