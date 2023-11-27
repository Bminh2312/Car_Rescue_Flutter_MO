class CustomerCar {
  final String id;
  final String customerId;
  final String? modelId;
  final String color;
  final String vinNumber;
  final String manufacturer;
  final int manufacturingYear;
  final String licensePlate;
  final String status;
  final String? image;
  bool isSelected;
  CustomerCar({
    required this.image,
    required this.id,
    required this.customerId,
    required this.modelId,
    required this.color,
    required this.vinNumber,
    required this.manufacturer,
    required this.manufacturingYear,
    required this.licensePlate,
    required this.status,
    this.isSelected= false,
  });

  // Optionally, you can add a factory constructor to create an instance from a map
  // Useful for creating an instance from JSON data
  factory CustomerCar.fromJson(Map<String, dynamic> json) {
    return CustomerCar(
        id: json['id'],
        customerId: json['customerId'],
        modelId: json['modelId'] ?? '',
        color: json['color'],
        vinNumber: json['vinNumber'],
        manufacturer: json['manufacturer'],
        manufacturingYear: json['manufacturingYear'],
        licensePlate: json['licensePlate'],
        status: json['status'],
        image: json['image'] ?? '');
  }

  // Method to convert CustomerCar instance to a map, useful for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'modelId': modelId,
      'color': color,
      'vinNumber': vinNumber,
      'manufacturer': manufacturer,
      'manufacturingYear': manufacturingYear,
      'licensePlate': licensePlate,
      'status': status,
    };
  }
}
