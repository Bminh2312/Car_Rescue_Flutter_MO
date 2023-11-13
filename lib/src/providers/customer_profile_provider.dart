import 'dart:convert';

import 'package:CarRescue/src/enviroment/env.dart';
import 'package:CarRescue/src/models/customer.dart';
import 'package:http/http.dart' as http;

class CustomerProfileProvider {
  final String apiUrl = Environment.API_URL + 'api/Customer/Get';

  Future<Customer> getCustomerById(String id) async {
    try {
      final url = Uri.parse('$apiUrl?id=$id');

      final response = await http.get(url, headers: {
        'accept': '*/*',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final customer = Customer.fromJson(jsonResponse['data']);
        return customer;
      } else {
        throw Exception('Failed to load customer');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> updateCustomer(Customer customer) async {
    final url = Uri.parse(
        'https://rescuecapstoneapi.azurewebsites.net/api/Customer/Update');

    final Map<String, dynamic> requestBody = {
      "id": customer.id,
      "accountId": customer.accountId,
      "fullname": customer.fullname,
      "sex": customer.sex,
      "phone": customer.phone,
      "licensePlate": customer.licensePlate,
      "avatar": customer.avatar,
      "address": customer.address,
      "status": customer.status,
      "createAt": customer.createAt,
      "updateAt": customer.updateAt,
      "birthdate": customer.birthdate,
    };

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json-patch+json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Customer updated successfully');
      return true;
    } else {
      throw Exception('Failed to update customer');
    }
  }
}
