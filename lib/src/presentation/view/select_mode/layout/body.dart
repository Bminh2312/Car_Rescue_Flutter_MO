
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/auth/log_in/layout/body.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/auth/log_in/log_in_view.dart';
import 'package:CarRescue/src/presentation/view/technician_view/auth/log_in/log_in_view.dart';

import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';

import 'package:CarRescue/src/presentation/view/customer_view/auth/log_in/log_in_view.dart';

class SelectModeBody extends StatelessWidget {
  const SelectModeBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    "assets/images/towtruck.png",
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.7),
                    BlendMode.srcOver,
                  )),
            ),

            child: Container(
              // color: Colors.black.withOpacity(0.30),
              decoration: const BoxDecoration(),
            )),
        // Positioned.fill(
        //   child: ,
        // ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(
                child: Image.asset(
                  "assets/images/logo-no-background.png",
                  height: 200,
                  width: 300,
                ),
              ),
              const SizedBox(
                height: 9,
              ),
              RichText(
                  text: TextSpan(
                      text: "Chào mừng đến với",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                          fontSize: 16),
                      children: [
                    TextSpan(
                      text: " Car Rescue Management.",
                      style: TextStyle(
                          color: Color(0xffffdc00),
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    )
                  ])),
              const SizedBox(
                height: 18,
              ),
              CustomText(
                text:
                    "Your automotive guardian. Proactive alerts, a vast support network, and peace of mind on the road. Drive confidently with us.",
                color: Colors.white,
              ),
              const SizedBox(
                height: 15,
              ),
              AppButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PassengerLogInView()));
                },
                btnLabel: "Tôi là khách hàng",
              ),
              const SizedBox(
                height: 18,
              ),
              AppButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TechnicianLogInView()));
                },
                btnLabel: "Tôi là kĩ thuật viên",
              ),
              const SizedBox(
                height: 18,
              ),
              AppButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CarOwnerLogInView()));
                },

                btnLabel: "Tôi là chủ xe cứu hộ",
              )
            ],
          ),
        )
      ],
    );
  }
}
