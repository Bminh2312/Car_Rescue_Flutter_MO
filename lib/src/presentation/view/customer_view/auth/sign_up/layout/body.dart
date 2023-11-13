import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/view/customer_view/auth/verify_number/verify_number_view.dart';

import '../../../../../../configuration/frontend_configs.dart';
import '../../../../../elements/app_button.dart';
import '../../../../../elements/auth_field.dart';

class SignUpBody extends StatelessWidget {
  SignUpBody({Key? key}) : super(key: key);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
                "Create your \nAccount",
                style: FrontendConfigs.kHeadingStyle,
              ),
              const SizedBox(
                height: 30,
              ),
              CustomTextField(
                  isSecure: false,
                  controller: _emailController,
                  icon: "assets/svg/person_icon.svg",
                  text: 'Full Name',
                  onTap: () {},
                  keyBoardType: TextInputType.emailAddress),
              const SizedBox(
                height: 18,
              ),
              CustomTextField(
                  isSecure: false,
                  controller: _emailController,
                  icon: "assets/svg/email_icon.svg",
                  text: 'Email',
                  onTap: () {},
                  keyBoardType: TextInputType.emailAddress),
              const SizedBox(
                height: 18,
              ),
              CustomTextField(
                controller: _passwordController,
                icon: "assets/svg/lock_icon.svg",
                text: 'Password',
                onTap: () {},
                keyBoardType: TextInputType.text,
                isPassword: true,
              ),
              const SizedBox(
                height: 18,
              ),
              CustomTextField(
                icon: "assets/svg/lock_icon.svg",
                text: 'Password',
                onTap: () {},
                keyBoardType: TextInputType.text,
                isPassword: true,
              ),
              const SizedBox(
                height: 24,
              ),
              AppButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const VerifyNumberView()));
                  },
                  btnLabel: "Create Account"),
            ],
          ),
        ),
      ),
    );
  }
}
