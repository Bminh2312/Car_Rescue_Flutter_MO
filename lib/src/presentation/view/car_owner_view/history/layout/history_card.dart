import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/models/vehicle_item.dart';
import 'package:CarRescue/src/presentation/elements/booking_status.dart';
import 'package:CarRescue/src/presentation/elements/empty_state.dart';
import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/booking_details/booking_details_view.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:intl/intl.dart';
import '../../../../../configuration/frontend_configs.dart';
// import '../../layout/selection_location_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/booking_list/widgets/selection_location_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HistoryCard extends StatefulWidget {
  HistoryCard({
    Key? key,
    required this.userId,
    required this.addressesDepart,
    required this.subAddressesDepart,
    required this.addressesDesti,
    required this.subAddressesDesti,
    required this.accountId,
  }) : super(key: key);
  final String userId;
  final String accountId;
  final Map<String, String> addressesDepart;
  final Map<String, String> subAddressesDepart;
  final Map<String, String> addressesDesti;
  final Map<String, String> subAddressesDesti;
  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard>
    with SingleTickerProviderStateMixin {
  bool isDataLoaded = false;
  List<Booking> completedBookings = [];
  List<Booking> canceledBookings = [];
  AuthService authService = AuthService();
  Map<String, String> addressesDepart = {};
  Map<String, String> subAddressesDepart = {};
  Map<String, String> addressesDesti = {};
  Map<String, String> subAddressesDesti = {};
  double ratingStars = 0.0;
  TabController? _tabController;
  bool isCompletedEmpty = false;
  bool isCanceledEmpty = false;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  void initState() {
    super.initState();
    loadCompletedBookings();
    loadCanceledBookings();

    // loadBookings();
  }

  Future<Map<String, dynamic>> fetchServiceData(String orderId) async {
    final apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/OrderDetail/GetDetailsOfOrder?id=$orderId';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);
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
    throw Exception('Failed to load data from API');
  }

  void loadCompletedBookings() async {
    try {
      final List<Booking> completedBookingsFromAPI =
          await AuthService().fetchCarOwnerBookingByCompleted(widget.userId);

      final apiFeedbacks =
          await authService.fetchFeedbackRatings(widget.userId);
      completedBookingsFromAPI.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      List<Future> vehicleAndFeedbackTasks = [];

      for (Booking booking in completedBookingsFromAPI) {
        vehicleAndFeedbackTasks
            .add(_fetchVehicleAndFeedbacks(booking, apiFeedbacks));
      }
      // for (int i = 0; i < completedBookingsFromAPI.length; i++) {
      //   final Map<String, dynamic> serviceData =
      //       await fetchServiceData(completedBookingsFromAPI[i].id);
      //   completedBookingsFromAPI[i].quantity = serviceData['quantity'];
      //   completedBookingsFromAPI[i].total = serviceData['total'];
      // }
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
          await AuthService().fetchCarOwnerBookingByCanceled(widget.userId);
      canceledBookingsFromAPI.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      List<Future> vehicleTasks = [];

      for (Booking booking in canceledBookingsFromAPI) {
        vehicleTasks.add(_fetchVehicleForBooking(booking));
      }

      await Future.wait(vehicleTasks);

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

  Future<void> _fetchVehicleForBooking(Booking booking) async {
    Vehicle vehicleInfoFromAPI =
        await authService.fetchVehicleInfo(booking.vehicleId ?? '');
    booking.vehicleInfo = vehicleInfoFromAPI;
  }

  Future<void> _fetchVehicleAndFeedbacks(
      Booking booking, Map<String, Map<String, dynamic>> apiFeedbacks) async {
    Vehicle vehicleInfoFromAPI =
        await authService.fetchVehicleInfo(booking.vehicleId ?? '');

    booking.vehicleInfo = vehicleInfoFromAPI;
    var feedbackForBooking = apiFeedbacks[booking.id];
    booking.rating = feedbackForBooking?['rating']?.toDouble();
    booking.note = feedbackForBooking?['note'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      'Đã hoàn thành',
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
                      : isCompletedEmpty
                          ? EmptyState()
                          : _buildBookingListView(completedBookings),
                  Column(
                    children: [
                      Expanded(
                        child: !isDataLoaded
                            ? LoadingState()
                            : isCanceledEmpty
                                ? EmptyState()
                                : _buildOtherListView(canceledBookings),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Call setState to reload the screen or perform other refresh logic
    setState(() {
      loadCanceledBookings();
      loadCompletedBookings();
    });
    // Wait for a short delay to simulate network refresh
    await Future.delayed(Duration(seconds: 6));
  }

  Widget _buildBookingListView(List<Booking> bookings) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];

          String formattedStartTime = DateFormat('dd/MM/yyyy | HH:mm')
              .format(booking.createdAt ?? DateTime.now());
          final int quantity = booking.quantity ?? 0;
          final int total = booking.total ?? 0;
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
                      title: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: CustomText(
                          text: formattedStartTime,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Text(booking.rescueType),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2.0,
                                  ),
                                ),
                                child: Text(
                                  '${booking.vehicleInfo!.licensePlate}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: FrontendConfigs.kAuthColor),
                                ),
                              ),
                              Text(
                                ' | ${booking.vehicleInfo!.manufacturer}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: FrontendConfigs.kAuthColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Text(booking.note ?? 'Không có'),
                          BookingStatus(
                            status: booking.status,
                            fontSize: 14,
                          ), // Your existing BookingStatus widget
                          SizedBox(height: 8.0),
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
                      ),
                    ),
                    Divider(
                      color: FrontendConfigs.kIconColor,
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
                            title: widget.addressesDepart[booking.id] ??
                                '', // Use addresses parameter
                            body: widget.subAddressesDepart[booking.id] ?? '',
                            onPressed: () {},
                          ),
                        ),
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
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingDetailsView(
                                        userId: widget.userId,
                                        accountId: widget.accountId,
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
                                color: FrontendConfigs.kAuthColor,
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
      ),
    );
  }

  Widget _buildOtherListView(List<Booking> bookings) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];

          String formattedStartTime = DateFormat('dd/MM/yyyy | HH:mm')
              .format(booking.createdAt ?? DateTime.now());

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
                      title: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: CustomText(
                          text: formattedStartTime,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Text(booking.rescueType),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2.0,
                                  ),
                                ),
                                child: Text(
                                  '${booking.vehicleInfo!.licensePlate}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: FrontendConfigs.kAuthColor),
                                ),
                              ),
                              Text(
                                ' | ${booking.vehicleInfo!.manufacturer}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: FrontendConfigs.kAuthColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Text(booking.note ?? 'Không có'),
                          BookingStatus(
                            status: booking.status,
                            fontSize: 14,
                          ), // Your existing BookingStatus widget
                          SizedBox(height: 8.0),
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
                      ),
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
                                  SvgPicture.asset(
                                      "assets/svg/location_icon.svg",
                                      color: FrontendConfigs.kIconColor),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  CustomText(
                                      text: '6.5km',
                                      fontWeight: FontWeight.w600,
                                      color: FrontendConfigs.kAuthColor)
                                ],
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset("assets/svg/watch_icon.svg",
                                      color: FrontendConfigs.kIconColor),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  CustomText(
                                      text: "15 mins",
                                      fontWeight: FontWeight.w600,
                                      color: FrontendConfigs.kAuthColor)
                                ],
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/svg/wallet_icon.svg",
                                    color: FrontendConfigs.kIconColor,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  CustomText(
                                      text: "\$56.00",
                                      fontWeight: FontWeight.w600,
                                      color: FrontendConfigs.kAuthColor)
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
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingDetailsView(
                                        userId: widget.userId,
                                        accountId: widget.accountId,
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
                                color: FrontendConfigs.kAuthColor,
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
      ),
    );
  }
}
