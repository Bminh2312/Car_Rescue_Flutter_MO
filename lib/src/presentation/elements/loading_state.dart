import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Light grey background for the container
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Only take up the space that's needed
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  FrontendConfigs.kActiveColor), // Blue colored spinner
            ),
            SizedBox(height: 20),
            Text(
              "Đang tải...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700], // Dark grey text for contrast
              ),
            ),
          ],
        ),
      ),
    );
  }
}
