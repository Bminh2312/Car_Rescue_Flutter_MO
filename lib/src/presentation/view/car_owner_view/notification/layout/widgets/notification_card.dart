import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationItem {
  final int id;
  final String title;
  final String content;
  final String status;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.status,
    required this.createdAt,
  });
}

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  NotificationCard({required this.notification});

  Icon _getAvatarIcon() {
    double iconSize = 40.0; // Adjust the size as needed

    // Define your logic to determine the appropriate icon based on notification status
    if (notification.status == 'Mới') {
      // Mới status
      return Icon(
        Icons.build_circle_rounded, // Wrench icon for Mới status
        color: Colors.blue,
        size: iconSize,
      );
    } else if (notification.status == 'Hoàn thành') {
      // Hoàn thành status
      return Icon(
        Icons.verified, // Green verified icon for Hoàn thành status
        color: Colors.green,
        size: iconSize,
      );
    } else {
      // Đã huỷ status
      return Icon(
        Icons.close, // Red cross icon for Đã huỷ status
        color: Colors.red,
        size: iconSize,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.all(10.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(20.0),
        leading: CircleAvatar(
          backgroundColor:
              const Color.fromARGB(0, 96, 125, 139), // Default background color
          child: _getAvatarIcon(),
        ),
        title: Text(
          notification.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(notification.content),
            Text(
              '${DateFormat('dd, MMMM, yyyy HH:mm').format(notification.createdAt)}',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        onTap: () {
          // Handle tapping on the notification
        },
      ),
    );
  }
}

// The rest of your code remains the same
