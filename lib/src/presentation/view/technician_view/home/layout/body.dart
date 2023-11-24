import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/feedback.dart';
import 'package:CarRescue/src/models/technician.dart';
import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:CarRescue/src/presentation/view/technician_view/waiting_payment/waiting_payment.dart';
import 'package:CarRescue/src/presentation/view/technician_view/home/layout/widgets/calendar/calendar_view.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_list/booking_view.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/presentation/view/technician_view/home/layout/widgets/active_booking.dart';
import 'package:CarRescue/src/presentation/view/technician_view/home/layout/widgets/calender.dart';
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
  DateTime? selectedDate; // Change the type to DateTime?
  int completedBookings = 0;
  double averageRating = 0;
  AuthService authService = AuthService();
  Technician? _tech;
  List<String> weeklyTasks = [
    "Thứ Hai: \n9:00 - 21:00",
  ];
  List<Booking> assignedBookings = [];
  bool isLoading = true;
  // Method to show the shift registration popup
  void initState() {
    super.initState();
    fetchBookings();
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
  }

  Future<void> _loadInprogressBookings() async {
    try {
      List<Booking> bookings =
          await authService.fetchTechBookingByInprogress(widget.userId);
      // Filter bookings for 'ASSIGNED' status after fetching
      setState(() {
        assignedBookings = bookings
            .where((booking) => booking.status == 'INPROGRESS')
            .toList();
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

  Future<void> fetchBookings() async {
    try {
      final bookingsFromApi =
          await authService.fetchBookings(widget.userId);
      completedBookings = bookingsFromApi
          .where((booking) => booking.status == 'COMPLETED')
          .length;

      setState(() {
        bookings = bookingsFromApi;
      });
    } catch (error) {
      print('Error loading data: $error');
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
            'Hiệu suất làm việc trong tuần',
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
                      builder: (context) => CalendarView(),
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
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lịch làm việc',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: FrontendConfigs.kAuthColor,
            ),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: weeklyTasks.map((task) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 1,
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
                          color: FrontendConfigs.kIconColor,
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
                                  .format(DateTime.now())
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              DateFormat('d').format(DateTime.now()),
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
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                width:
                                    55), // Adjusted to accommodate the "10 SEP" column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '9:00 - 21:00',
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
                                        'Messi',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'CR7',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  // if (event.isScheduled)
                                  //   Align(
                                  //     alignment: Alignment.centerLeft,
                                  //     child: Chip(
                                  //       padding: EdgeInsets.zero,
                                  //       label: Text("SCHEDULED"),
                                  //       backgroundColor: Colors.green,
                                  //       labelStyle: TextStyle(
                                  //           color: Colors.white,
                                  //           fontWeight: FontWeight.bold),
                                  //     ),
                                  //   ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
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
                              buildWeeklyTaskSchedule(),
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
