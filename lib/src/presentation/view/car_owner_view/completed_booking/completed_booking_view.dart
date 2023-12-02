import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/models/customerInfo.dart';
import 'package:CarRescue/src/models/vehicle_item.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/homepage/homepage_view.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/booking_list/widgets/selection_location_widget.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:CarRescue/src/models/payment.dart';

class BookingCompletedScreen extends StatefulWidget {
  final String userId;
  final String accountId;
  final Booking booking;
  final Map<String, String> addressesDepart;
  final Map<String, String> subAddressesDepart;
  final Map<String, String> addressesDesti;
  final Map<String, String> subAddressesDesti;
  final Payment payment;
  BookingCompletedScreen(
    this.userId,
    this.accountId,
    this.booking,
    this.addressesDepart,
    this.subAddressesDepart,
    this.addressesDesti,
    this.subAddressesDesti,
    this.payment,
  );
  @override
  State<BookingCompletedScreen> createState() => _BookingCompletedScreenState();
}

class _BookingCompletedScreenState extends State<BookingCompletedScreen> {
  Booking? booking;
  AuthService authService = AuthService();
  CustomerInfo? customerInfo;
  Vehicle? vehicleInfo;

  void initState() {
    super.initState();
    booking = widget.booking;
    _loadCustomerInfo(widget.booking.customerId);
    _loadVehicleInfo(widget.booking.vehicleId ?? '');
  }

  Future<void> _loadCustomerInfo(String customerId) async {
    Map<String, dynamic>? userProfile =
        await authService.fetchCustomerInfo(customerId);
    print(userProfile);
    if (userProfile != null) {
      setState(() {
        customerInfo = CustomerInfo.fromJson(userProfile);
      });
    }
  }

  Future<void> _loadVehicleInfo(String vehicleId) async {
    try {
      Vehicle? fetchedVehicleInfo =
          await authService.fetchVehicleInfo(vehicleId);
      print('Fetched vehicle: $fetchedVehicleInfo');

      setState(() {
        vehicleInfo = fetchedVehicleInfo;
      });
    } catch (e) {
      print('Error loading vehicle info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int durationInMinutes =
        widget.booking.endTime!.difference(widget.booking.startTime!).inMinutes;
    print(durationInMinutes);
    int durationInSeconds =
        widget.booking.endTime!.difference(widget.booking.startTime!).inSeconds;
    print(durationInMinutes);
    String durationDisplay = durationInMinutes < 1
        ? '${durationInSeconds} giây'
        : '${durationInMinutes} phút';
    return Scaffold(
      backgroundColor: FrontendConfigs.kIconColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Checkmark Icon and Title
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Lottie.asset(
                        'assets/animations/Animation - 1698775742839.json',
                        width: 150,
                        height: 150,
                        fit: BoxFit.fill),
                    Text(
                      'Đơn đã hoàn thành',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // Doctor's Details
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              NetworkImage(customerInfo?.avatar ?? ''),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customerInfo?.fullname ?? '',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(customerInfo?.phone ??
                                'Chưa thêm số điện thoại'),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    // Location Details
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: RideSelectionWidget(
                        icon: 'assets/svg/pickup_icon.svg',
                        title: widget.addressesDepart[widget.booking.id] ??
                            '', // Use addresses parameter
                        body:
                            widget.subAddressesDepart[widget.booking.id] ?? '',
                        onPressed: () {},
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: RideSelectionWidget(
                        icon: 'assets/svg/location_icon.svg',
                        title: widget.addressesDesti[widget.booking.id] ?? '',
                        body: widget.subAddressesDesti[widget.booking.id] ?? '',
                        onPressed: () {},
                      ),
                    ),
                    SizedBox(height: 30),
                    // Date and Time
                    ListTile(
                      title: Text(
                        'Ngày',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(
                        style: TextStyle(fontSize: 16),
                        DateFormat('dd-MM-yyyy').format(
                          widget.booking.endTime ?? DateTime.now(),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Thời gian',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                              style: TextStyle(fontSize: 18),
                              DateFormat('HH:mm').format(widget.booking.endTime!
                                  .toUtc()
                                  .add(Duration(hours: 14)))),
                        ],
                      ),
                    ),
                    // Duration and Speciality
                    ListTile(
                      title: Text(
                        'Thời lượng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        durationDisplay,
                        style: TextStyle(fontSize: 18),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Tổng cộng',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                            NumberFormat.currency(
                              locale: 'vi_VN',
                              symbol: '₫',
                            ).format(widget.payment.amount),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              // Bottom Button

              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomNavBarCarView(
                            userId: widget.userId, accountId: widget.accountId),
                      ));
                },
                child: Text('Trang chủ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FrontendConfigs.kActiveColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
