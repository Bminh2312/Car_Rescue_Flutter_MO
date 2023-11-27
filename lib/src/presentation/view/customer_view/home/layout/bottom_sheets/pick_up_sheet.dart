import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

import '../../../../../../configuration/frontend_configs.dart';
import '../../../../../elements/app_button.dart';
import '../../../../../elements/custom_text.dart';
import '../../../select_car/select_car_view.dart';
import '../home_selection_widget.dart';

Future<void> piUpLocationBottomSheet(context, String location, String? desLocation) {
  return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize:MainAxisSize.min,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: "Distance",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  CustomText(
                      text: "4.8 km",
                      fontSize: 14,
                      fontWeight: FontWeight.w600)
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Divider(
                color: FrontendConfigs.kIconColor,
              ),
              const SizedBox(
                height: 10,
              ),
              HomeSelectionWidget(
                icon: 'assets/svg/pickup_icon.svg',
                title: 'Pick up Location',
                body: '$location', onPressed: () { Navigator.pop(context); },),
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
              HomeSelectionWidget(
                icon: 'assets/svg/location_icon.svg',
                title: 'Drop off Location',
                body: '$desLocation', onPressed: () { Navigator.pop(context); },),
              const SizedBox(
                height: 34,
              ),
              AppButton(onPressed: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context)=>const SelectCarView()));
              }, btnLabel: "Book"),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        );
      });
}