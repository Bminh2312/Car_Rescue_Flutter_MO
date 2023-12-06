import 'dart:convert';
import 'dart:io';
import 'package:CarRescue/src/models/car_model.dart';
import 'package:CarRescue/src/models/current_week.dart';
import 'package:CarRescue/src/models/feedback.dart';
import 'package:CarRescue/src/models/vehicle_item.dart';
import 'package:CarRescue/src/models/wallet_transaction.dart';
import 'package:CarRescue/src/models/work_shift.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/models/wallet.dart';
import 'package:CarRescue/src/models/manager.dart';
import 'package:CarRescue/src/models/notification.dart';
import 'package:CarRescue/src/models/banking_info.dart';
import 'package:get_storage/get_storage.dart';

import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

class LoginResult {
  final String userId;
  final String accountId;
  final String fullname;
  final String? avatar;
  final String role;
  final String accessToken;
  LoginResult({
    required this.userId,
    required this.accountId,
    required this.fullname,
    required this.avatar,
    required this.role,
    required this.accessToken,
  });
}


final String apiKey1 = 'AIzaSyDBh1rDpymnE4ClAjbY3NrLSd4yP4GWweE';

final String fcmToken =
    'eyJhbGciOiJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGRzaWctbW9yZSNobWFjLXNoYTUxMiIsInR5cCI6IkpXVCJ9.eyJFbWFpbCI6IlRlY2huaWNpYW5AZ21haWwuY29tIiwiQWNjb3VudElEIjoiZGQyZjFhMjAtNTc2OS00MDUyLTg1MTktOTIyYmZkYzk5NWViIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiVGVjaG5pY2lhbiIsImV4cCI6MTcwMTYwNTIyOH0.OaLPzJzbtudoQYRPwlEjG1WEUGVPVc6lFZa2xoxxlCEGyoCvrKGckemMvceeMgtPwffbDy-MJcROKs3ad78nhw';

class AuthService {
  String? accessToken = GetStorage().read<String>("accessToken");

