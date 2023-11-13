import 'dart:convert' as convert;
import 'package:CarRescue/src/enviroment/env.dart';
import 'package:CarRescue/src/models/service.dart';
import 'package:http/http.dart' as http;
import 'package:CarRescue/src/models/order_booking.dart';

class ServiceProvider {
  final String apiUrl = Environment.API_URL + 'api/Service/GetAll';

  final String apiUrlGetAllServiceById = Environment.API_URL + '/api/Service/Get';

  Future<List<Service>> getServiceById(List<String> idService) async {
  final List<Service> serviceList = [];

  for (String id in idService) {
  final String apiUrl = '${apiUrlGetAllServiceById}?id=$id';
  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final dynamic jsonData = convert.json.decode(response.body);
      final dynamic data = jsonData['data'];
      print("Data for $id: $data");
      if (data is Map<String, dynamic>) { // Kiểm tra kiểu dữ liệu
        Service service = Service.fromJson(data);
        serviceList.add(service);
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
  print("${serviceList.length}");
  for (int i = 0; i < serviceList.length; i++) {
  print("Service $i: ${serviceList[i].name}, Price: ${serviceList[i].price}");
}
  return serviceList;
}



  Future<List<Service>> getAllServicesFixing() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = convert.jsonDecode(response.body);
        final List<dynamic> serviceList = data['data'] as List<dynamic>;

        List<Service> services = serviceList
            .map((serviceData) => Service.fromJson(serviceData))
            .toList();

        List<Service> towingServices = services.where((service) => service.type == "Fixing").toList();

        return towingServices;
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Service>> getAllServicesTowing() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = convert.jsonDecode(response.body);
        final List<dynamic> serviceList = data['data'] as List<dynamic>;

        List<Service> services = serviceList
            .map((serviceData) => Service.fromJson(serviceData))
            .toList();

        List<Service> towingServices = services.where((service) => service.type == "Towing").toList();

        return towingServices;
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
