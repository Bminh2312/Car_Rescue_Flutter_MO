import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'layout/body.dart';

class CancelRideView extends StatelessWidget {
  const CancelRideView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, showText: true, text: 'Cancel Ride'),
      body: const CancelRideBody(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 18, left: 18),
        child: AppButton(
          onPressed: () {},
          btnLabel: 'Submit',
        ),
      ),
    );
  }
}
