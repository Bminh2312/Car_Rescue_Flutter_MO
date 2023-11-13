import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import '../../../../../elements/round_button.dart';

class DriverDetailsWidget extends StatelessWidget {
  const DriverDetailsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 171,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                RoundButton(
                  onPressed: () {},
                  icon: 'assets/svg/star_icon.svg',
                  svgColor: Colors.white,
                ),
                const SizedBox(
                  height: 12,
                ),
                CustomText(
                  text: '4.9',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                CustomText(
                  text: 'Rating',
                  color: FrontendConfigs.kIconColor,
                ),
              ],
            ),
            Column(
              children: [
                RoundButton(
                  onPressed: () {},
                  icon: 'assets/svg/car_icon.svg',
                  svgColor: Colors.white,
                ),
                const SizedBox(
                  height: 12,
                ),
                CustomText(
                  text: '210',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                CustomText(
                  text: 'Trips',
                  color: FrontendConfigs.kIconColor,
                ),
              ],
            ),
            Column(
              children: [
                RoundButton(
                  onPressed: () {},
                  icon: 'assets/svg/watch_icon.svg',
                  svgColor: Colors.white,
                ),
                const SizedBox(
                  height: 12,
                ),
                CustomText(
                  text: '3',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                CustomText(
                  text: 'Months',
                  color: FrontendConfigs.kIconColor,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
