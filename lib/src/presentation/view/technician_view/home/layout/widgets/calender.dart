import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
// import 'package:CarRescue/src/presentation/view/technician_view/home/layout/widgets/scheduling_task.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../../models/work_shift.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class MyCalendarPage extends StatefulWidget {
  @override
  _MyCalendarPageState createState() => _MyCalendarPageState();
}

class _MyCalendarPageState extends State<MyCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late ShiftDetails _selectedShift; // Declare as non-nullable

  // Sample shift data, replace this with your actual data source
  final List<ShiftDetails> _shifts = [
    ShiftDetails(
      date: DateTime(2023, 10, 5),
      time: '9:00 AM - 5:00 PM',
      numberOfSlots: 8,
      managerName: 'John Doe',
    ),
    // Add more shift details here
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormattingVietnamese();
    // Initialize _selectedShift with default values
    _selectedShift = ShiftDetails(
      date: DateTime.now(), // Provide a default date or other default values
      time: DateFormat('HH:mm').format(DateTime.now()),
      numberOfSlots: 0,
      managerName: 'N/A',
    );
  }

  void initializeDateFormattingVietnamese() async {
    await initializeDateFormatting('vi_VN', null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, text: 'Lịch làm việc', showText: true),
      backgroundColor: FrontendConfigs.kBackgrColor, // Background color
      body: SingleChildScrollView(
        // Wrap your column with a SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // App Bar

            // Table Calendar
            Container(
              color: Colors.white,
              child: TableCalendar(
                locale: 'vi_VN',
                calendarFormat: _calendarFormat,
                focusedDay: _focusedDay,
                firstDay: DateTime(2000),
                lastDay: DateTime(2050),
                startingDayOfWeek: StartingDayOfWeek.sunday,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;

                    // Find the shift details for the selected date
                    _selectedShift = _shifts.firstWhere(
                      (shift) => shift.date == selectedDay,
                      orElse: () => ShiftDetails(
                        date: selectedDay,
                        time: 'N/A',
                        numberOfSlots: 0,
                        managerName: 'N/A',
                      ),
                    );

                    // Display the shift details as a modal bottom sheet
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: FrontendConfigs.kIconColor,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(color: Colors.white),
                  todayTextStyle: TextStyle(color: Colors.white),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Colors.black,
                  ),
                  weekendStyle: TextStyle(
                    color: Colors.red,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Shift Details
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    thickness: 2,
                    height: 2,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Shift Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  ListTile(
                    title: Text('Date'),
                    subtitle: _selectedDay != null
                        ? Text(DateFormat('dd/MM/yyyy').format(_selectedDay!))
                        : Text(DateFormat('dd/MM/yyyy').format(DateTime.now())),
                  ),
                  ListTile(
                    title: Text('Time'),
                    subtitle: Text(_selectedShift.time),
                  ),
                  ListTile(
                    title: Text('Slots'),
                    subtitle: Text(_selectedShift.numberOfSlots.toString()),
                  ),
                  ListTile(
                    title: Text('Manager'),
                    subtitle: Text(_selectedShift.managerName),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show the shift details as a modal bottom sheet
}
