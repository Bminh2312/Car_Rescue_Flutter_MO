// import 'package:flutter/material.dart';

// import '../widgets/booking.dart';
// import 'package:diacritic/diacritic.dart';

// class SearchBookingDetails extends StatefulWidget {
//   final List<Booking> allBookings;
//   final Function(List<Booking>) onSearch;

//   SearchBookingDetails({
//     required this.allBookings,
//     required this.onSearch,
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<SearchBookingDetails> createState() => _SearchBookingDetailsState();
// }

// class _SearchBookingDetailsState extends State<SearchBookingDetails> {
//   TextEditingController _searchController = TextEditingController();
//   bool _isListEmpty = false;
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(5.0),
//       child: Column(
//         children: [
//           TextField(
//             controller: _searchController,
//             onChanged: (String query) {
//               // Filter the bookings based on the departure location as you type (ignoring diacritics)
//               List<Booking> filteredBookings = widget.allBookings
//                   .where((booking) =>
//                       removeDiacritics(booking.departure.toLowerCase())
//                           .contains(removeDiacritics(query.toLowerCase())))
//                   .toList();
//               widget.onSearch(filteredBookings);

//               // Set a flag to indicate whether the list is empty or not
//               bool isListEmpty = filteredBookings.isEmpty;
//               setState(() {
//                 _isListEmpty = isListEmpty;
//               });
//             },
//             decoration: InputDecoration(
//               prefixIcon: Icon(Icons.search),
//               hintText: "Tìm kiếm theo điểm bắt đầu",
//             ),
//           ),
//           if (_isListEmpty)
//             Container(
//               padding: EdgeInsets.only(top: 250),
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.search,
//                         size: 64, // Adjust the size as needed
//                         color: Colors.grey,
//                       ),
//                       SizedBox(
//                           height:
//                               5), // Add vertical space between the icon and text
//                       Text(
//                         "Không có kết quả phù hợp",
//                         style: TextStyle(
//                           fontSize: 20,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             )
//         ],
//       ),
//     );
//   }
// }
