import 'package:CarRescue/src/presentation/view/customer_view/select_service/widget/animated_indicator.dart';
import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';

class SliderBanner extends StatefulWidget {
  final List<String> advertisements;

  SliderBanner({required this.advertisements});

  @override
  _SliderBannerState createState() => _SliderBannerState();
}

class _SliderBannerState extends State<SliderBanner> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          width: 400,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.advertisements.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: FrontendConfigs.kActiveColor,
                ),
                margin: EdgeInsets.symmetric(horizontal: 3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.advertisements[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 7),
        AnimatedIndicator(
          pageController: _pageController,
          itemCount: widget.advertisements.length,
          activeColor: FrontendConfigs.kPrimaryColor,
          inactiveColor: Colors.grey,
        ),
        SizedBox(height: 7),
      ],
    );
  }
}
