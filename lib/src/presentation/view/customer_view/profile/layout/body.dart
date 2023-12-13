import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/presentation/view/customer_view/profile/edit_profile/edit_profile_view.dart';
import 'package:CarRescue/src/presentation/view/select_city/select_city_view.dart';
import 'package:CarRescue/src/providers/customer_profile_provider.dart';

import 'package:CarRescue/src/providers/gmail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:get_storage/get_storage.dart';

import 'row_widget.dart';
import 'test.dart';

class ProfileBody extends StatefulWidget {
  ProfileBody({Key? key}) : super(key: key);

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  final Color redColor = const Color(0xffFF455B);

  GmailProvider gmailProvider = GmailProvider();

  bool isFirstSelected = false;

  bool isSecondSelected = false;

  bool isThirdSelected = false;

  Customer customer = Customer.fromJson(GetStorage().read('customer') ?? {});

  String avt =
      'https://firebasestorage.googleapis.com/v0/b/car-rescue-399511.appspot.com/o/profile_images%2Fdefaultava.jpg?alt=media&token=72b870e8-a42d-418c-af41-9ff4acd41431';

  String fullname = '';

  String phone = '';

  void _handleSignOut() async {
    gmailProvider.handleSignOut();
    if (customer.id != '') {
      GetStorage().remove("customer");
      GetStorage().remove("role");
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => SelectCityView(),
      ),
      (route) => false, // Loại bỏ tất cả các màn hình khỏi ngăn xếp
    );
  }

  void _fetchCustomer(String id) async {
    try {
      final fetchData = await CustomerProfileProvider().getCustomerById(id);
      setState(() {
        avt = fetchData.avatar;
        fullname = fetchData.fullname;
        phone = fetchData.phone;
      });
    } catch (e) {
      print("Lỗi: $e}");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _fetchCustomer(customer.id);
    print("Id: ${customer.id}");
    print("AccId: ${customer.accountId}");
    // _handleUpdateProfile();
    super.initState();
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
                          avt), // Use 'backgroundImage' to set the image
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    CustomText(
                      text: fullname,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    CustomText(
                      text: phone,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    )
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
              name: 'Chỉnh sửa thông tin',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => EditProfileViewCustomer(
                            id: customer.id,
                            accountId: customer.accountId,
                          )),
                );
                // Navigator.pushNamed(context, "/editProfile");
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WebsocketDemo()));
              },
            ),
            const SizedBox(
              height: 24,
            ),
            InkWell(
              onTap: () {
                // Perform logout actions (e.g., clear session, remove tokens, etc.)

                // Navigate to the login screen and replace the current screen
                _handleSignOut();
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
