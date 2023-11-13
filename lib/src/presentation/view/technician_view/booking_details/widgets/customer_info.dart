import 'package:flutter/material.dart';

class CustomerInfoRow extends StatelessWidget {
  final String name;
  final String phone;

  CustomerInfoRow({
    required this.name,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/avatars-2.png'),
            radius: 30.0,
          ),
          SizedBox(width: 16.0), // Add spacing between avatar and text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
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
