import 'package:CarRescue/src/presentation/view/car_owner_view/auth/log_in/log_in_view.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/edit_profile/edit_profile_view.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:get_storage/get_storage.dart';
import 'row_widget.dart';
import '../../../customer_view/profile/layout/test.dart';

class ProfileBody extends StatefulWidget {
  ProfileBody({Key? key, required this.userId, required this.accountId})
      : super(key: key);
  final String userId;
  final String accountId;

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  final Color redColor = const Color(0xffFF455B);
  bool isFirstSelected = false;

  bool isSecondSelected = false;

  bool isThirdSelected = false;
  int? _area;
  String userName = '';
  String phoneNumber = '';
  String avatar =
      'https://firebasestorage.googleapis.com/v0/b/car-rescue-399511.appspot.com/o/profile_images%2Fdefaultava.jpg?alt=media&token=72b870e8-a42d-418c-af41-9ff4acd41431';
  AuthService authService = AuthService();
  Map<String, dynamic>? userProfileData;
  final box = GetStorage();
  @override
  void initState() {
    super.initState();
    // Call the function to fetch user data when the widget is initialized
    fetchUserProfileData();
  }

  // Function to fetch user profile data
  void fetchUserProfileData() async {
    try {
      final userProfile =
          await authService.fetchRescueCarOwnerProfile(widget.userId);

      if (userProfile != null) {
        print('User Profile: $userProfile');
        // Extract the 'data' map from the response
        final Map<String, dynamic> data = userProfile['data'];
        print(data);
        // Extract 'fullname' and 'phone' values from the 'data' map
        final String fullName = data['fullname'];
        final String phone = data['phone'];
        final String avatarURL = data['avatar'];
        final int area = data['area'];
        // Update the state with the extracted values or 'N/A' if they are null
        setState(() {
          userName = fullName;
          phoneNumber = phone;
          avatar = avatarURL;
          _area = area;
        });
      } else {
        // Handle the case where the userProfile is null
        // Set default values for userName and phoneNumber
      }
    } catch (e) {
      // Handle any exceptions that occur during the API request
      print('Error fetching user profile1: $e');
      // You can set an error message or handle the error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Color.fromARGB(0, 158, 158, 158),
                      radius: 64,
                      backgroundImage: NetworkImage(
                          avatar), // Use 'backgroundImage' to set the image
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    CustomText(
                      text: userName,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    CustomText(
                      text: phoneNumber,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    CustomText(
                      text: "Khu vực ${_area.toString()}",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            SettingWidget(
              icon: "assets/svg/user.svg",
              title: "John_wick",
              name: ' Chỉnh sửa thông tin',
              onTap: () async {
                // Navigate to EditProfileView
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileView(
                      userId: widget.userId,
                      accountId: widget.accountId,
                    ),
                  ),
                ).then((value) => {fetchUserProfileData()});

                // Check if the result indicates a successful update
                if (result == 'Profile updated successfully') {
                  // Fetch updated data here
                  fetchUserProfileData();
                }
              },
            ),
            const SizedBox(
              height: 24,
            ),
            SettingWidget(
              icon: "assets/svg/privacy.svg",
              height: 30,
              weight: 30,
              title: "John_wick",
              name: 'Chính sách riêng tư',
              onTap: () {},
            ),
            const SizedBox(
              height: 24,
            ),
            SettingWidget(
              icon: "assets/svg/help_center.svg",
              title: "",
              name: 'Trung tâm hỗ trợ',
              onTap: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => WebsocketDemo()));
              },
            ),
            const SizedBox(
              height: 24,
            ),
            InkWell(
              onTap: () async {
                // Perform logout actions (e.g., clear session, remove tokens, etc.)
                box.remove("role");
                box.remove("userId");
                box.remove("accountId");
                box.remove("accessToken");
                box.erase();
                // Navigate to the login screen and replace the current screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CarOwnerLogInView(),
                  ),
                );
              },
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/svg/exit.svg",
                    height: 30,
                    width: 30,
                  ),
                  const SizedBox(
                    width: 18,
                  ),
                  Text(
                    "Đăng xuất",
                    style: TextStyle(
                      color: redColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
