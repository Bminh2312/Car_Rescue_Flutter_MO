import 'package:CarRescue/src/models/notification.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  final Notify notification;

  NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    DateTime originalDateTime = notification.createdAt;
    DateTime newDateTime = originalDateTime.add(Duration(hours: 14));

    String formattedDateTime =
        DateFormat('dd MMM yyyy • HH:mm').format(newDateTime);
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(20.0),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                notification.content,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              Text(
                formattedDateTime,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          // Handle tapping on the notification
        },
      ),
    );
  }
}
