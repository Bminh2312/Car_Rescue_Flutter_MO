import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/select_city/layout/custom_button.dart';

class SelectCityBody extends StatelessWidget {
  const SelectCityBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 60,
              ),
              Center(
                child: Image.asset(
                  "assets/images/logocarescue.png",
                  height: 200,
                  width: 500,
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              const SizedBox(
                height: 44,
              ),
              CustomText(
                text: "Chọn thành phố bạn đang sống",
                fontSize: 21,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
              const SizedBox(
                height: 12,
              ),

              CityButton(btnLabel: "TP Hồ Chí Minh"),
              const SizedBox(
                height: 18,
              ),
              CityButton(
                btnLabel: "Hà Nội (Sớm ra mắt)",
                isDisabled: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
