import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:flutter/material.dart';

class VehicleInfoRow extends StatelessWidget {
  final String type;
  final String manufacturer;
  final String licensePlate;
  final String image;
  VehicleInfoRow({
    required this.type,
    required this.licensePlate,
    required this.image,
    required this.manufacturer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  manufacturer,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.grey.shade300),
                  child: Text(
                    licensePlate,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: FrontendConfigs.kAuthColor),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 12,
          ),
          CircleAvatar(
            backgroundImage: NetworkImage(image),
            radius: 30.0,
          ),
        ],
      ),
    );
  }
}
