import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../configuration/frontend_configs.dart';

class RoundButton extends StatelessWidget {
  VoidCallback onPressed;
  final String icon;
  final Color ?color;
  final Color ?svgColor;
  double height;
  double widht;

  RoundButton({
    required this.onPressed,
    required this.icon,
    this.height=24,
    this.widht=24,
     this.color,
    this.svgColor=Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary:const Color(0xFF2DBB54),
          fixedSize: const Size(40, 62),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          )),
      onPressed: onPressed,
      child: Center(child: SvgPicture.asset(icon, color: svgColor,height:height,width:widht,)),
    );
  }
}
