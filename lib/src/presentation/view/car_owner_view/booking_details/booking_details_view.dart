import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/booking_details/layout/body.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:flutter/material.dart';

class BookingDetailsView extends StatefulWidget {
  final Booking booking;
  final String userId;
  final String accountId;

  // Add this line to store the booking
  final Map<String, String> addressesDepart;
  final Map<String, String> subAddressesDepart;
  final Map<String, String> addressesDesti;
  final Map<String, String> subAddressesDesti;
  final Function? updateTabCallback;
  final Function? reloadData;

  BookingDetailsView({
    Key? key,
    required this.userId,
    required this.accountId,
    required this.booking,
    required this.addressesDepart,
    required this.subAddressesDepart,
    required this.subAddressesDesti,
    required this.addressesDesti,
    this.updateTabCallback,
    this.reloadData,
  }) : super(key: key);

  @override
  State<BookingDetailsView> createState() => _BookingDetailsViewState();
}

class _BookingDetailsViewState extends State<BookingDetailsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        text: 'Chi tiết đơn hàng',
        showText: true,
      ),
      body: BookingDetailsBody(
        widget.userId,
        widget.accountId,
        widget.booking,
        widget.addressesDepart,
        widget.subAddressesDepart,
        widget.addressesDesti,
        widget.subAddressesDesti,
        widget.updateTabCallback,
        widget.reloadData,
      ),
    );
  }
}
