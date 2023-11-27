import 'dart:convert';

import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/models/customer_car.dart';
import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'widgets/select_car.dart';

class SelectCarBody extends StatefulWidget {
  const SelectCarBody({Key? key, required this.onCarSelected})
      : super(key: key);
  final Function(String) onCarSelected;

  @override
  State<SelectCarBody> createState() => _SelectCarBodyState();
}

class _SelectCarBodyState extends State<SelectCarBody> {
  List<CustomerCar> carData = [];
  bool isLoading = true;
  String selectedCarId = "";
  Customer customer = Customer.fromJson(GetStorage().read('customer') ?? {});

  @override
  void initState() {
    super.initState();
    fetchCustomerCar(customer.id).then((data) {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              const SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: 'Hãy chọn xe của bạn mà bạn muốn cứu.',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
              const SizedBox(
                height: 14,
              ),
              carData.isEmpty ? 
              Center(
                child: Text("Không có xe nào..."),
              )
              :
              isLoading
                  ? CircularProgressIndicator() // Show loading indicator while data is being fetched
                  : Column(
                      children: carData.map((car) {
                        return SelectCarWidget(
                          licensePlate: car.licensePlate ,
                          img: car.image!,
                          name: car.manufacturer,
                          onSelect: () {
                            setState(() {
                              selectedCarId = car.id; // Use car.id or choose an appropriate field
                            });
                            widget.onCarSelected(selectedCarId);
                          },
                        );
                      }).toList(),
                    ),
              
            ],
          ),
        ),
      ),
    );
  }
}
