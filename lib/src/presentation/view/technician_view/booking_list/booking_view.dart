import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/technician_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';
import 'layout/body.dart';
import '../../../../models/booking.dart';

import 'dart:convert';

class BookingListView extends StatefulWidget {
  const BookingListView(
      {Key? key, required this.userId, required this.accountId})
      : super(key: key);
  final String userId;
  final String accountId;
  @override
  _BookingListViewState createState() => _BookingListViewState();
}

enum SortType { statusAssigned, dateNow, defaultSort }

class _BookingListViewState extends State<BookingListView> {
  List<Booking> bookings = [];
  AuthService authService = AuthService();
  Map<String, String> addressesDepart = {};
  Map<String, String> subAddressesDepart = {};
  Map<String, String> addressesDesti = {};
  Map<String, String> subAddressesDesti = {};
  String customerName = '';
  String customerPhone = '';
  @override
  @override
  void initState() {
    super.initState();
    // _loadData();
  }

  // Future<void> _loadData() async {
  //   try {
  //     final bookingsFromApi = await authService.fetchBookings(widget.userId);

  //     // Use Future.wait to parallelize the asynchronous operations
  //     await Future.wait([
  //       authService.getDestiForBookings(
  //           bookingsFromApi, setState, addressesDesti, subAddressesDesti),
  //       authService.getAddressesForBookings(
  //           bookingsFromApi, setState, addressesDepart, subAddressesDepart),
  //     ]);

  //     setState(() {
  //       bookings = bookingsFromApi;
  //       // Sort by dateNow initially
  //     });
  //   } catch (error) {
  //     print('Error loading data: $error');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BottomNavBarTechView(
                      userId: widget.userId, accountId: widget.accountId),
                ));
          },
        ),
        title: CustomText(
          text: 'Đơn làm việc',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: FrontendConfigs.kPrimaryColor,
        ),
        centerTitle: true,
      ),
      body: BookingListBody(
        accountId: widget.accountId,
        userId: widget.userId,
        bookings: bookings,
        addressesDepart: addressesDepart,
        addressesDesti: addressesDesti,
        subAddressesDepart: subAddressesDepart,
        subAddressesDesti: subAddressesDesti,
      ),
    );
  }
}
