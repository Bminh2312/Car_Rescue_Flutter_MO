import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/driver_details/layout/widgets/details_widget.dart';

import '../../../../../configuration/frontend_configs.dart';

class DriverDetailsBody extends StatelessWidget {
  const DriverDetailsBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            child: Image.asset('assets/images/profile.png'),
          ),
          const SizedBox(
            height: 12,
          ),
          CustomText(
            text: "Daniel Austin",
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(
            height: 8,
          ),
          CustomText(
            text: "+1 343-234-4544",
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(
            height: 12,
          ),
          const DriverDetailsWidget(),
          const SizedBox(
            height: 24,
          ),
          Container(
            height: 171,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Member Since',
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: FrontendConfigs.kIconColor,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      CustomText(
                        text: 'Car Model',
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: FrontendConfigs.kIconColor,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      CustomText(
                        text: 'Plate Number',
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: FrontendConfigs.kIconColor,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomText(
                        text: 'April 09, 2022',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      CustomText(
                        text: 'Mercedes Benz E-Class',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      CustomText(
                        text: 'HAX - 234',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
