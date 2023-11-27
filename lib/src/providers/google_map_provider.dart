import 'package:CarRescue/src/enviroment/env.dart';
import 'package:CarRescue/src/models/location_info.dart';
import 'package:CarRescue/src/models/routes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:intl/intl.dart';

class LocationProvider {
  final String key = Environment.API_KEY_MAPS;
  final String url = Environment.API_URL_PLACES_NEW;
  final String keyPredictions = Environment.API_KEY_PREDICTIONS;

  Future<LatLng> searchPlaces(String searchText) async {
    var headers = {
      'Content-Type': 'application/json',
      // 'x-android-package': 'com.infusibleCoder.raido',
      // 'x-android-cert': 'c3:88:f2:12:85:1e:23:55:dc:17:28:f2:1b:57:8a:4a:a0:9c:c9:6e',
      'X-Goog-Api-Key': key,
      'X-Goog-FieldMask':
          'places.displayName,places.formattedAddress,places.location,places.priceLevel',
    };

    var body = {
      'textQuery': '$searchText',
    };

    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: convert.jsonEncode(body),
    );

    if (response.statusCode == 200) {
      var responseData = convert.jsonDecode(response.body);
      var locationMap = responseData['places'][0]['location'];
      var latitude = locationMap['latitude'];
      var longitude = locationMap['longitude'];
      LatLng newPosition = LatLng(latitude, longitude);
      print(newPosition);
      return newPosition;
    } else {
      print('Error: ${response.statusCode}');
      print("Body: ${response.body}");
      throw Exception('Failed to fetch location');
    }
  }

  Future<LatLng> getLongLat(String refid) async {
    final apiKey = 'c3d0f188ff669f89042771a20656579073cffec5a8a69747';
    final url = Uri.parse(
        'https://maps.vietmap.vn/api/place/v3?apikey=$apiKey&refid=$refid');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = convert.json.decode(response.body);
        final lat = double.parse(data['lat'].toString());
        final lng = double.parse(data['lng'].toString());
        return LatLng(lat, lng);
      } else {
        // Xử lý lỗi tại đây nếu cần
        print('Error: ${response.statusCode}');
        return LatLng(0, 0);
      }
    } catch (e) {
      // Xử lý lỗi mạng tại đây nếu cần
      print('Network Error: $e');
      return LatLng(0, 0);
    }
  }

  Future<LatLng> getPlaceDetails(String placeId) async {
    final places = GoogleMapsPlaces(apiKey: key);
    try {
      PlacesDetailsResponse placeDetails =
          await places.getDetailsByPlaceId(placeId);

      if (placeDetails.isOkay) {
        // Lấy thông tin chi tiết của địa điểm, bao gồm LatLng
        final latLng = placeDetails.result.geometry!.location;
        final address = placeDetails.result.formattedAddress;

        // In thông tin lên console
        print("Location Address: $address");
        print("Location LatLng: ${latLng.lat}, ${latLng.lng}");

        return LatLng(latLng.lat, latLng.lng);
      } else {
        print("Failed to get place details.");
        return LatLng(0, 0);
      }
    } catch (e) {
      print(e);
      return LatLng(0, 0);
    }
  }

  Future<PlacesAutocompleteResponse> getPlacePredictions(String input) async {
    try {
      final places = GoogleMapsPlaces(
          apiKey: key, apiHeaders: await const GoogleApiHeaders().getHeaders());
      final response = await places.autocomplete(
        input,
        language: 'vn',
        components: [
          Component(Component.country, 'vn')
        ], // Thay thế bằng quốc gia
      );

      if (response.isOkay) {
        return response;
      } else {
        return PlacesAutocompleteResponse(
            status: 'ZERO_RESULTS', predictions: []);
      }
    } catch (e) {
      print('Error fetching place predictions: $e');
      return PlacesAutocompleteResponse(status: 'ERROR', predictions: []);
    }
  }

//   Future<List<LocationInfo>> getDisplayNames(String searchText) async {
//   final Map<String, String> params = {
//     'q': searchText,
//     'format': 'json',
//     'addressdetails': '1',
//     'polygon_geojson': '0',
//   };
//   final Uri uri = Uri.https('nominatim.openstreetmap.org', '/search', params);

//   final Map<String, String> headers = {
//     'Content-Type': 'application/json',
//   };

