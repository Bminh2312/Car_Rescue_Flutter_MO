class Service {
  late String id;
  late String createdBy;
  late String name;
  late String description;
  late int price;
  late String type;
  late String createdAt;
  late String updatedAt;
  late String status;

  Service({
    required this.id,
    required this.createdBy,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? "",
      createdBy: json['createdBy'] ?? "",
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      price: json['price'] ?? 0,
      type: json['type'] ?? "",
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
      status: json['status'] ?? "",
    );
  }
}
