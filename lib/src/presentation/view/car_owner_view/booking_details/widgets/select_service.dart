import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/booking_details/widgets/service_card.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/booking_details/booking_details_view.dart';
import 'package:CarRescue/src/providers/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:CarRescue/src/models/service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

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
  final String orderId;
  final int quantity;
  ServiceSelectionScreen(
      {required this.selectedServices,
      required this.booking,
      required this.addressesDepart,
      required this.subAddressesDepart,
      required this.addressesDesti,
      required this.subAddressesDesti,
      required this.userId,
      required this.accountId,
      required this.orderId,
      required this.quantity});
  @override
  _ServiceSelectionScreenState createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  @override
  void initState() {
    super.initState();
    availableServices = loadService();
    fetchServiceData(widget.booking.id);
  }

  String? selectedServices;
  List<Map<String, dynamic>> orderDetails = [];
  bool _isLoading = true;
  Future<List<Service>>? availableServices; 
  
  
  // Replace with your actual method
  Future<List<Service>> loadService() async {
    final serviceProvider = ServiceProvider();
    try {
      return serviceProvider.getAllServicesTowing();
    } catch (e) {
      // Xử lý lỗi khi tải dịch vụ
      print('Lỗi khi tải danh sách dịch vụ: $e');
      return [];
    }
  }

  // void updateSelectedServices(Service service, bool isSelected) {
  //   setState(() {
  //     if (isSelected) {
  //       selectedServices.add(service);
  //     } else {
  //       selectedServices.remove(service);
  //     }
  //   });
  // }
  Future<void> deleteServiceInOrder(String id) async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Order/DeleteOrderDetail?id=$id';

    final response =
        await http.put(Uri.parse(apiUrl), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      // 'Authorization': 'Bearer $accessToken'
    });
    print(response.statusCode);
    try {
      if (response.statusCode == 201) {
        print('Change status successfuly');
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      print('Delete not ok: $e');
      // Handle the error appropriately
    }
  }

  Future<void> _updateService(
      String orderDetailId, int quantity, String service) async {
    setState(() {
      _isLoading = true;
    });
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Order/ManagerUpdateService"; // Replace with your endpoint URL

    final response = await http.post(Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // 'Authorization': 'Bearer $accessToken'
        },
        body: json.encode({
          'orderDetailId': orderDetailId,
          'quantity': quantity,
          'service': service
        }));
    final Map<String, dynamic> requestBody = {
      'orderDetailId': orderDetailId,
      'quantity': quantity,
      'service': service
    };
    print('bzzb: $requestBody');
    if (response.statusCode == 200) {
      print('Successfully update the service ${response.body}');
      setState(() {
        _isLoading = false;
      });
      // onLoadingComplete();
    } else {
      print('Failed to update the service: ${response.body}');
    }
  }

  Future<void> addServices(String orderId, String service, int quantity) async {
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Order/ManagerAddService";

    // final List<Map<String, dynamic>> serviceData = services
    //     .map((service) => {
    //           'orderId': orderId,
    //           'quantity': service.quantity,
    //           'service': service.name,
    //         })
    //     .toList();
    // print('abbb: $serviceData');

    // bool anyServiceAlreadyExists = false;

    // for (var service in serviceData) {
    //   // Fetch details for each service ID
    //   for (Map<String, dynamic> orderDetail in orderDetails) {
    //     Map<String, dynamic> serviceDetails =
    //         await fetchServiceNameAndQuantity(orderDetail['serviceId']);

    //     // Compare the fetched service details with the current service
    //     bool alreadyExists = serviceDetails['name'] == service['service'];

    //     if (alreadyExists) {
    //       print('Service ${service['service']} already exists. Skipping...');
    //       print('Details of existing service: $serviceDetails');
    //       showToast(
    //           'Service ${service['service']} already exists. Skipping...');
    //       anyServiceAlreadyExists = true;
    //       break; // Exit the inner loop when a duplicate is found
    //     }
    //   }

    //   if (anyServiceAlreadyExists) {
    //     // If at least one service is already present, skip adding all services
    //     print(
    //         'Skipping the entire process. At least one service already exists.');
    //     return;
    //   }
    // }

    // If we reach here, it means none of the services in orderDetails is a duplicate
    // Add all services as usual
    // for (var service in serviceData) {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(
          {'orderId': orderId, 'quantity': quantity, 'service': service}),
    );
    final Map<String, dynamic> requestBody = {
      'orderId': orderId,
      'quantity': quantity,
      'service': service
    };

    print(json.encode(
        {'orderId': orderId, 'quantity': quantity, 'service': service}));
    if (response.statusCode == 201) {
      print('Successfully add the service: ${response.body}');
    } else {
      print('Failed to add the service: ${response.body}');
      showToast('Failed to add the service. Please try again.');
      return; // Stop the process on error
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

    final response = await http.get(Uri.parse(apiUrl));

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

      final response = await http.get(Uri.parse(apiUrl));
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
                      return ServiceCard(
                        service: service,
                        onSelected: () {
                          setState(() {
                            selectedServices = service.name;
                          });
                        },
                        isSelected: selectedServices == service.name,
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
                      _updateService(
                        widget.orderId,
                        widget.quantity,
                        selectedServices!,
                      );
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
                      // _updateService(widget.orderId, widget.quantity,
                      //     selectedServices!.name);
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
// class ServiceCard extends StatelessWidget {
//   final Service service;
//   final bool isSelected;
//   final ValueChanged<bool> onSelected;

//   ServiceCard({required this.service, required this.isSelected, required this.onSelected});

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(service.name),
//       // Add other widget details as needed
//       onTap: () {
//         onSelected(!isSelected); // Invert the selection status
//       },
//     );
//   }
// }
class ServiceCard extends StatelessWidget {
  final Service service;
  final bool isSelected;
  final VoidCallback onSelected;

  const ServiceCard({
    Key? key,
    required this.service,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0₫', 'vi_VN');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color:
            isSelected ? FrontendConfigs.kPrimaryColorCustomer : Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(64, 158, 158, 158).withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          service.name,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          currencyFormat.format(service.price),
          style: TextStyle(
            color: FrontendConfigs.kAuthColor,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        tileColor:
            isSelected ? FrontendConfigs.kActiveColor : Colors.transparent,
        selectedTileColor: FrontendConfigs.kActiveColor,
        onTap: onSelected,
      ),
    );
  }
}
