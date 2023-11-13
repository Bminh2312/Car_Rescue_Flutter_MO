import 'package:flutter/material.dart';

import '../../../../configuration/frontend_configs.dart';
import '../../../elements/custom_text.dart';
import 'layout/body.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key, required this.userId, required this.accountId})
      : super(key: key);
  final String userId;
  final String accountId;
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
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
              Navigator.of(context).pop(true);
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(
                left: 18.0, top: 11, bottom: 11, right: 4),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Color.fromARGB(0, 0, 0, 0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo-color.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit
                        .cover, // Optional, you can adjust the BoxFit as needed
                  ),
                ),
              ),
            ),
          ),
          title: CustomText(
            text: 'Cá nhân',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: FrontendConfigs.kPrimaryColor,
          ),
          centerTitle: true,
        ),
        body: ProfileBody(
          userId: widget.userId,
          accountId: widget.accountId,
        ),
      ),
    );
  }
}