  //TECHNICIAN API
  Future<LoginResult?> login(
      String email, String password, String deviceToken) async {
    try {
      // Your existing login logic here
      final response = await http.post(
        Uri.parse(
            'https://rescuecapstoneapi.azurewebsites.net/api/Login/Login'),
        body: jsonEncode(
            {'email': email, 'password': password, 'devicetoken': deviceToken}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );
      print('zzzz: $accessToken');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 200) {
          final technician = data['data']['technician'];
          final role = data['data']['role'];
          final accessToken = data['data']['accessToken'];
          if (technician != null) {
            final userId = technician['id'];
            final accountId = technician['accountId'];
            final fullname = technician['fullname'];
            final avatar = technician['avatar'] ?? '';
            // Fetch user profile information using the user ID
            final userProfile = await fetchTechProfile(userId);

            if (userProfile != null) {
              // Now you have the user profile data
              print('PROFILE: $userProfile');
            } else {
              // Handle the case where profile fetching failed
            }

            return LoginResult(
                userId: userId,
                accountId: accountId,
                fullname: fullname,
                avatar: avatar,
                role: role,
                accessToken: accessToken);
          }
        } else {
          return null; // Return null for failed login (adjust as needed)
        }
      } else {
        // Handle non-200 status code
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchTechProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://rescuecapstoneapi.azurewebsites.net/api/Technician/Get?id=$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        }, // Replace with your actual API endpoint
      );

      if (response.statusCode == 200) {
        print(response.statusCode);
        return json.decode(response.body);
      } else {
        // Handle non-200 status code when fetching the user profile
        return null;
      }
    } catch (e) {
      print('Error fetching user profile1: $e');
      return null;
    }
  }

  Future<Manager?> fetchManagerProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://rescuecapstoneapi.azurewebsites.net/api/Manager/Get?id=$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        },
      );

      if (response.statusCode == 200) {
        // Parse the JSON response into a Manager object
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final Manager manager = Manager.fromJson(
            jsonData); // Adjust this based on your Manager class

        print('Get manager successfully!');
        return manager;
      } else {
        print('Error: ${response.statusCode}');
        // Handle non-200 status code when fetching the user profile
        throw Exception('Failed to fetch manager profile');
      }
    } catch (e) {
      print('Error fetching manager profile: $e');
      throw Exception('Failed to fetch manager profile');
    }
  }

  Future<List<Booking>> fetchBookings(String userId) async {
    try {
      final apiUrl = Uri.parse(
          'https://rescuecapstoneapi.azurewebsites.net/api/Order/GetOrdersOfTechnician?id=$userId');
      final response = await http.get(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Kiểm tra xem dữ liệu JSON chứa mảng 'data' hay không
        if (jsonData.containsKey('data')) {
          List<dynamic> data = jsonData['data'];

          // Filter the data to exclude the specified ID
          List<Booking> bookings = data
              .where((json) => json['id'] != 'a') // Exclude a specific ID
              .map((json) => Booking.fromJson(json))
              .toList();

          return bookings;
        } else {
          throw Exception('API ');
        }
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      throw Exception('Error fetching bookings1: $e');
    }
  }

  // CAR OWNER API
  Future<LoginResult?> loginCarOwner(
      String email, String password, String deviceToken) async {
    try {
      // Your existing login logic here
      final response = await http.post(
        Uri.parse(
            'https://rescuecapstoneapi.azurewebsites.net/api/Login/Login'),
        body: jsonEncode(
            {'email': email, 'password': password, 'deviceToken': deviceToken}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 200) {
          final rescueVehicleOwner = data['data']['rescueVehicleOwner'];
          final role = data['data']['role'];
          final accessToken = data['data']['accessToken'];
          if (rescueVehicleOwner != null) {
            final rescueVehicleOwnerId = rescueVehicleOwner['id'];
            final accountId = rescueVehicleOwner['accountId'];
            final fullname = rescueVehicleOwner['fullname'];
            final avatar = rescueVehicleOwner['avatar'];
            // Fetch user profile information using the user ID

            return LoginResult(
                userId: rescueVehicleOwnerId,
                accountId: accountId,
                fullname: fullname,
                avatar: avatar,
                role: role,
                accessToken: accessToken);
          }
        } else {
          return null; // Return null for failed login (adjust as needed)
        }
      } else {
        // Handle non-200 status code
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchRescueCarOwnerProfile(
      String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://rescuecapstoneapi.azurewebsites.net/api/RescueVehicleOwner/Get?id=$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        }, // Replace with your actual API endpoint
      );

      if (response.statusCode == 200) {
        print(response.statusCode);
        return json.decode(response.body);
      } else {
        // Handle non-200 status code when fetching the user profile
        return null;
      }
    } catch (e) {
      print('Error fetching user profile1: $e');
      return null;
    }
  }

  Future<List<Booking>> fetchCarOwnerBookings(String userId) async {
    try {
      final apiUrl = Uri.parse(
          'https://rescuecapstoneapi.azurewebsites.net/api/Order/GetOrdersOfRVO?id=$userId');
      final response = await http.get(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Kiểm tra xem dữ liệu JSON chứa mảng 'data' hay không
        if (jsonData.containsKey('data')) {
          List<dynamic> data = jsonData['data'];

          // Filter the data to exclude the specified ID
          List<Booking> bookings = data
              // Exclude a specific ID
              .map((json) => Booking.fromJson(json))
              .toList();

          return bookings;
        } else {
          throw Exception('Loi');
        }
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      throw Exception('Error fetching booking1s: $e');
    }
  }

  Future<Booking> fetchBookingById(String orderId) async {
    try {
      final apiUrl = Uri.parse(
          'https://rescuecapstoneapi.azurewebsites.net/api/Order/GetOrder?id=$orderId');
      final response = await http.get(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // If 'data' key exists and it's not null
        if (jsonData.containsKey('data') && jsonData['data'] != null) {
          return Booking.fromJson(jsonData['data']);
        } else {
          throw Exception('Invalid data format in response.');
        }
      } else {
        throw Exception('Failed to load booking');
      }
    } catch (e) {
      throw Exception('Error fetching booking: $e');
    }
  }

  Future<List<Booking>> fetchCarOwnerBookingByCompleted(String userId) async {
    try {
      final apiUrl = Uri.parse(
          'https://rescuecapstoneapi.azurewebsites.net/api/Order/GetAllOrderCompletedOfRVO?id=$userId');
      final response = await http.get(apiUrl, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // If 'data' key exists and it's not null
        if (jsonData.containsKey('data') && jsonData['data'] != null) {
          List<dynamic> bookingsData = jsonData['data'];
          return bookingsData
              .map((booking) => Booking.fromJson(booking))
              .toList();
        } else {
          throw Exception('Invalid data format in response.');
        }
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  Future<List<Booking>> fetchCarOwnerBookingByCanceled(String userId) async {
    try {
      final apiUrl = Uri.parse(
          'https://rescuecapstoneapi.azurewebsites.net/api/Order/GetAllOrderCancelledOfRVO?id=$userId');
      final response = await http.get(apiUrl, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // If 'data' key exists and it's not null
        if (jsonData.containsKey('data') && jsonData['data'] != null) {
          List<dynamic> bookingsData = jsonData['data'];
          return bookingsData
              .map((booking) => Booking.fromJson(booking))
              .toList();
        } else {
          throw Exception('Invalid data format in response.');
        }
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  Future<List<Booking>> fetchCarOwnerBookingByAssigning(String userId) async {
    try {
      final apiUrl = Uri.parse(
          'https://rescuecapstoneapi.azurewebsites.net/api/Order/GetAllOrderAssigningOfRVO?id=$userId');
      final response = await http.get(apiUrl, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // If 'data' key exists and it's not null
        if (!jsonData.containsKey('data') || jsonData['data'] == null) {
          return []; // Return an empty list if 'data' key is missing or null
        } else {
          List<dynamic> bookingsData = jsonData['data'];
          return bookingsData
              .map((booking) => Booking.fromJson(booking))
              .toList();
        }
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  Future<List<Booking>> fetchCarOwnerBookingByAssigned(String userId) async {
    try {
      final apiUrl = Uri.parse(
          'https://rescuecapstoneapi.azurewebsites.net/api/Order/GetAllOrderAssignedOfRVO?id=$userId');
      final response = await http.get(apiUrl, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // If 'data' key exists and it's not null
        if (!jsonData.containsKey('data') || jsonData['data'] == null) {
          return []; // Return an empty list if 'data' key is missing or null
        } else {
          List<dynamic> bookingsData = jsonData['data'];
          return bookingsData
              .map((booking) => Booking.fromJson(booking))
              .toList();
        }
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  Future<List<Booking>> fetchTechBookingByInprogress(String userId) async {
    try {
      final apiUrl = Uri.parse(
          'https://rescuecapstoneapi.azurewebsites.net/api/Order/GetAllOrderInprogressOfTech?id=$userId');
      final response = await http.get(apiUrl, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // If 'data' key exists and it's not null
        if (!jsonData.containsKey('data') || jsonData['data'] == null) {
          return []; // Return an empty list if 'data' key is missing or null
        } else {
          List<dynamic> bookingsData = jsonData['data'];
          return bookingsData
              .map((booking) => Booking.fromJson(booking))
              .toList();
        }
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  Future<List<Booking>> fetchTechBookingByAssigned(String userId) async {
    try {
      final apiUrl = Uri.parse(
          'https://rescuecapstoneapi.azurewebsites.net/api/Order/GetAllOrderAssignedOfTech?id=$userId');
      final response = await http.get(apiUrl, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // If 'data' key exists and it's not null
        if (!jsonData.containsKey('data') || jsonData['data'] == null) {
          return []; // Return an empty list if 'data' key is missing or null
        } else {
          List<dynamic> bookingsData = jsonData['data'];
          return bookingsData
              .map((booking) => Booking.fromJson(booking))
              .toList();
        }
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  Future<List<Booking>> fetchTechBookingByCompleted(String userId) async {
    try {
      final apiUrl = Uri.parse(
          'https://rescuecapstoneapi.azurewebsites.net/api/Order/GetAllOrderCompletedOfTech?id=$userId');
      final response = await http.get(apiUrl, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // If 'data' key exists and it's not null
        if (jsonData.containsKey('data') && jsonData['data'] != null) {
          List<dynamic> bookingsData = jsonData['data'];

          return bookingsData
              .map((booking) => Booking.fromJson(booking))
              .toList();
        } else {
          throw Exception('Invalid data format in response.');
        }
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  Future<List<Booking>> fetchTechBookingByCanceled(String userId) async {
    try {
      final apiUrl = Uri.parse(
          'https://rescuecapstoneapi.azurewebsites.net/api/Order/GetAllOrderCancelledOfTech?id=$userId');
      final response = await http.get(apiUrl, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // If 'data' key exists and it's not null
        if (jsonData.containsKey('data') && jsonData['data'] != null) {
          List<dynamic> bookingsData = jsonData['data'];

          return bookingsData
              .map((booking) => Booking.fromJson(booking))
              .toList();
        } else {
          throw Exception('Invalid data format in response.');
        }
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  Future<List<Booking>> fetchCarOwnerBookingByInprogress(String userId) async {
    try {
      final apiUrl = Uri.parse(
          'https://rescuecapstoneapi.azurewebsites.net/api/Order/GetAllOrderInprogressOfRVO?id=$userId');
      final response = await http.get(apiUrl, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // If 'data' key exists and it's not null
        if (!jsonData.containsKey('data') || jsonData['data'] == null) {
          return []; // Return an empty list if 'data' key is missing or null
        } else {
          List<dynamic> bookingsData = jsonData['data'];
          return bookingsData
              .map((booking) => Booking.fromJson(booking))
              .toList();
        }
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  Future<Vehicle> fetchVehicleInfo(String vehicleId) async {
    try {
      final apiUrl = Uri.parse(
          'https://rescuecapstoneapi.azurewebsites.net/api/Vehicle/Get?id=$vehicleId');
      final response = await http.get(apiUrl, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Check if the JSON contains the vehicle info
        if (jsonData.containsKey('data')) {
          final dynamic data = jsonData['data'];

          // Create a VehicleInfo object from the JSON data
          final Vehicle vehicleInfo = Vehicle.fromJson(data);

          return vehicleInfo;
        } else {
          throw Exception('Vehicle info not found');
        }
      } else {
        throw Exception('Failed to load vehicle info');
      }
    } catch (e) {
      throw Exception('Error fetching vehicle info: $e');
    }
  }

  Future<Map<String, String>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final Placemark firstPlacemark = placemarks[0];
        final String street = firstPlacemark.street ?? '';
        final String subAddress =
            '${firstPlacemark.thoroughfare}, ${firstPlacemark.subAdministrativeArea}, ${firstPlacemark.country}';
        final String address = '$street';

        final Map<String, String> result = {
          'address': address,
          'subAddress': subAddress,
        };

        return result;
      } else {
        return {
          'address': 'Không tìm thấy địa chỉ',
          'subAddress': '',
        };
      }
    } catch (e) {
      print('Error getting address from coordinates: $e');
      return {
        'address': 'Lỗi khi lấy địa chỉ',
        'subAddress': '',
      };
    }
  }

  Future<Map<String, dynamic>> getAddressInfo(Booking booking) async {
    // Extract departure latitude and longitude
    final latMatchDeparture =
        RegExp(r'lat:\s?([\-0-9.]+)').firstMatch(booking.departure);
    final longMatchDeparture =
        RegExp(r'long:\s?([\-0-9.]+)').firstMatch(booking.departure);
    final double? latDeparture =
        double.tryParse(latMatchDeparture?.group(1) ?? '');
    final double? longDeparture =
        double.tryParse(longMatchDeparture?.group(1) ?? '');

    // Extract destination latitude and longitude
    final latMatchDestination =
        RegExp(r'lat:\s?([\-0-9.]+)').firstMatch(booking.destination ?? '');
    final longMatchDestination =
        RegExp(r'long:\s?([\-0-9.]+)').firstMatch(booking.destination ?? '');
    final double? latDestination =
        double.tryParse(latMatchDestination?.group(1) ?? '');
    final double? longDestination =
        double.tryParse(longMatchDestination?.group(1) ?? '');

    // Initialize response map with default values
    Map<String, dynamic> response = {
      'bookingId': booking.id,
      'address': 'Unknown Address',
      'subAddress': 'Unknown SubAddress',
      'destinationAddress': 'Unknown Destination Address',
      'destinationSubAddress': 'Unknown Destination SubAddress',
    };

    // Check if departure coordinates are available
    if (latDeparture != null && longDeparture != null) {
      // Replace with your actual API key
      final String urlDeparture =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latDeparture,$longDeparture&key=${apiKey1}';

      final responseDeparture = await http.get(Uri.parse(urlDeparture));
      if (responseDeparture.statusCode != 200) {
        // Handle error or return default values
      } else {
        var jsonResponseDeparture = json.decode(responseDeparture.body);
        if (jsonResponseDeparture['status'] == 'OK' &&
            jsonResponseDeparture['results'].isNotEmpty) {
          var addressComponentsDeparture = jsonResponseDeparture['results'][0]
              ['address_components'] as List<dynamic>;
          String formattedAddressDeparture =
              formatStreetAndRoute(addressComponentsDeparture);
          String formattedSubAddressDeparture =
              formatSubAddress(addressComponentsDeparture);
          var addressComponentsDestination1 =
              jsonResponseDeparture['results'][0]['formatted_address'];
          // Update the response map with departure address and sub-address
          response['address'] = formattedAddressDeparture;
          response['subAddress'] = addressComponentsDestination1;
        }
      }
    }

    // Check if destination coordinates are available
    if (latDestination != null && longDestination != null) {
      // Replace with your actual API key
      final String urlDestination =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latDestination,$longDestination&key=$apiKey1';
      print(apiKey1);
      final responseDestination = await http.get(Uri.parse(urlDestination));
      if (responseDestination.statusCode != 200) {
        // Handle error or return default values
      } else {
        var jsonResponseDestination = json.decode(responseDestination.body);
        if (jsonResponseDestination['status'] == 'OK' &&
            jsonResponseDestination['results'].isNotEmpty) {
          var addressComponentsDestination = jsonResponseDestination['results']
              [0]['address_components'] as List<dynamic>;
          var addressComponentsDestination1 =
              jsonResponseDestination['results'][0]['formatted_address'];
          print('abczx: $addressComponentsDestination1');
          String formattedAddressDestination =
              formatStreetAndRoute(addressComponentsDestination);
          String formattedSubAddressDestination =
              formatSubAddress(addressComponentsDestination);

          // Update the response map with destination address and sub-address
          response['destinationAddress'] = formattedAddressDestination;
          response['destinationSubAddress'] = addressComponentsDestination1;
        }
      }
    }

    return response;
  }

  String formatStreetAndRoute(List<dynamic> addressComponents) {
    String pointOfInterest = '';
    String park = '';
    String route = '';
    String street = '';
    String neighborhood = '';
    String admin1 = '';

    for (var component in addressComponents) {
      if (component['types'].contains('point_of_interest')) {
        pointOfInterest = component['long_name'];
      }
      if (component['types'].contains('park')) {
        park = component['long_name'];
      }
      if (component['types'].contains('route')) {
        route = component[
            'short_name']; // You had long_name here, I'm keeping your newer preference for short_name.
      }
      if (component['types'].contains('street_number')) {
        street = component['long_name'];
      }
      if (component['types'].contains('neighborhood')) {
        neighborhood = component['long_name'];
      }
      if (component['types'].contains('administrative_area_level_1')) {
        admin1 = component[
            'long_name']; // Fixed key from 'administrative_area_level_1' to 'long_name'.
      }
    }

    // Constructing the address based on the presence of different components
    if (pointOfInterest.isNotEmpty || park.isNotEmpty) {
      return '$pointOfInterest${park.isNotEmpty ? " $park" : ""}';
    } else if (street.isNotEmpty && route.isNotEmpty && park.isEmpty) {
      return '$street $route';
    } else if (neighborhood.isNotEmpty && street.isEmpty && route.isEmpty) {
      return neighborhood;
    } else if (route.isNotEmpty && street.isEmpty && park.isEmpty) {
      return route;
    } else if (neighborhood.isNotEmpty &&
        street.isNotEmpty &&
        route.isNotEmpty) {
      return '$neighborhood, $street $route';
    } else if (admin1.isNotEmpty) {
      return '${neighborhood.isNotEmpty ? "$neighborhood, " : ""}${pointOfInterest.isNotEmpty ? "$pointOfInterest, " : ""}${street.isNotEmpty ? "$street " : ""}${route.isNotEmpty ? "$route" : ""}'
          .trim();
    }

    return 'Unknown Address';
  }

  String formatSubAddress(List<dynamic> addressComponents) {
    String? route;
    String? street;
    String? neighborhood;
    String? admin2;
    String? admin1;
    String? locality;

    for (var component in addressComponents) {
      if (component['types'].contains('route')) {
        route = component['long_name'];
      }
      if (component['types'].contains('street_number')) {
        street = component['long_name'];
      }
      if (component['types'].contains('neighborhood')) {
        neighborhood = component['long_name'];
      }
      if (component['types'].contains('administrative_area_level_2')) {
        admin2 = component['long_name'];
      }
      if (component['types'].contains('administrative_area_level_1')) {
        admin1 = component['long_name'];
      }
      if (component['types'].contains('locality')) {
        locality = component['long_name'];
      }
    }

    if (street != null && route != null && admin2 != null) {
      return '$street $route,${locality ?? ''} $admin2, ${admin1 ?? ''}'.trim();
    } else if (street == null &&
        route == null &&
        neighborhood != null &&
        admin2 != null) {
      return '${street ?? ''} ${route ?? ""} $admin2, ${admin1 ?? ''}'.trim();
    } else if (admin1 != null) {
      return '${route ?? ''} ${locality ?? ''} $admin1'.trim();
    }

    return 'Unknown Address';
  }

  // This function fetches address and subaddress for departure locations.
  Future<void> getAddressesForBookings(
      List<Booking> bookings,
      void Function(VoidCallback) setState,
      Map<String, String> addresses,
      Map<String, String> subAddresses) async {
    var results =
        await Future.wait(bookings.map((booking) => getAddressInfo(booking)));

    // Update the state once with all the results.
    setState(() {
      for (var result in results) {
        addresses[result['bookingId']] = result['address'];
        subAddresses[result['bookingId']] = result['subAddress'];
      }
    });
  }

// This function fetches address and subaddress for destination locations.
  Future<void> getDestiForBookings(
      List<Booking> bookings,
      void Function(VoidCallback) setState,
      Map<String, String> addressesDesti,
      Map<String, String> subAddressesDesti) async {
    var results =
        await Future.wait(bookings.map((booking) => getAddressInfo(booking)));

    // Update the state once with all the results.
    setState(() {
      for (var result in results) {
        addressesDesti[result['bookingId']] = result['destinationAddress'];
        subAddressesDesti[result['bookingId']] =
            result['destinationSubAddress'];
      }
    });
  }

  Future<Map<String, dynamic>?> fetchCustomerInfo(String customerId) async {
    try {
      final response = await http.get(
          Uri.parse(
              'https://rescuecapstoneapi.azurewebsites.net/api/Customer/Get?id=$customerId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken'
          } // Replace with your actual API endpoint
          );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Handle non-200 status code when fetching the user profile
        return null;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<String?> uploadImageToFirebase(
      File imageFile, String storagePath) async {
    try {
      // Generate a unique id for the image
      String filename = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a custom storage reference
      final Reference storageReference =
          FirebaseStorage.instance.ref().child(storagePath + '/$filename');

      UploadTask uploadTask = storageReference.putFile(imageFile);

      // Get the download URL
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool> createCarApproval(String? id,
      {required String rvoid,
      required String licensePlate,
      required String manufacturer,
      required String status,
      required String vinNumber,
      required String type,
      required String color,
      required int manufacturingYear,
      required File carRegistrationFontImage,
      required File carRegistrationBackImage,
      required File vehicleImage}) async {
    var uuid = Uuid();
    id ??= uuid.v4();

    String? frontImageUrl = await uploadImageToFirebase(
        carRegistrationFontImage, 'vehicle_verify/images');
    String? backImageUrl = await uploadImageToFirebase(
        carRegistrationBackImage, 'vehicle_verify/images');
    String? vehicleUrl =
        await uploadImageToFirebase(vehicleImage, 'vehicle/images');

    if (frontImageUrl == null || backImageUrl == null || vehicleUrl == null) {
      // Hiển thị lỗi
      print('ko co hinh');
      return false;
    } // If id is null, generate a random UUID
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Vehicle/CreateApproval"; // Replace with your endpoint URL

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      },
      body: json.encode({
        'id': id,
        'rvoid': rvoid,
        'licensePlate': licensePlate,
        'manufacturer': manufacturer,
        'status': status,
        'vinNumber': vinNumber,
        'type': type,
        'color': color,
        'manufacturingYear': manufacturingYear,
        "carRegistrationFont": frontImageUrl,
        "carRegistrationBack": backImageUrl,
        'image': vehicleUrl
        // Note: Handling image uploads would require a multipart request.
        // For simplicity, this example does not cover image uploads.
        // You might need a separate API or endpoint to handle the image upload.
      }),
    );

    if (response.statusCode == 200) {
      print('Successfully created the car ${response.body}');
      return true; //
    } else {
      print('Failed to create the car: ${response.body}');
      return false; // Failed to create the car
    }
  }

  Future<bool> createCarforCustomer(String? id,
      {required String customerId,
      required String licensePlate,
      required String manufacturer,
      required String status,
      required String vinNumber,
      required String modelId,
      required String color,
      required int manufacturingYear,
      required File vehicleImage}) async {
    var uuid = Uuid();
    id ??= uuid.v4();

    String? vehicleUrl =
        await uploadImageToFirebase(vehicleImage, 'vehicle/images');

    if (vehicleUrl == null) {
      // Hiển thị lỗi
      print('ko co hinh');
      return false;
    } // If id is null, generate a random UUID
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Car/Create"; // Replace with your endpoint URL

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        // Add other headers if needed, like authorization headers
      },
      body: json.encode({
        'id': id,
        'customerId': customerId,
        'licensePlate': licensePlate,
        'manufacturer': manufacturer,
        'status': status,
        'vinNumber': vinNumber,
        'modelId': modelId,
        'color': color,
        'manufacturingYear': manufacturingYear,

        'image': vehicleUrl
        // Note: Handling image uploads would require a multipart request.
        // For simplicity, this example does not cover image uploads.
        // You might need a separate API or endpoint to handle the image upload.
      }),
    );
    final List userImage = [vehicleUrl];
    print(userImage);
    if (response.statusCode == 200) {
      print('Successfully created the car ${response.body}');
      return true; //
    } else {
      print('Failed to create the car: ${response.body}');
      return false; // Failed to create the car
    }
  }

  Future<String?> getDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    String? token;
    try {
      token = await messaging.getToken();
      print('Device Token: $token');
      return token;
    } catch (e) {
      print('Failed to get FCM token: $e');
      return null;
    }
  }

  Future<bool> acceptOrder(String orderId, bool decision) async {
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Order/AcceptOrderForCustomer?id=$orderId&decision=$decision";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      },
      body: json.encode({'id': orderId, 'decision': decision}),
    );
    var data = json.decode(response.body);
    if (data['status'] == 200) {
      print('Successfully accept order ${response.body}');
      return true;
    } else if(data['status'] == 201) {
      print('Denied success: ${response.body}');
      return true;
    }else{
      print('Failed to accept order: ${response.body}');
    }
    return false;
  }

  Future<bool> startOrder(String orderId) async {
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Order/StartOrder?id=$orderId";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      },
      body: json.encode({'id': orderId}),
    );
    if (response.statusCode == 201) {
      print('Successfully starting order ${response.body}');
      return true;
    } else {
      print('Failed to start order: ${response.body}');
      // Failed to create the car
    }
    return false;
  }

  Future<dynamic> endOrder(String orderId) async {
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Order/EndOrder?id=$orderId";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
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

      return null; // You can return null or handle the error differently as needed
    }
  }

  Future<Map<String, Map<String, dynamic>>> fetchFeedbackRatings(
      String userId) async {
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Feedback/GetFeedbacksOfRVO?id=$userId"; // Your API endpoint

    try {
      final response =
          await http.get(Uri.parse(apiUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var feedbacks = jsonResponse['data']['feedbacks'] as List;

        Map<String, Map<String, dynamic>> feedbackData = {};

        for (var feedback in feedbacks) {
          String orderId = feedback['orderId'];
          int? rating = feedback['rating'];
          String? note = feedback['note'];

          feedbackData[orderId] = {'rating': rating, 'note': note};
        }

        return feedbackData;
      } else {
        print("Failed to fetch ratings. Status code: ${response.statusCode}");
        return {};
      }
    } catch (error) {
      print("Error fetching feedback ratings: $error");
      return {};
    }
  }

  Future<FeedbackData?> fetchFeedbackRatingCountofRVO(String userId) async {
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Feedback/GetFeedbacksOfRVO?id=$userId"; // Replace with your API endpoint

    try {
      final response =
          await http.get(Uri.parse(apiUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var dataField = jsonResponse['data'];
        FeedbackData feedbackData = FeedbackData.fromJson(dataField);
        print('Rating: ${feedbackData.rating}, Count: ${feedbackData.count}');
        return feedbackData;
      } else {
        print("Failed to fetch ratings. Status code: ${response.statusCode}");
        return null;
      }
    } catch (error) {
      print("Error fetching feedback ratings: $error");
      return null;
    }
  }

  Future<Map<String, Map<String, dynamic>>> fetchTechFeedbackRatings(
      String userId) async {
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Feedback/GetFeedbacksOfTeachnician?id=$userId"; // Your API endpoint

    try {
      final response =
          await http.get(Uri.parse(apiUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var feedbacks = jsonResponse['data']['feedbacks'] as List;

        Map<String, Map<String, dynamic>> feedbackData = {};

        for (var feedback in feedbacks) {
          String orderId = feedback['orderId'];
          int? rating = feedback['rating'];
          String? note = feedback['note'];

          feedbackData[orderId] = {'rating': rating, 'note': note};
        }

        return feedbackData;
      } else {
        print("Failed to fetch ratings. Status code: ${response.statusCode}");
        return {};
      }
    } catch (error) {
      print("Error fetching feedback ratings: $error");
      return {};
    }
  }

  Future<FeedbackData?> fetchFeedbackRatingCountofTech(String userId) async {
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Feedback/GetFeedbacksOfTeachnician?id=$userId"; // Replace with your API endpoint

    try {
      final response =
          await http.get(Uri.parse(apiUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var dataField = jsonResponse['data'];
        FeedbackData feedbackData = FeedbackData.fromJson(dataField);
        print('Rating: ${feedbackData.rating}, Count: ${feedbackData.count}');
        return feedbackData;
      } else {
        print("Failed to fetch ratings. Status code: ${response.statusCode}");
        return null;
      }
    } catch (error) {
      print("Error fetching feedback ratings: $error");
      return null;
    }
  }

  Future<List<String>> fetchImageUrls(String orderId) async {
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Order/GetImagesOfOrder?id=$orderId";
    // Make the HTTP GET request to the API
    final response =
        await http.get(Uri.parse(apiUrl), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken'
    });

    // Check if the response is successful
    if (response.statusCode == 200) {
      // Parse the JSON response
      final jsonResponse = json.decode(response.body);

      // Check if the 'status' is 'Success' and there's data
      if (jsonResponse['status'] == 'Success' && jsonResponse['data'] != null) {
        // Iterate over the data and collect all the URLs
        List<String> imageUrls = [];
        for (var item in jsonResponse['data']) {
          if (item['url'] != null) {
            imageUrls.add(item['url']);
          }
        }

        return imageUrls;
      } else {
        // Handle the case where there is no 'data' or status is not 'Success'
        throw Exception('Failed to load image URLs');
      }
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw Exception('Failed to load data from the API');
    }
  }

  Future<Map<String, dynamic>> fetchPayment(String orderId) async {
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Payment/GetPaymentOfOrder?id=$orderId";

    try {
      // Make the HTTP GET request to the API
      final response =
          await http.get(Uri.parse(apiUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });

      // Check if the response is successful
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        return jsonResponse;
      } else {
        // Handle non-200 responses
        print('Request failed with status: ${response.statusCode}.');
        throw Exception('Failed to load payment data');
      }
    } catch (e) {
      // Handle any exceptions
      print('An error occurred: $e');
      throw Exception('Failed to load payment data');
    }
  }

  Future<List<WorkShift>> getWeeklyShiftofTechnician(
      String weekId, String techId) async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Schedule/GetWeeklyShiftOfTechnician?id=$weekId&techID=$techId';
    try {
      final response =
          await http.post(Uri.parse(apiUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> shiftData = jsonData['data'];
        final List<WorkShift> shifts =
            shiftData.map((e) => WorkShift.fromJson(e)).toList();
        return shifts;
      } else {
        throw Exception('Failed to load data from the server');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<WorkShift>> getWeeklyShiftOfCarOwner(
      String weekId, String rvoId) async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Schedule/GetWeeklyShiftOfRVO?id=$weekId&rvoId=$rvoId';
    try {
      final response =
          await http.post(Uri.parse(apiUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });
      print('${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> shiftData = jsonData['data'];
        final List<WorkShift> shifts =
            shiftData.map((e) => WorkShift.fromJson(e)).toList();
        return shifts;
      } else {
        throw Exception('Failed to load data from the server');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<CurrentWeek> getCurrentWeek() async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Schedule/GetWorkWeeks';
    try {
      final response =
          await http.get(Uri.parse(apiUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Since the data is a single object and not a list
        final Map<String, dynamic> weekData = jsonData['data'];

        // Assuming you have a CurrentWeek class that matches the structure of weekData
        final CurrentWeek currentWeek = CurrentWeek.fromJson(weekData);
        print(currentWeek);
        return currentWeek;
      } else {
        throw Exception('Failed to load data from the server');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<CurrentWeek> getNextWeek(DateTime startDate) async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Schedule/GetWorkWeeksByStartDate?startdate=$startDate';
    try {
      final response =
          await http.get(Uri.parse(apiUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Since the data is a single object and not a list
        final Map<String, dynamic> weekData = jsonData['data'];

        // Assuming you have a CurrentWeek class that matches the structure of weekData
        final CurrentWeek currentViewWeek = CurrentWeek.fromJson(weekData);
        print(currentViewWeek);
        return currentViewWeek;
      } else {
        throw Exception('Failed to load data from the server');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Wallet> getWalletInfo(String userId) async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Wallet/GetWalletOfRVO?id=$userId';
    try {
      final response =
          await http.get(Uri.parse(apiUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final Map<String, dynamic> walletData = jsonData['data'];

        final Wallet wallet = Wallet.fromJson(walletData);
        print(wallet);
        return wallet;
      } else {
        print(response.statusCode);
        throw Exception('Failed to load data from the server');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<WalletTransaction>> getWalletTransaction(String walletId) async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Transaction/GetTransactionOfWallet?id=$walletId';
    try {
      final response =
          await http.get(Uri.parse(apiUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });
      print(response.body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> walletTransactionList = jsonData['data'];
        List<WalletTransaction> walletTransactions = walletTransactionList
            .map((data) => WalletTransaction.fromJson(data))
            .toList();
        return walletTransactions;
      } else {
        print('Failed with status code: ${response.statusCode}');
        throw Exception('Failed to load data from the server');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<List<BankingInfo>> getBankingInfo() async {
    final String apiUrl = 'https://api.vietqr.io/v2/banks';
    try {
      final response =
          await http.get(Uri.parse(apiUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });
      print(response.body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> bankingList = jsonData['data'];
        List<BankingInfo> bankings =
            bankingList.map((data) => BankingInfo.fromJson(data)).toList();
        return bankings;
      } else {
        print('Failed with status code: ${response.statusCode}');
        throw Exception('Failed to load data from the server');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<bool> completedOrder(String orderId, bool decision) async {
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Payment/CompletePayment?id=$orderId&boolean=$decision";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      },
      body: json.encode({'id': orderId, 'decision': decision}),
    );
    if (response.statusCode == 200) {
      print('Successfully complete order ${response.body}');
      return true;
    } else {
      print('Failed to accept order: ${response.body}');
      // Failed to create the car
    }
    return false;
  }

  Future<CarModel> fetchCarModel(String modelId) async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Model/Get?id=$modelId';

    try {
      final response =
          await http.get(Uri.parse(apiUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        var dataField = data['data'];
        CarModel carModelAPI = CarModel.fromJson(
            dataField); // Convert the map to a CarModel object
        return carModelAPI;
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching or parsing CarModel: $e');
      throw Exception('Error fetching or parsing CarModel: $e');
    }
  }

  Future<Map<String, double>> getLiveLocation(String techId) async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Location/GetLocation?id=$techId';

    try {
      final response =
          await http.get(Uri.parse(apiUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });
      print('codew real :${response.statusCode}');
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        var dataField = data['data'];

        print('day la1: $dataField');
        if (dataField != null && dataField is Map<String, dynamic>) {
          // Parse the "body" string as JSON
          Map<String, dynamic> bodyData = json.decode(dataField['body']);
          print(json.decode(dataField['body']));
          // Access "Lat" and "Long"
          double lat = double.parse(bodyData['Lat']);
          double long = double.parse(bodyData['Long']);

          print('Latitude: $lat, Longitude: $long');

          // Return the latitude and longitude as a Map
          return {'lat': lat, 'long': long};
        } else {
          print('Invalid or missing "data" field in the API response.');
        }
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        print('Error fetching data: ${e.message}');
      } else if (e is http.Response) {
        print('Error in HTTP request. Status code: ${e.statusCode}');
        print('Response body: ${e.body}');
      } else {
        print('Error fetching or parsing data: $e');
      }
      throw Exception('Error fetching or parsing data: $e');
    }

    // Return an empty Map in case of an error
    return {};
  }

  Future<List<Notify>> getAllNotiList(String accountId) async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Notification/Getall?id=$accountId';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print("${response.statusCode}");
      if (response.statusCode == 200) {
        // Parse the JSON response and handle the data
        final List<dynamic> jsonData = json.decode(response.body);
        // Assuming you have a Notification class to represent the data
        List<Notify> notifications = List.from(
          jsonData.map((notification) => Notify.fromJson(notification)),
        );

        print(notifications);
        // Process the list of notifications as needed

        return notifications;
      } else {
        print('Error: ${response.statusCode}');
        // Handle non-200 status code when fetching notifications
        throw Exception('Failed to fetch notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      // Handle other errors that may occur during the HTTP request
      throw Exception('Failed to fetch notifications');
    }
  }

  Future<void> sendNotification({
    required String deviceId,
    required bool isAndroidDevice,
    required String title,
    required String body,
    required String target,
    required String orderId,
  }) async {
    final url = Uri.parse(
        'https://rescuecapstoneapi.azurewebsites.net/api/Notification/send');

    final payload = {
      "deviceId": deviceId,
      "isAndroiodDevice": isAndroidDevice,
      "title": title,
      "body": body,
    };
    print(payload);
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        },
        body: json.encode(payload),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print(
            'Failed to send notification. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending notification: $error');
    }
  }

  Future<void> createLocation({
    required String id,
    required String lat,
    required String long,
  }) async {
    final url = Uri.parse(
        'https://rescuecapstoneapi.azurewebsites.net/api/Location/Create');

    final payload = {'id': id, 'lat': lat, 'long': long};
    print(payload);
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        },
        body: json.encode(payload),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('Create location successfully');
      } else {
        print('Failed to create location. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error to create location: $error');
    }
  }

  Future<void> updateLocation({
    required String id,
    required String lat,
    required String long,
  }) async {
    final url = Uri.parse(
        'https://rescuecapstoneapi.azurewebsites.net/api/Location/Update');

    final payload = {'id': id, 'lat': lat, 'long': long};
    print(payload);
    try {
      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        },
        body: json.encode(payload),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('Update location successfully');
      } else {
        print('Failed to update location. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error to update location: $error');
    }
  }
}
