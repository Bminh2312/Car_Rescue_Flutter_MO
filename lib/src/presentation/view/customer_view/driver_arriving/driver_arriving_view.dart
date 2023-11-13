import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';

import 'layout/body.dart';

class DriverArrivingView extends StatelessWidget {
  const DriverArrivingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: customAppBar(context),
      body: DriverArrivingBody(),
    );
  }
}
