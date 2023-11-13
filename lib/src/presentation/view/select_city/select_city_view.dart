import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/view/select_mode/select_mode_view.dart';

import 'layout/body.dart';

class SelectCityView extends StatelessWidget {
  const SelectCityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(right: 18.0, left: 18, bottom: 10),
        child: AppButton(
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const SelectModeView()));
          },
          btnLabel: 'Next',
        ),
      ),
      body: const SelectCityBody(),
    );
  }
}
