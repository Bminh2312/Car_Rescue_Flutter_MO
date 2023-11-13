import 'dart:collection';

import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarView extends StatefulWidget {
  final Function(BuildContext context)? showRegisterShiftModal;

  CalendarView({this.showRegisterShiftModal});
  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime? _selectedDay;
  late LinkedHashMap<DateTime, List<Event>> events;
  String? selectedShift;
  DateTime selectedDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.showRegisterShiftModal?.call(context);
    });
    initializeDateFormattingVietnamese();
    _selectedDay = DateTime.now();
    events = LinkedHashMap(
      equals: isSameDay,
      hashCode: (dt) => dt.day,
    )..addAll({
        DateTime.now(): [
          Event(
              time: "10:00AM - 11:00AM",
              caregiver: "Ronaldo, Messi",
              client: "Huff, Emma",
              isScheduled: true,
              date: DateTime.now()),
          Event(
              time: "10:00AM - 11:00AM",
              caregiver: "Ronaldo, Messi",
              client: "Huff, Emma",
              isScheduled: true,
              date: DateTime.now()),
          Event(
              time: "10:00AM - 11:00AM",
              caregiver: "Ronaldo, Messi",
              client: "Huff, Emma",
              isScheduled: true,
              date: DateTime.now()),
          Event(
              time: "10:00AM - 11:00AM",
              caregiver: "Ronaldo, Messi",
              client: "Huff, Emma",
              isScheduled: true,
              date: DateTime.now()),
          Event(
              time: "10:00AM - 11:00AM",
              caregiver: "Ronaldo, Messi",
              client: "Huff, Emma",
              isScheduled: true,
              date: DateTime.now()),
          Event(
              time: "10:00AM - 11:00AM",
              caregiver: "Ronaldo, Messi",
              client: "Huff, Emma",
              isScheduled: true,
              date: DateTime.now()),
          Event(
              time: "10:00AM - 11:00AM",
              caregiver: "Ronaldo, Messi",
              client: "Huff, Emma",
              isScheduled: true,
              date: DateTime.now().add(Duration(days: 3))),
        ],
        DateTime.now().subtract(Duration(days: 2)): [
          Event(
              time: "8:00PM - 8:00AM",
              caregiver: "Ronaldo, Messi",
              client: "Huff, Emma",
              isScheduled: true,
              date: DateTime.now().subtract(Duration(days: 1))),
          Event(
              time: "8:00PM - 8:00AM",
              caregiver: "Ronaldo, Messi",
              client: "Huff, Emma",
              isScheduled: true,
              date: DateTime.now()),
          Event(
              time: "8:00PM - 8:00AM",
              caregiver: "Ronaldo, Messi",
              client: "Huff, Emma",
              isScheduled: true,
              date: DateTime.now()),
          Event(
              time: "8:00PM - 8:00AM",
              caregiver: "Ronaldo, Messi",
              client: "Huff, Emma",
              isScheduled: true,
              date: DateTime.now()),
        ],
      });
  }

  void _selectDate(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
    });
  }

// Hàm hiển thị modal bottom sheet
  void showRegisterShiftModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 350,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(width: 10),
                  Text(
                    'Đăng kí ca làm việc',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: FrontendConfigs.kAuthColor,
                    ),
                  ),
                ],
              ),

              // DatePickerWidget(onDateSelected: (datetime) {}),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(CupertinoIcons.time),
                  SizedBox(width: 10),
                  Text(
                    'Chọn ca làm việc',
                    style: TextStyle(
                        fontSize: 18,
                        color: FrontendConfigs.kAuthColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        ChoiceChip(
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          label: Text('08:00 - 16:00'),
                          selected: selectedShift == 'morning',
                          onSelected: (bool selected) {},
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        ChoiceChip(
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          label: Text('16:00 - 00:00'),
                          selected: selectedShift == 'morning',
                          onSelected: (bool selected) {},
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        ChoiceChip(
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          label: Text('00:00 - 08:00'),
                          selected: selectedShift == 'morning',
                          onSelected: (bool selected) {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(CupertinoIcons.calendar),
                  SizedBox(width: 10),
                  Text(
                    'Chọn ngày làm việc',
                    style: TextStyle(
                        fontSize: 18,
                        color: FrontendConfigs.kAuthColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: FrontendConfigs.kActiveColor),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2025),
                      );

                      if (picked != null && picked != selectedDate) {
                        _selectDate(picked);
                        setState(() {});
                      }
                    },
                    child: Text('Chọn ngày'),
                  )
                ],
              ),
              SizedBox(height: 20),
              // RegisteredShiftsTimeline(),
              Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FrontendConfigs.kActiveColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('Xác nhận'),
                      onPressed: () {},
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void initializeDateFormattingVietnamese() async {
    await initializeDateFormatting('vi_VN', null);
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  List<Event> _getEventsForWeek(DateTime startDay) {
    List<Event> weeklyEvents = [];
    for (int i = 0; i < 7; i++) {
      DateTime currentDay = startDay.add(Duration(days: i));
      weeklyEvents.addAll(events[currentDay] ?? []);
    }
    return weeklyEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Lịch làm việc',
          style: TextStyle(
              color: FrontendConfigs.kPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            color: FrontendConfigs.kPrimaryColor,
            icon: Icon(Icons.add),
            onPressed: () {
              showRegisterShiftModal(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'vi_VN',
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: DateTime.now(),
            eventLoader: _getEventsForDay,
            calendarFormat: CalendarFormat.twoWeeks,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _getEventsForWeek(DateTime.now()
                      .subtract(Duration(days: DateTime.now().weekday - 1)))
                  .length,
              itemBuilder: (context, index) {
                final event = _getEventsForWeek(DateTime.now().subtract(
                    Duration(days: DateTime.now().weekday - 1)))[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                  child: Stack(
                    children: [
                      // The "10 SEP" column
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 50,
                          decoration: BoxDecoration(
                            color: FrontendConfigs.kActiveColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('MMM')
                                    .format(event.date)
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                DateFormat('d').format(event.date),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // The rest of the content
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                width:
                                    60), // Adjusted to accommodate the "10 SEP" column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.time,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Manager',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                      Text('Client',
                                          style: TextStyle(
                                              color: Colors.grey[600])),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        event.caregiver,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        event.client,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  if (event.isScheduled)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Chip(
                                        padding: EdgeInsets.zero,
                                        label: Text("SCHEDULED"),
                                        backgroundColor: Colors.green,
                                        labelStyle: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class Event {
  final String time;
  final String caregiver;
  final String client;
  final bool isScheduled;
  final DateTime date; // Add this line

  Event(
      {required this.time,
      required this.caregiver,
      required this.client,
      required this.isScheduled,
      required this.date}); // Modify this line
}
