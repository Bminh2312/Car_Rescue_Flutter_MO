class FeedbackCustomer {
  final String id;
  final String customerId;
  final String orderId;
  final int rating;
  final String? note;
  final String status;

  FeedbackCustomer({
    required this.id,
    required this.customerId,
    required this.orderId,
    required this.rating,
    required this.note,
    required this.status,
  });

  factory FeedbackCustomer.fromJson(Map<String, dynamic> json) {
    return FeedbackCustomer(
      id: json['id'],
      customerId: json['customerId'],
      orderId: json['orderId'],
      rating: json['rating'],
      note: json['note'] != null ? json['note'] : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'orderId': orderId,
      'rating': rating,
      'note': note,
      'status': status,
    };
  }
}