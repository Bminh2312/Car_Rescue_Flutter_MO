import 'dart:convert';

import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/presentation/elements/booking_status.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_list/widgets/selection_location_widget.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_details/booking_details_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart'; // Import the geocoding package
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BookingListBody extends StatefulWidget {
  final List<Booking> bookings; // Define the list of bookings
  final String userId;
  final Map<String, String> addressesDepart;
  final Map<String, String> subAddressesDepart;
  final Map<String, String> addressesDesti;
  final Map<String, String> subAddressesDesti;
  BookingListBody({
    Key? key,
    required this.bookings,
    required this.userId,
    required this.addressesDepart,
    required this.subAddressesDepart,
    required this.subAddressesDesti,
    required this.addressesDesti,
  }) : super(key: key);

  @override
  _BookingListBodyState createState() => _BookingListBodyState();
}

class _BookingListBodyState extends State<BookingListBody> {
  List<Booking> inprogressBookings = [];
  List<Booking> assignedBookings = [];
  List<Booking> otherBookings = [];
  List<Booking> canceledBookings = [];
  String addressDep = '';
  AuthService authService = AuthService();
  bool isDataLoaded = false;
  List<Booking> completedBookings = [];
  bool isCompletedEmpty = false;
  bool isCanceledEmpty = false;
  @override
  void initState() {
    super.initState();
    separateBookings();
    loadCompletedBookings();
    loadCanceledBookings();
  }

