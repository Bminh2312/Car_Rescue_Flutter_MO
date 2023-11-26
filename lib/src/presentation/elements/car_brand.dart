class CarBrand {
  final int id;
  final String name;

  CarBrand({required this.id, required this.name});

  // Constructor for creating a new CarBrand instance from a map (deserialization)
  factory CarBrand.fromJson(Map<String, dynamic> json) {
    return CarBrand(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  // Method to convert CarBrand instance to a map (serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': name,
    };
  }

  @override
  String toString() {
    return 'CarBrand{id: $id, brand: $name}';
  }
}
