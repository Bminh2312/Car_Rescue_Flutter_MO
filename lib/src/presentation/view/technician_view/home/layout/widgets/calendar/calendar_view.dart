import 'dart:convert';

import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/current_week.dart';
import 'package:CarRescue/src/models/work_shift.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class CalendarView extends StatefulWidget {
  final String userId;
  CalendarView({required this.userId});
  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime? _selectedDay;
  CurrentWeek? _currentWeek;
  String? selectedShift;
  DateTime selectedDate = DateTime.now();
  List<WorkShift> weeklyShifts = [];
  CurrentWeek? _nextWeek;
  DateTime? _focusedDay = DateTime.now();
  bool isTrue = true;
  @override
  void initState() {
    super.initState();
    loadCurrentWeek();
    initializeDateFormattingVietnamese();
    _selectedDay = DateTime.utc(2023, 01, 9);
  }

  Future<void> loadCurrentWeek() async {
    try {
      final CurrentWeek currentWeekFromApi =
          await AuthService().getCurrentWeek();
      setState(() {
        _currentWeek = currentWeekFromApi;
        print('a: $_currentWeek');

        // After obtaining currentWeek.id, call loadWeeklyShift with it
        loadWeeklyShift(_currentWeek!.id, widget.userId);
      });
    } catch (e) {
      // Handle any exceptions here, such as network errors or errors from getCurrentWeek()
      print('Error loading current week: $e');
      throw e; // Rethrow the exception if needed
    }
  }

  Future<void> loadWeeklyShift(String weekId, String userId) async {
    try {
      final List<WorkShift> weeklyShiftsFromAPI =
          await AuthService().getWeeklyShiftofTechnician(weekId, userId);

      // Sort the list by the latest date (assuming WorkShift has a date property)
      weeklyShiftsFromAPI.sort((a, b) => a.date.compareTo(b.date));

      // Update the state variable with the sorted data
      setState(() {
        weeklyShifts = weeklyShiftsFromAPI;
        print(weeklyShifts);
      });
    } catch (e) {
      // Handle the error or return an empty list based on your requirements

      print('Error loading weekly shifts: $e');
    }
  }

  Future<void> loadNextWeek(DateTime startDate) async {
    try {
      final CurrentWeek nextWeekFromAPI =
          await AuthService().getNextWeek(startDate);

      // Sort the list by the latest date (assuming WorkShift has a date property)
      // nextWeekFromAPI.sort((a, b) => a.date.compareTo(b.date));

      // Update the state variable with the sorted data
      setState(() {
        _nextWeek = nextWeekFromAPI;
        print(_nextWeek);
      });
      loadWeeklyShift(_nextWeek!.id, widget.userId);
    } catch (e) {
      // Handle the error or return an empty list based on your requirements
      print('Error loading next weeks: $e');
    }
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay; // Update the focusedDay when a day is selected
    });
  }

 

  String getTimeRange(String type) {
    switch (type) {
      case 'Night':
        return '16:00 - 00:00';
      case 'Morning':
        return '08:00 - 16:00';
      case 'Midnight':
        return '00:00 - 08:00';
      default:
        return 'Unknown'; // Add a default value in case the type is not recognized
    }
  }

