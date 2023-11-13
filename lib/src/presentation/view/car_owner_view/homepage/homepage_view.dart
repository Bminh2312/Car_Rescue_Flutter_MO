import 'package:CarRescue/src/presentation/view/car_owner_view/auth/log_in/log_in_view.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/homepage/layout/body.dart';
import 'package:CarRescue/src/presentation/view/technician_view/auth/log_in/log_in_view.dart';
import 'package:flutter/material.dart';

class CarOwnerHomeView extends StatefulWidget {
  final String userId;
  final String accountId;

  CarOwnerHomeView({
    Key? key,
    required this.userId,
    required this.accountId,
  }) : super(key: key);

  @override
  State<CarOwnerHomeView> createState() => _CarOwnerHomeViewState();
}

class _CarOwnerHomeViewState extends State<CarOwnerHomeView> {
  Future<bool> _onWillPop(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cảnh báo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Bạn có chắc chắn muốn đăng xuất?',
            style: TextStyle(fontSize: 16)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Huỷ',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              // Perform logout action here
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CarOwnerLogInView(),
                  ));
            },
            child: Text(
              'Đồng ý',
              style: TextStyle(
                  color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        body: Container(
          child: CarOwnerHomePageBody(
            userId: widget.userId,
            accountId: widget.accountId,
          ),
        ),
      ),
    );
  }
}
