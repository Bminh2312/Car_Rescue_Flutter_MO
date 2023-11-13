import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:flutter/material.dart';

class QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  QuickAccessButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 45, // Adjust the container width as needed
          height: 45, // Adjust the container height as needed
          decoration: BoxDecoration(
            // Background color
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          child: IconButton(
            icon: Icon(icon,
                color: FrontendConfigs.kPrimaryColor,
                size: 32), // Icon with white color
            onPressed: onPressed,
          ),
        ),
        SizedBox(
          height: 3,
        ),
        Text(
          label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: FrontendConfigs.kAuthColor), // Adjust the label size
        ),
      ],
    );
  }
}
