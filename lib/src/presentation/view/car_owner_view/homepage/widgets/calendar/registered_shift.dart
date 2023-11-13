import 'package:flutter/material.dart';

class RegisteredShiftsTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Hiển thị các mốc thời gian đã đăng ký
          TimelineTile(
              icon: Icon(Icons.access_time),
              date: 'Hôm qua',
              shift: '7:00 - 15:00'),
          TimelineTile(
              icon: Icon(Icons.access_time),
              date: 'Hôm nay',
              shift: '15:00 - 23:00'),
          TimelineTile(
              icon: Icon(Icons.access_time),
              date: 'Ngày mai',
              shift: '23:00 - 7:00'),
        ],
      ),
    );
  }
}

// Timeline riêng lẻ
class TimelineTile extends StatelessWidget {
  final Icon icon;
  final String date;
  final String shift;

  TimelineTile({required this.icon, required this.date, required this.shift});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.abc,
            color: Colors.lightBlueAccent,
            size: 36,
          ),
          SizedBox(height: 8),
          Text('abc',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(
            'abc',
            style: TextStyle(fontSize: 14),
          )
        ],
      ),
    );
  }
}
