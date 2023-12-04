import 'package:CarRescue/src/enviroment/env.dart';
import 'package:CarRescue/src/models/feedback_customer.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class FeedBackProvider {
  String? accessToken = GetStorage().read<String>("accessToken");
  final String apiUrlCreateFeedBack =
      Environment.API_URL + 'api/Feedback/Update';

  final String apiUrlGetAllFeedBack =
      Environment.API_URL + 'api/Feedback/GetWaitingFeedbacksOfUser';

  final String apiUrlGetFeedBackOfOrder =
      Environment.API_URL + 'api/Feedback/GetFeedbackOfOrder';

  Future<FeedbackCustomer> getFeedbackOfOrder(String orderId) async {
    final Uri url = Uri.parse('$apiUrlGetFeedBackOfOrder?id=${orderId}');
    final response = await http.get(

      url,headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        });


    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      final dynamic responseBody = convert.json.decode(response.body);
      // Assuming that the Feedback class has been defined
      final dynamic feedbackData = responseBody['data'];
      final FeedbackCustomer filteredFeedback =
          FeedbackCustomer.fromJson(feedbackData);
      print(filteredFeedback);
      return filteredFeedback;
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw Exception('Failed to load feedback');
    }
  }

  Future<String> getWaitingFeedbacks(String customerId, String orderId) async {
    final Uri url = Uri.parse('$apiUrlGetAllFeedBack?id=$customerId');

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody =
            convert.json.decode(response.body);
        final List<dynamic> feedbacksData = responseBody['data'];

        if (feedbacksData.isNotEmpty) {
          print(feedbacksData);
          print(orderId);
          final List<FeedbackCustomer> feedbackList = feedbacksData
              .map((feedbackData) => FeedbackCustomer.fromJson(feedbackData))
              .toList();

          // Filter feedbacks based on orderId
          final FeedbackCustomer filteredFeedback = feedbackList
              .firstWhere((feedback) => feedback.orderId == orderId);

          return filteredFeedback.id;
        } else {
          // Handle case when feedbacksData is empty
          throw Exception(
              'No feedback data available for customer $customerId');
        }
      } else {
        throw Exception(
            'Failed to load feedbacks. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> updateFeedback(String id, int rating, String note) async {
    final Map<String, dynamic> feedbackData = {
      'id': id,
      'rating': rating,
      'note': note,
    };
    print('data: $feedbackData');
    try {
      final response = await http.post(
        Uri.parse(apiUrlCreateFeedBack),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        },
        body: convert.jsonEncode(feedbackData),
      );

      if (response.statusCode == 200) {
        // Handle success, if needed
        print('Feedback submitted successfully');
        return true;
      } else {
        // Handle errors, if needed
        print('Failed to submit feedback. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      // Handle exceptions
      print('Error: $e');
      return false;
    }
  }
}
