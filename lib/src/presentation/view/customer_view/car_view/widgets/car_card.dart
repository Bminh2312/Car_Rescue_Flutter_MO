import 'dart:convert';

import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/car_model.dart';
import 'package:CarRescue/src/models/customer_car.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/car_view/widgets/car_status.dart';
import 'package:CarRescue/src/presentation/view/customer_view/car_view/widgets/update_car_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class CarCard extends StatefulWidget {
  final CustomerCar customerCar;
  final String userId;
  final String accountId;
  CarCard(
      {required this.customerCar,
      required this.userId,
      required this.accountId});

  @override
  State<CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<CarCard> {
  CarModel? carModel;
  String? accessToken = GetStorage().read<String>("accessToken");
  @override
  void initState() {
    super.initState();
    fetchCarModel(widget.customerCar.modelId ?? "");
  }

  Future<void> fetchCarModel(String modelId) async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Model/Get?id=$modelId';

    final response =
        await http.get(Uri.parse(apiUrl), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken'
    });
    try {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        var dataField = data['data'];
        CarModel carModelAPI = CarModel.fromJson(
            dataField); // Convert the map to a CarModel object
        print('a : $carModelAPI');
        setState(() {
          carModel = carModelAPI;
        });
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      print('Error parsing CarModel: $e');
      // Handle the error appropriately
    }
  }

  void _showCarDetails(BuildContext context, String id) {
    // Assuming that you have properly initialized the 'car' object

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            color: FrontendConfigs.kBackgrColor,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Image(
                        image: NetworkImage(widget.customerCar.image ??
                            'https://firebasestorage.googleapis.com/v0/b/car-rescue-399511.appspot.com/o/vehicle%2Fimages%2Fcar.png?alt=media&token=4a112258-d73c-4f2e-9f2f-bf46aa204790')),
                  ),
                ),
                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 120,
                          child: Text(
                            'Trạng thái',
                            style: TextStyle(
                              fontSize: 16.5,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: CarStatus(status: widget.customerCar.status),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    _buildDetailItem(
                        'Nhà sản xuất', widget.customerCar.manufacturer),
                    _buildDetailItem('Số khung', widget.customerCar.vinNumber),
                    _buildDetailItem(
                        'Biển số xe', widget.customerCar.licensePlate),
                    _buildDetailItem('Màu sắc', widget.customerCar.color),
                    _buildDetailItem('Năm sản xuất',
                        widget.customerCar.manufacturingYear.toString()),
                    _buildDetailItem('Loại xe', carModel?.model1 ?? 'unknown'),
                  ],
                ),
                SizedBox(height: 16),
                Center(
                    child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateCarScreen(
                          userId: widget.userId,
                          accountId: widget.accountId,
                          car: widget.customerCar,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Cập nhật',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: FrontendConfigs.kIconColor,
                    minimumSize: Size(double.infinity, 48),
                  ),
                ))
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () {
          _showCarDetails(context, widget.customerCar.id);
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          color: Colors.white,
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              width: 80,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(widget.customerCar.image ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: CustomText(
              text: carModel?.model1 ?? '',
              fontWeight: FontWeight.normal,
              color: Colors.grey,
              fontSize: 18,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Container(
                  child: CustomText(
                      text:
                          '${widget.customerCar.manufacturer} (${widget.customerCar.manufacturingYear})',
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color.fromARGB(134, 154, 154, 154),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        child: Text(
                          widget.customerCar.licensePlate,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: FrontendConfigs.kPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                    CarStatus(status: widget.customerCar.status),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildDetailItem(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
