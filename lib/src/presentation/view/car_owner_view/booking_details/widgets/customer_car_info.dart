import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:flutter/material.dart';

class CustomerCarInfoRow extends StatelessWidget {
  final String type;
  final String manufacturer;
  final String licensePlate;
  final String image;
  CustomerCarInfoRow({
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
          CircleAvatar(
            backgroundImage: NetworkImage(image),
            radius: 30.0,
          ),
          SizedBox(width: 16.0), // Add spacing between avatar and text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 250,
                child: Text(
                  manufacturer,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              Container(
                width: 250,
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
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
        ],
      ),
    );
  }
}
