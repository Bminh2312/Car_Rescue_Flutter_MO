import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:flutter/material.dart';

class AnimatedIndicator extends AnimatedWidget {
  AnimatedIndicator({
    Key? key,
    required this.pageController,
    required this.itemCount,
    this.activeColor = Colors.brown,
    this.inactiveColor = Colors.grey,
  }) : super(key: key, listenable: pageController);

  final PageController pageController;
  final int itemCount;
  final Color activeColor;
  final Color inactiveColor;

  Widget _buildIndicator(int index, int pageCount, double dotSize) {
    return Container(
      height: dotSize,
      width: dotSize + (pageCount - 1 - index).abs() * dotSize,
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color:
            pageController.page?.round() == index ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(dotSize / 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        itemCount,
        (index) => _buildIndicator(index, itemCount, 6.0),
      ),
    );
  }
}
