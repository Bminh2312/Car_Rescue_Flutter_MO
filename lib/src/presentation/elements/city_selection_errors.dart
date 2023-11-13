import 'package:flutter/material.dart';
import 'dart:ui';

class CitySelectionErrorDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Blurred background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color:
                  Colors.black.withOpacity(0.5), // Adjust the opacity as needed
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: 5, sigmaY: 5), // Adjust the blur values as needed
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Dialog content
          AlertDialog(
            title: Text("Error"),
            content: Text("Please select a city before proceeding."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("OK"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
