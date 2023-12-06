import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/models/customerInfo.dart';
import 'package:CarRescue/src/models/order.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart' as animated;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_arc_speed_dial/flutter_speed_dial_menu_button.dart';
import 'package:flutter_arc_speed_dial/main_menu_floating_action_button.dart';

class MapScreen extends StatefulWidget {
  final String techImg;
  final Order booking;
  final String techId;
  final String phone;
  const MapScreen(
      {super.key,
      required this.techImg,
      required this.booking,
      required this.cus,
      required this.techId,
      required this.phone});
  final Customer cus;
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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
    // _loadLocation();
    myTimer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      _loadLocation();
      _getCurrentLocation();
      _getOrderLocation();
      _updateCameraToTechnicianLocation();
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

  void launchDialPad(String phoneNumber) async {
    String uri = 'tel:$phoneNumber';

    try {
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      print('Error launching dial pad: $e');
      throw 'Could not launch $uri';
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

  void _updateCameraToTechnicianLocation() {
    if (mapController != null && technicianLocation != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(technicianLocation!),
      );
    }
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
        technicianLocation!.latitude,
        technicianLocation!.longitude,
      ),
      PointLatLng(
        _targetLocation!.latitude,
        _targetLocation!.longitude,
      ),
      travelMode: TravelMode.walking,
    );
    if (technicianLocation != null && _targetLocation != null) {
      double distance =
          calculateDistance(technicianLocation!, _targetLocation!);

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
                  animated.Lottie.asset('assets/animations/technician.json',
                      width: 250, height: 250, fit: BoxFit.fill),
                  Column(
                    children: [
                      CustomText(
                        text: 'Kĩ thuật viên đã đến điểm của bạn',
                        fontSize: 18,
                      ),
                      CustomText(
                        text: 'Bạn đã thấy kĩ thuật viên chưa?',
                        fontSize: 18,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Add relevant images or icons here
                  // For example, you can use Image.asset or Icon widgets

                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                // The button is in the pressed state
                                return Colors.white.withOpacity(
                                    0.5); // Change the color when pressed
                              }
                              // The default color when not pressed
                              return FrontendConfigs.kActiveColor;
                            },
                          ),
                        ),
                        onPressed: () {
                          // Implement your action for calling the technician
                          launchDialPad(widget.phone); // Close the dialog
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
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                // The button is in the pressed state
                                return Colors.white.withOpacity(
                                    0.5); // Change the color when pressed
                              }
                              // The default color when not pressed
                              return FrontendConfigs.kActiveColor;
                            },
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
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
        await getBytesFromAsset('assets/images/tow-truck-top-view.png', 150);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 1,
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
                  target: _targetLocation!,
                  zoom: 15.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId("currentLocation"),
                    position: currentLocation!,
                    icon: departureIcon ?? BitmapDescriptor.defaultMarker,
                    infoWindow: InfoWindow(title: "Vị trí của tôi"),
                  ),
                  Marker(
                    markerId: MarkerId("targetLocation"),
                    position: _targetLocation!,
                    icon: destinationIcon ?? BitmapDescriptor.defaultMarker,
                    infoWindow: InfoWindow(
                      title: "Địa điểm cứu hộ",
                    ),
                  ),
                  Marker(
                    markerId: MarkerId("technicianLocation"),
                    position: technicianLocation!,
                    icon: techIcon ?? BitmapDescriptor.defaultMarker,
                    infoWindow: InfoWindow(title: "Vị trí của nhân viên"),
                  ),
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
        floatingActionButton: _getFloatingActionButton());
  }

  Widget _getFloatingActionButton() {
    return SpeedDialMenuButton(
      //if needed to close the menu after clicking sub-FAB

      //manually open or close menu
      updateSpeedDialStatus: (isShow) {
        //return any open or close change within the widget
      },
      //general init
      isMainFABMini: false,
      mainMenuFloatingActionButton: MainMenuFloatingActionButton(
          mini: false,
          child: Icon(Icons.menu),
          onPressed: () {},
          closeMenuChild: Icon(Icons.close),
          closeMenuForegroundColor: Colors.white,
          closeMenuBackgroundColor: Colors.red),
      floatingActionButtonWidgetChildren: <FloatingActionButton>[
        FloatingActionButton(
          onPressed: () {
            if (mapController != null && currentLocation != null) {
              mapController!.animateCamera(
                CameraUpdate.newLatLng(currentLocation!),
              );
            }
          },
          tooltip: 'Go to current location',
          child: Icon(Icons.my_location),
        ),
        FloatingActionButton(
          onPressed: () {
            launchDialPad(widget.phone);
          },
          child: Icon(Icons.phone),
        ),
        FloatingActionButton(
            onPressed: () {
              if (mapController != null && technicianLocation != null) {
                mapController!.animateCamera(
                  CameraUpdate.newLatLng(technicianLocation!),
                );
              }
            },
            tooltip: 'Show technician location',
            child: Image.asset(
              'assets/icons/mechanic.png',
              height: 30,
              width: 30,
            )),
      ],
      isSpeedDialFABsMini: true,
      paddingBtwSpeedDialButton: 30.0,
    );
  }
}
