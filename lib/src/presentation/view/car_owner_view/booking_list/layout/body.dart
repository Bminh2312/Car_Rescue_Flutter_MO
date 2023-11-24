import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/models/rescue_vehicle_owner.dart';
import 'package:CarRescue/src/models/vehicle_item.dart';
import 'package:CarRescue/src/presentation/elements/booking_status.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/presentation/elements/empty_state.dart';
import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/booking_list/widgets/selection_location_widget.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/booking_details/booking_details_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

class _BookingListBodyState extends State<BookingListBody>
    with SingleTickerProviderStateMixin {
  List<Booking> inprogressBookings = [];
  List<Booking> assiginingBookings = [];
  List<Booking> assiginedBookings = [];
  String addressDep = '';
  AuthService authService = AuthService();
  bool isDataLoaded = false;
  Vehicle? vehicleInfo;
  bool isEmpty = false;
  TabController? _tabController;
  Map<String, dynamic>? userProfile;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  String accountId = '';
  String phoneNumber = '';
  String avatar = ''; // Default index
  bool isAssiginingEmpty = false;
  bool isAssiginedEmpty = false;
  bool isInprogressEmpty = false;
  bool isDataLoadedForTab0 = false;
  bool isDataLoadedForTab1 = false;
  bool isDataLoadedForTab2 = false;
  List<Map<String, dynamic>> orderDetails = [];
  @override
  void initState() {
    super.initState();
    loadAssigningBookings();
    _tabController = TabController(length: 3, vsync: this);
    _tabController!.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController!.index == 0) {
      // The first tab (index 0) is active, and the data hasn't been loaded yet
      loadAssigningBookings();
    } else if (_tabController!.index == 1) {
      loadAssignedBookings();
    } else if (_tabController!.index == 2) {
      loadInprogressBookings();
    }
  }

  @override
  void dispose() {
    print("Disposing TabController.");
    _tabController?.dispose();
    _tabController!.removeListener(_handleTabSelection);
    super.dispose();
  }

  void _reloadData() {
    setState(() {
      isDataLoaded = true;
    });
    loadAssignedBookings();
    loadInprogressBookings();
    setState(() {
      isDataLoaded = false;
    });
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

  void loadAssigningBookings() async {
    try {
      setState(() {
        // This seems like a naming error. You might want to change this to canceledBookings.
        isDataLoaded = false;
      });
      final List<Booking> assigningBookingsFromAPI =
          await AuthService().fetchCarOwnerBookingByAssigning(widget.userId);
      assigningBookingsFromAPI.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      List<Future> vehicleTasks = [];

      for (Booking booking in assigningBookingsFromAPI) {
        vehicleTasks.add(_fetchVehicleForBooking(booking));
      }
      for (int i = 0; i < assigningBookingsFromAPI.length; i++) {
        final Map<String, dynamic> serviceData =
            await fetchServiceData(assigningBookingsFromAPI[i].id);
        assigningBookingsFromAPI[i].quantity = serviceData['quantity'];
        assigningBookingsFromAPI[i].total = serviceData['total'];
      }
      await Future.wait(vehicleTasks);

      setState(() {
        assiginingBookings =
            assigningBookingsFromAPI; // This seems like a naming error. You might want to change this to canceledBookings.
        isDataLoaded = true;
      });
      if (assiginingBookings.isEmpty) {
        // This seems like a naming error. You might want to change this to canceledBookings.
        isAssiginingEmpty = true;
      }
    } catch (e) {
      // Handle any exceptions that occur during the API request
      print('Error loading bookings: $e');
    }
  }

  void loadAssignedBookings() async {
    try {
      setState(() {
        isDataLoaded = false;
      });
      final List<Booking> assignedBookingsFromAPI =
          await AuthService().fetchCarOwnerBookingByAssigned(widget.userId);
      assignedBookingsFromAPI.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      List<Future> vehicleTasks = [];

      for (Booking booking in assignedBookingsFromAPI) {
        vehicleTasks.add(_fetchVehicleForBooking(booking));
      }

      // Fetch quantity and total for each booking
      for (int i = 0; i < assignedBookingsFromAPI.length; i++) {
        final Map<String, dynamic> serviceData =
            await fetchServiceData(assignedBookingsFromAPI[i].id);
        assignedBookingsFromAPI[i].quantity = serviceData['quantity'];
        assignedBookingsFromAPI[i].total = serviceData['total'];
      }

      await Future.wait(vehicleTasks);

      setState(() {
        assiginedBookings = assignedBookingsFromAPI;
        isDataLoaded = true;
      });
      if (assiginedBookings.isEmpty) {
        isAssiginedEmpty = true;
      }
    } catch (e) {
      print('Error loading bookings: $e');
    }
  }

  void loadInprogressBookings() async {
    try {
      setState(() {
        // This seems like a naming error. You might want to change this to canceledBookings.
        isDataLoaded = false;
      });
      final List<Booking> inprogressBookingsFromAPI =
          await AuthService().fetchCarOwnerBookingByInprogress(widget.userId);
      inprogressBookingsFromAPI.sort((a, b) {
        if (a.startTime == null) return 1;
        if (b.startTime == null) return -1;
        return b.startTime!.compareTo(a.startTime!);
      });
      List<Future> vehicleTasks = [];

      for (Booking booking in inprogressBookingsFromAPI) {
        vehicleTasks.add(_fetchVehicleForBooking(booking));
      }
      for (int i = 0; i < inprogressBookingsFromAPI.length; i++) {
        final Map<String, dynamic> serviceData =
            await fetchServiceData(inprogressBookingsFromAPI[i].id);
        inprogressBookingsFromAPI[i].quantity = serviceData['quantity'];
        inprogressBookingsFromAPI[i].total = serviceData['total'];
      }
      await Future.wait(vehicleTasks);

      setState(() {
        inprogressBookings =
            inprogressBookingsFromAPI; // This seems like a naming error. You might want to change this to canceledBookings.
        isDataLoaded = true;
      });
      if (inprogressBookings.isEmpty) {
        // This seems like a naming error. You might want to change this to canceledBookings.
        isInprogressEmpty = true;
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

  void _reloadBookingList() async {
    // Call the API to fetch the latest booking list
    List<Booking> inprogressOnlyBookings =
        await authService.fetchCarOwnerBookingByInprogress(widget.userId);
    inprogressOnlyBookings.sort((a, b) {
      if (a.startTime == null) return 1;
      if (b.startTime == null) return -1;
      return b.startTime!.compareTo(a.startTime!);
    });
    for (Booking booking in inprogressOnlyBookings) {
      Vehicle vehicleInfoFromAPI =
          await authService.fetchVehicleInfo(booking.vehicleId ?? '');
      booking.vehicleInfo = vehicleInfoFromAPI;
    }
    // Update the local list of bookings with the fetched data
    setState(() {
      inprogressBookings = inprogressOnlyBookings;
    });
  }

  void fetchUserProfileData() async {
    try {
      final userProfile =
          await authService.fetchRescueCarOwnerProfile(widget.userId);

      if (userProfile != null) {
        print('User Profile: $userProfile');
        // Extract the 'data' map from the response
        final Map<String, dynamic> data = userProfile['data'];

        // Extract 'fullname' and 'phone' values from the 'data' map
        final String accountIdAPI = data['accountId'];

        // Update the state with the extracted values or 'N/A' if they are null
        setState(() {
          accountId = accountIdAPI;
        });
      } else {
        // Handle the case where the userProfile is null
        // Set default values for userName and phoneNumber
        setState(() {});
      }
    } catch (e) {
      // Handle any exceptions that occur during the API request
      print('Error fetching user profile1: $e');
      // You can set an error message or handle the error as needed
    }
  }

  Future<bool> separateBookings() async {
    try {
      final List<Booking> data =
          await AuthService().fetchCarOwnerBookings(widget.userId);
      print(data);

      // data.sort((a, b) {
      //   if (a.createdAt == null) return 1;
      //   if (b.createdAt == null) return -1;
      //   return b.createdAt!.compareTo(a.createdAt!);
      // }); // If createdAt is a String

      for (Booking booking in data) {
        Vehicle vehicleInfoFromAPI =
            await authService.fetchVehicleInfo(booking.vehicleId ?? '');
        booking.vehicleInfo = vehicleInfoFromAPI;
      }
      // Fetch RescueVehicleOwner profile

      // Use `setState` to reflect changes
      setState(() {
        inprogressBookings = data.where((booking) {
          final status = booking.status.trim().toUpperCase();
          return status == 'INPROGRESS';
        }).toList();
        if (inprogressBookings.isEmpty) {
          isInprogressEmpty = true;
        }
        assiginingBookings = data.where((booking) {
          final status = booking.status.trim().toUpperCase();
          return status == 'ASSIGNING';
        }).toList();
        if (assiginingBookings.isEmpty) {
          isAssiginingEmpty = true;
        }
        assiginedBookings = data.where((booking) {
          final status = booking.status.trim().toUpperCase();
          return status == 'ASSIGNED';
        }).toList();
        if (assiginedBookings.isEmpty) {
          isAssiginedEmpty = true;
        }
        if (assiginingBookings.isEmpty) {
          setState(() {
            isEmpty = true;
          });
        }
        isDataLoaded = true; // Mark the data as loaded
      });
      return true;
    } catch (e) {
      print('Error: $e');
      return false;
    }
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
                      'Chờ xác nhận',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Tab(
                  child: Center(
                    child: Text(
                      'Đã phân công',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Tab(
                  child: Center(
                    child: Text(
                      'Đang hoạt động',
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
                      : isAssiginingEmpty
                          ? EmptyState()
                          : _buildOtherListView(assiginingBookings),
                  !isDataLoaded
                      ? LoadingState()
                      : isAssiginedEmpty
                          ? EmptyState()
                          : _buildOtherListView(assiginedBookings),
                  Column(
                    children: [
                      Expanded(
                        child: !isDataLoaded
                            ? LoadingState()
                            : isInprogressEmpty
                                ? EmptyState()
                                : _buildBookingListView(inprogressBookings),
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
      separateBookings();
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
          final int quantity = booking.quantity ?? 0;
          final int total = booking.total ?? 0;
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
                                padding: EdgeInsets.all(4),
                                decoration:
                                    BoxDecoration(color: Colors.grey.shade300),
                                child: Text(
                                  '${booking.vehicleInfo?.licensePlate ?? ''}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: FrontendConfigs.kAuthColor),
                                ),
                              ),
                              Text(
                                ' | ${booking.vehicleInfo?.manufacturer ?? ''}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: FrontendConfigs.kAuthColor,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: BookingStatus(
                        status: booking.status,
                        fontSize: 14,
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
                                  SvgPicture.asset(
                                      "assets/svg/location_icon.svg",
                                      color: FrontendConfigs.kIconColor),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  CustomText(
                                      text: '$quantity',
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
                                      text: currencyFormat.format(total),
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
                                var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingDetailsView(
                                      userId: widget.userId,
                                      accountId: accountId,
                                      booking: booking,
                                      addressesDepart: widget.addressesDepart,
                                      addressesDesti: widget.addressesDesti,
                                      subAddressesDepart:
                                          widget.subAddressesDepart,
                                      subAddressesDesti:
                                          widget.subAddressesDesti,
                                      updateTabCallback: (int tabIndex) {
                                        _tabController?.index =
                                            tabIndex; // This will change the tab in `BookingListBody`.
                                      },
                                      reloadData: _reloadData,
                                    ),
                                  ),
                                ).then((value) => {loadInprogressBookings()});
                                // if (result == 'reload') {
                                //   setState(() {
                                //     isDataLoaded = true;
                                //   });
                                //   loadInprogressBookings();
                                //   setState(() {
                                //     isDataLoaded = false;
                                //   });
                                // }
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
          final int quantity = booking.quantity ?? 0;
          final int total = booking.total ?? 0;
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
                                padding: EdgeInsets.all(4),
                                decoration:
                                    BoxDecoration(color: Colors.grey.shade300),
                                child: Text(
                                  '${booking.vehicleInfo?.licensePlate ?? ''}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: FrontendConfigs.kAuthColor),
                                ),
                              ),
                              Text(
                                ' | ${booking.vehicleInfo?.manufacturer ?? ''}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: FrontendConfigs.kAuthColor,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: BookingStatus(
                        status: booking.status,
                        fontSize: 14,
                      ),
                      // Use the BookingStatusWidget here
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                      text: '$quantity km',
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
                                      text: currencyFormat.format(total),
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
                                var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingDetailsView(
                                        userId: widget.userId,
                                        accountId: accountId,
                                        booking: booking,
                                        addressesDepart: widget.addressesDepart,
                                        addressesDesti: widget.addressesDesti,
                                        subAddressesDepart:
                                            widget.subAddressesDepart,
                                        subAddressesDesti:
                                            widget.subAddressesDesti,
                                        updateTabCallback: (int tabIndex) {
                                          _tabController?.index =
                                              tabIndex; // This will change the tab in `BookingListBody`.
                                        },
                                        reloadData: _reloadData),
                                  ),
                                );
                                //   if (result == 'reload') {
                                //     setState(() {
                                //       isDataLoaded = true;
                                //     });
                                //     loadAssignedBookings();
                                //     loadAssigningBookings();
                                //     loadInprogressBookings();
                                //     setState(() {
                                //       isDataLoaded = false;
                                //     });
                                //   }
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
