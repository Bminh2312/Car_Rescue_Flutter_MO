class Incident {
  final String carId;
  final String symptomId;
  final String customerId;
  final String paymentMethod;
  final String departure;
  final String destination;
  final String rescueType;
  late int? distance;
  final List<String> url;
  final int area;

  Incident({
    required this.carId,
    required this.symptomId,
    required this.customerId,
    required this.paymentMethod,
    required this.departure,
    required this.destination,
    required this.rescueType,
    required this.distance,
    required this.url,
    required this.area,
  });

  Map<String, dynamic> toJson() {
    return {
      'carId': carId,
      'symptomId': symptomId,
      'customerId': customerId,
      'paymentMethod': paymentMethod,
      'departure': departure,
      'destination': destination,
      'rescueType': rescueType,
      'distance': distance,
      'url': url,
      'area': area,
    };
  }
}