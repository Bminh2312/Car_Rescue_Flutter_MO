import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
// ...

class LocationService {
  final WebSocketChannel channel;

  LocationService(String techId)
      : channel =
            IOWebSocketChannel.connect('ws://rescuecapstoneapi.azurewebsites.net/api/Location/GetLocation?id=$techId');

  Stream<Map<String, double>> get locationStream {
    return channel.stream.map((event) {
      Map<String, dynamic> data = json.decode(event);
      var dataField = data['data'];

      if (dataField != null && dataField is Map<String, dynamic>) {
        Map<String, dynamic> bodyData = json.decode(dataField['body']);
        double lat = double.parse(bodyData['Lat']);
        double long = double.parse(bodyData['Long']);
        return {'lat': lat, 'long': long};
      } else {
        print('Invalid or missing "data" field in the WebSocket message.');
        return {};
      }
    });
  }

  void closeWebSocket() {
    channel.sink.close();
  }
}
