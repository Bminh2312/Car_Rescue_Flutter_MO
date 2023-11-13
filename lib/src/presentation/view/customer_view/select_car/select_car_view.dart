import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/searching_driver/searching_driver_view.dart';
import '../../../../configuration/frontend_configs.dart';
import 'layout/body.dart';

class SelectCarView extends StatelessWidget {
  const SelectCarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, text: "Select your Car", showText: true),
      body: const SelectCarBody(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none),
              elevation: 0.5,
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 12.0, left: 12, top: 30, bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset("assets/svg/location_icon.svg"),
                        const SizedBox(
                          width: 7,
                        ),
                        CustomText(text: '4.8 km')
                      ],
                    ),
                    Row(
                      children: [
                        // ignore: deprecated_member_use
                        SvgPicture.asset(
                          "assets/svg/watch_icon.svg",
                          color: FrontendConfigs.kIconColor,
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                        CustomText(text: '4.8 km')
                      ],
                    ),
                    Row(
                      children: [
                        SvgPicture.asset("assets/svg/amount_icon.svg"),
                        const SizedBox(
                          width: 7,
                        ),
                        CustomText(text: '4.8 km')
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            AppButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SearchingDriverView()));
                },
                btnLabel: 'Continue'),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
