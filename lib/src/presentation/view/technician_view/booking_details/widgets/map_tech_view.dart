import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/models/car_model.dart';
import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/models/customerInfo.dart';
import 'package:CarRescue/src/models/customer_car.dart';
import 'package:CarRescue/src/models/order.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart' as animated;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_arc_speed_dial/flutter_speed_dial_menu_button.dart';
import 'package:flutter_arc_speed_dial/main_menu_floating_action_button.dart';

class MapTechScreen extends StatefulWidget {
  final String techImg;
  final Booking booking;
  final String techId;
  final String techPhone;
  final CustomerCar car;
  final CarModel model;
  const MapTechScreen(
      {super.key,
      required this.techImg,
      required this.booking,
      required this.cus,
      required this.techId,
      required this.techPhone,
      required this.car,
      required this.model});
  final CustomerInfo cus;
  @override
  _MapTechScreenState createState() => _MapTechScreenState();
}

final String apiKey = "AIzaSyAi5WnYjSGtYS_L7nudU2i0d4aFY_3jPVo";

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
  bool isArrived = false;
  String? _duration;
  String? _distance;
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
    _getEstimatedTravelTime();
    myTimer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      _loadLocation();
      _getCurrentLocation();
      _getOrderLocation();
      loadUpdateLocation();
      if (currentLocation != null && _targetLocation != null) {
        _getEstimatedTravelTime(); // Call the function to get estimated travel time
      }
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

  double calculateTotalDistance(PolylineResult result) {
    double totalDistance = 0.0;

    for (int i = 0; i < result.points.length - 1; i++) {
      double distance = Geolocator.distanceBetween(
        result.points[i].latitude,
        result.points[i].longitude,
        result.points[i + 1].latitude,
        result.points[i + 1].longitude,
      );

      totalDistance += distance;
    }

    // Convert distance to kilometers
    totalDistance /= 1000.0;

    return totalDistance;
  }

  Future<void> _getEstimatedTravelTime() async {
    // final String apiKey = "AIzaSyAiyZLdDwpp0_dAOPNBMItItXixgLH9ABo";
    final String apiUrl =
        "https://maps.googleapis.com/maps/api/directions/json";

    final response = await http.get(
      Uri.parse(
        "$apiUrl?origin=${currentLocation!.latitude},${currentLocation!.longitude}&destination=${_targetLocation!.latitude},${_targetLocation!.longitude}&key=$apiKey",
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data["status"] == "OK") {
        final List<dynamic> routes = data["routes"];
        if (routes.isNotEmpty) {
          final Map<String, dynamic> route = routes.first;
          final Map<String, dynamic> legs = route["legs"].first;
          print(legs);
          final String durationText = legs["duration"]["text"];
          final String distance = legs["distance"]["text"];
          setState(() {
            _duration = durationText;
            _distance = distance;
          });
          print("Estimated Travel Time: $durationText");

          // You can use durationSeconds or durationText as needed

          return;
        }
      }
    }

    print("Error fetching estimated travel time");
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
      "$apiKey",
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

      if (distance < 80) {
        // Stop the timer
        // myTimer?.cancel();

        print(
            "Technician is close to the target location. Stopping the timer.");
        if (!isArrived) {
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
                          text: 'Bạn đã đến địa điểm cứu hộ',
                          fontSize: 18,
                        ),
                        CustomText(
                          text: 'Bạn đã thấy khách hàng chưa?',
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
                            launchDialPad(widget.techPhone); // Close the dialog
                          },
                          child: Row(
                            children: [
                              Icon(Icons.call),
                              SizedBox(width: 8),
                              Text("Gọi khách hàng"),
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

        setState(() {
          isArrived = true;
        });
      }
    }
    if (result.points.isNotEmpty) {
      setState(() {
        routeCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      });
      double totalDistance = calculateTotalDistance(result);
      print("Total Distance: $totalDistance km");
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
        await getBytesFromAsset('assets/icons/tech.png', 100);

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
      body: Stack(
        children: [
          (currentLocation != null && _targetLocation != null)
              ? GoogleMap(
                  onMapCreated: (controller) {
                    setState(() {
                      mapController = controller;
                    });
                  },
                  initialCameraPosition: CameraPosition(
                    target: currentLocation ?? LatLng(0.0, 0.0),
                    zoom: 15.0,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId("currentLocation"),
                      position: currentLocation ?? LatLng(0.0, 0.0),
                      icon: techIcon ?? BitmapDescriptor.defaultMarker,
                      infoWindow: InfoWindow(title: "Vị trí của tôi"),
                    ),
                    Marker(
                      markerId: MarkerId("targetLocation"),
                      position: _targetLocation ?? LatLng(0.0, 0.0),
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
                      color: Colors.blue,
                      width: 3,
                      points:
                          routeCoordinates, // Use routeCoordinates instead of [technicianLocation!, _targetLocation!]
                    ),
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
          DraggableScrollableSheet(
            initialChildSize: 0.28,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Column(
                              children: [
                                CustomText(
                                  text: 'Khoảng cách',
                                  fontWeight: FontWeight.bold,
                                ),
                                CustomText(
                                  text: '${_distance ?? 'Đang tính..'}',
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: VerticalDivider(
                              thickness: 1,
                            ),
                          ),
                          Container(
                            child: Column(
                              children: [
                                CustomText(
                                  text: 'Thời gian',
                                  fontWeight: FontWeight.bold,
                                ),
                                CustomText(
                                  text: '${_duration ?? 'Đang tính..'}',
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            text: 'Thông tin khách hàng',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: '${widget.cus.fullname}',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              CustomText(
                                text: '${widget.car.manufacturer}',
                                fontSize: 15,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade300),
                                    child: Text(
                                      '${widget.car.licensePlate}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: FrontendConfigs.kAuthColor),
                                    ),
                                  ),
                                  Text(
                                    ' | ${widget.model.model1 ?? ''} ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: FrontendConfigs.kAuthColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(widget.car.image ??
                                'https://firebasestorage.googleapis.com/v0/b/car-rescue-399511.appspot.com/o/profile_images%2Fcardefault.png?alt=media&token=8344e522-0e82-426f-93c9-6204a7e3a760'),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FrontendConfigs.kActiveColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: () {
                          launchDialPad(widget.cus.phone);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.phone_arrow_down_left),
                            SizedBox(width: 5),
                            Text('Gọi khách hàng'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _getFloatingActionButton(),
    );
  }

  Widget _getFloatingActionButton() {
    return SpeedDialMenuButton(
      //if needed to close the menu after clicking sub-FAB
      mainFABPosX: 1,
      mainFABPosY: 230,
      //manually open or close menu
      updateSpeedDialStatus: (isShow) {
        //return any open or close change within the widget
      },
      //general init
      isMainFABMini: false,
      mainMenuFloatingActionButton: MainMenuFloatingActionButton(
          mini: true,
          child: Icon(Icons.menu),
          onPressed: () {},
          closeMenuChild: Icon(Icons.close),
          closeMenuForegroundColor: Colors.white,
          closeMenuBackgroundColor: Colors.red),
      floatingActionButtonWidgetChildren: <FloatingActionButton>[
        FloatingActionButton(
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
            mini: true,
            onPressed: () {
              if (mapController != null && _targetLocation != null) {
                mapController!.animateCamera(
                  CameraUpdate.newLatLng(_targetLocation!),
                );
              }
            },
            tooltip: 'Show technician location',
            child: Image.asset(
              'assets/icons/location.png',
              height: 30,
              width: 30,
            )),
        FloatingActionButton(
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
