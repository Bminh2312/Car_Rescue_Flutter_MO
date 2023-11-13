// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:ui' as ui;
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/location_info.dart';
import 'package:CarRescue/src/models/vehicle_item.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';

import 'package:CarRescue/src/presentation/view/customer_view/service_details/layout/order_view.dart';
import 'package:CarRescue/src/providers/google_map_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'layout/widget/home_field.dart';

// import 'package:google_api_headers/google_api_headers.dart';
// import 'package:google_maps_webservice/places.dart';

class HomeView extends StatefulWidget {
  final String services;

  HomeView({required this.services});

  @override
  State<HomeView> createState() => HomeViewState();
}

final GlobalKey<ScaffoldMessengerState> homeScaffoldKey =
    GlobalKey<ScaffoldMessengerState>();

class HomeViewState extends State<HomeView> {
  final TextEditingController _pickUpController = TextEditingController();
  final TextEditingController _dropLocationController = TextEditingController();
  final Completer<GoogleMapController> _controller = Completer();
  // ServiceType selectedService = ServiceType.repair;
  PanelController _pc = new PanelController();
  late GoogleMapController controller;
  LocationProvider service = LocationProvider();
  StreamSubscription<Position>? _positionStreamSubscription;
  late LatLng _latLng = LatLng(0, 0);
  LatLng _latLngDrop = LatLng(0, 0);
  String formattedDistance = "0";
  Position? position;
  BitmapDescriptor? destinationIcon;
  bool _isMounted = false;
  bool isPickingPickupLocation = false;
  late Future<List<LocationInfo>> predictions;
  late Future<PlacesAutocompleteResponse> predictionsPlaces;
  bool _showPlaceDirection = false;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(10.762622, 106.660172),
    zoom: 10,
  );

  Future<void> requestLocationPermission() async {
    var res = await Geolocator.checkPermission();
    if (res != LocationPermission.always &&
        res != LocationPermission.whileInUse) {
      await Geolocator.requestPermission();
    }

    // Lấy vị trí hiện tại
    getCurrentLocation();

    // Theo dõi vị trí và cập nhật Marker
    startListeningToLocationUpdates();
  }

  Set<Marker> markers = {};
  // static const CameraPosition _kLake = CameraPosition(
  //   bearing: 192.8334901395799,
  //   target: LatLng(37.43296265331129, -122.08832357078792),
  //   tilt: 59.440717697143555,
  //   zoom: 19.151926040649414,
  // );

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future setSourceAndDestinationIcons() async {
    final Uint8List icon1 =
        await getBytesFromAsset('assets/images/driver_marker.png', 240);

    destinationIcon = BitmapDescriptor.fromBytes(icon1);
  }

  // Cập nhật Marker dựa trên vị trí hiện tại
  void updateMarker(LatLng latLng) {
    markers.clear();
    if (position != null && destinationIcon != null) {
      markers.addAll([
        Marker(
            markerId: const MarkerId('2'),
            position: latLng,
            icon: destinationIcon!),
        // Polyline(polylineId: )
      ]);
      print("Position: $position");
    }
  }

  void _updateCameraPosition(LatLng latLng) async {
    controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: latLng,
          zoom: 15.0, // Điều chỉnh mức zoom theo nhu cầu của bạn
        ),
      ),
    );
    updateMarker(latLng);
  }

  void getCurrentLocation() async {
    Position? currentPosition;
    try {
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      if (currentPosition != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          currentPosition.latitude,
          currentPosition.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks[0];
          String address =
              "${placemark.name},${placemark.street}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}";
          setState(() {
            _pickUpController.text = address;
          });
        } else {
          print("No placemark found.");
        }
      }
    } catch (e) {
      print("Lỗi khi lấy vị trí: $e");
    }
    if (currentPosition != null && _isMounted) {
      setState(() {
        position = currentPosition;
        _latLng = LatLng(position!.latitude, position!.longitude);
      });
      updateMarker(_latLng);
    }
  }

  void startListeningToLocationUpdates() {
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((event) {
      if (_isMounted) {
        if (event == true) {
          setState(() {
            position = event;
            _latLng = LatLng(position!.latitude, position!.longitude);
            updateMarker(_latLng);
          });
        }
      }
    });
  }

  void searchAndMoveCamera(String searchText) async {
    try {
      LatLng newPosition = await service.searchPlaces(searchText);
      setState(() {
        _latLng = newPosition;
      });
      _updateCameraPosition(_latLng);
    } catch (e) {
      // Xử lý lỗi ở đây
      print('Error: $e');
    }
  }

  void stopListeningToLocationUpdates() {
    _positionStreamSubscription?.cancel();
    print("Stop Listening to Location");
  }

  Future<double> calculateDistance(LatLng from, LatLng to) async {
    double distanceInMeters = await Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );

    // Kết quả sẽ là khoảng cách trong mét
    return distanceInMeters;
  }

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    predictions = Future.value([]);
    predictionsPlaces = Future.value(
        PlacesAutocompleteResponse(predictions: [], status: 'INIT'));
    requestLocationPermission();
    setSourceAndDestinationIcons();
    // Timer(
    //   const Duration(seconds: 5),
    //   () => piUpLocationBottomSheet(context),
    // );
  }

  @override
  void dispose() {
    _isMounted = false;
    _pickUpController.dispose();
    _dropLocationController.dispose();
    super.dispose();
    // Cancel sự kiện async trong dispose
    _positionStreamSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        text: 'Map Location',
        showText: true,
      ),
      key: homeScaffoldKey,
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            mapToolbarEnabled: false,
            markers: markers,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          if (position != null)
            Positioned(
              bottom: widget.services == 'Fixing' ? 270 : 400,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: FrontendConfigs.kPrimaryColor,
                mini: true,
                onPressed: () {
                  getCurrentLocation();
                  startListeningToLocationUpdates();
                  _updateCameraPosition(LatLng(
                    position!.latitude,
                    position!.longitude,
                  ));
                },
                child: Icon(Icons.my_location),
              ),
            ),
          SlidingUpPanel(
            controller: _pc,
            minHeight: widget.services == 'Fixing' ? 200 : 300,
            maxHeight: widget.services == 'Fixing' ? 250 : 400,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            panel: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    alignment: Alignment.center,
                    height: 3,
                    width: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xffE0E0E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (widget.services == "Towing" &&
                      _latLngDrop != LatLng(0, 0))
                    FutureBuilder<double>(
                      future: calculateDistance(_latLng,
                          _latLngDrop), // Thay bằng hàm lấy dữ liệu thích hợp
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          if (snapshot.hasData) {
                            double distance = snapshot.data! / 1000;
                            formattedDistance = distance.toStringAsFixed(1);
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(text: 'Khoảng cách'),
                                    CustomText(text: '${formattedDistance} Km')
                                  ],
                                ),
                                Divider(
                                  color: FrontendConfigs.kIconColor,
                                ),
                              ],
                            );
                          } else {
                            return Text('Không có dữ liệu.');
                          }
                        }
                      },
                    ),
                  const SizedBox(height: 12),
                  // Hiển thị trường đầu vào dựa trên dịch vụ được chọn
                  HomeField(
                    onTap: () {
                      setState(() {
                        isPickingPickupLocation = true;
                      });

                      if (_pc.isPanelOpen) {
                        _pc.close(); // Đóng panel nếu đã mở
                      } else {
                        _pc.open(); // Mở panel nếu đã đóng
                      }
                    },
                    svg: 'assets/svg/pickup_icon.svg',
                    hint: 'Vị trí đang đứng',
                    controller: _pickUpController,
                    inputType: TextInputType.text,
                    onTextChanged: getListPredictions,
                  ),
                  const SizedBox(height: 18),
                  if (widget.services == "Towing")
                    HomeField(
                      onTap: () {
                        setState(() {
                          isPickingPickupLocation = false;
                        });
                        if (_pc.isPanelOpen) {
                          _pc.close(); // Đóng panel nếu đã mở
                        } else {
                          _pc.open(); // Mở panel nếu đã đóng
                        }
                      },
                      svg: 'assets/svg/setting_location.svg',
                      hint: 'Vị trí muốn đến',
                      controller: _dropLocationController,
                      inputType: TextInputType.text,
                      onTextChanged: getListPredictions,
                    ),
                  FutureBuilder<PlacesAutocompleteResponse>(
                    future: predictionsPlaces,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        if (snapshot.hasData) {
                          final predictions = snapshot.data!.predictions;

                          return Expanded(
                            child: Card(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  children: [
                                    predictions.isNotEmpty
                                        ? Expanded(
                                            child: ListView.builder(
                                              itemCount: predictions.length,
                                              itemBuilder: (context, index) {
                                                final prediction =
                                                    predictions[index];
                                                return ListTile(
                                                  title: Text(
                                                      prediction.description!),
                                                  onTap: () {
                                                    if (isPickingPickupLocation) {
                                                      _pickUpController.text =
                                                          prediction
                                                              .description!;
                                                      getLatLngByPlaceDetails(
                                                          prediction.placeId!,
                                                          true);
                                                      // Di chuyển camera đến _latLng
                                                    } else {
                                                      _dropLocationController
                                                              .text =
                                                          prediction
                                                              .description!;
                                                      getLatLngByPlaceDetails(
                                                          prediction.placeId!,
                                                          false);
                                                      // Di chuyển camera đến _latLngDrop
                                                    }
                                                  },
                                                  tileColor: Colors.transparent,
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  shape: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Colors.black,
                                                      width: .5,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Container()
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Text('');
                        }
                      }
                    },
                  ),
                  if (predictionsPlaces ==
                      Future.value(PlacesAutocompleteResponse(
                          predictions: [], status: 'CLEAR')))
                    SizedBox(
                      height: 10,
                    ),
                  AppButton(
                    onPressed: () {
                      // _handlePressButton();
                      // stopListeningToLocationUpdates();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => OrderView(
                                  latLngPick: _latLng,
                                  addressPick: _pickUpController.text,
                                  serviceType: widget.services,
                                  latLngDrop: _latLngDrop,
                                  addressDrop: _dropLocationController.text,
                                  distance: formattedDistance,
                                )),
                      );
                    },
                    btnLabel: "Xác nhận địa điểm",
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> onSearchTextChanged(String query) async {
    try {
      final response = await service.getDisplayNamesByVietMap(query);
      setState(() {
        predictions =
            Future.value(response); // Gán danh sách LocationInfo vào Future
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getListPredictions(String query) async {
    try {
      final response = await service.getPlacePredictions(query);
      setState(() {
        predictionsPlaces =
            Future.value(response); // Gán danh sách LocationInfo vào Future
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void getLatLngByPlaceDetails(String placeId, bool type) async {
    try {
      final response = await service.getPlaceDetails(placeId);
      final LatLng newLatLng = LatLng(response.latitude, response.longitude);
      setState(() {
        if (type) {
          _latLng = newLatLng;
        } else {
          _latLngDrop = newLatLng;
        }
        _updateCameraPosition(newLatLng);
        clearPredictions();
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void getLatLng(String query, bool type) async {
    final response = await service.searchPlaces(query);
    if (type) {
      setState(() {
        _latLng = LatLng(response.latitude, response.longitude);
        _updateCameraPosition(_latLng);
      });
    } else {
      setState(() {
        _latLngDrop = LatLng(response.latitude, response.longitude);
        _updateCameraPosition(_latLngDrop);
      });
    }
  }

  void clearPredictions() {
    setState(() {
      predictionsPlaces = Future.value(
          PlacesAutocompleteResponse(predictions: [], status: 'CLEAR'));
    });
  }
}
