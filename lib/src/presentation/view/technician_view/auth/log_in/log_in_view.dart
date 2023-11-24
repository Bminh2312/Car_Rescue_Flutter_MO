import 'package:CarRescue/src/presentation/view/select_mode/select_mode_view.dart';
import 'package:flutter/material.dart';

import '../../../../elements/custom_appbar.dart';
import 'layout/body.dart';

class TechnicianLogInView extends StatelessWidget {
  const TechnicianLogInView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectModeView(),
                ));
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: TechnicianLogInBody(),
    );
  }
}
