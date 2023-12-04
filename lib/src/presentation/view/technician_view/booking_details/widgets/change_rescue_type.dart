import 'dart:developer';

import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/configuration/show_toast_notify.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/models/incident.dart';
import 'package:CarRescue/src/models/location_info.dart';
import 'package:CarRescue/src/models/service.dart';
import 'package:CarRescue/src/models/symptom.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/booking_status.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_details/widgets/order_completed.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_list/widgets/selection_location_widget.dart';
import 'package:CarRescue/src/providers/google_map_provider.dart';
import 'package:CarRescue/src/providers/incident_provider.dart';
import 'package:CarRescue/src/providers/order_provider.dart';
import 'package:CarRescue/src/providers/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'symptom_selector.dart';

class ChangeRescueScreen extends StatefulWidget {
  final Booking booking;
  final Map<String, String> addressesDepart;
  final Map<String, String> subAddressesDepart;
  final Map<String, String> addressesDesti;
  final Map<String, String> subAddressesDesti;
  final String userId;
  final String accountId;
  final String paymentMethod;

  // final String departure;
  // final String incidentId;
  // final String paymentMethod;
  // final String rescueType;
  // final String orderId;
  const ChangeRescueScreen(
      {Key? key,
      required this.booking,
      required this.addressesDepart,
      required this.subAddressesDepart,
      required this.addressesDesti,
      required this.subAddressesDesti,
      required this.userId,
      required this.accountId,
      required this.paymentMethod})
      : super(key: key);

  @override
  State<ChangeRescueScreen> createState() => _ChangeRescueScreenState();
}

class _ChangeRescueScreenState extends State<ChangeRescueScreen> {
  String _searchText = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dropLocationController = TextEditingController();
  Symptom? symptom;
  NotifyMessage notifyMessage = NotifyMessage();
  bool isPickingPickupLocation = false;
  LocationProvider service = LocationProvider();
  late Future<List<LocationInfo>> predictions;
  late Future<PlacesAutocompleteResponse> predictionsPlaces;
  late LatLng _latLng = LatLng(0, 0);
  LatLng _latLngDrop = LatLng(0, 0);
  Set<Polyline> polylines = {};
  List<LatLng> routesLatLng = [];
  final ServiceProvider _serviceProvider = ServiceProvider();
  final OrderProvider _orderProvider = OrderProvider();
  Service? selectedService;
  int _distance = 0;

