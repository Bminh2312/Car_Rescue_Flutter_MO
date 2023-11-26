class CarModel {
  final String? id;

  final String? model1;

  final String? status;

  CarModel({
    required this.id,
    required this.model1,
    required this.status,
  });

  // Optionally, you can add a factory constructor to create an instance from a map
  // Useful for creating an instance from JSON data
  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'] ?? '',
      model1: json['model1'] ?? '',
      status: json['status'] ?? '',
    );
  }

  // Method to convert CustomerCar instance to a map, useful for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model1': model1,
      'status': status,
    };
  }
}
