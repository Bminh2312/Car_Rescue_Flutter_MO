import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/orders/orders_view.dart';

class ProfileCardWidget extends StatelessWidget {
  ProfileCardWidget(
      {Key? key,
      required this.profileImage,
      required this.name,
      required this.details,
      required this.time,
      required this.onPressed,
      this.isShow = false})
      : super(key: key);
  final String profileImage;
  final String name;
  final String details;
  final String time;
  bool isShow;
  VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 25,
                  child: Image.asset(
                    profileImage,
                    fit: BoxFit.fill,
                  )),
              const SizedBox(
                width: 11,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: name,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  CustomText(
                    text: details,
                    fontSize: 12,
                  ),
                ],
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              isShow
                  ? Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.green),
                      child: Center(
                          child: CustomText(
                        text: '4',
                        color: Colors.white,
                        fontSize: 10,
                      )),
                    )
                  : const SizedBox(),
              const SizedBox(
                height: 5,
              ),
              CustomText(
                text: time,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              )
            ],
          )
        ],
      ),
    );
  }
}
