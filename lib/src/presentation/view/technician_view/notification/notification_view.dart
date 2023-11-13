import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:flutter/material.dart';
import '../../../../configuration/frontend_configs.dart';
import '../../../elements/custom_text.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        text: 'Thông báo',
        showText: true,
      ),
      // body: NotificationList(),
    );
  }
}
