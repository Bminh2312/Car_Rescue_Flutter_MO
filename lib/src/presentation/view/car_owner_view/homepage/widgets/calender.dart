// // Copyright 2019 Aleksander Woźniak
// // SPDX-License-Identifier: Apache-2.0

// import 'dart:collection';

// import 'package:CarRescue/src/configuration/frontend_configs.dart';
// import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:intl/intl.dart';
// import 'package:intl/date_symbol_data_local.dart';

// class CalendarScreen extends StatefulWidget {
//   @override
//   _CalendarScreenState createState() => _CalendarScreenState();
// }

// class _CalendarScreenState extends State<CalendarScreen> {
//   DateTime? _selectedDay;
//   late LinkedHashMap<DateTime, List<Event>> events;

//   @override
//   void initState() {
//     super.initState();
//     initializeDateFormattingVietnamese();
//     _selectedDay = DateTime.now();
//     events = LinkedHashMap(
//       equals: isSameDay,
//       hashCode: (dt) => dt.day,
//     )..addAll({
//         DateTime.now().subtract(Duration(days: 3)): [
//           Event(
//               time: "10:00AM - 11:00AM",
//               caregiver: "Ronaldo, Messi",
//               client: "Huff, Emma",
//               isScheduled: true,
//               date: DateTime.now().subtract(Duration(days: 3))),
//         ],
//         DateTime.now().subtract(Duration(days: 2)): [
//           Event(
//               time: "8:00PM - 8:00AM",
//               caregiver: "Ronaldo, Messi",
//               client: "Huff, Emma",
//               isScheduled: true,
//               date: DateTime.now().subtract(Duration(days: 2))),
//           Event(
//               time: "8:00PM - 8:00AM",
//               caregiver: "Ronaldo, Messi",
//               client: "Huff, Emma",
//               isScheduled: true,
//               date: DateTime.now().subtract(Duration(days: 2))),
//           Event(
//               time: "8:00PM - 8:00AM",
//               caregiver: "Ronaldo, Messi",
//               client: "Huff, Emma",
//               isScheduled: true,
//               date: DateTime.now().subtract(Duration(days: 2))),
//           Event(
//               time: "8:00PM - 8:00AM",
//               caregiver: "Ronaldo, Messi",
//               client: "Huff, Emma",
//               isScheduled: true,
//               date: DateTime.now().subtract(Duration(days: 2))),
//         ],
//       });
//   }
// Color primaryColor = Colors.lightBlue[300]!;
// Color secondaryColor = Colors.yellow[200]!;

// // Hàm hiển thị modal bottom sheet
// void showRegisterShiftModal(BuildContext context) {

//   showModalBottomSheet(
//     context: context,
//     builder: (context) {
    
//       return Container(
//         height: 400,
//         padding: EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
          
//           // Tiêu đề modal
//           children: [
//             Text('Đăng Ký Ca Làm Việc', 
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: primaryColor
//               )
//             ),
            
//             SizedBox(height: 20),
            
//             // Lịch chọn ngày
//             Text('Chọn Ngày',
//               style: TextStyle(
//                 fontSize: 16, 
//                 color: secondaryColor
//               ),
//             ),
            
//             // Sử dụng lịch xoay hình tròn
//             DatePickerWidget(
//               onDateSelected: (datetime) {
//                 // Xử lý ngày được chọn
//               }  
//             ),
              
//             // Chọn khung giờ làm việc          
//             Text('Chọn Giờ Làm Việc',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: secondaryColor  
//               ), 
//             ),
            
//             // Cho phép chọn giờ linh hoạt
//             TimeRangePicker(),
            
//             // Hiển thị lịch sử đã đăng ký
//             Text('Lịch Sử Đăng Ký',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: secondaryColor
//               ),
//             ),
            
//             // Dạng timeline
//             RegisteredShiftsTimeline(),
            
//             // Button đăng ký
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 primary: primaryColor,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20)
//                 )  
//               ),
              
//               child: Text('Xác Nhận'),
//               onPressed: () {
//                 // Xử lý đăng ký ca làm
//               },
//             ),
//           ],
//         ),
//       );
      
//     }
//   );
  
// }

//   void initializeDateFormattingVietnamese() async {
//     await initializeDateFormatting('vi_VN', null);
//   }

//   List<Event> _getEventsForDay(DateTime day) {
//     return events[day] ?? [];
//   }

//   List<Event> _getEventsForWeek(DateTime startDay) {
//     List<Event> weeklyEvents = [];
//     for (int i = 0; i < 7; i++) {
//       DateTime currentDay = startDay.add(Duration(days: i));
//       weeklyEvents.addAll(events[currentDay] ?? []);
//     }
//     return weeklyEvents;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text(
//           'Lịch làm việc',
//           style: TextStyle(
//               color: FrontendConfigs.kPrimaryColor,
//               fontSize: 16,
//               fontWeight: FontWeight.bold),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             color: FrontendConfigs.kPrimaryColor,
//             icon: Icon(Icons.add),
//             onPressed: () {
//               _showRegisterShiftModal(context);
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           TableCalendar(
//             locale: 'vi_VN',
//             firstDay: DateTime.utc(2010, 10, 16),
//             lastDay: DateTime.utc(2030, 3, 14),
//             focusedDay: DateTime.now(),
//             eventLoader: _getEventsForDay,
//             calendarFormat: CalendarFormat.twoWeeks,
//             onDaySelected: (selectedDay, focusedDay) {
//               setState(() {
//                 _selectedDay = selectedDay;
//               });
//             },
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _getEventsForWeek(DateTime.now()
//                       .subtract(Duration(days: DateTime.now().weekday - 1)))
//                   .length,
//               itemBuilder: (context, index) {
//                 final event = _getEventsForWeek(DateTime.now().subtract(
//                     Duration(days: DateTime.now().weekday - 1)))[index];
//                 return Card(
//                   margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                   elevation: 3,
//                   child: Stack(
//                     children: [
//                       // The "10 SEP" column
//                       Positioned(
//                         left: 0,
//                         top: 0,
//                         bottom: 0,
//                         child: Container(
//                           width: 50,
//                           decoration: BoxDecoration(
//                             color: FrontendConfigs.kActiveColor,
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(10),
//                               bottomLeft: Radius.circular(10),
//                             ),
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 DateFormat('MMM')
//                                     .format(event.date)
//                                     .toUpperCase(),
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               Text(
//                                 DateFormat('d').format(event.date),
//                                 style: TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       // The rest of the content
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(
//                                 width:
//                                     60), // Adjusted to accommodate the "10 SEP" column
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     event.time,
//                                     style: TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   SizedBox(height: 5),
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         'Manager',
//                                         style:
//                                             TextStyle(color: Colors.grey[600]),
//                                       ),
//                                       Text('Client',
//                                           style: TextStyle(
//                                               color: Colors.grey[600])),
//                                     ],
//                                   ),
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         event.caregiver,
//                                         style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                       Text(
//                                         event.client,
//                                         style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                     ],
//                                   ),
//                                   if (event.isScheduled)
//                                     Align(
//                                       alignment: Alignment.centerLeft,
//                                       child: Chip(
//                                         padding: EdgeInsets.zero,
//                                         label: Text("SCHEDULED"),
//                                         backgroundColor: Colors.green,
//                                         labelStyle: TextStyle(
//                                             color: Colors.white,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// class Event {
//   final String time;
//   final String caregiver;
//   final String client;
//   final bool isScheduled;
//   final DateTime date; // Add this line

//   Event(
//       {required this.time,
//       required this.caregiver,
//       required this.client,
//       required this.isScheduled,
//       required this.date}); // Modify this line
// }
