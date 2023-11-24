import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';

class RideSelectionWidget extends StatelessWidget {
  RideSelectionWidget(
      {Key? key,
      required this.icon,
      required this.title,
      required this.body,
      required this.onPressed})
      : super(key: key);
  final String icon;
  final String title;
  final String body;
  VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: FrontendConfigs.kIconColor.withOpacity(0.6)),
              child: Center(
                child: Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: const Color(0xff252525)),
                  child: Center(
                    child: SvgPicture.asset(
                      icon,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 11,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  child: CustomText(
                    text: title,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Container(
                  width: 220,
                  child: CustomText(
                    text: body,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            )
          ],
        ),
      ],
    );
  }
}
