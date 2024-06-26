import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import '../../../../../../configuration/frontend_configs.dart';

class SelectCarWidget extends StatefulWidget {
  SelectCarWidget({
    Key? key,
    required this.img,
    required this.name,
    required this.onSelect,
    required this.licensePlate,
    required this.isSelected, // Added isSelected parameter
  }) : super(key: key);

  final String img;
  final String name;
  final String licensePlate;
  final ValueChanged<bool> onSelect; // Callback to be triggered when the widget is tapped
  final bool isSelected; // Parameter to determine if the car is selected

  @override
  State<SelectCarWidget> createState() => _SelectCarWidgetState();
}

class _SelectCarWidgetState extends State<SelectCarWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onSelect(!widget.isSelected); // Toggle the selection state
      },
      child: Card(
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        elevation: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.network(
                    widget.img,
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
                        text: widget.licensePlate,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: FrontendConfigs.kAuthColor,
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  if (widget.isSelected)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SizedBox(
                        height: 10,
                        child: Icon(
                          Icons.check_circle,
                          color: FrontendConfigs.kPrimaryColor,
                          size: 16,
                        ),
                      ),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
