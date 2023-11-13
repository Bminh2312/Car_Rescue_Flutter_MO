// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';

// class DatePickerWidget extends StatefulWidget {
//   final Function(DateTime) onDateSelected;

//   DatePickerWidget({required this.onDateSelected});

//   @override
//   _DatePickerWidgetState createState() => _DatePickerWidgetState();
// }

// class _DatePickerWidgetState extends State<DatePickerWidget> {
//   DateTime _selectedDate = DateTime.now();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Container(
//       child: Expanded(child: SfDateRangePicker()),
//     ));
//   }
// }

//   // Future<void> _showDatePicker() async {
//   //   var datePicked = await DatePicker.showSimpleDatePicker(
//   //     context,
//   //     initialDate: DateTime.now(),
//   //     firstDate: DateTime(2000),
//   //     lastDate: DateTime(2100),
//   //     dateFormat: "dd-MMMM-yyyy",
//   //     locale: DateTimePickerLocale.en_us,
//   //     looping: true, // set looping true for infinite scrolling
//   //   );

//   //   if (datePicked != null && datePicked != _selectedDate) {
//   //     setState(() {
//   //       _selectedDate = datePicked;
//   //       widget.onDateSelected(_selectedDate);
//   //     });
//   //   }
//   // }