//   try {
//     final response = await http.get(uri, headers: headers);

//     if (response.statusCode == 200) {
//       final List<dynamic> data = convert.json.decode(response.body);
//       if (data.isNotEmpty) {
//         final locationInfoList = data.map((result) {
//           return LocationInfo.fromJson(result);
//         }).toList();
//         return locationInfoList;
//       } else {
//         // Return an empty list if data is empty
//         return [];
//       }
//     } else {
//       throw Exception('Lỗi kết nối');
//     }
//   } catch (e) {
//     throw Exception('Lỗi: $e');
//   }
// }

  Future<List<LocationInfo>> getDisplayNamesByVietMap(String searchText) async {
    final Map<String, String> params = {
      'apikey': 'c3d0f188ff669f89042771a20656579073cffec5a8a69747',
      'cityId': '12',
      'text': searchText,
      'circle_center': '10.8760856947,106.801249981',
      'circle_radius': '50000',
      'layers': 'POI',
    };

    final Uri uri =
        Uri.https('maps.vietmap.vn', '/api/autocomplete/v3', params);

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = convert.json.decode(response.body);
        if (data.isNotEmpty) {
          final locationInfoList = data.map((result) {
            return LocationInfo.fromJson(result);
          }).toList();
          return locationInfoList;
        } else {
          // Return an empty list if data is empty
          return [];
        }
      } else {
        throw Exception('Lỗi kết nối');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  Future<String> getAddressDetail(String latLng) async {
  final latMatchDeparture = RegExp(r'lat:\s?([\-0-9.]+)').firstMatch(latLng);
  final longMatchDeparture = RegExp(r'long:\s?([\-0-9.]+)').firstMatch(latLng);
  final double? latDeparture = double.tryParse(latMatchDeparture?.group(1) ?? '');
  final double? longDeparture = double.tryParse(longMatchDeparture?.group(1) ?? '');

  if (latDeparture == null || longDeparture == null) {
    // Xử lý khi không thể phân tích tọa độ
    return "Invalid Coordinates";
  }

  final String urlDeparture =
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latDeparture,$longDeparture&key=$key';
  
  final responseDeparture = await http.get(Uri.parse(urlDeparture));

  if (responseDeparture.statusCode == 200) {
    final jsonResult = convert.json.decode(responseDeparture.body);
    if (jsonResult['status'] == 'OK') {
      // Lấy địa chỉ từ kết quả JSON
      final results = jsonResult['results'] as List;
      if (results.isNotEmpty) {
        final firstResult = results.first;
        final formattedAddress = firstResult['formatted_address'];
        return formattedAddress;
      } else {
        return "No Address Found";
      }
    } else {
      return "No Address Found";
    }
  } else {
    // Xử lý lỗi nếu có lỗi kết nối
    return "Connection Error";
  }
}

Future<RouteResponse> fetchRoutes(LatLng latLngDep, LatLng latLngDes) async {

  final String apiUrl = 'https://routes.googleapis.com/directions/v2:computeRoutes';

  DateTime futureTime = DateTime.now().toUtc().add(Duration(hours: 1));

  final Map<String, dynamic> requestData = {
    "origin": {
      "location": {
        "latLng": {
          "latitude": latLngDep.latitude,
          "longitude": latLngDep.longitude
        }
      }
    },
    "destination": {
      "location": {
        "latLng": {
          "latitude": latLngDes.latitude,
          "longitude": latLngDes.longitude
        }
      }
    },
    "travelMode": "DRIVE",
    "routingPreference": "TRAFFIC_AWARE",
    "departureTime": DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSSSSSS'Z'").format(futureTime),
    "computeAlternativeRoutes": false,
    "routeModifiers": {
      "avoidTolls": false,
      "avoidHighways": false,
      "avoidFerries": false
    },
    "languageCode": "en-US",
    "units": "IMPERIAL"
  };

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'X-Goog-Api-Key': key,
    'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
  };

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: convert.jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      // Handle the successful response here
      final Map<String, dynamic> responseData = convert.jsonDecode(response.body);
      // Extract and use the relevant data from responseData
      print(responseData);
      return RouteResponse.fromJson(responseData);
    } else {
      // Handle the error response here
      print('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to fetch routes');
    }
  } catch (e) {
    // Handle exceptions here
    print('Exception: $e');
    throw Exception('Failed to fetch routes');
  }
}

}
