import 'dart:convert';

import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/presentation/elements/booking_status.dart';
import 'package:CarRescue/src/presentation/elements/empty_state.dart';
import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_list/widgets/selection_location_widget.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_details/booking_details_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart'; // Import the geocoding package
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingListBody extends StatefulWidget {
  final List<Booking> bookings; // Define the list of bookings
  final String userId;
  final String accountId;
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
    required this.accountId,
  }) : super(key: key);

  @override
  _BookingListBodyState createState() => _BookingListBodyState();
}

class _BookingListBodyState extends State<BookingListBody>
    with SingleTickerProviderStateMixin {
  String? accessToken = GetStorage().read<String>("accessToken");
  TabController? _tabController;
  List<Booking> waitingBookings = [];
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
  bool isAssiginedEmpty = false;
  bool isWaitingEmpty = false;
  Map<String, String> addressesDepart = {};
  Map<String, String> subAddressesDepart = {};
  Map<String, String> addressesDesti = {};
  Map<String, String> subAddressesDesti = {};
  @override
  void initState() {
    super.initState();
    // separateBookings();
    // loadCompletedBookings();
    loadAssignedBookings();
    loadCanceledBookings();
    // loadAssignedBookings();
    // loadWaitingBookings();
    _tabController = TabController(length: 4, vsync: this);
    _tabController!.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController!.index == 0) {
      // The first tab (index 0) is active, and the data hasn't been loaded yet
      loadAssignedBookings();
    } else if (_tabController!.index == 1) {
      loadWaitingBookings();
      // loadAssignedBookings();
    } else if (_tabController!.index == 2) {
      loadCompletedBookings();
    } else if (_tabController!.index == 3) {
      loadCanceledBookings();
    }
  }

  @override
  void dispose() {
    print("Disposing TabController.");
    _tabController?.dispose();
    _tabController!.removeListener(_handleTabSelection);
    super.dispose();
  }

  Future<void> _fetchFeedbacks(
      Booking booking, Map<String, Map<String, dynamic>> apiFeedbacks) async {
    var feedbackForBooking = apiFeedbacks[booking.id];
    booking.rating = feedbackForBooking?['rating']?.toDouble();
    booking.note = feedbackForBooking?['note'];
  }

  Future<Map<String, dynamic>> fetchServiceData(String orderId) async {
    final apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/OrderDetail/GetDetailsOfOrder?id=$orderId';

    try {
      final response =
          await http.get(Uri.parse(apiUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      });
      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('abc : $responseData');

        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          print(data);

          if (data.isNotEmpty) {
            final Map<String, dynamic> orderData = data[0];
            final int quantity = orderData['quantity'];
            final int total = orderData['tOtal'];

            return {
              'quantity': quantity,
              'total': total,
            };
          }
        }
      }

      // Return a specific result for cases where an exception is caught
      return {
        'error': 'Failed to load data from API',
      };
    } catch (e) {
      // Return a specific result for cases where an exception is thrown
      return {
        'error': 'Exception: $e',
      };
    }
  }

  void loadCompletedBookings() async {
    try {
      setState(() {
        isDataLoaded = false;
      });

      final List<Booking> completedBookingsFromAPI =
          await authService.fetchTechBookingByCompleted(widget.userId);

      final apiFeedbacks =
          await authService.fetchTechFeedbackRatings(widget.userId);

      // authService.getDestiForBookings(completedBookingsFromAPI, setState,
      //     addressesDesti, subAddressesDesti);

      await authService.getAddressesForBookings(completedBookingsFromAPI,
          setState, addressesDepart, subAddressesDepart);

      completedBookingsFromAPI.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      await Future.forEach(completedBookingsFromAPI, (Booking booking) async {
        await _fetchFeedbacks(booking, apiFeedbacks);
      });

      setState(() {
        completedBookings = completedBookingsFromAPI;
        isDataLoaded = true;
      });

      if (completedBookings.isEmpty) {
        isCompletedEmpty = true;
      }
    } catch (e) {
      print('Error loading bookings: $e');
    }
  }

  void loadAssignedBookings() async {
    try {
      setState(() {
        // This seems like a naming error. You might want to change this to canceledBookings.
        isDataLoaded = false;
      });
      final List<Booking> assignedBookingsFromAPI =
          await AuthService().fetchTechBookingByAssigned(widget.userId);

      authService.getAddressesForBookings(assignedBookingsFromAPI, setState,
          addressesDepart, subAddressesDepart);
      final apiFeedbacks =
          await authService.fetchTechFeedbackRatings(widget.userId);

      assignedBookingsFromAPI.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      List<Future> vehicleAndFeedbackTasks = [];

      for (Booking booking in assignedBookingsFromAPI) {
        vehicleAndFeedbackTasks.add(_fetchFeedbacks(booking, apiFeedbacks));
      }

      await Future.wait(vehicleAndFeedbackTasks);

      setState(() {
        assignedBookings = assignedBookingsFromAPI;
        isDataLoaded = true;
      });
      if (assignedBookings.isEmpty) {
        isAssiginedEmpty = true;
      }
    } catch (e) {
      // Handle any exceptions that occur during the API request
      print('Error loading bookings: $e');
    }
  }

  void loadWaitingBookings() async {
    setState(() {
      // This seems like a naming error. You might want to change this to canceledBookings.
      isDataLoaded = false;
    });
    try {
      setState(() {
        // This seems like a naming error. You might want to change this to canceledBookings.
        isDataLoaded = false;
      });
      final List<Booking> waitingBookingsFromAPI =
          await AuthService().fetchTechBookingByWaiting(widget.userId);
      waitingBookingsFromAPI.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      authService.getAddressesForBookings(waitingBookingsFromAPI, setState,
          addressesDepart, subAddressesDepart);
      setState(() {
        waitingBookings =
            waitingBookingsFromAPI; // This seems like a naming error. You might want to change this to canceledBookings.
        isDataLoaded = true;
      });
      if (waitingBookings.isEmpty) {
        // This seems like a naming error. You might want to change this to canceledBookings.
        isWaitingEmpty = true;
      }
    } catch (e) {
      // Handle any exceptions that occur during the API request
      print('Error loading bookings: $e');
    }
  }

  void loadCanceledBookings() async {
    setState(() {
      // This seems like a naming error. You might want to change this to canceledBookings.
      isDataLoaded = false;
    });
    try {
      setState(() {
        // This seems like a naming error. You might want to change this to canceledBookings.
        isDataLoaded = false;
      });
      final List<Booking> canceledBookingsFromAPI =
          await AuthService().fetchTechBookingByCanceled(widget.userId);
      authService.getDestiForBookings(
          canceledBookingsFromAPI, setState, addressesDesti, subAddressesDesti);
      authService.getAddressesForBookings(canceledBookingsFromAPI, setState,
          addressesDepart, subAddressesDepart);
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
          await AuthService().fetchBookings(widget.userId);

      data.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null)
          return 0; // Both are null, so they're considered equal
        if (a.createdAt == null)
          return 1; // a is null, so it should come after b
        if (b.createdAt == null)
          return -1; // b is null, so it should come after a
        return b.createdAt!.compareTo(
            a.createdAt!); // Both are non-null, proceed with the comparison
      });
      // Sort by startTime
      setState(() {
        waitingBookings = data.where((booking) {
          final status = booking.status.trim().toUpperCase();
          return status == 'WAITING';
        }).toList();
      });
      if (waitingBookings.isEmpty) {
        // This seems like a naming error. You might want to change this to canceledBookings.
        isWaitingEmpty = true;
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              child: TabBar(
                controller: _tabController,
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
                        'Đang chờ',
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
                  controller: _tabController,
                  children: [
                    !isDataLoaded
                        ? LoadingState()
                        : isAssiginedEmpty
                            ? EmptyState()
                            : _buildBookingListView(assignedBookings),
                    !isDataLoaded
                        ? LoadingState()
                        : isWaitingEmpty
                            ? EmptyState()
                            : _buildBookingListView(waitingBookings),
                    !isDataLoaded
                        ? LoadingState()
                        : isCompletedEmpty
                            ? EmptyState()
                            : _buildBookingListView(completedBookings),
                    !isDataLoaded
                        ? LoadingState()
                        : isCanceledEmpty
                            ? EmptyState()
                            : _buildBookingListView(canceledBookings),
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
            .format(booking.createdAt!.toUtc().add(Duration(hours: 14)));

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
                    subtitle: Text(
                      booking.rescueType == "Towing"
                          ? "Keo xe cứu hộ"
                          : (booking.rescueType == "Fixing"
                              ? "Sửa chữa tại chỗ"
                              : booking.rescueType),
                      style: TextStyle(
                        fontSize: 15,
                        color: FrontendConfigs.kAuthColor,
                      ),
                    ),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          title: subAddressesDepart[booking.id] ??
                              '', // Use addresses parameter

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
                                      userId: widget.userId,
                                      accountId: widget.accountId,
                                      booking: booking,
                                      addressesDepart: addressesDepart,
                                      addressesDesti: addressesDesti,
                                      subAddressesDepart: subAddressesDepart,
                                      subAddressesDesti: subAddressesDesti),
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
