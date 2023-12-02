// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// class OrderDetailWidget extends StatefulWidget {
//   final Map<String, dynamic> orderDetail;

//   OrderDetailWidget({required this.orderDetail});

//   @override
//   State<OrderDetailWidget> createState() => _OrderDetailWidgetState();
// }

// class _OrderDetailWidgetState extends State<OrderDetailWidget> {
//   Future<Map<String, dynamic>> fetchServiceNameAndQuantity(
//       String serviceId) async {
//     final apiUrl =
//         'https://rescuecapstoneapi.azurewebsites.net/api/Service/Get?id=$serviceId';

//     final response = await http.get(Uri.parse(apiUrl));

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
//         final Map<String, dynamic> responseData = data['data'];
//         final String name = responseData['name'];
//         final int price = responseData['price'];
//         final int quantity = orderDetails
//             .firstWhere((order) => order['serviceId'] == serviceId)['quantity'];

//         return {'name': name, 'quantity': quantity, 'price': price};
//       }
//     }
//     throw Exception('Failed to load service name and quantity from API');
//   }
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       // Key for FutureBuilder
//       future: fetchServiceNameAndQuantity(widget.orderDetail['serviceId']),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           final name = snapshot.data?['name'] ?? 'Name not available';
//           final quantity = widget.orderDetail['quantity'] ?? 0;
//           final price = snapshot.data?['price'] ?? 0;
//           int total = widget.orderDetail['tOtal'] ?? 1.0;
//           final orderId = widget.orderDetail['id'];
//           final formatter =
//               NumberFormat.currency(symbol: '₫', locale: 'vi_VN');
//           final formattedTotal = formatter.format(total);

//           return Column(
//             children: [
//               _buildInfoRow(
//                 '$name (Số lượng: $quantity) ',
//                 Text(
//                   '$formattedTotal',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 // Include quantity selection here
//               ),
//               Row(
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.remove),
//                     onPressed: () async {
//                       if (quantity > 1) {
//                         setState(() {
//                           _updateService(
//                             orderId,
//                             quantity - 1,
//                             name,
//                           );
//                           widget.orderDetail['quantity'] = quantity - 1;

//                           // Recalculate total
//                           widget.orderDetail['tOtal'] = (quantity - 1) * price;

//                           // Trigger refresh by changing the key
//                         });

//                         // Introduce a small delay before calling _loadPayment
//                         await Future.delayed(Duration(milliseconds: 100));

//                         // Now, call _loadPayment after a short delay
//                         await _loadPayment(widget.booking.id);
//                       }
//                     },
//                   ),
//                   SizedBox(
//                     width: 50,
//                     height: 32,
//                     child: TextFormField(
//                       readOnly: true,
//                       textAlign: TextAlign.center,
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(),
//                       ),
//                       controller: TextEditingController(
//                         text: quantity.toString(),
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.add),
//                     onPressed: () async {
//                       setState(() {
//                         _updateService(
//                           orderId,
//                           quantity + 1,
//                           name,
//                         );
//                         widget.orderDetail['quantity'] = quantity + 1;

//                         // Recalculate total
//                         widget.orderDetail['tOtal'] = (quantity + 1) * price;

//                         // Trigger refresh by changing the key
//                       });

//                       // Introduce a small delay before calling _loadPayment
//                       await Future.delayed(Duration(milliseconds: 100));

//                       // Now, call _loadPayment after a short delay
//                       await _loadPayment(widget.booking.id);
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           );
//         } else if (snapshot.hasError) {
//           return Text('Error fetching service name and quantity');
//         } else {
//           return SizedBox.shrink(); // Show a loading indicator
//         }
//       },
//     );
//   }
// }