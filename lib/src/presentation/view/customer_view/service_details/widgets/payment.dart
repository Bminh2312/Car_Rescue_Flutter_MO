import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:flutter/material.dart';

class PaymentMethodTile extends StatelessWidget {
  final String method;
  final String icon;
  final bool isSelected;

  const PaymentMethodTile({
    Key? key,
    required this.method,
    required this.icon,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: isSelected
            ? Border.all(color: FrontendConfigs.kActiveColor, width: 2.0)
            : null,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Image.asset(icon),
          SizedBox(width: 10.0),
          Text(
            method,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
