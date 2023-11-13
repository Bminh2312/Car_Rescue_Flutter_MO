import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:flutter/material.dart';

class SlideToConfirmButton extends StatefulWidget {
  final VoidCallback onConfirmed;
  final String title;
  SlideToConfirmButton({required this.onConfirmed, required this.title});

  @override
  _SlideToConfirmButtonState createState() => _SlideToConfirmButtonState();
}

class _SlideToConfirmButtonState extends State<SlideToConfirmButton> {
  double _slideOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * 0.9; // 80% of the screen width

    return Container(
      width: containerWidth,
      child: Stack(
        children: [
          // Base Container
          Container(
            width: containerWidth,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Center(
                child: Text(
              widget.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
          ),

          // Sliding Container
          Positioned(
            left: _slideOffset,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _slideOffset += details.delta.dx;
                  _slideOffset = _slideOffset.clamp(
                      0.0,
                      containerWidth -
                          100); // Assuming the sliding button width is 100
                });
              },
              onPanEnd: (details) {
                if (_slideOffset > containerWidth * 0.7) {
                  widget.onConfirmed();
                }
                setState(() {
                  _slideOffset = 0.0;
                });
              },
              child: Container(
                height: 50,
                width: 80,
                decoration: BoxDecoration(
                  color: FrontendConfigs.kActiveColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Center(
                    child: Icon(Icons.chevron_right, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
