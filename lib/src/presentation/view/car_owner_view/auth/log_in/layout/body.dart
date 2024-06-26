import 'package:CarRescue/src/providers/firebase_message_provider.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/auth_field.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:get_storage/get_storage.dart';

class CarOwnerLogInBody extends StatefulWidget {
  CarOwnerLogInBody({
    Key? key,
  }) : super(key: key);

  @override
  State<CarOwnerLogInBody> createState() => _CarOwnerLogInBodyState();
}

class _CarOwnerLogInBodyState extends State<CarOwnerLogInBody> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final box = GetStorage();
  String? deviceToken;
  String errorMessage = '';
  void initState() {
    super.initState();
    FireBaseMessageProvider().getDeviceToken().then((token) {
      setState(() {
        deviceToken = token;
        print(deviceToken);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Đăng nhập \ntài khoản",
                style: FrontendConfigs.kHeadingStyle,
              ),
              const SizedBox(
                height: 30,
              ),
              CustomTextField(
                isSecure: false,
                controller: _emailController,
                icon: "assets/svg/email_icon.svg",
                text: 'Email',
                onTap: () {},
                keyBoardType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 18,
              ),
              CustomTextField(
                controller: _passwordController,
                icon: "assets/svg/lock_icon.svg",
                text: 'Mật khẩu',
                onTap: () {},
                keyBoardType: TextInputType.text,
                isPassword: true,
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomText(
                    text: 'Quên mật khẩu?',
                    fontSize: 16,
                    color: FrontendConfigs.kAuthColor,
                  )
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              AppButton(
                onPressed: () async {
                  final result = await AuthService().loginCarOwner(
                      _emailController.text.toString(),
                      _passwordController.text.toString(),
                      deviceToken ?? '');

                  if (result != null) {
                    box.write("role", result.role);
                    box.write("userId", result.userId);
                    box.write("accountId", result.accountId);
                    box.write('accessToken', result.accessToken);
                    box.write('deviceToken', result.deviceToken);
                    print("User id: " + result.accountId);
                    print("User id: " + result.userId);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomNavBarCarView(
                          accountId: result.accountId,
                          userId: result.userId,
                        ),
                      ),
                    );
                  } else {
                    // Handle login failure or show an error message
                    setState(() {
                      errorMessage =
                          'Đăng nhập thất bại. Tài khoản hoặc mật khẩu không đúng.';
                    });
                  }
                },
                btnLabel: "Đăng nhập",
              ),
              const SizedBox(
                height: 8, // Adjust the height as needed
              ),
              // Display the error message below the button
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              const SizedBox(
                height: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
