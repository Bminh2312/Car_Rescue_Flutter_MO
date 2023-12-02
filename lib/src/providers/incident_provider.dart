import 'package:CarRescue/src/enviroment/env.dart';
import 'package:CarRescue/src/models/incident.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


class IncidentProvider{

  final String apiCreateIncident = Environment.API_URL + "api/Incident/CreateIncident";

  Future<int?> createIncident(Incident incident) async {

  try {
    final String incidentBody = convert.jsonEncode(incident.toJson());
    final response = await http.post(
      Uri.parse(apiCreateIncident),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json-patch+json',
      },
      body: incidentBody,
    );

    if (response.statusCode == 200) {
        print('Đơn hàng đã được tạo thành công');
        return response.statusCode;
      } else if (response.statusCode == 500) {
        print('External Error');
        return response.statusCode;
      } else {
        print('Đã xảy ra lỗi khi tạo đơn hàng. Mã lỗi: ${response.statusCode}');
        print('Đã xảy ra lỗi khi tạo đơn hàng. Body: ${response.body}');
        return response.statusCode;
      }
  } catch (e) {
    print('Request Error: $e');
    throw Exception('Error: $e');
  }
}
}