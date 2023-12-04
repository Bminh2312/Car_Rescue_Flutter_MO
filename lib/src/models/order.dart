class Order {
  final String? carId;
  final String id;
  final String customerId;
  final String? technicianId;
  final String? managerId;
  final String? vehicleId;
  final String paymentId;
  final String? customerNote;
  final String? departure;
  final String? destination;
  final String? rescueType;
  final String? staffNote;
  final String? cancellationReason;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? createdAt;
  final String status;
  int area;

  Order({
    required this.carId,
    required this.id,
    required this.customerId,
    required this.technicianId,
    required this.managerId,
    required this.vehicleId,
    required this.paymentId,
    required this.customerNote,
    required this.departure,
    required this.destination,
    required this.rescueType,
    required this.staffNote,
    required this.cancellationReason,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.status,
    required this.area,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      carId: json['carId'],
      id: json['id'],
      customerId: json['customerId'],
      technicianId: json['technicianId'] ?? "",
      managerId: json['managerId'] ?? "",
      vehicleId: json['vehicleId'] ?? "",
      paymentId: json['paymentId'] ?? "",
      customerNote: json['customerNote'] ?? "",
      departure: json['departure'] ?? "",
      destination: json['destination'] ?? "",
      rescueType: json['rescueType'] ?? "",
      staffNote: json['staffNote'] ?? "",
      cancellationReason: json['cancellationReason'] ?? "",
      startTime:
          json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      status: json['status'] ?? "",
      area: json['area'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carId': carId,
      'id': id,
      'customerId': customerId,
      'technicianId': technicianId,
      'managerId': managerId,
      'vehicleId': vehicleId,
      'paymentId': paymentId,
      'customerNote': customerNote,
      'departure': departure,
      'destination': destination,
      'rescueType': rescueType,
      'staffNote': staffNote,
      'cancellationReason': cancellationReason,
      'startTime': startTime,
      'endTime': endTime,
      'createdAt': createdAt,
      'status': status,
      'area': area,
    };
  }
}
