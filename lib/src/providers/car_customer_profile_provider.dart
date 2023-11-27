
import 'dart:convert' as convert;
import 'package:CarRescue/src/enviroment/env.dart';
import 'package:http/http.dart' as http;
import 'package:CarRescue/src/models/customer_car.dart';

class CarCustomerProvider{
  final String apiUrlGetCarCustomer = Environment.API_URL + 'api/Car/Get';

  Future<CustomerCar> getCar(String carId) async {
  final String apiUrl = '$apiUrlGetCarCustomer?id=$carId';

  final response = await http.get(Uri.parse(apiUrl));

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