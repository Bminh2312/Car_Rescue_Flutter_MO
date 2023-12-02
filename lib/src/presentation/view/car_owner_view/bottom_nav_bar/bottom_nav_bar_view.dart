import 'package:CarRescue/src/presentation/view/car_owner_view/homepage/homepage_view.dart';

import 'package:CarRescue/src/presentation/view/car_owner_view/wallet/wallet_view.dart';

import 'package:CarRescue/src/presentation/view/car_owner_view/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';

class BottomNavBarCarView extends StatefulWidget {
  const BottomNavBarCarView({
    Key? key,
    required this.userId,
    required this.accountId,
    this.initialIndex = 0,
  }) : super(key: key);
  final String userId;
  final String accountId;
  final int initialIndex;
  @override
  _BottomNavBarCarViewState createState() => _BottomNavBarCarViewState();
}

class _BottomNavBarCarViewState extends State<BottomNavBarCarView> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // set the initial index here
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration:
            const Duration(milliseconds: 300), // Adjust the duration as needed
        curve: Curves.easeInOut, // Adjust the curve as needed
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        // Disable swipe gesture
        children: [
          CarOwnerHomeView(
            userId: widget.userId,
            accountId: widget.accountId,
          ),
          WalletView(userId: widget.userId),
          ProfileView(userId: widget.userId, accountId: widget.accountId),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: FrontendConfigs.kActiveColor,
        unselectedItemColor: FrontendConfigs.kIconColor,
        backgroundColor: Colors.white,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          fontFamily: "Montserrat",
          color: FrontendConfigs.kAuthColor,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 10,
          fontFamily: "Montserrat",
          color: FrontendConfigs.kAuthColor,
        ),
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: SvgPicture.asset(
                'assets/svg/home_icon.svg',
                height: 18,
                width: 18,
                color: _currentIndex == 0
                    ? FrontendConfigs.kAuthColor
                    : FrontendConfigs.kIconColor,
              ),
            ),
            label: "Trang chủ",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: SvgPicture.asset(
                'assets/svg/wallet_icon.svg',
                height: 18,
                width: 18,
                color: _currentIndex == 1
                    ? FrontendConfigs.kAuthColor
                    : FrontendConfigs.kIconColor,
              ),
            ),
            label: "Ví của tôi",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: SvgPicture.asset(
                'assets/svg/person_icon.svg',
                height: 18,
                width: 18,
                color: _currentIndex == 2
                    ? FrontendConfigs.kAuthColor
                    : FrontendConfigs.kIconColor,
              ),
            ),
            label: "Cá nhân",
          ),
        ],
      ),
    );
  }

  // Function to determine which screen to show based on the selected index
}
