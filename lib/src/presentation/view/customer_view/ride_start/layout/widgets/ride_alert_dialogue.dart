import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/ride_start/layout/widgets/ride_bottom_sheet.dart';
import '../../../../../../configuration/frontend_configs.dart';

Future<void> rideArrivedDialog(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
          insetPadding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset("assets/svg/dialogue_cover.svg"),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Arrived!",
                    style: FrontendConfigs.kHeadingStyle,
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              CustomText(
                  text:
                      "You have arrived  at your destination,\n see you on the next trip :) "),
              const SizedBox(
                height: 18,
              ),
              AppButton(
                  onPressed: () {
                    showRatingSheet(context);
                  },
                  btnLabel: 'Ok')
            ],
          ));
    },
  );
}
