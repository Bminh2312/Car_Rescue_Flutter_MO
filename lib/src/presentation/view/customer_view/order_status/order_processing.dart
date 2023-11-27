import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/feedback/layout/body.dart';
import 'package:CarRescue/src/presentation/view/customer_view/select_service/select_service_view.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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
                          builder: (context) => BottomNavBarView(page: 0),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10), // Spacing between buttons
                  ElevatedButton(
                    child: Text('Xem chi tiết đơn'),
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
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => FeedbackScreen(),
                      //   ),
                      // );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OrderProgressTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TrackerStep(title: 'Xác nhận', completed: true),
        ProgressLine(completed: true),
        TrackerStep(title: 'Đang trên đường', completed: true),
        ProgressLine(completed: false),
        TrackerStep(title: 'Hoàn Thành', completed: false),
      ],
    );
  }
}

class TrackerStep extends StatelessWidget {
  final String title;
  final bool completed;

  const TrackerStep({required this.title, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ProgressDot(completed: completed),
        Text(title),
      ],
    );
  }
}

class ProgressDot extends StatelessWidget {
  final bool completed;

  const ProgressDot({required this.completed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: completed ? Colors.blue : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}

class ProgressLine extends StatelessWidget {
  final bool completed;

  const ProgressLine({required this.completed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 5,
      color: completed ? Colors.blue : Colors.grey,
    );
  }
}
