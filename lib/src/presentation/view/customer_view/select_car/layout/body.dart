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
  final Function(String?) onCarSelected;

  @override
  State<SelectCarBody> createState() => _SelectCarBodyState();
}

class _SelectCarBodyState extends State<SelectCarBody> {
  List<CustomerCar> carData = [];
  bool isLoading = true;
  String? selectedCarId;
  Customer customer = Customer.fromJson(GetStorage().read('customer') ?? {});

  @override
  void initState() {
    super.initState();
    fetchCustomerCar(customer.id).then((data) {
      if (data['data'] != null) {
        final carList = (data['data'] as List<dynamic>)
            .where((carData) => carData['status'] == 'ACTIVE')
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
        setState(() {
          carData = [];
          isLoading = false;
        });
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
              carData.isEmpty
                  ? Center(
                      child: Text("Không có xe nào đang hoạt động"),
                    )
                  : isLoading
                      ? CircularProgressIndicator()
                      : Column(
                          children: carData.map((car) {
                            return SelectCarWidget(
                              licensePlate: car.licensePlate,
                              img: car.image!,
                              name: car.manufacturer,
                              isSelected: selectedCarId == car.id,
                              onSelect: (isSelected) {
                                setState(() {
                                  selectedCarId =
                                      selectedCarId == car.id ? null : car.id;
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
