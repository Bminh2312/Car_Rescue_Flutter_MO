import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/select_service/select_service_view.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OrderProcessingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              children: [
                SizedBox(width: 40),
                Lottie.asset('assets/animations/order_processing.json',
                    width: 350, height: 350, fit: BoxFit.fill),
              ],
            ),
            Text(
              'Tạo đơn thành công.\nHệ thống đang xác nhận',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: .5),
            ),
            SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.all(8.0), // Padding cho nút
              child: SizedBox(
                width: double.infinity, // Chiều rộng trải rộng toàn bộ màn hình
                child: ElevatedButton(
                  child: Text('Quay lại trang chủ'),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceView(),
                      ),
                    );
                  },
                ),
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
