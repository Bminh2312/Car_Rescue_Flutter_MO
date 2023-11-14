import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/technician.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/technician_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WaitingForPaymentScreen extends StatefulWidget {
  @override
  State<WaitingForPaymentScreen> createState() =>
      _WaitingForPaymentScreenState();
}

class _WaitingForPaymentScreenState extends State<WaitingForPaymentScreen> {
  Technician? technicianInfo;
  // Future<void> _loadTechInfo(String techId) async {
  //   Map<String, dynamic>? techProfile =
  //       await AuthService().fetchTechProfile(techId);
  //   print('day la ${techProfile}');
  //   if (techProfile != null) {
  //     setState(() {
  //       technicianInfo = Technician.fromJson(techProfile);
  //     });
  //   }
  // }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FrontendConfigs.kIconColor,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Lottie.asset('assets/animations/waiting_payment.json',
                width: 350, height: 350, fit: BoxFit.fill),
            Center(
              child: CustomText(
                text: 'Chờ thanh toán',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                margin: EdgeInsets.all(16),
                child: ListView(
                  children: <Widget>[
                    OrderItem(title: 'Item 1', quantity: 2),
                    OrderItem(title: 'Item 2', quantity: 3),
                    // Add more items as needed
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Trả bằng tiền mặt',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '1.200.000đ', // Replace with your total amount calculation
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Hãy đảm bảo bạn đã nhận đủ tiền và nhấn nút xác nhận phía dưới.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => BottomNavBarView(
                //       accountId: technicianInfo!.accountId,
                //       userId: technicianInfo!.id,
                //     ),
                //   ),
                // );
              },
              child: Text('Xác nhận'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: FrontendConfigs.kActiveColor, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12), // Padding
              ),
            )
          ],
        ),
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
