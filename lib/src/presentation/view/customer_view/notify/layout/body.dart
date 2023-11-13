import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotifyBody extends StatefulWidget {
  final Object message;
  const NotifyBody({super.key, required this.message});

  @override
  State<NotifyBody> createState() => _NotifyBodyState();
}

class _NotifyBodyState extends State<NotifyBody> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Push notifycations page"),
          
          Text("Message: ${widget.message}"), // Hiển thị message ở đây nếu không phải null
        ],
      ),
    );
  }
}