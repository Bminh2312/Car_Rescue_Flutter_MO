import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_details/layout/body.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:flutter/material.dart';

class BookingDetailsView extends StatefulWidget {
  final Booking booking;
  // Add this line to store the booking
  final Map<String, String> addressesDepart;
  final Map<String, String> subAddressesDepart;
  final Map<String, String> addressesDesti;
  final Map<String, String> subAddressesDesti;
  BookingDetailsView({
    Key? key,
    required this.booking,
    required this.addressesDepart,
    required this.subAddressesDepart,
    required this.subAddressesDesti,
    required this.addressesDesti,
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
        text: 'Booking Details',
        showText: true,
      ),
      body: BookingDetailsBody(
        widget.booking,
        widget.addressesDepart,
        widget.subAddressesDepart,
        widget.addressesDesti,
        widget.subAddressesDesti,
      ),
    );
  }
}
