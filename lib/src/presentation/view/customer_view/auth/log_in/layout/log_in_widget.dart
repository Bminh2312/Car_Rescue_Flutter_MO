import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:flutter/material.dart';

class LogInWidget extends StatelessWidget {
  LogInWidget(
      {Key? key,
      required this.logo,
      required this.onPressed,
      required this.isLoading})
      : super(key: key);
  final String logo;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!isLoading) {
          onPressed(); // Only call onPressed when not loading
        }
      },
      child: Container(
        height: 61,
        width: 98,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xff9B9B9B), width: 0.2),
        ),
        child: Center(
          child: isLoading
              ? LoadingState()
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    logo,
                  ),
                ),
        ),
      ),
    );
  }
}
