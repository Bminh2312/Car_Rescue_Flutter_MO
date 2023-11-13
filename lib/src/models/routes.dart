class RouteResponse {
  final List<Route> routes;

  RouteResponse({required this.routes});

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> routesJson = json['routes'];
    final List<Route> routes = routesJson.map((route) => Route.fromJson(route)).toList();
    return RouteResponse(routes: routes);
  }
}

class Route {
  final int distanceMeters;
  final String duration;
  final Polyline polyline;

  Route({required this.distanceMeters, required this.duration, required this.polyline});

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      distanceMeters: json['distanceMeters'],
      duration: json['duration'],
      polyline: Polyline.fromJson(json['polyline']),
    );
  }
}

class Polyline {
  final String encodedPolyline;

  Polyline({required this.encodedPolyline});

  factory Polyline.fromJson(Map<String, dynamic> json) {
    return Polyline(encodedPolyline: json['encodedPolyline']);
  }
}