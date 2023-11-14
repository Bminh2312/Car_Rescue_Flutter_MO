import 'package:CarRescue/src/presentation/view/customer_view/select_service/select_service_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/view/customer_view/profile/profile_view.dart';
import '../orders/orders_view.dart';

class BottomNavBarView extends StatefulWidget {
  final int page;

  const BottomNavBarView({Key? key, required this.page}) : super(key: key);

  @override
  _BottomNavBarViewState createState() => _BottomNavBarViewState();
}

class _BottomNavBarViewState extends State<BottomNavBarView> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    const ServiceView(),
    const OrderView(),
    const ProfileView()
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    _currentIndex = widget.page;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Colors.green,
        unselectedItemColor: FrontendConfigs.kIconColor,
        backgroundColor: Colors.white,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 10,
          fontFamily: "Montserrat",
          color: FrontendConfigs.kPrimaryColor,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 10,
          fontFamily: "Montserrat",
          color: FrontendConfigs.kIconColor,
        ),
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        // currentIndex:getIndex,
        items: [
          BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: SvgPicture.asset(
                  height: 18,
                  width: 18,
                  'assets/svg/home_icon.svg',
                  // ignore: deprecated_member_use
                  color: _currentIndex == 0
                      ? Colors.green
                      : FrontendConfigs.kIconColor,
                ),
              ),
              label: "Trang chủ"),
          BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: SvgPicture.asset(
                  height: 18,
                  width: 18,
                  'assets/svg/message.svg',
                  // ignore: deprecated_member_use
                  color: _currentIndex == 1
                      ? Colors.green
                      : FrontendConfigs.kIconColor,
                ),
              ),
              label: "Đơn hàng"),
          BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: SvgPicture.asset(
                  'assets/svg/person_icon.svg',
                  // ignore: deprecated_member_use
                  color: _currentIndex == 2
                      ? Colors.green
                      : FrontendConfigs.kIconColor,
                  height: 18,
                  width: 18,
                ),
              ),
              label: "Cá nhân"),
        ],
      ),
    );
  }
}
