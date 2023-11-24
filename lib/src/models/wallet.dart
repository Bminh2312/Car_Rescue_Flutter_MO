
class Wallet {
  final String id;
  final String rvoid;
  final int total;

  Wallet({
    required this.id,
    required this.rvoid,
    required this.total,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      rvoid: json['rvoid'],
      total: json['total'],
    );
  }
}
