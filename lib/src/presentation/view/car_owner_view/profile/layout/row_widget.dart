// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';

class SettingWidget extends StatelessWidget {
  SettingWidget(
      {Key? key,
      required this.icon,
      required this.title,
      this.isShow = false,
      this.height = 30,
      this.weight = 30,
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
              ),
              const SizedBox(
                width: 18,
              ),
              Text(name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
            ],
          ),
          isShow
              ? Text(
                  title,
                  style: TextStyle(
                      color: FrontendConfigs.kAuthColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900),
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
