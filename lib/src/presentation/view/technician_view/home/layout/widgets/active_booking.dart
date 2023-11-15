import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/models/customerInfo.dart';
import 'package:CarRescue/src/presentation/elements/booking_status.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_details/booking_details_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../models/booking.dart';
import 'package:url_launcher_android/url_launcher_android.dart';

class ActiveBookingCard extends StatefulWidget {
  final String userId;
  final String avatar;
  final Booking booking;

  ActiveBookingCard({
    required this.userId,
    required this.avatar,
    required this.booking,
  });

  @override
  State<ActiveBookingCard> createState() => _ActiveBookingCardState();
}

class _ActiveBookingCardState extends State<ActiveBookingCard> {
  AuthService authService = AuthService();
  Map<String, String> addressesDepart = {};
  Map<String, String> subAddressesDepart = {};
  Map<String, String> addressesDesti = {};
  Map<String, String> subAddressesDesti = {};

  CustomerInfo? customerInfo;

  late Future<CustomerInfo?>
      customerInfoFuture; // Add a Future for customerInfo

  @override
  void initState() {
    super.initState();
    customerInfoFuture = loadCustomerInfo(widget.booking.customerId);
    authService.getAddressesForBookings(
        [widget.booking], setState, addressesDepart, subAddressesDepart);

    authService.getDestiForBookings(
        [widget.booking], setState, addressesDesti, subAddressesDesti);
  }

  Future<CustomerInfo?> loadCustomerInfo(String customerId) async {
    Map<String, dynamic>? userProfile =
        await authService.fetchCustomerInfo(customerId);
    if (userProfile != null) {
      return CustomerInfo.fromJson(userProfile);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CustomerInfo?>(
      future: customerInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          customerInfo = snapshot.data;
          return buildCard();
        } else {
          return CircularProgressIndicator(); // Loading indicator while waiting for data
        }
      },
    );
  }

  // void _launchCaller(String phoneNumber) async {
  //   String url = "tel:$phoneNumber";
  //   if (await canLaunch(url)
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  Widget buildCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetailsView(
              booking: widget.booking,
              addressesDepart: addressesDepart,
              addressesDesti: addressesDesti,
              subAddressesDepart: subAddressesDesti,
              subAddressesDesti: subAddressesDesti,
            ),
          ),
        );
        print('day la: ${addressesDepart}');
      },
      child: Container(
        child: Card(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                15.0), // Adjust the border radius as needed
          ),
          child: Stack(children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CustomText(
                  //   text: 'Đơn đang thực hiện',
                  //   fontSize: 18,
                  //   fontWeight: FontWeight.bold,
                  // ),
                  // Divider(),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 32.0,
                        backgroundColor: Colors.grey,
                        backgroundImage: customerInfo?.avatar != null
                            ? NetworkImage(customerInfo!.avatar)
                            : const AssetImage('assets/images/profile.png')
                                as ImageProvider,
                      ),

                      SizedBox(width: 16.0),

                      // User Info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Align children vertically centered
                        children: [
                          // Pro Name
                          Text(
                            customerInfo?.fullname ??
                                '', // Use customerInfo.fullname or 'Tom' as a fallback
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          CustomText(
                            text: customerInfo?.phone ?? 'Chưa thêm SĐT',
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/svg/pickup_icon.svg', // Replace with the path to your SVG file
                                color: FrontendConfigs.kIconColor,
                                width: 20.0,
                                height: 20.0,
                              ),
                              SizedBox(width: 9.5),
                              CustomText(
                                text: '${addressesDepart[widget.booking.id]}',
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                          // Add spacing

                          // Add spacing

                          SizedBox(height: 10.0), // Add spacing

                          Row(
                            children: [
                              BookingStatus(status: widget.booking.status)
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FrontendConfigs.kActiveColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final Uri telUri = Uri(
                            scheme: 'tel',
                            path:
                                '${customerInfo?.phone ?? ''}'); // Replace with actual number
                        if (await canLaunchUrl(telUri)) {
                          await launchUrl(telUri);
                        } else {
                          print('Could not launch $telUri');
                        }
                      } catch (e) {
                        print('Failed to make a call because: $e');
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.phone_arrow_down_left),
                        SizedBox(width: 5),
                        Text('Gọi khách hàng'),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
