import 'dart:async';
import 'package:CarRescue/src/presentation/view/select_mode/select_mode_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/view/onboarding/onboarding_view.dart';

class SplashBody extends StatefulWidget {
  const SplashBody({Key? key}) : super(key: key);

  @override
  State<SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<SplashBody> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  void _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('first_launch') ?? true;

    if (isFirstLaunch) {
      // It's the first launch, show the onboarding view
      prefs.setBool(
          'first_launch', false); // Mark that it's no longer the first launch

      Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnBoardingView()),
        ),
      );
    } else {
      // Not the first launch, navigate to your main app screen
      Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SelectModeView()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/logocarescue.png",
            height: 200,
            width: 200,
          ),
          const SizedBox(
            height: 16,
          ),
          // RichText(
          //     text: const TextSpan(
          //         text: "Be your own ",
          //         style: TextStyle(
          //             color:Color(0xff2F2E41),
          //             fontWeight: FontWeight.w400,
          //             letterSpacing:2,
          //             fontSize: 16),children: [
          //         TextSpan(
          //         text: "Concierge.",
          //         style: TextStyle(
          //             color: Colors.red,
          //             fontWeight: FontWeight.w600,
          //             letterSpacing:2,
          //             fontSize: 16),)
          //     ]))
        ],
      ),
    );
  }
}