// Hàm hiển thị modal bottom sheet
  void showRegisterShiftModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
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
                            selectedColor: FrontendConfigs.kActiveColor,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedShift == 'Morning'
                                  ? Colors.white // Set text color when selected
                                  : FrontendConfigs
                                      .kAuthColor, // Set text color when not selected
                            ),
                            backgroundColor: selectedShift == 'Morning'
                                ? FrontendConfigs
                                    .kActiveColor // Set background color when selected
                                : Colors
                                    .transparent, // Set background color when not selected
                            label: Text('08:00 - 16:00'),
                            selected: selectedShift == 'Morning',
                            onSelected: (bool selected) {
                              setState(() {
                                selectedShift =
                                    'Morning'; // Update selectedShift
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          ChoiceChip(
                            selectedColor: FrontendConfigs.kActiveColor,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedShift == 'Night'
                                  ? Colors.white // Set text color when selected
                                  : FrontendConfigs
                                      .kAuthColor, // Set text color when not selected
                            ),
                            backgroundColor: selectedShift == 'Night'
                                ? FrontendConfigs
                                    .kActiveColor // Set background color when selected
                                : Colors
                                    .transparent, // Set background color when not selected
                            label: Text('16:00 - 00:00'),
                            selected: selectedShift == 'Night',
                            onSelected: (bool selected) {
                              setState(() {
                                selectedShift = 'Night'; // Update selectedShift
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          ChoiceChip(
                            selectedColor: FrontendConfigs.kActiveColor,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedShift == 'Midnight'
                                  ? Colors.white // Set text color when selected
                                  : FrontendConfigs
                                      .kAuthColor, // Set text color when not selected
                            ),
                            backgroundColor: selectedShift == 'Midnight'
                                ? FrontendConfigs
                                    .kActiveColor // Set background color when selected
                                : Colors
                                    .transparent, // Set background color when not selected
                            label: Text('00:00 - 08:00'),
                            selected: selectedShift == 'Midnight',
                            onSelected: (bool selected) {
                              setState(() {
                                selectedShift =
                                    'Midnight'; // Update selectedShift
                              });
                            },
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
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FrontendConfigs.kActiveColor,
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2025),
                        );

                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            // Add this setState to update the selectedDate
                            selectedDate = picked;
                          });
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
                        onPressed: () async {
                          // Check if a shift type is selected
                          if (selectedShift == null) {
                            // Show an error message or handle the case where no shift type is selected
                            return;
                          }

                          // Create the weekly shift based on the selected options
                          try {
                            await createWeeklyShift(
                              technicianId: widget
                                  .userId, // Replace with the actual technicianId
                              workScheduleId: _currentWeek!
                                  .id, // Replace with the actual workScheduleId
                              date: selectedDate,
                              type: selectedShift!,
                            );

                            // Shift created successfully, you can handle success here

                            // Close the modal
                            Navigator.of(context).pop();
                            //
                            loadWeeklyShift(_nextWeek!.id, widget.userId);
                          } catch (e) {
                            // Handle the error or show an error message
                            print('Error creating weekly shift: $e');
                            // You can display an error message here or handle the error as needed
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void showUpdatedShiftModal(BuildContext context, String workShiftId,
      DateTime workShiftDate, String workShiftType) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(workShiftDate);
    selectedShift = workShiftType;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: 250,
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

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          ChoiceChip(
                            selectedColor: FrontendConfigs.kActiveColor,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedShift == 'Morning'
                                  ? Colors.white // Set text color when selected
                                  : FrontendConfigs
                                      .kAuthColor, // Set text color when not selected
                            ),
                            backgroundColor: selectedShift == 'Morning'
                                ? FrontendConfigs
                                    .kActiveColor // Set background color when selected
                                : Colors
                                    .transparent, // Set background color when not selected
                            label: Text('08:00 - 16:00'),
                            selected: selectedShift == 'Morning',
                            onSelected: (bool selected) {
                              setState(() {
                                selectedShift =
                                    'Morning'; // Update selectedShift
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          ChoiceChip(
                            selectedColor: FrontendConfigs.kActiveColor,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedShift == 'Night'
                                  ? Colors.white // Set text color when selected
                                  : FrontendConfigs
                                      .kAuthColor, // Set text color when not selected
                            ),
                            backgroundColor: selectedShift == 'Night'
                                ? FrontendConfigs
                                    .kActiveColor // Set background color when selected
                                : Colors
                                    .transparent, // Set background color when not selected
                            label: Text('16:00 - 00:00'),
                            selected: selectedShift == 'Night',
                            onSelected: (bool selected) {
                              setState(() {
                                selectedShift = 'Night'; // Update selectedShift
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          ChoiceChip(
                            selectedColor: FrontendConfigs.kActiveColor,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedShift == 'Midnight'
                                  ? Colors.white // Set text color when selected
                                  : FrontendConfigs
                                      .kAuthColor, // Set text color when not selected
                            ),
                            backgroundColor: selectedShift == 'Midnight'
                                ? FrontendConfigs
                                    .kActiveColor // Set background color when selected
                                : Colors
                                    .transparent, // Set background color when not selected
                            label: Text('00:00 - 08:00'),
                            selected: selectedShift == 'Midnight',
                            onSelected: (bool selected) {
                              setState(() {
                                selectedShift =
                                    'Midnight'; // Update selectedShift
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    SizedBox(height: 20),
                    Icon(CupertinoIcons.calendar),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        formattedDate,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
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
                        onPressed: () async {
                          // Check if a shift type is selected
                          if (selectedShift == null) {
                            // Show an error message or handle the case where no shift type is selected
                            return;
                          }

                          // Create the weekly shift based on the selected options

                          await updateWeeklyShift(
                            id: workShiftId,
                            type: selectedShift!, // Replace with the new type
                          );

                          // Shift created successfully, you can handle success here

                          // Close the modal
                          Navigator.of(context).pop();
                          loadWeeklyShift(_nextWeek?.id ?? '', widget.userId);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void initializeDateFormattingVietnamese() async {
    await initializeDateFormatting('vi_VN', null);
  }

  Future<void> createWeeklyShift({
    required String technicianId,
    required String workScheduleId,
    required DateTime date,
    required String type,
  }) async {
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Schedule/CreateShift";
    try {
      final response = await http.post(
        Uri.parse('$apiUrl'), // Replace with your actual API endpoint
        headers: {
          "Content-Type": "application/json",
          // Add other headers if needed, like authorization headers
        },
        body: json.encode({
          "technicianId": technicianId,
          "workScheduleId": workScheduleId,
          "date": date.toUtc().add(Duration(hours: 8)).toIso8601String(),
          "type": type,
        }),
      );

      if (response.statusCode == 200) {
        // Successfully created the weekly shift
        print('Weekly shift created successfully.');
      } else {
        // Failed to create the weekly shift
        print('Failed to create the weekly shift: ${response.body}');
        throw Exception('Failed to create the weekly shift');
      }
    } catch (e) {
      // Handle any exceptions or errors
      print('Error creating weekly shift: $e');
      throw Exception('Error creating weekly shift: $e');
    }
  }

  Future<void> updateWeeklyShift({
    required String id,
    required String type,
  }) async {
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Schedule/UpdateShift";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          // Add other headers if needed, like authorization headers
        },
        body: json.encode({
          "id": id,
          "type": type,
        }),
      );

      final responseData = json.decode(response.body);
      // final int status = responseData['status'];
      final String message = responseData['message'];

      if (message == 'Success') {
        print('Weekly shift updated successfully: $message');
      } else if (message == 'Fail To update due to past due date') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đã quá ngày để cập nhật"), // "Too late to update"
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }

      // print("a: ${status}");
    } catch (e) {
      print('Error updating weekly shift: $e');
      throw Exception('Error updating weekly shift: $e');
    }
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
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay; // Update the focused day
              });
              // Calculate the start date of the week based on the new focused day
              DateTime startDate =
                  focusedDay.subtract(Duration(days: focusedDay.weekday - 1));

              // Call loadNextWeek with the start date
              loadNextWeek(startDate);
            },
            locale: 'vi_VN',
            startingDayOfWeek: StartingDayOfWeek.monday,
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay!,
            calendarFormat: CalendarFormat.week,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: weeklyShifts.length,
              itemBuilder: (context, index) {
                final workShift = weeklyShifts[index];

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
                                    .format(workShift.date)
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                DateFormat('d').format(workShift.date),
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
                                    getTimeRange(workShift.type),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
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
                            ),
                            IconButton(
                              onPressed: () {
                                showUpdatedShiftModal(context, workShift.id,
                                    workShift.date, workShift.type);
                                // Call the updateWeeklyShift function here
                              },
                              icon: Icon(CupertinoIcons.pencil, size: 25),
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
