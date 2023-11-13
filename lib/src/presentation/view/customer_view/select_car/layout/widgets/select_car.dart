import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import '../../../../../../configuration/frontend_configs.dart';

class SelectCarWidget extends StatefulWidget {
  SelectCarWidget(
      {Key? key,
      required this.svg,
      required this.name,
      required this.distance,
      required this.amount})
      : super(key: key);
  final String svg;
  final String name;
  final String distance;
  final String amount;

  @override
  State<SelectCarWidget> createState() => _SelectCarWidgetState();
}

class _SelectCarWidgetState extends State<SelectCarWidget> {
  bool isShow = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isShow = !isShow;
        });
      },
      child: Card(
        shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none),
        elevation: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    widget.svg,
                    height: 62,
                    width: 62,
                  ),
                  const SizedBox(
                    width: 11,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: widget.name,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      CustomText(
                        text: widget.distance,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: FrontendConfigs.kIconColor,
                      ),
                    ],
                  )
                ],
              ),
              Column(
                children: [
                  if (isShow)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SizedBox(
                          height: 10,
                          child: Icon(
                            Icons.check_circle,
                            color: FrontendConfigs.kPrimaryColor,
                            size: 16,
                          )),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Container(
                        height: 10,
                      ),
                    ),
                  Container(
                    height: 10,
                  ),
                  SizedBox(
                    height: 20,
                    child: CustomText(
                      text: widget.amount,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
