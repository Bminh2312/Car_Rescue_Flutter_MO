import 'package:flutter/material.dart';

class CarStatus extends StatelessWidget {
  final String status;

  CarStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    TextStyle statusTextStyle;
    String statusText; // Variable to hold the display text

    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Color(0xffdff6de);
        statusTextStyle = TextStyle(
          color: Color(0xff00721e),
          fontWeight: FontWeight.bold,
        );
        statusText = 'Hoạt động'; // Text for 'active' status
        break;
      case 'assigned':
        statusColor = Color(0xffc9e5fb);
        statusTextStyle = TextStyle(
          color: Color(0xff276fdb),
          fontWeight: FontWeight.bold,
        );
        statusText = 'Đã giao'; // Text for 'assigned' status
        break;
      case 'rejected':
        statusColor = Color.fromARGB(47, 251, 201, 201);
        statusTextStyle = TextStyle(
          color: Color.fromARGB(167, 205, 12, 12),
          fontWeight: FontWeight.bold,
        );
        statusText = 'Từ chối'; // Text for 'rejected' status
        break;
      case 'waiting_approval':
        statusColor = Color.fromARGB(216, 251, 251, 201);
        statusTextStyle = TextStyle(
          color: Color.fromARGB(167, 205, 199, 12),
          fontWeight: FontWeight.bold,
        );
        statusText = 'Chờ phê duyệt';
        break; // Text for 'waiting_approval' status
      case 'inactive':
        statusColor = Color.fromARGB(53, 251, 251, 201);
        statusTextStyle = TextStyle(
          color: Color.fromARGB(182, 169, 169, 166),
          fontWeight: FontWeight.bold,
        );
        statusText = 'Không hoạt động'; // Text for 'waiting_approval' status
        break;
      default:
        statusColor = Colors.blue;
        statusTextStyle = TextStyle(
          color: Colors.white,
        );
        statusText = 'Khác'; // Default text
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        statusText, // Use the appropriate text based on the status
        style: statusTextStyle,
      ),
    );
  }
}
