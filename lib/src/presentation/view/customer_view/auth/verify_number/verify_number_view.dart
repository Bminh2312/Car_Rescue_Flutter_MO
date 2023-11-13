import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';

import 'layout/body.dart';

class VerifyNumberView extends StatelessWidget {
  const VerifyNumberView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: const VerifyNumberBody(),
    );
  }
}
