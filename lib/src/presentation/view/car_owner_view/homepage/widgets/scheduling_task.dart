import 'package:flutter/material.dart';

class TaskSchedulingCard extends StatelessWidget {
  final String taskTitle;
  final String taskTime;
  final String taskDescription;
  final String taskCreated;

  TaskSchedulingCard({
    required this.taskTitle,
    required this.taskTime,
    required this.taskDescription,
    required this.taskCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            taskTitle,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            taskTime,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 12.0),
          Text(
            taskDescription,
            style: TextStyle(fontSize: 16.0),
          ),
          SizedBox(height: 12.0),
          Text(
            'Date: ${taskCreated}',
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
