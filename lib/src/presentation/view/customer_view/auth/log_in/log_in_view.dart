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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpView()));
              },
              child: RichText(
                  text: TextSpan(
                      text: "Don’t have an account? ",
                      style: TextStyle(
                          color: FrontendConfigs.kPrimaryColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 16),
                      children: [
                    TextSpan(
                      text: " Sign up.",
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
