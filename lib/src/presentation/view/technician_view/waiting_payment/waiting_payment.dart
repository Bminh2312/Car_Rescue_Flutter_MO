import 'dart:convert';

import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/models/payment.dart';
import 'package:CarRescue/src/models/technician.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/technician_view/waiting_payment/completed_payment.dart';

import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class WaitingForPaymentScreen extends StatefulWidget {
  final Payment payment;
  final Booking booking;
  final String userId;
  final String accountId;
  final Map<String, String> addressesDepart;
  final Map<String, String> subAddressesDepart;
  final Map<String, String> addressesDesti;
  final Map<String, String> subAddressesDesti;
  final String managerId;
  final String deviceToken;
  final String data;
  final Technician tech;
  const WaitingForPaymentScreen(
      {super.key,
      required this.payment,
      required this.userId,
      required this.booking,
      required this.addressesDepart,
      required this.subAddressesDepart,
      required this.addressesDesti,
      required this.subAddressesDesti,
      required this.accountId,
      required this.data,
      required this.managerId,
      required this.deviceToken,
      required this.tech});
  @override
  State<WaitingForPaymentScreen> createState() =>
      _WaitingForPaymentScreenState();
}

class _WaitingForPaymentScreenState extends State<WaitingForPaymentScreen> {
  String? accessToken = GetStorage().read<String>("accessToken");
  Technician? technicianInfo;
  Booking? booking;
  List<Map<String, dynamic>> orderDetails = [];
  num totalQuantity = 0;
  num totalAmount = 0;
  int total = 0;
  Payment? _payment;

  Future<void> _loadTechInfo(String techId) async {
    Map<String, dynamic>? techProfile =
        await AuthService().fetchTechProfile(techId);

    if (techProfile != null) {
      setState(() {
        technicianInfo = Technician.fromJson(techProfile);
      });
    }
  }

  void calculateTotals() {
    int totalQuantity = 0;
    double totalAmount = 0.0;

    for (var order in orderDetails) {
      int quantity = order['quantity'] ?? 0; // Giả định 'quantity' là một int
      double total = double.tryParse(order['tOtal'].toString()) ??
          0.0; // Chuyển 'total' sang double

      totalQuantity += quantity;
      totalAmount += total;
    }

    // Cập nhật state với tổng số lượng và tổng giá trị
    setState(() {
      this.totalQuantity = totalQuantity;
      this.totalAmount = totalAmount;
    });
  }

