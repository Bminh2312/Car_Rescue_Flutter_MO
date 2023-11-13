import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';

class TimeRangePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.access_time),
      onPressed: () async {
        TimeRange? result = await showTimeRangePicker(
          context: context,
          start: TimeOfDay(hour: 9, minute: 0),
          end: TimeOfDay(hour: 17, minute: 0),
          interval: Duration(minutes: 30),
        );
        if (result != null) {
          print("result: ${result.startTime}, ${result.endTime}");
        }
      },
    );
  }
}