  // Future<void> fetchData() async {
  //   try {
  //     final List<Booking> data = await authService.fetchBookings(
  //         widget.userId, '97757c05-1a15-4009-a156-e43095dddd81');
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }
  Future<void> _fetchFeedbacks(
      Booking booking, Map<String, Map<String, dynamic>> apiFeedbacks) async {
    var feedbackForBooking = apiFeedbacks[booking.id];
    booking.rating = feedbackForBooking?['rating']?.toDouble();
    booking.note = feedbackForBooking?['note'];
  }

  void loadCompletedBookings() async {
    try {
      final List<Booking> completedBookingsFromAPI =
          await AuthService().fetchTechBookingByCompleted(widget.userId);

      final apiFeedbacks =
          await authService.fetchTechFeedbackRatings(widget.userId);
      completedBookingsFromAPI.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      List<Future> vehicleAndFeedbackTasks = [];

      for (Booking booking in completedBookingsFromAPI) {
        vehicleAndFeedbackTasks.add(_fetchFeedbacks(booking, apiFeedbacks));
      }

      await Future.wait(vehicleAndFeedbackTasks);

      setState(() {
        completedBookings = completedBookingsFromAPI;
        isDataLoaded = true;
      });
      if (completedBookings.isEmpty) {
        isCompletedEmpty = true;
      }
    } catch (e) {
      // Handle any exceptions that occur during the API request
      print('Error loading bookings: $e');
    }
  }

  void loadCanceledBookings() async {
    try {
      setState(() {
        // This seems like a naming error. You might want to change this to canceledBookings.
        isDataLoaded = false;
      });
      final List<Booking> canceledBookingsFromAPI =
          await AuthService().fetchTechBookingByCanceled(widget.userId);
      canceledBookingsFromAPI.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      setState(() {
        canceledBookings =
            canceledBookingsFromAPI; // This seems like a naming error. You might want to change this to canceledBookings.
        isDataLoaded = true;
      });
      if (canceledBookings.isEmpty) {
        // This seems like a naming error. You might want to change this to canceledBookings.
        isCanceledEmpty = true;
      }
    } catch (e) {
      // Handle any exceptions that occur during the API request
      print('Error loading bookings: $e');
    }
  }

  void separateBookings() async {
    try {
      final List<Booking> data =
          await AuthService().fetchBookings(widget.userId, '');

      // data.sort((a, b) {
      //   if (a.createdAt == null && b.createdAt == null)
      //     return 0; // Both are null, so they're considered equal
      //   if (a.createdAt == null)
      //     return 1; // a is null, so it should come after b
      //   if (b.createdAt == null)
      //     return -1; // b is null, so it should come after a
      //   return b.createdAt!.compareTo(
      //       a.createdAt!); // Both are non-null, proceed with the comparison
      // });
      // Sort by startTime
      setState(() {
        assignedBookings = data.where((booking) {
          final status = booking.status.trim().toUpperCase();
          return status == 'ASSIGNED';
        }).toList();
      });

      print('ASSIGNED Bookings: $inprogressBookings');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              child: TabBar(
                indicatorColor: FrontendConfigs.kPrimaryColor,
                tabs: [
                  Tab(
                    child: Center(
                      child: Text(
                        'Được giao',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Center(
                      child: Text(
                        'Hoàn thành',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Center(
                      child: Text(
                        'Đã hủy',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: FrontendConfigs.kBackgrColor,
                child: TabBarView(
                  children: [
                    _buildBookingListView(assignedBookings),
                    _buildBookingListView(completedBookings),
                    _buildBookingListView(canceledBookings),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingListView(List<Booking> bookings) {
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];

        String formattedStartTime = DateFormat('dd/MM/yyyy | HH:mm')
            .format(booking.createdAt ?? DateTime.now());

        // Future<Customer?> _loadCustomerInfo(String customerId) async {
        //   Map<String, dynamic>? userProfile =
        //       await authService.fetchCustomerInfo(booking.customerId);
        //   print(userProfile);

        //   if (userProfile != null) {
        //     return Customer.fromJson(userProfile);
        //   } else {
        //     return null;
        //   }
        // }

        return Container(
          color: FrontendConfigs.kBackgrColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color.fromARGB(86, 115, 115, 115),
                          width: 2.0,
                        ),
                        color: Color.fromARGB(0, 255, 255, 255),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Color.fromARGB(115, 47, 47, 47),
                        backgroundImage:
                            AssetImage('assets/images/logocarescue.png'),
                        radius: 20,
                      ),
                    ),
                    title: CustomText(
                      text: formattedStartTime,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    subtitle: Text(booking.rescueType),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BookingStatus(
                          status: booking.status,
                          fontSize: 14,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        if (booking.status.toUpperCase() ==
                            'COMPLETED') // Spacing
                          Container(
                            child: RatingBar.builder(
                              itemSize: 12,
                              initialRating: booking.rating ?? 0,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                size: 10,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                          )
                      ],
                    ), // Use the BookingStatusWidget here
                  ),
                  Divider(
                    color: FrontendConfigs.kIconColor,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset("assets/svg/location_icon.svg",
                                    color: FrontendConfigs.kPrimaryColor),
                                const SizedBox(
                                  width: 10,
                                ),
                                CustomText(
                                  text: "6.5 km",
                                  fontWeight: FontWeight.w600,
                                )
                              ],
                            ),
                            Row(
                              children: [
                                SvgPicture.asset("assets/svg/watch_icon.svg"),
                                const SizedBox(
                                  width: 10,
                                ),
                                CustomText(
                                  text: "15 mins",
                                  fontWeight: FontWeight.w600,
                                )
                              ],
                            ),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/svg/wallet_icon.svg",
                                  color: FrontendConfigs.kPrimaryColor,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                CustomText(
                                  text: "\$56.00",
                                  fontWeight: FontWeight.w600,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: FrontendConfigs.kIconColor,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: RideSelectionWidget(
                          icon: 'assets/svg/pickup_icon.svg',
                          title: widget.addressesDepart[booking.id] ??
                              '', // Use addresses parameter
                          body: widget.subAddressesDepart[booking.id] ?? '',
                          onPressed: () {},
                        ),
                      ),
                      if (booking.rescueType == "Towing")
                        const Padding(
                          padding: EdgeInsets.only(left: 29),
                          child: DottedLine(
                            direction: Axis.vertical,
                            lineLength: 30,
                            lineThickness: 1.0,
                            dashLength: 4.0,
                            dashColor: Colors.black,
                            dashRadius: 2.0,
                            dashGapLength: 4.0,
                            dashGapRadius: 0.0,
                          ),
                        ),
                      if (booking.rescueType == "Towing")
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: RideSelectionWidget(
                            icon: 'assets/svg/location_icon.svg',
                            title: widget.addressesDesti[booking.id] ?? '',
                            body: widget.subAddressesDesti[booking.id] ?? '',
                            onPressed: () {},
                          ),
                        ),
                      ButtonBar(
                        children: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingDetailsView(
                                      booking: booking,
                                      addressesDepart: widget.addressesDepart,
                                      addressesDesti: widget.addressesDesti,
                                      subAddressesDepart:
                                          widget.subAddressesDepart,
                                      subAddressesDesti:
                                          widget.subAddressesDesti),
                                ),
                              );
                            },
                            child: CustomText(
                              text: 'Chi tiết',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
