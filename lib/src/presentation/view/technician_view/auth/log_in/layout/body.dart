import 'package:CarRescue/src/providers/firebase_message_provider.dart';
import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/auth_field.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/technician_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../../../utils/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TechnicianLogInBody extends StatefulWidget {
  TechnicianLogInBody({Key? key}) : super(key: key);

  @override
  _TechnicianLogInBodyState createState() => _TechnicianLogInBodyState();
}

class _TechnicianLogInBodyState extends State<TechnicianLogInBody> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = ''; // To store the error message
  final box = GetStorage();
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
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
                    text: 'Quên mật khẩu',
                    fontSize: 16,
                  )
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              AppButton(
                onPressed: () async {
                  final token = await authService.getDeviceToken();
                  final result = await authService.login(

                      _emailController.text.toString(),
                      _passwordController.text.toString(),
                      token ?? '');

                  if (result != null) {
                    // Successfully logged in, navigate to the next screen
                    print(result.role);
                    box.write("role", result.role);
                    box.write("userId", result.userId);
                    box.write("accountId", result.accountId);
                    box.write("accessToken", result.accessToken);
                    print(result.role);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomNavBarTechView(
                          accountId: result.accountId,
                          userId: result.userId,
                          
                        ),
                      ),
                    );

                  } else {
                    // Handle login failure or show an error message
                    setState(() {
                      errorMessage =
                          'Login failed. Please check your credentials.';
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
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: FrontendConfigs.kIconColor,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  CustomText(
                    text: "hoặc tiếp tục với",
                    fontSize: 16,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Divider(
                      color: FrontendConfigs.kIconColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {},
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Image(
                        image: AssetImage("assets/images/google.png"),
                        height: 18.0,
                        width: 36,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 24, right: 8),
                        child: Text(
                          'Đăng nhập với Google',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