  Future<void> fetchServiceData(String orderId) async {
    final apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/OrderDetail/GetDetailsOfOrder?id=$orderId';

    final response =
        await http.get(Uri.parse(apiUrl), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken'
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('data') && responseData['data'] is List) {
        setState(() {
          orderDetails = List<Map<String, dynamic>>.from(responseData['data']);
          print(orderDetails);
          calculateTotals();
        });
      } else {
        throw Exception('API response does not contain a valid list of data.');
      }
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<Map<String, dynamic>> fetchServiceNameAndQuantity(
      String serviceId) async {
    final apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Service/Get?id=$serviceId';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = data['data'];
        final String name = responseData['name'];
        final int quantity = orderDetails
            .firstWhere((order) => order['serviceId'] == serviceId)['quantity'];

        return {'name': name, 'quantity': quantity};
      }
    }
    throw Exception('Failed to load service name and quantity from API');
  }

  @override
  void initState() {
    super.initState();
    _loadTechInfo(widget.userId);
    fetchServiceData(widget.booking.id);
    calculateTotals();
    _loadPayment(widget.booking.id);
  }

  Future<void> _loadPayment(String orderId) async {
    try {
      Map<String, dynamic>? paymentInfo =
          await AuthService().fetchPayment(widget.booking.id);
      print(paymentInfo);
      // Assuming Payment.fromJson is a constructor that returns a Payment object
      Payment payment = Payment.fromJson(paymentInfo);
      print(payment);
      setState(() {
        _payment = payment;
      });
    } catch (e) {
      // Handle any potential errors, such as network issues
      print('Error loading payment: $e');
      // Optionally, set some state to show an error message in the UI
    }
  }

  Widget _buildOrderItemSection() {
    return Container(
      height: 260,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: orderDetails.map((orderDetail) {
            return FutureBuilder<Map<String, dynamic>>(
              future: fetchServiceNameAndQuantity(
                  orderDetail['serviceId']), // Fetch service name and quantity
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final name = snapshot.data?['name'] ?? 'Name not available';
                  final quantity = snapshot.data?['quantity'] ?? 0;
                  final price = snapshot.data?['price'] ?? 0;
                  final total = orderDetail['tOtal'] ?? 0.0;
                  // Accumulate the total quantity and total amount
                  totalQuantity = quantity as int;
                  totalAmount = total as int;
                  final formatter =
                      NumberFormat.currency(symbol: '₫', locale: 'vi_VN');
                  final formattedTotal = formatter.format(total);

                  return Column(
                    children: [
                      _buildInfoRow(
                        '$name (Số lượng: ${totalQuantity.toString()}) ',
                        Text(
                          '$formattedTotal',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error fetching service name and quantity');
                } else {
                  return CircularProgressIndicator(); // Show a loading indicator
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
    ).format(_payment?.amount ?? 0);
    return Scaffold(
      backgroundColor: FrontendConfigs.kIconColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Lottie.asset('assets/animations/waiting_payment.json',
                    width: 250, height: 250, fit: BoxFit.fill),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CustomText(
                    text: 'Chờ thanh toán',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  height: 360,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomText(
                        text: 'Đơn hàng',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      _buildOrderItemSection(),

                      Spacer(),
                      Divider(
                        thickness: 2,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: CustomText(
                            text: 'Tổng cộng',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )),
                          Text(
                            NumberFormat.currency(
                              locale: 'vi_VN',
                              symbol: '₫',
                            ).format(_payment?.amount ?? 0),
                            // Replace with your total amount calculation
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                      // Add more items as needed
                    ],
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
          Spacer(),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Text(
                        (_payment?.method == 'Cash')
                            ? 'Trả bằng tiền mặt'
                            : (_payment?.method == 'Banking')
                                ? 'Trả bằng chuyển khoản'
                                : 'ko cóa',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _payment?.method != 'Cash'
                        ? IconButton(
                            icon: Icon(Icons.qr_code),
                            iconSize: 30,
                            onPressed: () {
                              // Show the QR code image when the button is pressed
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Container(
                                      width:
                                          500, // Set the width to your desired value
                                      // Set the height to your desired value
                                      child: Image.network(
                                        widget.data,
                                        height: 400,
                                        width:
                                            400, // Replace with your QR code image path
                                        fit: BoxFit
                                            .contain, // Fit the image within the available space
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              NumberFormat.currency(
                                locale: 'vi_VN',
                                symbol: '₫',
                              ).format(_payment?.amount ?? 0),
                              // Replace with your total amount calculation
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ), // Empty container when payment.method is 'Cash'
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  'Hãy đảm bảo bạn đã nhận đủ tiền và nhấn nút xác nhận phía dưới.',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Booking updatedBooking = await AuthService()
                          .fetchBookingById(widget.booking.id);
                      AuthService().completedOrder(widget.booking.id, true);
                      // Update the local state with the fetched booking details
                      AuthService().sendNotification(
                          deviceId: widget.deviceToken,
                          isAndroidDevice: true,
                          title: 'Thông báo từ kĩ thuật viên',
                          body:
                              'Kĩ thuật viên ${widget.tech.fullname} đã nhận số tiền ${currencyFormat} cho đơn hàng ${widget.booking.id}',
                          target: widget.managerId,
                          orderId: widget.booking.id);
                      setState(() {
                        booking = updatedBooking;
                      });
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingCompletedScreen(
                              widget.userId,
                              widget.accountId,
                              booking!,
                              widget.addressesDepart,
                              widget.subAddressesDepart,
                              widget.addressesDesti,
                              widget.subAddressesDesti,
                              widget.payment),
                        ),
                      );
                    },
                    child: Text('Xác nhận'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          FrontendConfigs.kActiveColor, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12), // Padding
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    Widget value,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.0), // Add spacing between label and value
          value
        ],
      ),
    );
  }
}

class OrderItem extends StatelessWidget {
  final String title;
  final int quantity;

  OrderItem({Key? key, required this.title, required this.quantity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(title),
            Text('Quantity: $quantity'),
          ],
        ),
      ),
    );
  }
}
