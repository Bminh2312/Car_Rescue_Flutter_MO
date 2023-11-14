import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:flutter/material.dart';

class CustomerInfoRow extends StatelessWidget {
  final String name;
  final String phone;
  final String avatar;
  CustomerInfoRow({
    required this.name,
    required this.phone,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: FrontendConfigs.kBackgrColor,
            backgroundImage: NetworkImage(avatar),
            radius: 30.0,
          ),
          SizedBox(width: 16.0), // Add spacing between avatar and text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 250,
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              Text(
                phone,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
