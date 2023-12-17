import 'dart:io';

import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/vehicle_item.dart';
import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/car_view/widgets/add_car_view.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/car_view/widgets/car_card.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/homepage/homepage_view.dart';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
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

enum SortingOption { byName, byStatus, defaultSort }

class _CarListViewState extends State<CarListView> {
  List<Vehicle> carData = [];
  SortingOption selectedSortingOption = SortingOption.defaultSort;
  String selectedStatus = 'ACTIVE'; // default selected status
  String searchQuery = '';
  bool isLoading = true;
  bool isAscending = true;
  final TextEditingController _controller = TextEditingController();
  String? accessToken = GetStorage().read<String>("accessToken");
  PopupMenuItem<String> buildItem(String value) {
    String displayText = value;

    // Check and customize the display text based on different values
    switch (value) {
      case "ACTIVE":
        displayText = "Hoạt động";
        break;
      case "WAITING_APPROVAL":
        displayText = "Chờ duyệt";
        break;
      case "ASSIGNED":
        displayText = "Đã phân công";
        break;
      case "REJECTED":
        displayText = "Từ chối";
        break;
      // Add more cases as needed

      // Default case (if none of the specific cases match)
      default:
        break;
    }

    return PopupMenuItem(
      value: value,
      child: Text(displayText),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCarOwnerCar(widget.userId).then((data) {
      try {
        if (data['data'] is List<dynamic>) {
          final carList = (data['data'] as List<dynamic>)
              .map((carData) => Vehicle(
                    id: carData['id'],
                    manufacturer: carData['manufacturer'],
                    licensePlate: carData['licensePlate'],
                    status: carData['status'],
                    vinNumber: carData['vinNumber'],
                    type: carData['type'],
                    color: carData['color'],
                    manufacturingYear: carData['manufacturingYear'],
                    carRegistrationFont: carData['carRegistrationFont'],
                    carRegistrationBack: carData['carRegistrationBack'],
                    image: carData['image'],
                  ))
              .toList();

          // Sort the list to prioritize vehicles with status 'ACTIVE', 'ASSIGNED', and then 'WAITING_APPROVAL'
          carList.sort((a, b) {
            const statusPriority = {
              'WAITING_APPROVAL': 1,
              'ACTIVE': 2,
              'ASSIGNED': 3
              // other statuses implicitly have lower priority
            };

            int priorityA = statusPriority[a.status] ?? 4;
            int priorityB = statusPriority[b.status] ?? 4;

            return priorityA.compareTo(priorityB);
          });

          setState(() {
            carData = carList;
            isLoading = false;
          });
        } else {
          // Handle the case when data['data'] is null or not a List<dynamic>
          // You may want to set a default value for carData or show an error message
          // depending on your application logic.
          setState(() {
            carData =
                []; // Set a default value or handle it according to your requirements.
            isLoading = false;
          });
        }
      } catch (e) {
        // Handle exceptions that might occur during data processing
        print('Error processing car owner data: $e');
        setState(() {
          carData =
              []; // Set a default value or handle it according to your requirements.
          isLoading = false;
        });
      }
    });
  }

  List<Vehicle> sortCarsByStatus(List<Vehicle> cars, String status) {
    return cars.where((car) => car.status == status).toList();
  }

  Future<Map<String, dynamic>> fetchCarOwnerCar(String userId) async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Vehicle/GetAllOfUser?id=$userId';

    final response =
        await http.get(Uri.parse(apiUrl), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken'
    });

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

  List<PopupMenuItem<String>> get statusMenuItems => [
        buildItem('ACTIVE'),
        buildItem('ASSIGNED'),
        buildItem('WAITING_APPROVAL'),
        buildItem('REJECTED'),
      ];

  @override
  Widget build(BuildContext context) {
    List<Vehicle> filteredCars = searchCars(carData, searchQuery);
    print(filteredCars);
    // Apply sorting when the user selects "Sort by Name"
    if (selectedSortingOption == SortingOption.byName) {
      filteredCars = sortCarsByName(filteredCars, isAscending);
    }
    if (selectedSortingOption == SortingOption.byStatus) {
      filteredCars = sortCarsByStatus(filteredCars, selectedStatus);
    }

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
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BottomNavBarCarView(
                      userId: widget.userId, accountId: widget.accountId),
                ));
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
          PopupMenuButton<String>(
            onSelected: (String newValue) {
              setState(() {
                selectedStatus = newValue;
                selectedSortingOption = SortingOption.byStatus;
              });
            },
            itemBuilder: (BuildContext context) => statusMenuItems,
            icon: Icon(Icons.more_vert,
                color: FrontendConfigs
                    .kIconColor), // Change to your preferred icon
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), // Slightly more rounded
                border: Border.all(
                  color:
                      const Color.fromARGB(255, 154, 180, 225), // Changed color
                  width: 1,
                ),
                color: Colors.white, // Added background color
              ),
              child: TextField(
                controller: _controller,
                onChanged: (query) {
                  setState(() {
                    searchQuery = query;
                  });
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tìm kiếm tên hoặc biển số',

                  prefixIcon: Icon(Icons.search), // Added search icon
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _controller.clear();
                              searchQuery = '';
                            });
                          },
                        )
                      : null,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: isLoading
                  ? LoadingState()
                  : filteredCars.isNotEmpty
                      ? SingleChildScrollView(
                          child: Column(
                            children: filteredCars
                                .map((vehicle) => CarCard(
                                      vehicle: vehicle,
                                      userId: widget.userId,
                                      accountId: widget.accountId,
                                    ))
                                .toList(),
                          ),
                        )
                      : Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.car_crash, size: 60),
                            Text(
                              'Danh sách xe đang trống.',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        )), // Show this when filteredCars is empty
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        foregroundColor: FrontendConfigs.kActiveColor,
        elevation: 1,
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddCarScreen(
                      userId: widget.userId,
                    )),
          );
          if (result != null && result) {
            _handleRefresh();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    try {
      final data = await fetchCarOwnerCar(widget.userId);
      final carList = (data['data'] as List<dynamic>)
          .map((carData) => Vehicle(
              id: carData['id'],
              manufacturer: carData['manufacturer'],
              licensePlate: carData['licensePlate'],
              status: carData['status'],
              vinNumber: carData['vinNumber'],
              type: carData['type'],
              color: carData['color'],
              manufacturingYear: carData['manufacturingYear'],
              carRegistrationFont: carData['carRegistrationFont'],
              carRegistrationBack: carData['carRegistrationBack'],
              image: carData['image']

              //... your properties mapping
              ))
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
