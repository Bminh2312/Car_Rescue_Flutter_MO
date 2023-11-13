import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/notify/layout/body.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NotifyView extends StatelessWidget {
  const NotifyView({super.key});

  @override
  Widget build(BuildContext context) {
    final  message = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
        appBar:AppBar(
          backgroundColor:Colors.transparent,
          elevation:0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 18.0,top:11,bottom:11,right:4),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color:  Color(0xFF2DBB54),),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset('assets/svg/car_icon.svg'),
              ),
            ),
          ),
          title:CustomText(text: 'My Notify',fontSize:16,color:FrontendConfigs.kPrimaryColor,),
          centerTitle:true,
        ),
      body:NotifyBody(message: message!),
    );
  }
}