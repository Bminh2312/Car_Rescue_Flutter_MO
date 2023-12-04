import 'package:CarRescue/src/models/current_week.dart';
import 'package:CarRescue/src/models/feedback.dart';
import 'package:CarRescue/src/models/payment.dart';
import 'package:CarRescue/src/models/rescue_vehicle_owner.dart';
import 'package:CarRescue/src/models/wallet.dart';
import 'package:CarRescue/src/models/wallet_transaction.dart';
import 'package:CarRescue/src/models/work_shift.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/car_view/widgets/add_car_view.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/waiting_payment/waiting_payment.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/homepage/widgets/calendar/calendar_view.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/notification/notification_view.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/profile/profile_view.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/wallet/layout/wallet_transation.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/wallet/layout/widgets/withdraw_form.dart';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/quick_access_buttons.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/car_view/car_view.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/booking_list/booking_view.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';

class CarOwnerHomePageBody extends StatefulWidget {
  final String userId;

  final String accountId;
  const CarOwnerHomePageBody({
    required this.userId,
    required this.accountId,
  });

  @override
  _CarOwnerHomePageBodyState createState() => _CarOwnerHomePageBodyState();
}

class _CarOwnerHomePageBodyState extends State<CarOwnerHomePageBody> {
  final AuthService authService = AuthService();
  List<Booking> bookings = [];
  List<String> weeklyTasks = [
    "Thứ Hai: \n9:00 - 21:00",
  ];
  Payment payments = Payment(
      method: 'method',
      id: 'id',
      orderId: 'orderId',
      createdAt: 'createdAt',
      amount: 0,
      status: 'status');
  DateTime? selectedDate;
  int completedBookings = 0;
  double averageRating = 4.7;
  RescueVehicleOwner? _owner;
  Wallet? _wallet;
  List<WalletTransaction> walletTransactions = [];
  List<WorkShift> weeklyShifts = [];
  CurrentWeek? _currentWeek;
  @override
  void initState() {
    super.initState();
    loadWalletInfo(widget.userId);
    displayFeedbackForBooking(widget.userId);
    loadCurrentWeek();
    fetchRVOInfo().then((value) {
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _owner = value;
        });
      }
    });
  }

  Future<void> loadCurrentWeek() async {
    try {
      final CurrentWeek currentWeekFromApi =
          await AuthService().getCurrentWeek();
      setState(() {
        _currentWeek = currentWeekFromApi;
        print('a1: $_currentWeek');

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
          await AuthService().getWeeklyShiftOfCarOwner(weekId, userId);

      // Sort the list by the latest date (assuming WorkShift has a date property)
      weeklyShiftsFromAPI.sort((a, b) => a.date.compareTo(b.date));

      // Update the state variable with the sorted data
      setState(() {
        weeklyShifts = weeklyShiftsFromAPI;
        print('a2: $weeklyShifts');
      });
    } catch (e) {
      // Handle the error or return an empty list based on your requirements

      print('Error loading weekly shifts: $e');
    }
  }

  Future<void> loadWalletTransaction(String walletId) async {
    try {
      final List<WalletTransaction> walletTransactionsFromAPI =
          await AuthService().getWalletTransaction(walletId);

      // Sort the list by the latest date (assuming WorkShift has a date property)
      walletTransactionsFromAPI
          .sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Update the state variable with the sorted data
      setState(() {
        walletTransactions = walletTransactionsFromAPI;
        print(walletTransactions);
      });
    } catch (e) {
      // Handle the error or return an empty list based on your requirements
      print('Error loading wallet transactions: $e');
    }
  }

  Future<void> loadWalletInfo(String userId) async {
    try {
      final Wallet walletInfoFromApi =
          await AuthService().getWalletInfo(widget.userId);
      setState(() {
        _wallet = walletInfoFromApi;

        // After obtaining currentWeek.id, call loadWeeklyShift with it
      });
      loadWalletTransaction(_wallet!.id);
    } catch (e) {
      // Handle any exceptions here, such as network errors or errors from getCurrentWeek()
      print('Error loading current week: $e');
      throw e; // Rethrow the exception if needed
    }
  }

  Future<RescueVehicleOwner> fetchRVOInfo() async {
    // call API
    final json = await authService.fetchRescueCarOwnerProfile(widget.userId);

    // convert response to model
    final owner = RescueVehicleOwner.fromJson(json!);
    print(owner);
    return owner;
  }

  void reloadData() {
    displayFeedbackForBooking(widget.userId);
  }

  Future<void> displayFeedbackForBooking(String userId) async {
    try {
      FeedbackData? feedbackData =
          await authService.fetchFeedbackRatingCountofRVO(widget.userId);
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

  Widget buildWallet() {
    final formatter = NumberFormat.currency(symbol: '₫', locale: 'vi_VN');
    final formattedTotal = formatter.format(_wallet?.total ?? 0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 16),
          child: Container(
            height: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    'Số dư ví',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  formattedTotal,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.all(0),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WithdrawFormScreen(wallet: _wallet!)),
            );
          },
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: FrontendConfigs.kIconColor,
                  border:
                      Border.all(color: FrontendConfigs.kIconColor, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.creditcard,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Rút tiền",
                style: TextStyle(
                    color: FrontendConfigs.kAuthColor,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.all(0),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WalletTransactionScreen(
                        wallet: _wallet!,
                        transactions: walletTransactions,
                      )),
            );
          },
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: FrontendConfigs.kIconColor,
                  border:
                      Border.all(color: FrontendConfigs.kIconColor, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.time,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Lịch sử",
                style: TextStyle(
                    color: FrontendConfigs.kAuthColor,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        )
      ],
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

  Widget buildWeeklyTaskSchedule() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    DateTime tomorrow2 = DateTime(now.year, now.month, now.day + 2);
    List<WorkShift> filteredShifts = weeklyShifts.where((shift) {
      DateTime shiftDate =
          DateTime(shift.date.year, shift.date.month, shift.date.day);
      return shiftDate == today ||
          shiftDate == tomorrow ||
          shiftDate == tomorrow2;
    }).toList();
    print(filteredShifts);
    if (weeklyShifts.length < 2) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
            child: CustomText(
          text: 'Hiện tại không có lịch làm việc',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        )),
      );
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
          height: 400,
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

  Widget buildQuickAccessButtons() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              QuickAccessButton(
                label: 'Xe của tôi',
                icon: Icons.fire_truck_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarListView(
                        userId: widget.userId,
                        accountId: widget.accountId,
                      ),
                    ),
                  );
                },
              ),
              QuickAccessButton(
                label: 'Đơn làm việc',
                icon: Icons.menu_book,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingListView(
                          userId: widget.userId, accountId: widget.accountId),
                    ),
                  ).then((value) => {reloadData()});
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
                      builder: (context) => WaitingForPaymentScreen(
                        addressesDepart: {},
                        addressesDesti: {},
                        subAddressesDepart: {},
                        subAddressesDesti: {},
                        accountId: '',
                        data: '',
                        payment: payments,
                        userId: '',
                        booking: Booking(
                            carId: 'carId',
                            id: 'id',
                            customerId: 'customerId',
                            technicianId: 'technicianId',
                            managerId: 'managerId',
                            vehicleId: 'vehicleId',
                            paymentId: 'paymentId',
                            rescueType: 'rescueType',
                            staffNote: 'staffNote',
                            customerNote: 'customerNote',
                            cancellationReason: 'cancellationReason',
                            startTime: DateTime.now(),
                            endTime: DateTime.now(),
                            createdAt: DateTime.now(),
                            status: 'status',
                            departure: 'departure',
                            destination: 'destination',
                            area: 1),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildQuickRegister() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddCarScreen(
                        userId: widget.userId,
                      )),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.square_list,
                    color: FrontendConfigs.kIconColor),
                SizedBox(width: 8),
                Text('Đăng ký xe',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  //   @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Color.fromARGB(34, 158, 158, 158),
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
                    top: 110), // Pushes content up by 150 pixels
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              16), // Set the border radius to 10
                        ),
                        child: Column(
                          children: [
                            buildQuickAccessButtons(),
                            Divider(thickness: 1, height: 0.5),
                            buildQuickRegister(),

                            // Divider(
                            //   thickness: 1,
                            //   height: 0.5,
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: buildWallet(),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                          margin: EdgeInsets.all(16),
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BottomNavBarCarView(
                                  userId: widget.userId,
                                  accountId: widget.accountId,
                                  initialIndex: 2,
                                )));
                  },
                  child: CircleAvatar(
                    backgroundColor: FrontendConfigs.kIconColor,
                    radius: 25,
                    child: ClipOval(
                      child: Image(
                        image: NetworkImage(
                          _owner?.avatar ?? '',
                        ),
                        width: 64, // double the radius
                        height: 64, // double the radius
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
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
                    _owner?.fullname ?? '',
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
}
