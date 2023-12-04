import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/models/customerInfo.dart';
import 'package:CarRescue/src/models/order.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapTechScreen extends StatefulWidget {
  final String techImg;
  final Booking booking;
  final String techId;
  const MapTechScreen(
      {super.key,
      required this.techImg,
      required this.booking,
      required this.cus,
      required this.techId});
  final CustomerInfo cus;
  @override
  _MapTechScreenState createState() => _MapTechScreenState();
}

class _MapTechScreenState extends State<MapTechScreen> {
  GoogleMapController? mapController;
  LatLng? currentLocation;
  LatLng? _targetLocation;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? departureIcon;
  BitmapDescriptor? techIcon;
  LatLng? technicianLocation;
  List<LatLng> routeCoordinates = [];
  Set<Polyline> polylines = {};
  Timer? myTimer;
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getOrderLocation();
    setSourceAndDestinationIcons();
    setSourceAndDepartureIcons();
    setSourceAndDepartureImage();

    _loadCreateLocation();
    loadUpdateLocation();
    myTimer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      _loadLocation();
      _getCurrentLocation();
      _getOrderLocation();
      loadUpdateLocation();
      // Stop the timer after a certain condition (e.g., after 10 ticks)
      // if (timer.tick == 10) {
      //   print("Stopping the timer.");
      //   myTimer?.cancel();
      // }
    });
  }

  @override
  void dispose() {
    // Dispose of the timer in the dispose method
    myTimer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  Future<void> _loadCreateLocation() async {
    try {
      if (currentLocation != null) {
        await AuthService().createLocation(
          id: widget.techId,
          lat: '${currentLocation!.latitude}',
          long: '${currentLocation!.longitude}',
        );
      }
    } catch (e) {
      print('Error in _loadcreateLocation: $e');
    }
  }

  void loadUpdateLocation() async {
    try {
      if (currentLocation != null) {
        await AuthService().updateLocation(
          id: widget.techId,
          lat: '${currentLocation!.latitude}',
          long: '${currentLocation!.longitude}',
        );
        print('zxzx: $currentLocation');
      }
    } catch (error) {
      print('Error loading updateLocation: $error');
    }
  }

  Future<void> _loadLocation() async {
    try {
      final technicianLocationData =
          await AuthService().getLiveLocation(widget.techId);
      if (technicianLocationData.isNotEmpty) {
        setState(() {
          technicianLocation = LatLng(
            technicianLocationData['lat'] ?? 0.0,
            technicianLocationData['long'] ?? 0.0,
          );
        });
      }
    } catch (e) {
      print('Error loading location: $e');
    }
  }

  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  void _getOrderLocation() async {
    String latLongString = "${widget.booking.departure}";

// Split the string into parts using ","
    List<String> parts = latLongString.split(',');

// Extract latitude and longitude strings
    String latString = parts[0].split(':')[1];
    String longString = parts[1].split(':')[1];

// Parse latitude and longitude to double
    double latitude = double.parse(latString);
    double longitude = double.parse(longString);

// Now you can use the latitude and longitude as needed
    LatLng targetLocation = LatLng(latitude, longitude);
    setState(() {
      _targetLocation = targetLocation;
    });
// Print the result
    print("Latitude: $latitude, Longitude: $longitude");
    print("Target Location: $targetLocation");

    if (technicianLocation == null) {
      await _loadLocation();
    }

    // Fetch route coordinates
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyDOI-u7wGzGG27hUGCO3z7MR8MIVsvJ2jg",
      PointLatLng(
        currentLocation!.latitude,
        currentLocation!.longitude,
      ),
      PointLatLng(
        _targetLocation!.latitude,
        _targetLocation!.longitude,
      ),
      travelMode: TravelMode.driving,
    );
    if (currentLocation != null && _targetLocation != null) {
      double distance = calculateDistance(currentLocation!, _targetLocation!);

      if (distance < 100) {
        // Stop the timer
        myTimer?.cancel();
        print(
            "Technician is close to the target location. Stopping the timer.");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Thông báo từ Kỹ thuật viên"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Kỹ thuật viên đã đến điểm cứu hộ."),
                  SizedBox(height: 10),
                  // Add relevant images or icons here
                  // For example, you can use Image.asset or Icon widgets

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Implement your action for calling the technician
                          Navigator.pop(context); // Close the dialog
                        },
                        child: Row(
                          children: [
                            Icon(Icons.call),
                            SizedBox(width: 8),
                            Text("Gọi Kỹ thuật viên"),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Implement your action for confirming the technician's arrival
                          Navigator.pop(context); // Close the dialog
                        },
                        child: Row(
                          children: [
                            Icon(Icons.check),
                            SizedBox(width: 8),
                            Text("Đã xác nhận"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }
    }
    if (result.points.isNotEmpty) {
      setState(() {
        routeCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      });
    } else {
      print("Error fetching route coordinates");
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<Uint8List> getBytesFromUrl(String url, int width) async {
    http.Response response = await http.get(Uri.parse(url));
    List<int> bytes = response.bodyBytes;

    ui.Codec codec = await ui.instantiateImageCodec(
      Uint8List.fromList(bytes),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> setSourceAndDepartureIcons() async {
    final Uint8List icon1 =
        await getBytesFromAsset('assets/images/tow-truck-top-view.png', 100);

    setState(() {
      techIcon = BitmapDescriptor.fromBytes(icon1);
    });
  }

  Future<void> setSourceAndDepartureImage() async {
    final Uint8List icon1 = await getBytesFromUrl(widget.cus.avatar, 100);
    print(widget.cus.avatar);
    setState(() {
      departureIcon = BitmapDescriptor.fromBytes(icon1);
    });
  }

  Future<void> setSourceAndDestinationIcons() async {
    final Uint8List icon1 =
        await getBytesFromAsset('assets/images/placeholder.png', 100);

    setState(() {
      destinationIcon = BitmapDescriptor.fromBytes(icon1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: (currentLocation != null && _targetLocation != null)
          ? GoogleMap(
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                });
              },
              initialCameraPosition: CameraPosition(
                target: currentLocation!,
                zoom: 15.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId("currentLocation"),
                  position: currentLocation!,
                  icon: techIcon ?? BitmapDescriptor.defaultMarker,
                  infoWindow: InfoWindow(title: "Vị trí của tôi"),
                ),
                Marker(
                  markerId: MarkerId("targetLocation"),
                  position: _targetLocation!,
                  icon: departureIcon ?? BitmapDescriptor.defaultMarker,
                  infoWindow: InfoWindow(
                    title: "Địa điểm cứu hộ",
                  ),
                ),
                // Marker(
                //   markerId: MarkerId("technicianLocation"),
                //   position: technicianLocation!,
                //   icon: departureIcon ?? BitmapDescriptor.defaultMarker,
                //   infoWindow: InfoWindow(title: "Vị trí gặp nạn của khách"),
                // ),
              },
              polylines: {
                Polyline(
                  polylineId: PolylineId("route"),
                  color: FrontendConfigs.kAuthColor,
                  width: 3,
                  points:
                      routeCoordinates, // Use routeCoordinates instead of [technicianLocation!, _targetLocation!]
                ),
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
