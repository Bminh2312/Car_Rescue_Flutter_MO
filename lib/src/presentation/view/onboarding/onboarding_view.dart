import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/view/onboarding/layout/on_boarding_widget.dart';
import 'package:CarRescue/src/presentation/view/select_city/select_city_view.dart';

import '../../elements/custom_text.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({Key? key}) : super(key: key);

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  final List<SliderPage> _pageList = [
    SliderPage(
      svg: 'assets/svg/onboarding_one.svg',
      body: 'Chúng tôi cung cấp một dịch vụ ',
      title: 'Đặt đơn nhanh chóng',
      subBody: ' với giá cả phải chăng và xử lí nhanh chóng. ',
    ),
    SliderPage(
      svg: 'assets/svg/onboarding_two.svg',
      body: 'Những kĩ thuật viên đã được huấn luyện  ',
      title: 'Kĩ thuật viên chuyên nghiệp',
      subBody: ' chuyên nghiệp để xử lí các tình huống ',
    ),
    SliderPage(
      svg: 'assets/svg/onboarding_three.svg',

      body: 'Hãy bắt đầu sử dụng dịch vụ của chúng tôi',
      title: 'Bắt đầu thôi',
      subBody: '',
    )
  ];
  PageController controller = PageController();
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: pageIndex != 0
            ? IconButton(
                onPressed: () {
                  if (pageIndex == 2) {
                    controller.jumpToPage(1);
                  } else if (pageIndex == 1) {
                    controller.jumpToPage(0);
                  }
                  setState(() {});
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ))
            : null,
        actions: [
          if (pageIndex == 0)
            TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SelectCityView()),
                  );
                },
                child: CustomText(
                  text: "Skip",
                  color: FrontendConfigs.kPrimaryColor,
                  fontSize: 16,
                )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Stack(
          children: [
            Positioned.fill(
              bottom: 100,
              child: PageView.builder(
                controller: controller,
                physics: const ScrollPhysics(),
                onPageChanged: (val) {
                  pageIndex = val;
                  setState(() {});
                },
                itemCount: _pageList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, i) {
                  return _pageList[i];
                },
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  // height: 60,
                  child: DotsIndicator(
                    dotsCount: 3,
                    position: int.parse(pageIndex.toString()),
                    decorator: DotsDecorator(
                      activeColor: const Color(0xFFC68642),
                      color: FrontendConfigs.kIconColor,
                      size: const Size.square(9.0),
                      activeSize: const Size(27.0, 8.0),
                      activeShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                AppButton(
                  onPressed: () {
                    if (pageIndex == 0) {
                      controller.jumpToPage(1);
                    } else if (pageIndex == 1) {
                      controller.jumpToPage(2);
                    } else if (pageIndex == 2) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SelectCityView()));
                    }
                    setState(() {});
                  },
                  btnLabel: pageIndex <= 1 ? 'Next' : 'Skip',
                ),
                const SizedBox(
                  height: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
