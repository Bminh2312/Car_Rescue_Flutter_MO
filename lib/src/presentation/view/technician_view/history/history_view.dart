import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/presentation/view/technician_view/history/layout/history_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../configuration/frontend_configs.dart';

class HistoryView extends StatefulWidget {
  const HistoryView(
      {Key? key,
      required this.userId,
      required this.addressesDepart,
      required this.subAddressesDepart,
      required this.addressesDesti,
      required this.subAddressesDesti,
      required this.bookings,
      required this.accountId})
      : super(key: key);
  final String userId;
  final String accountId;
  final List<Booking> bookings;
  final Map<String, String> addressesDepart;
  final Map<String, String> subAddressesDepart;
  final Map<String, String> addressesDesti;
  final Map<String, String> subAddressesDesti;
  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
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
          title: Text(
            "Lịch sử đơn hàng",
            style: TextStyle(
                color: FrontendConfigs.kPrimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: HistoryCard(
          userId: widget.userId,
          accountId: widget.accountId,
          addressesDepart: widget.addressesDepart,
          addressesDesti: widget.addressesDesti,
          subAddressesDepart: widget.subAddressesDepart,
          subAddressesDesti: widget.subAddressesDesti,
        ),
      ),
    );
  }
}
