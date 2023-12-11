import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
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
  final LocationUpdateService _locationUpdateService = LocationUpdateService();

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
      // _updateCameraToTechnicianLocation();
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
    mapController?.animateCamera(
      CameraUpdate.newLatLng(technicianLocation ?? LatLng(0, 0)),
    );
  }

  void _getOrderLocation() async {
    try {
      if (widget.booking != null && widget.booking.departure != null) {
        String latLongString = "${widget.booking.departure}";

        // Split the string into parts using ","
        List<String> parts = latLongString.split(',');

        // Check if the split parts are available
        if (parts.length >= 2) {
          // Extract latitude and longitude strings
          String latString = parts[0].split(':')[1].trim();
          String longString = parts[1].split(':')[1].trim();

          // Parse latitude and longitude to double
          double latitude = double.tryParse(latString) ?? 0.0;
          double longitude = double.tryParse(longString) ?? 0.0;

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
                        animated.Lottie.asset(
                            'assets/animations/technician.json',
                            width: 250,
                            height: 250,
                            fit: BoxFit.fill),
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
                                    if (states
                                        .contains(MaterialState.pressed)) {
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
                                    if (states
                                        .contains(MaterialState.pressed)) {
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

          PolylinePoints polylinePoints = PolylinePoints();
          PolylineResult result =
              await polylinePoints.getRouteBetweenCoordinates(
            "YOUR_GOOGLE_MAPS_API_KEY",
            PointLatLng(
              technicianLocation?.latitude ?? 0.0,
              technicianLocation?.longitude ?? 0.0,
            ),
            PointLatLng(
              _targetLocation?.latitude ?? 0.0,
              _targetLocation?.longitude ?? 0.0,
            ),
            travelMode: TravelMode.walking,
          );

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
      }
    } catch (e, stackTrace) {
      print("Error in _getOrderLocation: $e");
      print(stackTrace);
      // Handle the error as needed
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    try {
      // Load asset data
      ByteData? data = await rootBundle.load(path);
      if (data == null) {
        throw Exception("Failed to load asset data for $path");
      }

      // Decode image
      ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: width,
      );
      ui.FrameInfo fi = await codec.getNextFrame();

      // Convert to Uint8List
      ByteData? byteData =
          await fi.image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception("Failed to convert image to ByteData for $path");
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      print("Error in getBytesFromAsset: $e");
      // Handle the error, e.g., return a default image or rethrow the exception
      throw e;
    }
  }

  Future<Uint8List> getBytesFromUrl(String url, int width) async {
    try {
      // Fetch image data
      http.Response response = await http.get(Uri.parse(url));
      List<int>? bytes = response.bodyBytes;
      if (bytes == null) {
        throw Exception("Failed to fetch image data from $url");
      }

      // Decode image
      ui.Codec codec = await ui.instantiateImageCodec(
        Uint8List.fromList(bytes),
        targetWidth: width,
      );
      ui.FrameInfo fi = await codec.getNextFrame();

      // Convert to Uint8List
      ByteData? byteData =
          await fi.image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception("Failed to convert image to ByteData from $url");
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      print("Error in getBytesFromUrl: $e");
      // Handle the error, e.g., return a default image or rethrow the exception
      throw e;
    }
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
                  if (currentLocation != null)
                    Marker(
                      markerId: MarkerId("currentLocation"),
                      position: currentLocation ??
                          LatLng(0.0,
                              0.0), // Provide a default LatLng if currentLocation is null
                      icon: departureIcon ?? BitmapDescriptor.defaultMarker,
                      infoWindow: InfoWindow(title: "Vị trí của tôi"),
                    ),
                  if (_targetLocation != null)
                    Marker(
                      markerId: MarkerId("targetLocation"),
                      position: _targetLocation ?? LatLng(0.0, 0.0),
                      icon: destinationIcon ?? BitmapDescriptor.defaultMarker,
                      infoWindow: InfoWindow(
                        title: "Địa điểm cứu hộ",
                      ),
                    ),
                  if (technicianLocation != null)
                    Marker(
                      markerId: MarkerId("technicianLocation"),
                      position: technicianLocation ?? LatLng(0.0, 0.0),
                      icon: techIcon ?? BitmapDescriptor.defaultMarker,
                      infoWindow: InfoWindow(title: "Vị trí của nhân viên"),
                    ),
                },
                polylines: {
                  Polyline(
                    polylineId: PolylineId("route"),
                    color: FrontendConfigs.kAuthColor,
                    width: 3,
                    points: routeCoordinates ??
                        [], // Use routeCoordinates with a default value
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
          heroTag: 'a',
          mini: true,
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
          heroTag: 'a',
          mini: true,
          onPressed: () {
            launchDialPad(widget.phone);
          },
          child: Icon(Icons.phone),
        ),
        FloatingActionButton(
            heroTag: 'a',
            mini: true,
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
        FloatingActionButton(
          heroTag: 'a',
          mini: true,
          child: Icon(Icons.location_on),
          onPressed: () {
            _showBothLocations();
          },
          backgroundColor: Colors.green,
        ),
      ],
      isSpeedDialFABsMini: true,
      paddingBtwSpeedDialButton: 30.0,
    );
  }

  void _showBothLocations() {
    if (mapController != null &&
        _targetLocation != null &&
        technicianLocation != null) {
      double minLat = _targetLocation!.latitude < technicianLocation!.latitude
          ? _targetLocation!.latitude
          : technicianLocation!.latitude;

      double maxLat = _targetLocation!.latitude > technicianLocation!.latitude
          ? _targetLocation!.latitude
          : technicianLocation!.latitude;

      double minLng = _targetLocation!.longitude < technicianLocation!.longitude
          ? _targetLocation!.longitude
          : technicianLocation!.longitude;

      double maxLng = _targetLocation!.longitude > technicianLocation!.longitude
          ? _targetLocation!.longitude
          : technicianLocation!.longitude;

      LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }
}

class LocationUpdateService {
  final _locationController = StreamController<LatLng>();

  Stream<LatLng> get locationStream => _locationController.stream;

  void updateLocation(LatLng location) {
    _locationController.add(location);
  }

  void dispose() {
    _locationController.close();
  }
}
