import 'package:flutter/material.dart';

class BookingStatus extends StatelessWidget {
  final String status;

  BookingStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    TextStyle statusTextStyle;

    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = Color(0xffdff6de);
        statusTextStyle = TextStyle(
          color: Color(0xff00721e),
          fontWeight: FontWeight.bold,
        );
        break;
      case 'assigned':
        statusColor = Color(0xffc9e5fb);
        statusTextStyle = TextStyle(
          color: Color(0xff276fdb),
          fontWeight: FontWeight.bold,
        );
        break;
      case 'cancelled':
        statusColor = Color.fromARGB(255, 251, 201, 201);
        statusTextStyle = TextStyle(
          color: Color.fromARGB(255, 219, 39, 39),
          fontWeight: FontWeight.bold,
        );
        break;
      case 'canceled':
        statusColor = Color.fromARGB(255, 251, 201, 201);
        statusTextStyle = TextStyle(
          color: Color.fromARGB(255, 219, 39, 39),
          fontWeight: FontWeight.bold,
        );
        break;
      case 'inprogress':
        statusColor = Color.fromARGB(255, 251, 247, 201);
        statusTextStyle = TextStyle(
          color: Color.fromARGB(255, 228, 203, 10),
          fontWeight: FontWeight.bold,
        );
        break;
      default:
        statusColor = Colors.blue;
        statusTextStyle = TextStyle(
          color: Colors.white,
        );
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        status,
        style: statusTextStyle,
      ),
    );
  }
}
