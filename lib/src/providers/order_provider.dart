import 'dart:convert' as convert;
import 'dart:convert';
import 'package:CarRescue/src/enviroment/env.dart';
import 'package:CarRescue/src/models/order.dart';
import 'package:CarRescue/src/models/service.dart';
import 'package:http/http.dart' as http;
import 'package:CarRescue/src/models/order_booking.dart';

class OrderProvider {
  final String apiUrlCreateFixing =
      Environment.API_URL + 'api/Order/CreateFixingOrderForCustomer';
  final String apiUrlCreateTowing =
      Environment.API_URL + 'api/Order/CreateTowingOrderForCustomer';
  final String apiUrlGetOrderDetail =
      Environment.API_URL + 'api/Order/GetOrder';
  final String apiUrlGetAllOfCustomer =
      Environment.API_URL + 'api/Order/GetOrdersOfCustomer';
  final String apiUrlCancelOrder =
      Environment.API_URL + 'api/Order/CustomerCancelOrder';
  final String apiUrlGetImage =
      Environment.API_URL + 'api/Order/GetImagesOfOrder';
  final String apiUrlGetOrderDetails =
      Environment.API_URL + 'api/OrderDetail/GetDetailsOfOrder';
  final String apiUrlStartOrder = Environment.API_URL + 'api/Order/StartOrder';
  final String apiUrlEndOrder = Environment.API_URL + 'api/Order/EndOrder';
  final String apiUrlUpdateOrderForTech =
      Environment.API_URL + 'api/Order/UpdateOrderForTeachnician';

  Future<int?> createOrderFixing(OrderBookServiceFixing order) async {
    try {
      final String orderJson = convert.jsonEncode(order.toJson());

      // Thực hiện cuộc gọi POST bằng thư viện http
      final response = await http.post(
        Uri.parse(apiUrlCreateFixing),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: orderJson,
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
      throw Exception('Error: $e');
    }
  }

  Future<bool> cancelOrder(String orderID, String cancellationReason) async {
    final Map<String, dynamic> requestBody = {
      "orderID": orderID,
      "cancellationReason": cancellationReason,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrlCancelOrder),
        headers: {
          'Content-Type': 'application/json',
        },
        body: convert.jsonEncode(requestBody),
      );
      print("Body: ${response.body}");
      if (response.statusCode == 201) {
        print('Đã hủy đơn hàng thành công');
        return true;
      } else {
        print('Lỗi khi hủy đơn hàng: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Lỗi khi gửi yêu cầu hủy đơn hàng: $e');
      return false;
    }
  }

