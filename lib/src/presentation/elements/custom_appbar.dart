import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:flutter/material.dart';

customAppBar(
  BuildContext context, {
  String? text,
  bool showText = false,
}) {
  return AppBar(
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(
        Icons.arrow_back,
        color: Colors.black,
        size: 20,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    title: showText
        ? Text(
            text!,
            style: TextStyle(
                color: FrontendConfigs.kPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          )
        : const SizedBox(),
    backgroundColor: Colors.transparent,
    elevation: 0,
  );
}
