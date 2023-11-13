import 'dart:async';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

import '../../../../../../configuration/frontend_configs.dart';
import '../../../../../elements/custom_text.dart';
import '../../../../../elements/round_button.dart';
import '../../../layout/selection_location_widget.dart';

Future<void> pickUpBottomSheetSheet(context) {
  return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      context: context,
      builder: (dialogContext) {
        Timer(const Duration(seconds: 3), () {
          Navigator.pop(dialogContext);
          // goingTOPickingUpSheet(context);
        });
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 3,
                    width: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xffE0E0E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: "Picking up",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Divider(
                color: FrontendConfigs.kIconColor,
              ),
              const SizedBox(
                height: 8,
              ),
              // DriverProfileWidget(onTapped: () {}),
              const SizedBox(
                height: 8,
              ),
              Divider(
                color: FrontendConfigs.kIconColor,
              ),
              const SizedBox(
                height: 8,
              ),
              RideSelectionWidget(
                icon: 'assets/svg/pickup_icon.svg',
                title: 'Pick up Location',
                body: '089 Stark Gateway',
                onPressed: () {},
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: DottedLine(
                  direction: Axis.vertical,
                  lineLength: 30,
                  lineThickness: 1.0,
                  dashLength: 4.0,
                  dashColor: Colors.black,
                  dashRadius: 2.0,
                  dashGapLength: 4.0,
                  dashGapRadius: 0.0,
                ),
              ),
              RideSelectionWidget(
                icon: 'assets/svg/location_icon.svg',
                title: 'Drop off Location',
                body: '92676 Orion Meadows',
                onPressed: () {},
              ),
              const SizedBox(
                height: 8,
              ),
              Divider(
                color: FrontendConfigs.kIconColor,
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundButton(
                    icon: 'assets/svg/cancel_icon.svg',
                    height: 16,
                    widht: 16,
                    color: FrontendConfigs.kAuthColor,
                    svgColor: Colors.white,
                    onPressed: () {},
                  ),
                  const SizedBox(
                    width: 18,
                  ),
                  RoundButton(
                    icon: 'assets/svg/message.svg',
                    color: FrontendConfigs.kPrimaryColor,
                    svgColor: Colors.white,
                    onPressed: () {},
                  ),
                  const SizedBox(
                    width: 18,
                  ),
                  RoundButton(
                    icon: 'assets/svg/telephone_icon.svg',
                    color: FrontendConfigs.kPrimaryColor,
                    svgColor: Colors.white,
                    onPressed: () {},
                  )
                ],
              )
            ],
          ),
        );
      });
}
