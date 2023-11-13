import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';

class CancelRideBody extends StatefulWidget {
  const CancelRideBody({Key? key}) : super(key: key);

  @override
  State<CancelRideBody> createState() => _CancelRideBodyState();
}

class _CancelRideBodyState extends State<CancelRideBody> {
  bool waiting = false;
  bool contact = false;
  bool destination = false;
  bool pickup = false;
  bool wrongAddress = false;
  bool reasonable = false;
  final TextEditingController _searchController = TextEditingController();

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
                height: 12,
              ),
              CustomText(
                text: 'Please select the reason of cancellation',
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                      checkColor: Colors.white,
                      activeColor: Color(0xFF2DBB54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      value: waiting,
                      onChanged: (bool? value) {
                        setState(() {
                          waiting = value!;
                        });
                      }),
                  CustomText(text: 'Waiting for long time'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                      checkColor: Colors.white,
                      activeColor: Color(0xFF2DBB54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      value: contact,
                      onChanged: (bool? value) {
                        setState(() {
                          contact = value!;
                        });
                      }),
                  CustomText(text: 'Unable to contact driver'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                      checkColor: Colors.white,
                      activeColor: Color(0xFF2DBB54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      value: destination,
                      onChanged: (bool? value) {
                        setState(() {
                          destination = value!;
                        });
                      }),
                  CustomText(text: 'Driver denied to go to destination'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                      checkColor: Colors.white,
                      activeColor: Color(0xFF2DBB54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      value: pickup,
                      onChanged: (bool? value) {
                        setState(() {
                          pickup = value!;
                        });
                      }),
                  CustomText(text: 'Driver denied to come to pickup'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                      checkColor: Colors.white,
                      activeColor: Color(0xFF2DBB54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      value: wrongAddress,
                      onChanged: (bool? value) {
                        setState(() {
                          wrongAddress = value!;
                        });
                      }),
                  CustomText(text: 'Wrong address shown'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                      checkColor: Colors.white,
                      activeColor: Color(0xFF2DBB54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      value: contact,
                      onChanged: (bool? value) {
                        setState(() {
                          contact = value!;
                        });
                      }),
                  CustomText(text: 'The price is not reasonable'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                      checkColor: Colors.white,
                      activeColor: Color(0xFF2DBB54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      value: reasonable,
                      onChanged: (bool? value) {
                        setState(() {
                          reasonable = value!;
                        });
                      }),
                  CustomText(text: 'Other'),
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              SizedBox(
                height: 49,
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Other reason',
                    hintStyle: TextStyle(
                        color: FrontendConfigs.kIconColor,
                        fontSize: 14,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w400),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none),
                    fillColor: FrontendConfigs.kAuthColor,
                    filled: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
