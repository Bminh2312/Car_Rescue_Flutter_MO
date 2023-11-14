import 'package:CarRescue/src/presentation/view/technician_view/booking_list/booking_view.dart';
import 'package:CarRescue/src/presentation/view/technician_view/home/home_view.dart';
import 'package:CarRescue/src/presentation/view/technician_view/notification/notification_view.dart';
import 'package:CarRescue/src/presentation/view/technician_view/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';

class BottomNavBarView extends StatefulWidget {
  const BottomNavBarView(
      {Key? key,
      required this.userId,
      required this.accountId,
      })
      : super(key: key);
  final String userId;
  final String accountId;
  
  @override
  _BottomNavBarViewState createState() => _BottomNavBarViewState();
}

class _BottomNavBarViewState extends State<BottomNavBarView> {
  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _buildCurrentScreen(), // Updated to use a function to build the current screen
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: FrontendConfigs.kActiveColor,
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
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: SvgPicture.asset(
                'assets/svg/home_icon.svg',
                height: 18,
                width: 18,
                color: _currentIndex == 0
                    ? FrontendConfigs.kActiveColor
                    : FrontendConfigs.kIconColor,
              ),
            ),
            label: "Trang chủ",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: SvgPicture.asset(
                'assets/svg/person_icon.svg',
                height: 18,
                width: 18,
                color: _currentIndex == 3
                    ? FrontendConfigs.kActiveColor
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
  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return TechnicianHomeView(
         
          userId: widget.userId,
          accountId: widget.accountId,
        );
      case 1:
        return ProfileView(
          userId: widget.userId,
          accountId: widget.accountId,
        );

      default:
        return TechnicianHomeView(
          
          userId: widget.userId,
          accountId: widget.accountId,
        );
    }
  }
}
