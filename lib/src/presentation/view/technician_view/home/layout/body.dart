import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/current_week.dart';
import 'package:CarRescue/src/models/feedback.dart';
import 'package:CarRescue/src/models/technician.dart';
import 'package:CarRescue/src/models/wallet.dart';
import 'package:CarRescue/src/models/work_shift.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:CarRescue/src/presentation/view/technician_view/waiting_payment/waiting_payment.dart';
import 'package:CarRescue/src/presentation/view/technician_view/home/layout/widgets/calendar/calendar_view.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_list/booking_view.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/presentation/view/technician_view/home/layout/widgets/active_booking.dart';

import 'package:CarRescue/src/presentation/elements/quick_access_buttons.dart';
import 'package:CarRescue/src/presentation/view/technician_view/notification/notification_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TechncianHomePageBody extends StatefulWidget {
  final String userId;

  TechncianHomePageBody({
    required this.userId,
  });

  @override
  _TechncianHomePageBodyState createState() => _TechncianHomePageBodyState();
}

class _TechncianHomePageBodyState extends State<TechncianHomePageBody> {
  List<Booking> bookings = [];
  // Change the type to DateTime?
  int completedBookings = 0;
  double averageRating = 0;
  AuthService authService = AuthService();
  Technician? _tech;
  List<String> weeklyTasks = [
    "Thứ Hai: \n9:00 - 21:00",
  ];
  List<Booking> assignedBookings = [];
  DateTime? _selectedDay;
  CurrentWeek? _currentWeek;

