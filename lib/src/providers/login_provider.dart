import 'package:CarRescue/src/enviroment/env.dart';
import 'package:CarRescue/src/models/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class LoginProvider {
  final String key = Environment.API_URL + 'api/Login/LoginWithGoogle';

  Future<LoginResponse?> loginWithGmail(String accessToken, String deviceToken) async {
    final url = Uri.parse('https://rescuecapstoneapi.azurewebsites.net/api/Login/LoginWithGoogle');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {
      "accessToken": accessToken,
      "deviceToken": deviceToken
    };

    final String encodedBody = convert.jsonEncode(body);

    final response = await http.post(url, headers: headers, body: encodedBody);

    if (response.statusCode == 200) {
      // Xử lý phản hồi ở đây
      print("POST request thành công!");
      final jsonData = convert.jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(jsonData);
      return loginResponse;
    }else if (response.statusCode == 400){
      return null;
    }else {
      print("Lỗi trong quá trình gửi POST request. Mã trạng thái: ${response.statusCode}");
      throw Exception('Lỗi trong quá trình gửi POST request');
    }
  }
}
 