import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';

import 'layout/body.dart';

class TopUpView extends StatelessWidget {
  const TopUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        showText: true,
        text: 'Top up Wallet',
      ),
      body: TopUpBody(),
      // bottomNavigationBar:AppButton(onPressed: () {  }, btnLabel: 'Continue',),
    );
  }
}
