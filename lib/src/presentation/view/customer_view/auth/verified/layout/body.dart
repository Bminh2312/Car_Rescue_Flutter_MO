import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../configuration/frontend_configs.dart';
import '../../../../../elements/custom_text.dart';
class VerifiedBody extends StatelessWidget {
  const VerifiedBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:18.0),
        child: Column(
          mainAxisAlignment:MainAxisAlignment.center,
          children: [
          SvgPicture.asset("assets/svg/verified_done.svg"),
          const SizedBox(height:18,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: "Verified Successfully",
                fontSize: 21,
                fontWeight: FontWeight.w600,
                letterSpacing:1.2,
              ),
            ],
          ),
          RichText(
            textAlign:TextAlign.center,
              text:  TextSpan(
                  text: "Your account has been verified successfully. You\n",
                  style: TextStyle(
                      color: FrontendConfigs.kPrimaryColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    height:1.5
                  ),
                  children:   [
                    TextSpan(
                        text: " can now use our app to book the cabs",
                        style: TextStyle(
                            color: FrontendConfigs.kPrimaryColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            decoration:TextDecoration.none,
                        )),
                    TextSpan(
                        text: " \nHave a great day!",
                        style: TextStyle(
                            color: FrontendConfigs.kPrimaryColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            decoration:TextDecoration.none
                        ))

                  ])),

        ],),
      ),
    );
  }
}
