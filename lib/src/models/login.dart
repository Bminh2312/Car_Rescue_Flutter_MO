import 'package:CarRescue/src/models/customer.dart';

class LoginResponse {
  late String role;
  late String accessToken;
  late String refreshToken;
  late String accountId;
  late String email;
  late Customer customer;
  late String message;
  late int status;

  LoginResponse({
    required this.role,
    required this.accessToken,
    required this.refreshToken,
    required this.accountId,
    required this.email,
    required this.customer,
    required this.message,
    required this.status,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      role: json['data']['role'] ?? '',
      accessToken: json['data']['accessToken'] ?? '',
      refreshToken: json['data']['refreshToken'] ?? '',
      accountId: json['data']['accountId'] ?? '',
      email: json['data']['email'] ?? '',
      customer: Customer.fromJson(json['data']['customer']),
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
    );
  }


}

