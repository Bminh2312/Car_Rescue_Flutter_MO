import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/vehicle_item.dart';

import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/history/history_view.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'layout/body.dart';

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
  Vehicle? CarInfo;
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
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final bookingsFromApi =
          await authService.fetchCarOwnerBookings(widget.userId);

      await authService.getDestiForBookings(
          bookingsFromApi, setState, addressesDesti, subAddressesDesti);
      await authService.getAddressesForBookings(
          bookingsFromApi, setState, addressesDepart, subAddressesDepart);

      setState(() {
        bookings = bookingsFromApi;

        // Sort by dateNow initially
      });
    } catch (error) {
      print('Error loading data1: $error');
    }
  }

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
            Navigator.pop(context);
          },
        ),
        title: CustomText(
          text: 'Đơn làm việc',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: FrontendConfigs.kPrimaryColor,
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryView(
                        accountId: widget.accountId,
                        userId: widget.userId,
                        addressesDepart: addressesDepart,
                        addressesDesti: addressesDesti,
                        subAddressesDepart: subAddressesDepart,
                        subAddressesDesti: subAddressesDesti,
                        bookings: bookings,
                      ),
                    ));
              },
              icon: Icon(
                CupertinoIcons.timer,
                color: FrontendConfigs.kIconColor,
              ))
        ],
      ),
      body: BookingListBody(
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
