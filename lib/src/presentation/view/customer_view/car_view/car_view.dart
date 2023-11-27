import 'dart:io';

import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/car_model.dart';
import 'package:CarRescue/src/models/customer_car.dart';
import 'package:CarRescue/src/models/vehicle_item.dart';
import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:CarRescue/src/presentation/view/customer_view/car_view/widgets/add_car_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/car_view/widgets/car_card.dart';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CarListView extends StatefulWidget {
  final String userId;
  final String accountId;
  const CarListView({super.key, required this.userId, required this.accountId});
  @override
  _CarListViewState createState() => _CarListViewState();
}

enum SortingOption { byName, defaultSort }

class _CarListViewState extends State<CarListView> {
  List<CustomerCar> carData = [];
  SortingOption selectedSortingOption = SortingOption.defaultSort;
  String searchQuery = '';
  bool isLoading = true;
  bool isAscending = true;
  CarModel? carModel;
  @override
  void initState() {
    super.initState();

    fetchCustomerCar(widget.userId).then((data) {
      if (data['data'] != null) {
        final carList = (data['data'] as List<dynamic>)
            .map((carData) => CustomerCar(
                id: carData['id'],
                customerId: carData['customerId'],
                manufacturer: carData['manufacturer'],
                licensePlate: carData['licensePlate'],
                status: carData['status'],
                vinNumber: carData['vinNumber'],
                color: carData['color'],
                manufacturingYear: carData['manufacturingYear'],
                modelId: carData['modelId'],
                image: carData['image'] ??
                    'https://firebasestorage.googleapis.com/v0/b/car-rescue-399511.appspot.com/o/vehicle%2Fimages%2Fcar.png?alt=media&token=4a112258-d73c-4f2e-9f2f-bf46aa204790'))
            .toList();

        setState(() {
          carData = carList;
          isLoading = false;
        });
      } else {
        // Handle the case where 'data['data']' is null.
        // You can set a default value for carData or take other actions.
        setState(() {
          carData =
              []; // Set an empty list as a default value or choose an appropriate default.
          isLoading = false;
        });

        // Alternatively, you can display a message to the user or log the issue.
        // Example: showSnackBar('No car data available');
        // Example: log('Warning: Car data is null');
      }
    });
  }

