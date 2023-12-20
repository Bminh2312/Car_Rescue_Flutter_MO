import 'package:CarRescue/src/configuration/show_toast_notify.dart';
import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:CarRescue/src/providers/firebase_message_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:CarRescue/src/providers/gmail_provider.dart';
import 'package:CarRescue/src/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/auth_field.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/bottom_nav_bar/bottom_nav_bar_view.dart';

import 'log_in_widget.dart';

class LogInBody extends StatefulWidget {
  LogInBody({Key? key}) : super(key: key);

  @override
  State<LogInBody> createState() => _LogInBodyState();
}

class _LogInBodyState extends State<LogInBody> {
  GmailProvider gmailProvider = GmailProvider();
  LoginProvider loginProvider = LoginProvider();
  FireBaseMessageProvider fbMessage = FireBaseMessageProvider();
  final box = GetStorage();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  NotifyMessage notifyMessage = NotifyMessage();
  // GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: <String>[
  //     'email',
  //     'https://www.googleapis.com/auth/contacts.readonly',
  //   ],
  // );
  // Environment._googleSignIn;

  @override
  void initState() {
    // _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
    //   setState(() {
    //     _currentUser = account;
    //   });
    // } as void Function(GoogleSignInAccount? event)?);
    super.initState();
  }

  Future<void> _handleSignInWithGmail() async {
    setState(() {
      isLoading =
          true; // Set loading state to true when starting the login process
    });
    String? token = await gmailProvider.handleSignIn();
    String? deviceToken = await fbMessage.getDeviceToken();
    if (token != null) {
      final loginResponse =
          await loginProvider.loginWithGmail(token, deviceToken!);
      Customer customer = loginResponse!.customer;
      if (loginResponse != null && customer != null) {
        // Login successful, set loading state to false
        box.write("accessToken", loginResponse.accessToken);
        box.write("refreshToken", loginResponse.refreshToken);
        box.write("accountId", loginResponse.accountId);
        box.write("customer", customer.toJson());
        box.write("role", "Customer");
        setState(() {
          isLoading = false;
        });

        // Continue with navigation
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const BottomNavBarView(
                    page: 0,
                  )),
        );
        notifyMessage.showToast("Đăng nhập thành công");
      } else {
        // Login failed, set loading state to false
        setState(() {
          isLoading = true;
        });
        // Handle login failure
        notifyMessage.showToast("Đăng nhập không thành công");
      }
    } else {
      print("Không tìm thấy token");
      setState(() {
        isLoading = false;
      });
    }
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
                "Đăng nhập \ntài khoản bằng gmail",
                style: FrontendConfigs.kHeadingStyle,
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Expanded(
                      child: Divider(
                    color: FrontendConfigs.kIconColor,
                    height: 5,
                  )),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                      child: Divider(
                    color: FrontendConfigs.kIconColor,
                  )),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              InkWell(
                onTap: () async {
                  if (!isLoading) {
                    await _handleSignInWithGmail();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FrontendConfigs.kActiveColor,
                    borderRadius: BorderRadius.circular(
                        20), // Adjust the value to change the roundness
                  ),
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: FrontendConfigs.kHintColorCustomer,
                          ),
                        )
                      : Row(
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
                                  fontSize: 18,
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
