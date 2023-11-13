import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/elements/booking_status.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/layout/selection_location_widget.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_details/booking_details_view.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../../../models/booking.dart'; // Replace with the actual import path for Booking

class BookingCard extends StatelessWidget {
  final Booking booking; // Pass the Booking object as a parameter
  final Map<String, String> addressesDepart;
  final Map<String, String> subAddressesDepart;
  final Map<String, String> addressesDesti;
  final Map<String, String> subAddressesDesti;

  BookingCard(
      {required this.booking,
      required this.addressesDepart,
      required this.addressesDesti,
      required this.subAddressesDepart,
      required this.subAddressesDesti});

  @override
  Widget build(BuildContext context) {
    String formattedStartTime = DateFormat('dd/MM/yyyy | HH:mm')
        .format(booking.startTime ?? DateTime.now());

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
                    // Your leading content
                    ),
                title: Container(
                  height: 40, // Adjust the height as needed
                  child: CustomText(
                    text: formattedStartTime,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(booking.rescueType),
                trailing: BookingStatus(
                  status: booking.status,
                ),
              ),
              Divider(
                color: FrontendConfigs.kIconColor,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
                      title: 'abc',
                      body: '089 Stark Gateway',
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
                      title: 'abc',
                      body: '92676 Orion Meadows',
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
  }
}
