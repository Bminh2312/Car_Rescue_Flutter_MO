import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';

import '../../../../configuration/frontend_configs.dart';

class ProfileWidget extends StatelessWidget {
  ProfileWidget({Key? key, required this.onTapped}) : super(key: key);
  VoidCallback onTapped;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapped,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 26,
                  child: Image.asset(
                    "assets/images/profile.png",
                    fit: BoxFit.fill,
                  )),
              const SizedBox(
                width: 11,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "Daniel Austin",
                    color: const Color(0xff3F3D56),
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  CustomText(
                    text: "Mercedes Benz E-Class",
                    color: FrontendConfigs.kIconColor,
                  ),
                ],
              )
            ],
          ),
          Row(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      SvgPicture.asset("assets/svg/star_icon.svg"),
                      const SizedBox(
                        width: 3,
                      ),
                      CustomText(text: '4.9')
                    ],
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  CustomText(text: 'HAX-234')
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