  void getLatLngByPlaceDetails(String placeId) async {
    try {
      final response = await service.getPlaceDetails(placeId);
      final LatLng newLatLng = LatLng(response.latitude, response.longitude);
      setState(() {
        _latLngDrop = newLatLng;

        if (_latLng != LatLng(0, 0) && _latLngDrop != LatLng(0, 0)) {
          updatePolyline();
        }
        clearPredictions();
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void clearPredictions() {
    setState(() {
      predictionsPlaces = Future.value(
          PlacesAutocompleteResponse(predictions: [], status: 'CLEAR'));
    });
  }

  void updatePolyline() async {
    polylines.clear();
    await fetchPolyline();
    if (_latLng != LatLng(0, 0) && _latLngDrop != LatLng(0, 0)) {
      Polyline polyline = Polyline(
        polylineId: PolylineId("route"),
        color: Colors.blue,
        points: routesLatLng, // Add your polyline points here
        width: 5,
      );

      setState(() {
        polylines.add(polyline);
      });
    }
  }

  void _updateLatLng() {
    // Chuỗi tọa độ
    final String departure = widget.booking.departure;

    // Chuyển đổi chuỗi thành đối tượng LatLng
    LatLng parsedLatLng = parseLatLng(departure);

    // Sử dụng setState để cập nhật giá trị _latLng
    setState(() {
      _latLng = parsedLatLng;
    });
  }

  LatLng parseLatLng(String latLngString) {
    latLngString =
        latLngString.replaceAll('lat: ', '').replaceAll('long: ', '');

    List<String> values = latLngString.split(', ');

    double lat = double.parse(values[0]);
    double lng = double.parse(values[1]);

    LatLng latLng = LatLng(lat, lng);

    return latLng;
  }

  Future<void> fetchPolyline() async {
    final locationProvider = LocationProvider();
    try {
      final routes = await locationProvider.fetchRoutes(_latLng, _latLngDrop);
      String encodedPolyline = routes.routes[0].polyline.encodedPolyline;
      int distance = routes.routes[0].distanceMeters;
      setState(() {
        routesLatLng = decodePolyline(encodedPolyline);
        _distance = (distance / 1000).toDouble().round();
        print(_distance);
      });
    } catch (e) {
      print(e);
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    var polylinePoints = PolylinePoints();
    List<PointLatLng> result = polylinePoints.decodePolyline(encoded);
    return result.map((PointLatLng point) {
      return LatLng(point.latitude, point.longitude);
    }).toList();
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

  Future<void> _handleApiCall() async {
    // Call the createIncident method from IncidentProvider

    final result = await _orderProvider.changeRescueType(
        widget.booking.indicentId!,
        widget.booking.id,
        symptom!.id,
        selectedService!.id,
        widget.booking.departure,
        "lat: ${_latLngDrop.latitude}, long: ${_latLngDrop.longitude}",
        widget.paymentMethod,
        "Towing",
        _distance
        // Add other parameters as needed
        );

    // Check the result and handle accordingly
    if (result == 200) {
      // Successful API call
      print('Đổi thành công');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OrderProcessingScreen(),
        ),
        (route) => false, // Loại bỏ tất cả các màn hình khỏi ngăn xếp
      );
      notifyMessage.showToast("Đổi đơn thành công");
    } else if (result == 201) {
      print('Hết xe');
      notifyMessage.showToast("Hết xe");
      // Handle errors or other status codes
    } else {
      print('API call failed with status code: $result');
    }
  }

  Future<List<Service>> getTowingServices() async {
    try {
      final List<Service> towingServices =
          await _serviceProvider.getAllServicesTowing();
      if (towingServices.isNotEmpty) {
        return towingServices;
      }
      return [];
    } catch (e) {
      print('Error loading towing services: $e');
      return [];
    }
  }

  Future<void> loadTowingServices() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Chọn dịch vụ kéo xe',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    FutureBuilder(
                      future: getTowingServices(),
                      builder: (context, servicesSnapshot) {
                        if (servicesSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (servicesSnapshot.hasError) {
                          return Text('Error: ${servicesSnapshot.error}');
                        } else {
                          final services = servicesSnapshot.data ?? [];
                          return Column(
                            children: services.map((service) {
                              bool isSelected =
                                  selectedService?.id == service.id;
                              return GestureDetector(
                                onTap: () {
                                  updateSelectedService(service);
                                  setState(() {
                                    isSelected =
                                        selectedService?.id == service.id;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.all(8.0),
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? FrontendConfigs
                                              .kPrimaryColorCustomer
                                          : Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: isSelected
                                        ? FrontendConfigs.kPrimaryColorCustomer
                                        : Colors.white,
                                  ),
                                  width: double.infinity,
                                  child: Text(
                                    service.name,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    // Handle the selected service (selectedService)
                    // Call the changeRescueType function here
                    if (selectedService != null) {
                      // Do something with the selected service
                      print('Selected Service: ${selectedService!.name}');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FrontendConfigs.kAuthColorCustomer
                  ),
                  child: Text('Xác nhận'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void updateSelectedService(Service service) {
    setState(() {
      selectedService = service;
    });
  }

  Widget _buildInfoRow(String title, Widget value) {
    return ListTile(
      title: Text(title),
      subtitle: value,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: CustomText(
          text: title,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _updateLatLng();
    predictionsPlaces = Future.value(
        PlacesAutocompleteResponse(predictions: [], status: 'INIT'));
    print(widget.booking.indicentId!);
    print(widget.booking.id);
    print(widget.booking.departure);
    print(widget.paymentMethod);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar:
          customAppBar(context, text: 'Thông tin chuyển đơn', showText: true),
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      child: Center(
                        child: Column(
                          children: [
                            CustomText(
                              text: "Mã đơn hàng",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            CustomText(
                              text: " ${widget.booking.id}",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: 10,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    CustomText(
                      text: "Nhập điểm đến",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    TextFormField(
                      onChanged: (text) {
                        getListPredictions(text);
                      },
                      decoration: InputDecoration(
                        labelText: 'Tìm kiếm',
                        hintText: 'Tìm kiếm điểm đến...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      controller:
                          _dropLocationController, // Assign the controller for validation
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập địa chỉ'; // Provide an error message for empty input
                        }
                        // Add more validation as needed
                        return null; // Return null if the input is valid
                      },
                    ),
                    FutureBuilder<PlacesAutocompleteResponse>(
                      future: predictionsPlaces,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          if (snapshot.hasData) {
                            final predictions = snapshot.data!.predictions;
                            if (predictions.isNotEmpty) {
                              return Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Column(
                                      children: [
                                        predictions.isNotEmpty
                                            ? Expanded(
                                                child: ListView.builder(
                                                  itemCount: predictions.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final prediction =
                                                        predictions[index];
                                                    return ListTile(
                                                      title: Text(prediction
                                                          .description!),
                                                      onTap: () {
                                                        _dropLocationController
                                                                .text =
                                                            prediction
                                                                .description!;
                                                        getLatLngByPlaceDetails(
                                                            prediction
                                                                .placeId!);
                                                        // Di chuyển camera đến _latLngDrop
                                                      },
                                                      tileColor:
                                                          Colors.transparent,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      shape:
                                                          UnderlineInputBorder(
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
                              return SizedBox(
                                height: 10,
                              );
                            }
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
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionTitle('Đơn hàng'),
                              Flexible(
                                child: BookingStatus(
                                  status: widget.booking.status,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: RideSelectionWidget(
                              icon: 'assets/svg/pickup_icon.svg',
                              title:
                                  widget.addressesDepart[widget.booking.id] ??
                                      '', // Use addresses parameter
                              body: widget
                                      .subAddressesDepart[widget.booking.id] ??
                                  '',
                              onPressed: () {},
                            ),
                          ),
                          _buildInfoRow(
                            "Loại dịch vụ",
                            Text(
                              "Sửa chữa tại chỗ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: FrontendConfigs.kAuthColor,
                              ),
                            ),
                          ),
                          _buildInfoRow(
                              "Ghi chú của khách hàng",
                              Text(widget.booking.customerNote,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: FrontendConfigs.kAuthColor,
                                      fontSize: 15))),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Vấn đề chuyển đơn:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Expanded(
                      child: SymptomSelector(
                        onSymptomSelected: (selectedSymptom) {
                          // Handle the selected symptom
                          setState(() {
                            symptom = selectedSymptom;
                          });
                          print(
                              'Selected Symptom: ${selectedSymptom?.symptom1}');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: selectedService != null
                  ? Text(
                      'Dịch vụ: ${selectedService!.name}',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Container(),
            ),
            if (selectedService != null)
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    selectedService = null;
                  });
                },
              ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            await loadTowingServices();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(),
                  ],
                ),
                buildServiceList(context, "Loại dịch vụ", Icon(Icons.add)),
              ],
            ),
          ),
        ),
        AppButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              // Form is valid, submit the form
              // Add your submission logic here
              if (symptom != null) {
                if (selectedService != null) {
                  await _handleApiCall();
                } else {
                  notifyMessage.showToast("Hãy chọn dịch vụ");
                }
              } else {
                notifyMessage.showToast("Hãy chọn vấn đề.");
              }
            }
          },
          btnLabel: "Xác nhận",
        ),
      ]),
    );
  }

  Widget buildServiceList(BuildContext context, String content, Icon icon) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon, // Biểu tượng dấu '+'
              SizedBox(width: 8.0), // Khoảng cách giữa biểu tượng và văn bản
              Text(
                content, // Văn bản bên cạnh biểu tượng
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Kích thước văn bản
                ),
              ),
            ],
          )
        ],
      ),
      Text(
        "Khoảng cách: ${_distance} km", // Văn bản bên cạnh biểu tượng
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16, // Kích thước văn bản
        ),
      ),
    ]);
  }
}
