// import 'package:CarRescue/src/configuration/frontend_configs.dart';
// import 'package:CarRescue/src/models/booking.dart';
// import 'package:CarRescue/src/models/customerInfo.dart';
// import 'package:CarRescue/src/utils/api.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class ActiveBookingCard extends StatefulWidget {
//   final String userId;
//   final String avatar;
//   final Booking booking;

//   ActiveBookingCard({
//     required this.userId,
//     required this.avatar,
//     required this.booking,
//   });

//   @override
//   State<ActiveBookingCard> createState() => _ActiveBookingCardState();
// }

// class _ActiveBookingCardState extends State<ActiveBookingCard> {
//   AuthService authService = AuthService();
//   Map<String, String> addressesDepart = {};
//   Map<String, String> subAddressesDepart = {};
//   Map<String, String> addressesDesti = {};
//   Map<String, String> subAddressesDesti = {};

//   CustomerInfo? customerInfo;

//   late Future<CustomerInfo?>
//       customerInfoFuture; // Add a Future for customerInfo

//   @override
//   void initState() {
//     super.initState();
//     customerInfoFuture = loadCustomerInfo(widget.booking.customerId);
//     authService.getAddressesForBookings(
//         [widget.booking], setState, addressesDepart, subAddressesDepart);
//     authService.getDestiForBookings(
//         [widget.booking], setState, addressesDesti, subAddressesDesti);
//   }

//   Future<CustomerInfo?> loadCustomerInfo(String customerId) async {
//     Map<String, dynamic>? userProfile =
//         await authService.fetchCustomerInfo(customerId);
//     if (userProfile != null) {
//       return CustomerInfo.fromJson(userProfile);
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<CustomerInfo?>(
//       future: customerInfoFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           customerInfo = snapshot.data;
//           return buildCard();
//         } else {
//           return CircularProgressIndicator(); // Loading indicator while waiting for data
//         }
//       },
//     );
//   }

//   // Widget buildCard() {
//   //   return InkWell(
//   //     onTap: () {
//   //       Navigator.push(
//   //         context,
//   //         MaterialPageRoute(
//   //           builder: (context) => BookingDetailsView(
//   //             booking: widget.booking,
//   //             addressesDepart: addressesDepart,
//   //             addressesDesti: addressesDesti,
//   //             subAddressesDepart: subAddressesDesti,
//   //             subAddressesDesti: subAddressesDesti,
//   //           ),
//   //         ),
//   //       );
//   //       print('day la: ${addressesDesti}');
//   //     },
//   //     child: Container(
//   //       color: FrontendConfigs.kBackgrColor,
//   //       child: Card(
//   //         elevation: 2.0,
//   //         margin: EdgeInsets.all(15),
//   //         shape: RoundedRectangleBorder(
//   //           borderRadius: BorderRadius.circular(
//   //               15.0), // Adjust the border radius as needed
//   //         ),
//   //         child: Stack(children: [
//   //           Positioned(
//   //             right: 30, // Adjust the position as needed
//   //             bottom: 55, // Adjust the position as needed
//   //             child: Icon(Icons.arrow_forward),
//   //           ),
//   //           Padding(
//   //             padding: EdgeInsets.only(left: 10, bottom: 10, top: 12),
//   //             child: Row(
//   //               crossAxisAlignment: CrossAxisAlignment.center,
//   //               children: [
//   //                 // Avatar
//   //                 CircleAvatar(
//   //                   radius: 32.0,
//   //                   backgroundColor: Colors.grey,
//   //                   backgroundImage: AssetImage(widget.avatar),
//   //                 ),

//   //                 SizedBox(width: 16.0),

//   //                 // User Info
//   //                 Column(
//   //                   crossAxisAlignment: CrossAxisAlignment.start,
//   //                   mainAxisAlignment: MainAxisAlignment
//   //                       .center, // Align children vertically centered
//   //                   children: [
//   //                     // Pro Name
//   //                     Padding(
//   //                       padding: const EdgeInsets.only(bottom: 8.0),
//   //                       child: Text(
//   //                         customerInfo?.fullname ??
//   //                             '', // Use customerInfo.fullname or 'Tom' as a fallback
//   //                         style: TextStyle(
//   //                           fontSize: 18.0,
//   //                           fontWeight: FontWeight.bold,
//   //                           color: Colors.black,
//   //                         ),
//   //                       ),
//   //                     ),

//   //                     // Premium Badge
//   //                     Row(
//   //                       children: [
//   //                         SvgPicture.asset(
//   //                           'assets/svg/pickup_icon.svg', // Replace with the path to your SVG file
//   //                           color: FrontendConfigs.kIconColor,
//   //                           width: 20.0,
//   //                           height: 20.0,
//   //                         ),
//   //                         SizedBox(width: 9.5),
//   //                         Text(
//   //                           '${addressesDepart[widget.booking.id]}',
//   //                           style: TextStyle(
//   //                             fontSize: 16.0,
//   //                             fontWeight: FontWeight.w500,
//   //                             color: Colors.grey,
//   //                           ),
//   //                         ),
//   //                       ],
//   //                     ),
//   //                     SizedBox(height: 3.0), // Add spacing

//   //                     Row(
//   //                       children: [
//   //                         SizedBox(width: 2.5),
//   //                         SvgPicture.asset(
//   //                           'assets/svg/location_icon.svg',
//   //                           // Replace with the path to your SVG file
//   //                           color: FrontendConfigs.kIconColor,
//   //                           width: 10.0,
//   //                           height: 20.0,
//   //                         ),
//   //                         SizedBox(width: 12.5),
//   //                         Text(
//   //                           '${addressesDesti[widget.booking.id]}',
//   //                           style: TextStyle(
//   //                             fontSize: 16.0,
//   //                             fontWeight: FontWeight.bold,
//   //                             color: Colors.grey, // Slate-dark color
//   //                           ),
//   //                         ),
//   //                       ],
//   //                     ),
//   //                     SizedBox(height: 3.0), // Add spacing

//   //                     Row(
//   //                       children: [
//   //                         Icon(
//   //                           Icons.work_rounded, // Premium badge icon
//   //                           color: FrontendConfigs.kIconColor,
//   //                           size: 20.0,
//   //                         ),
//   //                         SizedBox(width: 10.0),
//   //                         Text(
//   //                           widget.booking.rescueType,
//   //                           style: TextStyle(
//   //                             fontSize: 16.0,
//   //                             fontWeight: FontWeight.bold,
//   //                             color: Colors.grey, // Slate-dark color
//   //                           ),
//   //                         ),
//   //                       ],
//   //                     ),
//   //                     SizedBox(height: 3.0), // Add spacing

//   //                     Row(
//   //                       children: [
//   //                         Container(
//   //                           padding: EdgeInsets.symmetric(
//   //                               horizontal: 8, vertical: 4),
//   //                           decoration: BoxDecoration(
//   //                             color:
//   //                                 Color(0xffc9e5fb), // Status background color
//   //                             borderRadius: BorderRadius.circular(
//   //                                 5.0), // Adjust the radius as needed
//   //                           ),
//   //                           child: Text(
//   //                             widget.booking.status, // Display the status text
//   //                             style: TextStyle(
//   //                               color: Color(0xff276fdb),
//   //                               fontWeight: FontWeight
//   //                                   .bold, // Text color for 'Completed'
//   //                             ),
//   //                           ),
//   //                         )
//   //                       ],
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //         ]),
//   //       ),
//   //     ),
//   //   );
//   // }
// }
