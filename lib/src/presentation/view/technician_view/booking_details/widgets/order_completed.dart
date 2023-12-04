import 'package:CarRescue/src/presentation/view/technician_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';

String accountId = GetStorage().read("accountId");
String userId = GetStorage().read("userId");


class OrderProcessingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xffffeda0),
              Color(0xffffa585),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 80,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tạo đơn thành công',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .5),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Vui lòng chờ hệ thống điều phối nhân sự phù hợp.',
                  style: TextStyle(
                      fontSize: 17, color: Colors.black87, letterSpacing: .5),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 10),
                Lottie.asset('assets/animations/order_processing.json',
                    width: 350, height: 350, fit: BoxFit.fill),
              ],
            ),
            SizedBox(height: 100),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              child: Column(
                children: [
                  ElevatedButton(
                    child: Text('Trang chủ'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // Background color
                      onPrimary: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12), // Padding
                      minimumSize:
                          Size(double.infinity, 36), // Button minimum size
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BottomNavBarTechView(accountId:accountId ,userId:userId ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10), // Spacing between buttons
                  // ElevatedButton(
                  //   child: Text('Xem chi tiết đơn'),
                  //   style: ElevatedButton.styleFrom(
                  //     primary: Colors.blue, // Background color
                  //     onPrimary: Colors.white, // Text color
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius:
                  //           BorderRadius.circular(10), // Rounded corners
                  //     ),
                  //     padding: EdgeInsets.symmetric(
                  //         horizontal: 20, vertical: 12), // Padding
                  //     minimumSize:
                  //         Size(double.infinity, 36), // Button minimum size
                  //   ),
                  //   onPressed: () {
                  //     // Navigator.pushReplacement(
                  //     //   context,
                  //     //   MaterialPageRoute(
                  //     //     builder: (context) => FeedbackScreen(),
                  //     //   ),
                  //     // );
                  //   },
                  // ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}