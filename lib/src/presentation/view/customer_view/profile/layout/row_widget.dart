import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';

class SettingWidget extends StatelessWidget {
  SettingWidget(
      {Key? key,
      required this.icon,
      required this.title,
      this.isShow = false,
      this.height = 20,
      this.weight = 20,
      required this.onTap,
      required this.name})
      : super(key: key);
  final String icon;
  final String title;
  final String name;
  bool isShow;
  double height;
  double weight;
  VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                icon,
                height: height,
                width: weight,
                color: FrontendConfigs.kPrimaryColor,
              ),
              const SizedBox(
                width: 18,
              ),
              Text(name,
                  style: TextStyle(
                      color: FrontendConfigs.kPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400))
            ],
          ),
          isShow
              ? Text(
                  title,
                  style: TextStyle(
                      color: FrontendConfigs.kAuthColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                )
              : const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                )
        ],
      ),
    );
  }
}
