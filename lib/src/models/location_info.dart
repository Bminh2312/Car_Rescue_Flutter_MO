class LocationInfo {
  late String refId;
  late int distance;
  late String address;
  late String name;
  late String display;
  late double latitude;
  late double longitude;

  LocationInfo({
    required this.refId,
    required this.distance,
    required this.address,
    required this.name,
    required this.display,
    required this.latitude,
    required this.longitude,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      refId: json['ref_id'] ?? "",
      distance: json['distance'] ?? 0,
      address: json['address'] ?? "",
      name: json['name'] ?? "",
      display: json['display'] ?? "",
      latitude: json['latitude'] ?? 0,
      longitude: json['longitude'] ?? 0,
    );
  }
}
