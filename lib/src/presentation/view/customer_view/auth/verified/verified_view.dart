import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/view/customer_view/bottom_nav_bar/bottom_nav_bar_view.dart';

import 'layout/body.dart';

class VerifiedView extends StatelessWidget {
  const VerifiedView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar:customAppBar(context),
      body: const VerifiedBody(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(right: 18.0, left: 18, bottom: 10),
        child: AppButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BottomNavBarView(page: 0,)));
          },
          btnLabel: 'Got it!',
        ),
      ),
    );
  }
}
