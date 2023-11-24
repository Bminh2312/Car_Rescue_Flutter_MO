class WalletTransaction {
  final String id;
  final String walletId;
  final int transactionAmount;
  final String type;
  final DateTime createdAt;
  final String description;
  final int totalAmount;
  final String status;

  WalletTransaction({
    required this.id,
    required this.walletId,
    required this.transactionAmount,
    required this.type,
    required this.createdAt,
    required this.description,
    required this.totalAmount,
    required this.status,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      walletId: json['walletId'],
      transactionAmount: json['transactionAmount'],
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']),
      description: json['description'],
      totalAmount: json['totalAmount'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['walletId'] = this.walletId;
    data['transactionAmount'] = this.transactionAmount;
    data['type'] = this.type;
    data['createdAt'] = this.createdAt.toIso8601String();
    data['description'] = this.description;
    data['totalAmount'] = this.totalAmount;
    data['status'] = this.status;
    return data;
  }
}
