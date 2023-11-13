import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/auth/verified/verified_view.dart';
import 'package:pinput/pinput.dart';

import '../../../../../../configuration/frontend_configs.dart';

class OTPBody extends StatelessWidget {
  OTPBody({Key? key}) : super(key: key);
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  final pinController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 77,
      height: 56,
      textStyle: TextStyle(
          fontSize: 16,
          color: FrontendConfigs.kPrimaryColor,
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: FrontendConfigs.kAuthColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black, width: 0.1),
      ),
    );

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              const SizedBox(
                height: 34,
              ),
              Image.asset(
                "assets/images/app_logo.png",
                height: 100,
                width: 100,
              ),
              const SizedBox(
                height: 16,
              ),
              RichText(
                  text: const TextSpan(
                      text: "Be your own ",
                      style: TextStyle(
                          color: Color(0xff2F2E41),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.2,
                          fontSize: 15),
                      children: [
                    TextSpan(
                      text: "Concierge.",
                      style: TextStyle(
                          color: Color(0xff27AE60),
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    )
                  ])),
              const SizedBox(
                height: 34,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomText(
                      text:
                          'Please type the verification code sent to \n+92 3********42  '),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Center(
                child: Pinput(
                  controller: pinController,
                  focusNode: focusNode,
                  androidSmsAutofillMethod:
                      AndroidSmsAutofillMethod.smsUserConsentApi,
                  listenForMultipleSmsOnAndroid: true,
                  defaultPinTheme: defaultPinTheme,
                  validator: (value) {
                    return value == '2222' ? null : '';
                  },
                  onClipboardFound: (value) {
                    debugPrint('onClipboardFound: $value');
                    pinController.setText(value);
                  },
                  // hapticFeedbackType: HapticFeedbackType.lightImpact,
                  onCompleted: (pin) {
                    debugPrint('onCompleted: $pin');
                  },
                  onChanged: (value) {
                    debugPrint('onChanged: $value');
                  },
                  cursor: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        width: 22,
                        height: 1,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      color: FrontendConfigs.kAuthColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black, width: 0.1),
                    ),
                  ),
                  errorPinTheme: defaultPinTheme.copyBorderWith(
                    border: Border.all(color: FrontendConfigs.kAuthColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 34,
              ),
              RichText(
                  text: TextSpan(
                      text: "Click Here",
                      style: TextStyle(
                          color: FrontendConfigs.kPrimaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          decoration: TextDecoration.underline),
                      children: [
                    TextSpan(
                        text: " to resend code in 50s",
                        style: TextStyle(
                            color: FrontendConfigs.kPrimaryColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            decoration: TextDecoration.none))
                  ])),
              const SizedBox(
                height: 44,
              ),
              AppButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const VerifiedView()));
                  },
                  btnLabel: 'Submit')
            ],
          ),
        ),
      ),
    );
  }
}
