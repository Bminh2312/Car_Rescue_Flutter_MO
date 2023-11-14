import 'package:CarRescue/src/presentation/view/technician_view/home/layout/body.dart';
import 'package:CarRescue/src/presentation/view/technician_view/profile/profile_view.dart';
import 'package:flutter/material.dart';

import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';

class TechnicianHomeView extends StatelessWidget {
  final String userId;
  final String accountId;
  TechnicianHomeView({Key? key, required this.userId, required this.accountId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: FrontendConfigs.kBackgrColor,
        child: TechncianHomePageBody(
          userId: userId,
        ),
      ),
    );
  }
}
