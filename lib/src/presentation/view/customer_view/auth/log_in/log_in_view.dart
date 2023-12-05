import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/view/customer_view/auth/sign_up/sign_up_view.dart';
import '../../../../elements/custom_appbar.dart';
import 'layout/body.dart';

class PassengerLogInView extends StatelessWidget {
  const PassengerLogInView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
      ),
      body: LogInBody(),
    );
  }
}
