import 'package:CarRescue/src/enviroment/env.dart';
import 'package:CarRescue/src/models/symptom.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class SymptomProvider{
  final String apiGetAllSymptom = Environment.API_URL + 'api/Symptom/GetAllSymptom';
  String accessToken = GetStorage().read("accessToken");
  Future<List<Symptom>> getAllSymptoms() async {
  final String url = "${apiGetAllSymptom}";

  try {
    final response = await http.get(Uri.parse(url), headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        });

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = convert.json.decode(response.body);

      if (jsonBody['status'] == 'Success') {
        final List<dynamic> data = jsonBody['data'];
        final List<Symptom> symptoms = data.map((symptomJson) => Symptom.fromJson(symptomJson)).toList();
        return symptoms;
      } else {
        print('Error: ${jsonBody['message']}');
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Request Error: $e');
  }

  return [];
}
}