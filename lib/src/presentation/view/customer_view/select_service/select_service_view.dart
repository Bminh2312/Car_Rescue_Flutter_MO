import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/select_service/layout/body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ServiceView extends StatelessWidget {
  const ServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ServiceBody(),
    );
  }
}
