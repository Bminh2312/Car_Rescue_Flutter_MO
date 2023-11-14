import 'package:CarRescue/src/models/customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../configuration/frontend_configs.dart';
import '../../../elements/custom_text.dart';
import 'layout/body.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: CustomText(
          text: 'Cá nhân',
          fontSize: 20,
          color: FrontendConfigs.kPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: ProfileBody(),
    );
  }
}