  Future<Map<String, dynamic>> fetchCustomerCar(String userId) async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Car/GetAllOfUser?id=$userId';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  List<Vehicle> sortCarsByName(List<Vehicle> cars, bool ascending) {
    return List.from(cars)
      ..sort((a, b) {
        final comparison = a.manufacturer.compareTo(b.manufacturer);
        return ascending ? comparison : -comparison;
      });
  }

  List<Vehicle> searchCars(List<Vehicle> cars, String query) {
    query = query.toLowerCase();
    return cars.where((car) {
      final manufacturer = car.manufacturer.toLowerCase();
      final licensePlate = car.licensePlate.toLowerCase();
      return manufacturer.contains(query) || licensePlate.contains(query);
    }).toList();
  }

  Future<void> changeStatusCustomerCar(String id) async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Car/Delete?id=$id';

    final response = await http.post(Uri.parse(apiUrl));

    try {
      if (response.statusCode == 200) {
        print('Change status successfuly');
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      print('Delete not ok: $e');
      // Handle the error appropriately
    }
  }

  Future<CustomerCar> fetchUpdatedCarData(String carId) async {
    // First, change the status of the car
    // final String changeStatusUrl =
    //     'https://rescuecapstoneapi.azurewebsites.net/api/Car/Delete?id=$carId';
    // await http.get(Uri.parse(
    //     changeStatusUrl)); // Assuming this is correct for changing status

    // Then, fetch the updated car data
    final String fetchCarUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Car/Get?id=$carId'; // Replace with your actual API endpoint for fetching car data

    final response = await http.get(Uri.parse(fetchCarUrl));
    try {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        var dataField = data['data'];
        // Assuming the response data is in the format you need
        return CustomerCar.fromJson(
            dataField); // Convert the data to a CustomerCar object
      } else {
        throw Exception('Failed to load updated car data from API');
      }
    } catch (e) {
      print('Error fetching updated CarModel: $e');
      throw Exception('Error fetching updated CarModel: $e');
    }
  }

  void _handleSwipeDismiss(int index, BuildContext context) async {
    final customerId = carData[index].id;

    // Change the status of the car
    await changeStatusCustomerCar(customerId);

    // Remove the dismissed item from the list
    setState(() {
      carData.removeAt(index);
    });

    // Optionally, fetch updated car data and add it to your list
    final updatedCarData = await fetchUpdatedCarData(customerId);
    setState(() {
      carData.insert(index,
          updatedCarData); // Re-insert at the same position with updated data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Xe của tôi",
          style: TextStyle(
            color: FrontendConfigs.kPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!isLoading) // Only show the sorting option button when data is loaded
            IconButton(
              onPressed: () {
                setState(() {
                  selectedSortingOption =
                      selectedSortingOption == SortingOption.byName
                          ? SortingOption.defaultSort
                          : SortingOption.byName;
                  // Toggle the sorting order
                  isAscending = !isAscending;
                });
              },
              icon: Icon(
                Icons.sort_by_alpha,
                color: FrontendConfigs.kIconColor,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            onChanged: (query) {
              setState(() {
                searchQuery = query;
              });
            },
            decoration: InputDecoration(
              labelText: 'Tìm kiếm bằng tên hoặc biển số',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: isLoading
                  ? LoadingState()
                  : SingleChildScrollView(
                      child: Column(
                      children: carData
                          .asMap()
                          .map((index, customerCar) => MapEntry(
                                index,
                                Dismissible(
                                  key: Key(customerCar.id),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (direction) async {
                                    if (customerCar.status.toLowerCase() ==
                                        'active') {
                                      return await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Xác nhận'),
                                            content: Text(
                                                'Bạn có chắc chắn muốn đổi trạng thái của xe này không?'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('Hủy bỏ'),
                                                onPressed: () {
                                                  Navigator.of(context).pop(
                                                      false); // Dismiss the dialog and don't dismiss the item
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Xác nhận'),
                                                onPressed: () {
                                                  Navigator.of(context).pop(
                                                      true); // Dismiss the dialog and proceed with item dismissal
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                    return false; // Don't allow dismissal if the status is not 'inactive'
                                  },
                                  onDismissed: (direction) {
                                    _handleSwipeDismiss(index, context);
                                  },
                                  background: Container(
                                    color: Colors.red,
                                    child: Align(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Icon(Icons.delete,
                                              color: Colors.white),
                                          Text('Đổi trạng thái',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          SizedBox(width: 20),
                                        ],
                                      ),
                                      alignment: Alignment.centerRight,
                                    ),
                                  ),
                                  child: GestureDetector(
                                    child: CarCard(
                                      accountId: widget.accountId,
                                      customerCar: customerCar,
                                      userId: widget.userId,
                                    ),
                                  ),
                                ),
                              ))
                          .values
                          .toList(),
                    )))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddCarScreen(
                      userId: widget.userId,
                    )),
          ).then((value) => _handleRefresh());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _handleRefresh() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await fetchCustomerCar(widget.userId);
      final carList = (data['data'] as List<dynamic>)
          .map((carData) => CustomerCar(
              id: carData['id'],
              customerId: carData['customerId'],
              manufacturer: carData['manufacturer'],
              licensePlate: carData['licensePlate'],
              status: carData['status'],
              vinNumber: carData['vinNumber'],
              // type: carData['type'],
              color: carData['color'],
              manufacturingYear: carData['manufacturingYear'],
              modelId: carData['modelId'],
              // carRegistrationFont: carData['carRegistrationFont'],
              // carRegistrationBack: carData['carRegistrationBack'],
              image: carData['image'] ?? ''))
          .toList();

      setState(() {
        carData = carList;
        isLoading = false;
      });
    } catch (e) {
      print("Error during refresh: $e");
      // Optionally show a message to the user
    }
  }
}
