import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class WebsocketDemo extends StatefulWidget {
  const WebsocketDemo({Key? key}) : super(key: key);

  @override
  State<WebsocketDemo> createState() => _WebsocketDemoState();
}

class _WebsocketDemoState extends State<WebsocketDemo> {
  late IOWebSocketChannel channel;
  String locationMessage = 'Waiting for location updates...';

  @override
  void initState() {
    super.initState();
    channel =
        IOWebSocketChannel.connect('wss://rescuesocketio.webpubsub.azure.com');

    channel.stream.listen((event) {
      Map<String, dynamic> data = json.decode(event);
      var dataField = data['data'];

      if (dataField != null && dataField is Map<String, dynamic>) {
        Map<String, dynamic> bodyData = json.decode(dataField['body']);
        double lat = double.parse(bodyData['Lat']);
        double long = double.parse(bodyData['Long']);
        setState(() {
          locationMessage = 'Latitude: $lat, Longitude: $long';
        });
      } else {
        print('Invalid or missing "data" field in the WebSocket message.');
      }
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Location Updates'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Location Updates:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              locationMessage,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
