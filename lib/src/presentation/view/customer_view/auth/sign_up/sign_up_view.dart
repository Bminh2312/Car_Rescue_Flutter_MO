import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/view/customer_view/auth/verify_number/verify_number_view.dart';

import '../../../../../configuration/frontend_configs.dart';
import '../../../../elements/custom_appbar.dart';
import 'layout/body.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
      ),
      body: SignUpBody(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: RichText(
                  text: TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                          color: FrontendConfigs.kPrimaryColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 16),
                      children: [
                    TextSpan(
                      text: " Sign in.",
                      style: TextStyle(
                          color: FrontendConfigs.kPrimaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    )
                  ])),
            )
          ],
        ),
      ),
    );
  }
}
