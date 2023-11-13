import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';

import 'widgets/select_car.dart';

class SelectCarBody extends StatelessWidget {
  const SelectCarBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              const SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: 'Select a vehicle category you want to ride',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
              const SizedBox(
                height: 14,
              ),
              SelectCarWidget(
                  svg: 'assets/images/wagon_car.png',
                  name: 'Mercedes Vito',
                  distance: "2 Near by",
                  amount: '\$10.40'),
              SelectCarWidget(
                  svg: 'assets/images/mercedies_car.png',
                  name: 'Audi A7',
                  distance: "2 Near by",
                  amount: '\$14.40'),
              SelectCarWidget(
                  svg: 'assets/images/mercedies_car.png',
                  name: 'Mercedes Benz',
                  distance: "2 Near by",
                  amount: '\$15.40')
            ],
          ),
        ),
      ),
    );
  }
}
