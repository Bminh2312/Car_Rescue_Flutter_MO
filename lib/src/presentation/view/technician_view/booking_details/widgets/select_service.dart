import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_details/booking_details_view.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_details/widgets/select_service_card.dart';
import 'package:CarRescue/src/providers/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:CarRescue/src/models/service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

extension IterableExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}

class ServiceSelectionScreen extends StatefulWidget {
  final List<Service> selectedServices;
  final Booking booking;
  final String userId;
  final String accountId;
  final Map<String, String> addressesDepart;
  final Map<String, String> subAddressesDepart;
  final Map<String, String> addressesDesti;
  final Map<String, String> subAddressesDesti;

  ServiceSelectionScreen(
      {required this.selectedServices,
      required this.booking,
      required this.addressesDepart,
      required this.subAddressesDepart,
      required this.addressesDesti,
      required this.subAddressesDesti,
      required this.userId,
      required this.accountId});
  @override
  _ServiceSelectionScreenState createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  String? accessToken = GetStorage().read<String>("accessToken");
  @override
  void initState() {
    super.initState();
    availableServices = loadService();
    fetchServiceData(widget.booking.id);
  }

  List<Service> selectedServices = [];
  List<Map<String, dynamic>> orderDetails = [];
  bool _isLoading = true;
  Future<List<Service>>? availableServices; // Replace with your actual method
  Future<List<Service>> loadService() async {
    final serviceProvider = ServiceProvider();
    try {
      return serviceProvider.getAllServicesFixing();
    } catch (e) {
      // Xử lý lỗi khi tải dịch vụ
      print('Lỗi khi tải danh sách dịch vụ: $e');
      return [];
    }
  }

  void updateSelectedServices(Service service, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedServices.add(service);
      } else {
        selectedServices.remove(service);
      }
    });
  }

  Future<void> _addServices(String orderId, List<Service> services) async {
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Order/ManagerAddService";

    final List<Map<String, dynamic>> serviceData = services
        .map((service) => {
              'orderId': orderId,
              'quantity': service.quantity,
              'service': service.name,
            })
        .toList();
    print('abbb: $serviceData');

    bool anyServiceAlreadyExists = false;

    for (var service in serviceData) {
      // Fetch details for each service ID
      for (Map<String, dynamic> orderDetail in orderDetails) {
        Map<String, dynamic> serviceDetails =
            await fetchServiceNameAndQuantity(orderDetail['serviceId']);

        // Compare the fetched service details with the current service
        bool alreadyExists = serviceDetails['name'] == service['service'];

        if (alreadyExists) {
          print('Service ${service['service']} already exists. Skipping...');
          print('Details of existing service: $serviceDetails');
          showToast(
              'Service ${service['service']} already exists. Skipping...');
          anyServiceAlreadyExists = true;
          break; // Exit the inner loop when a duplicate is found
        }
      }

      if (anyServiceAlreadyExists) {
        // If at least one service is already present, skip adding all services
        print(
            'Skipping the entire process. At least one service already exists.');
        return;
      }
    }

    // If we reach here, it means none of the services in orderDetails is a duplicate
    // Add all services as usual
    for (var service in serviceData) {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        },
        body: json.encode(service),
      );

      if (response.statusCode == 201) {
        print('Successfully add the service: ${response.body}');
      } else {
        print('Failed to add the service: ${response.body}');
        showToast('Failed to add the service. Please try again.');
        return; // Stop the process on error
      }
    }

    // Only navigate to the new screen when all services are successfully added
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailsView(
          userId: widget.userId,
          accountId: widget.accountId,
          selectedServices: selectedServices,
          booking: widget.booking,
          addressesDepart: widget.addressesDepart,
          subAddressesDepart: widget.subAddressesDepart,
          addressesDesti: widget.addressesDesti,
          subAddressesDesti: widget.subAddressesDesti,
        ),
      ),
    );

    setState(() {
      _isLoading = false;
    });
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> fetchServiceData(String orderId) async {
    final apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/OrderDetail/GetDetailsOfOrder?id=$orderId';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('data') && responseData['data'] is List) {
        setState(() {
          orderDetails = List<Map<String, dynamic>>.from(responseData['data']);
          print('acaa : $orderDetails');
        });

        // Get all service IDs

        final List<String> serviceIds =
            orderDetails.map((order) => order['serviceId'].toString()).toList();

        // Fetch details for each service ID
        for (String serviceId in serviceIds) {
          await fetchServiceNameAndQuantity(serviceId);
        }
      } else {
        throw Exception('API response does not contain a valid list of data.');
      }
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<Map<String, dynamic>> fetchServiceNameAndQuantity(
      String serviceId) async {
    try {
      final apiUrl =
          'https://rescuecapstoneapi.azurewebsites.net/api/Service/Get?id=$serviceId';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("accc : $response.body");
        final Map<String, dynamic> responseData = data['data'];

        final String name = responseData['name'] ?? '';
        final int price = responseData['price'] ?? 0;

        // Using null-aware operators to handle null values
        final int quantity = orderDetails.firstWhereOrNull(
              (order) => order['serviceId'] == serviceId,
            )?['quantity'] ??
            0;

        print('Service Name: $name, Quantity: $quantity, Price: $price');
        return {'name': name, 'quantity': quantity, 'price': price};
      }

      throw Exception('Failed to load service name and quantity from API');
    } catch (error) {
      print('Error in fetchServiceNameAndQuantity: $error');
      // You might want to log or handle the error in a way that suits your application
      throw Exception(
          'Failed to load service name and quantity from API: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, text: 'Chọn dịch vụ', showText: true),
      body: buildServiceSelection(context),
    );
  }

  Widget buildServiceSelection(BuildContext context) {
    return Container(
      height: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Service>>(
              future: availableServices,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Không có dữ liệu.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final service = snapshot.data![index];
                      final isSelected = selectedServices.contains(service);
                      return ServiceCard(
                        service: service,
                        onSelected: (isSelected) {
                          updateSelectedServices(service, isSelected);
                          if (isSelected) {
                            print('Selected service: ${service.name}');
                          } else {
                            print('Deselected service: ${service.name}');
                          }
                        },
                        isSelected: isSelected,
                      );
                    },
                  );
                }
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 10),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    child: Text(
                      'Tiếp tục',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FrontendConfigs
                          .kActiveColor, // Replace with your desired color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      _addServices(widget.booking.id, selectedServices);
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => BookingDetailsView(
                      //       selectedServices: selectedServices,
                      //       booking: widget.booking,
                      //       addressesDepart: widget.addressesDepart,
                      //       subAddressesDepart: widget.subAddressesDepart,
                      //       addressesDesti: widget.addressesDesti,
                      //       subAddressesDesti: widget.subAddressesDesti,
                      //     ),
                      //   ),
                      // );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
