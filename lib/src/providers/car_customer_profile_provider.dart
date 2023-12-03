import 'dart:convert' as convert;
import 'package:CarRescue/src/enviroment/env.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:CarRescue/src/models/customer_car.dart';

class CarCustomerProvider {
  final String apiUrlGetCarCustomer = Environment.API_URL + 'api/Car/Get';
  String accessToken = GetStorage().read("accessToken");
  Future<CustomerCar> getCar(String carId) async {
    final String apiUrl = '$apiUrlGetCarCustomer?id=$carId';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = convert.json.decode(response.body);

      if (data['status'] == 'Success') {
        Map<String, dynamic> carData = data['data'];
        return CustomerCar.fromJson(carData);
      } else {
        throw Exception('Failed to load car data: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load car data from API');
    }
  }
}