  Future<int?> createOrderTowing(OrderBookServiceTowing order) async {
    try {
      final String orderJson = convert.jsonEncode(order.toJson());

      // Thực hiện cuộc gọi POST bằng thư viện http
      final response = await http.post(
        Uri.parse(apiUrlCreateTowing),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: orderJson,
      );

      if (response.statusCode == 200) {
        print('Đơn hàng đã được tạo thành công');
        return response.statusCode;
      } else if (response.statusCode == 500) {
        print('External Error');
        return response.statusCode;
      } else if (response.statusCode == 201) {
        return response.statusCode;
      } else {
        throw Exception('Create failed');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Order>> getAllOrders(String id) async {
    try {
      final response =
          await http.get(Uri.parse("${apiUrlGetAllOfCustomer}?id=${id}"));
      if (response.statusCode == 200) {
        final dynamic data = convert.json.decode(response.body);

        if (data != null && data['data'] != null) {
          final List<dynamic> orderData = data['data'];
          List<Order> orders =
              orderData.map((data) => Order.fromJson(data)).toList();
          return orders;
        } else {
          // Handle empty or invalid response
          throw Exception('Empty or invalid response data');
        }
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      // Handle other exceptions or errors
      print('Error: $e');
      throw e;
    }
  }

  Future<Order> getOrderDetail(String id) async {
    try {
      final response =
          await http.get(Uri.parse("${apiUrlGetOrderDetail}?id=${id}"));
      print(response.body); // Add this line for debugging
      if (response.statusCode == 200) {
        final dynamic data = convert.json.decode(response.body);
        final dynamic orderData = data['data'];
        print(data);
        // Assuming Order class exists and you have a factory method to parse data
        Order order = Order.fromJson(orderData);

        // Check for null values and handle accordingly
        if (order.id == "") {
          throw Exception('Order ID is null');
        }

        return order;
      } else {
        throw Exception(
            'Failed to load orders. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other exceptions or errors
      print('Error: $e');
      throw e;
    }
  }

  Future<List<String>> getUrlImages(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrlGetImage?id=$orderId'),
        headers: {
          'accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final data = convert.json.decode(response.body);
        if (data['status'] == 'Success') {
          final List<dynamic> imageList = data['data'];
          final List<String> imageUrls =
              imageList.map((image) => image['url'].toString()).toList();
          return imageUrls;
        } else {
          // Xử lý trạng thái khác 'Success' nếu cần
          return [];
        }
      } else {
        // Xử lý lỗi trong trường hợp không có phản hồi 200
        return [];
      }
    } catch (e) {
      // Xử lý lỗi nếu có lỗi trong quá trình gọi API
      print('Error fetching images of order: $e');
      return [];
    }
  }

  Future<List<String>> getServiceIdInOrderDetails(String orderId) async {
    final String apiUrl = '${apiUrlGetOrderDetails}?id=$orderId';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            convert.json.decode(response.body);

        if (jsonData['data'] != null && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          final List<String> serviceIdList = data
              .where((item) => item is Map && item['serviceId'] is String)
              .map((item) => item['serviceId'].toString())
              .toList();

          if (serviceIdList.isNotEmpty) {
            print("ServiceId: ${serviceIdList[0]}");
            return serviceIdList;
          }
        }
      } else {
        print("Body: ${response.body}");
      }
    } catch (e) {
      print("getServiceIdInOrderDetails");
      print('Error: $e');
    }

    return [];
  }

  // Future<bool> startOrder(String orderId) async {
  //   final String apiUrl = '$apiUrlStartOrder';

  //   try {
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: {
  //         'Content-Type':
  //             'application/json', // Thay đổi header tùy theo yêu cầu của API
  //       },
  //       body: convert.json.encode({
  //         'id': orderId, // Thay 'orderId' bằng giá trị thực tế của orderId
  //       }),
  //     );

  //     if (response.statusCode == 201) {
  //       // Xử lý phản hồi ở đây nếu cần
  //       final responseBody = convert.json.decode(response.body);
  //       final status = responseBody['status'];
  //       final message = responseBody['message'];
  //       print('Trạng thái: $status');
  //       print('Thông điệp: $message');
  //       return true;
  //     } else {
  //       // Xử lý phản hồi lỗi nếu cần
  //       print('HTTP error ${response.statusCode}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     return false;
  //   }
  // }

  Future<void> startOrder(String orderId) async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Order/StartOrder';

    try {
      final response = await http.post(
        Uri.parse('$apiUrl?id=$orderId'),
        headers: {'accept': '*'},
      );

      if (response.statusCode == 201) {
        // Nếu mã trạng thái là 201, có nghĩa là yêu cầu thành công
        print('Order đã được bắt đầu');
      } else {
        // Nếu mã trạng thái không phải là 201, in ra thông báo lỗi
        print('Lỗi: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      // Xử lý lỗi trong trường hợp gặp lỗi khi thực hiện yêu cầu
      print('Lỗi: $error');
    }
  }

  Future<dynamic> endOrder(String orderId) async {
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Order/EndOrder?id=$orderId";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        // Add other headers if needed, like authorization headers
      },
      body: json.encode({'id': orderId}),
    );

    if (response.statusCode == 201) {
      print('Successfully ending the order ${response.body}');
      // Parse the JSON response to access the "data" field
      final jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'];

      // Return the "data" field
      return data;
    } else {
      print('Failed to end the order: ${response.body}');
      // Failed to create the car
      return null; // You can return null or handle the error differently as needed
    }
  }

  Future<bool> updateOrderForTechnician(
    String orderId,
    String staffNote,
    List<String> imageUrls,
  ) async {
    final apiUrl = '${apiUrlUpdateOrderForTech}';

    final Map<String, dynamic> requestBody = {
      'orderId': orderId,
      'staffNote': staffNote,
      'url': imageUrls,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json-patch+json'},
      body: convert.json.encode(requestBody),
    );

    if (response.statusCode == 201) {
      // Xử lý thành công
      print('Đã cập nhật đơn hàng cho kỹ thuật viên thành công.');
      return true;
    } else {
      // Xử lý lỗi
      print('Lỗi khi cập nhật đơn hàng: ${response.statusCode}');
      print('Lỗi khi cập nhật đơn hàng: ${response.body}');
      return false;
    }
  }
}
