import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';

class CityButton extends StatefulWidget {
  CityButton({
    Key? key,
    required this.btnLabel,
    this.isDisabled = false, // Add isDisabled property with a default value
  }) : super(key: key);

  final String btnLabel;
  bool isChecked = false;
  bool isDisabled; // Boolean to control the button's state

  @override
  State<CityButton> createState() => _CityButtonState();
}

class _CityButtonState extends State<CityButton> {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.isDisabled ? 0.5 : 1.0,
      child: InkWell(
        onTap: widget.isDisabled // Check the isDisabled property
            ? null // Button is disabled when isDisabled is true
            : () {
                setState(() {
                  widget.isChecked = !widget.isChecked;
                });
              },
        child: Container(
          height: 51,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: FrontendConfigs.kPrimaryColor, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 30,
                ),
                Expanded(
                  child: Center(
                    child: CustomText(
                      text: widget.btnLabel,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.isDisabled)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Icon(
                      Icons.lock, // Lock icon when disabled
                      color: Colors.black, // Adjust the color as needed
                      size: 24, // Adjust the size as needed
                    ),
                  )
                else if (widget.isChecked!)
                  const Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: SizedBox(
                        width: 10,
                        child: Icon(
                          Icons.check_circle,
                          color: Color(0xFF2DBB54),
                          size: 15,
                        )),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Container(
                      width: 10,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
