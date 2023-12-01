import 'package:flutter/material.dart';

class CarStatus extends StatelessWidget {
  final String status;

  CarStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    TextStyle statusTextStyle;
    String displayText;

    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Color(0xffdff6de);
        statusTextStyle = TextStyle(
          color: Color(0xff00721e),
          fontWeight: FontWeight.bold,
        );
        displayText = 'Hoạt động';
        break;
      case 'assigned':
        statusColor = Color(0xffc9e5fb);
        statusTextStyle = TextStyle(
          color: Color(0xff276fdb),
          fontWeight: FontWeight.bold,
        );
        displayText = 'Đã phân công';
        break;
      case 'rejected':
        statusColor = Color.fromARGB(47, 251, 201, 201);
        statusTextStyle = TextStyle(
          color: Color.fromARGB(167, 205, 12, 12),
          fontWeight: FontWeight.bold,
        );
        displayText = 'Từ chối';
        break;
      case 'waiting_approval':
        statusColor = Color.fromARGB(216, 251, 251, 201);
        statusTextStyle = TextStyle(
          color: Color.fromARGB(167, 205, 199, 12),
          fontWeight: FontWeight.bold,
        );
        displayText = 'Chờ phê duyệt';
        break;
      case 'new':
        statusColor = Color.fromARGB(215, 251, 201, 251);
        statusTextStyle = TextStyle(
          color: Color.fromARGB(167, 144, 12, 205),
          fontWeight: FontWeight.bold,
        );
        displayText = 'Mới';
        break;
      case 'inactive':
        statusColor = Color.fromARGB(215, 212, 212, 196);
        statusTextStyle = TextStyle(
          color: Color.fromARGB(167, 53, 53, 42),
          fontWeight: FontWeight.bold,
        );
        displayText = 'Không hoạt động';
        break;
      default:
        statusColor = Colors.blue;
        statusTextStyle = TextStyle(
          color: Colors.white,
        );
        displayText = status; // Display the status as is if no match
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        displayText,
        style: statusTextStyle,
      ),
    );
  }
}
