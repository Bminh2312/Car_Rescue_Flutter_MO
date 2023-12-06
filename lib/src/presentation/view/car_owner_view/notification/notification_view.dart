import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/notification/layout/body.dart';
import 'package:flutter/material.dart';
import '../../../../configuration/frontend_configs.dart';
import '../../../elements/custom_text.dart';

class NotificationView extends StatelessWidget {
  final String accountId;
  const NotificationView({Key? key, required this.accountId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        text: 'Thông báo',
        showText: true,
      ),
      body: NotificationList(accountId: accountId),
    );
  }
}
