import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/auth/log_in/layout/body.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/auth/log_in/log_in_view.dart';
import 'package:CarRescue/src/presentation/view/technician_view/auth/log_in/log_in_view.dart';

import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';

import 'package:CarRescue/src/presentation/view/customer_view/auth/log_in/log_in_view.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectModeBody extends StatefulWidget {
  const SelectModeBody({Key? key}) : super(key: key);

  @override
  State<SelectModeBody> createState() => _SelectModeBodyState();
}

class _SelectModeBodyState extends State<SelectModeBody> {
  void launchDialPad(String phoneNumber) async {
    String uri = 'tel:$phoneNumber';

    try {
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      print('Error launching dial pad: $e');
      throw 'Could not launch $uri';
    }
  }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
              ),
              Container(
                 width: MediaQuery.of(context).size.width * 0.3,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: FrontendConfigs.kActiveColor),
                  onPressed: () => launchDialPad("0363235421"),
                  child: Container(
                    child: Row(
                      children: [
                        CustomText(
                          text: 'Hotline',
                          fontSize: 20,
                          color: Colors.white,
                        ),
                        Icon(Icons.phone_android),
                      ],
                    ),
                  ),
                ),
              ),
              Spacer(),
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
                    "Người cứu hộ ô tô của bạn. Cứu trợ kịp thời, mạng lưới hỗ trợ rộng lớn và là sự an tâm khi gặp sự cố.",
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