  String? selectedShift;
  DateTime selectedDate = DateTime.now();
  List<WorkShift> weeklyShifts = [];
  DateTime? _focusedDay = DateTime.now();
  bool isLoading = true;
  // Method to show the shift registration popup
  void initState() {
    super.initState();

    _loadInprogressBookings();
    displayFeedbackForBooking(widget.userId);
    fetchTechInfo().then((value) {
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _tech = value;
        });
      }
    });
    loadCurrentWeek();
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

  Future<void> _loadInprogressBookings() async {
    try {
      List<Booking> bookings =
          await authService.fetchTechBookingByInprogress(widget.userId);
      // Filter bookings for 'ASSIGNED' status after fetching
      setState(() {
        assignedBookings = bookings;

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching assigned bookings: $e');
    }
  }

  Future<Technician> fetchTechInfo() async {
    // call API
    final json = await authService.fetchTechProfile(widget.userId);

    // convert response to model
    final tech = Technician.fromJson(json!);
    print(tech);
    return tech;
  }

  Future<void> displayFeedbackForBooking(String userId) async {
    try {
      FeedbackData? feedbackData =
          await authService.fetchFeedbackRatingCountofTech(widget.userId);
      print("Fetched feedbackData: $feedbackData");

      if (feedbackData != null) {
        if (feedbackData.count != null && feedbackData.rating != null) {
          setState(() {
            completedBookings = feedbackData.count!;
            averageRating = feedbackData.rating!;
            print("Inside setState - Setting Rating: ${completedBookings}");
            print("Inside setState - Setting Count: ${averageRating}");
          });
        } else {
          print("feedbackData.count or feedbackData.rating is null.");
        }
      } else {
        print("feedbackData is null.");
      }
    } catch (error) {
      print("Error in displayFeedbackForBooking: $error");
    }
  }

  Widget headerWidget = Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 20, top: 15),
        child: Text(
          'Đơn đang thực hiện ',
          style: TextStyle(
            fontSize: 18.0, // Adjust the font size as needed
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
  Widget _buildConditionalWidget() {
    return isLoading
        ? CircularProgressIndicator()
        : Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: Colors.transparent),
            child: Column(
              children: [
                if (assignedBookings.isNotEmpty) ...[
                  // Your header widget here
                  for (var booking in assignedBookings)
                    ActiveBookingCard(
                      userId: booking.technicianId,
                      avatar: 'assets/images/avatars-2.png',
                      booking: booking,
                    ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                  )
                ],
              ],
            ),
          );
  }

  Widget buildPerformanceMetrics() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hiệu suất làm việc',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: FrontendConfigs.kAuthColor,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tổng đơn', style: TextStyle(fontSize: 16)),
                  Text(
                    completedBookings.toString(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Đánh giá', style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.star, color: Colors.amber, size: 24),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
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

  Widget buildQuickAccessButtons() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              QuickAccessButton(
                label: 'Đơn làm việc',
                icon: Icons.menu_book,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingListView(
                          userId: widget.userId, accountId: _tech!.accountId),
                    ),
                  );
                },
              ),
              QuickAccessButton(
                label: 'Lịch',
                icon: Icons.calendar_today,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CalendarView(userId: widget.userId),
                    ),
                  );
                },
              ),
              QuickAccessButton(
                label: 'Thông báo',
                icon: Icons.notifications,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationView(),
                    ),
                  );
                },
              ),
              // QuickAccessButton(
              //   label: 'Test',
              //   icon: Icons.menu_book,
              //   onPressed: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => WaitingForPaymentScreen(),
              //         ));
              //   },
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildWeeklyTaskSchedule() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    List<WorkShift> filteredShifts = weeklyShifts.where((shift) {
      DateTime shiftDate =
          DateTime(shift.date.year, shift.date.month, shift.date.day);
      return shiftDate == today || shiftDate == tomorrow;
    }).toList();
    if (weeklyShifts.length < 2) {
      return Center(child: LoadingState());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Lịch làm việc',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: FrontendConfigs.kAuthColor,
            ),
          ),
        ),
        Container(
          height: 300,
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: filteredShifts.length,
            itemBuilder: (context, index) {
              final workShift = filteredShifts[index];

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
                          // IconButton(
                          //   onPressed: () {
                          //     showUpdatedShiftModal(context, workShift.id,
                          //         workShift.date, workShift.type);
                          //     // Call the updateWeeklyShift function here
                          //   },
                          //   icon: Icon(CupertinoIcons.pencil, size: 25),
                          // )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: FrontendConfigs.kBackgrColor,
        child: Stack(
          children: <Widget>[
            // Image container
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xffffa585), Color(0xffffeda0)],
                ),
              ),
              width: double.infinity,
              height: 300,
            ),
            // Content with Padding instead of Transform
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                    top: 120), // Pushes content up by 150 pixels
                child: Container(
                  // color: FrontendConfigs.kIconColor,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(
                              32), // Set the border radius to 10
                        ),
                        child: Column(
                          children: [
                            buildQuickAccessButtons(),
                            SizedBox(
                              height: 8,
                            ),
                            _buildConditionalWidget(),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                16), // Set the border radius to 10
                          ),
                          child: Column(
                            children: [
                              buildPerformanceMetrics(),
                              Divider(thickness: 1, height: 0.5),
                              buildWeeklyTaskSchedule()
                            ],
                          )),

                      // ... Add more widgets as needed
                    ],
                  ),
                ),
              ),
            ),
            // Icon overlay
            Positioned(
                top: 65,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => BottomNavBarView(
                    //               userId: widget.userId,
                    //               accountId: widget.accountId,
                    //               initialIndex: 2,
                    //             )));
                  },
                  child: CircleAvatar(
                      backgroundColor: FrontendConfigs.kIconColor,
                      radius: 25,
                      child: ClipOval(
                        child: _tech?.avatar != null &&
                                _tech!.avatar!.isNotEmpty
                            ? Image.network(
                                _tech!.avatar!,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.person,
                                size:
                                    64), // Hiển thị biểu tượng mặc định nếu `_tech?.avatar` là null hoặc rỗng
                      )),
                )),
            // Welcome text on top left
            Positioned(
              top: 70,
              left: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào,',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _tech?.fullname ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 0.5,
                      color: FrontendConfigs.kAuthColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Floating Action Button (Add Button)
}
