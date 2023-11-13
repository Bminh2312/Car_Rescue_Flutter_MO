import 'package:country_calling_code_picker/country.dart';
import 'package:country_calling_code_picker/country_code_picker.dart';
import 'package:country_calling_code_picker/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';

import '../../../../../../configuration/frontend_configs.dart';
import '../../otp/otp_view.dart';

class VerifyNumberBody extends StatefulWidget {
  const VerifyNumberBody({Key? key}) : super(key: key);

  @override
  State<VerifyNumberBody> createState() => _VerifyNumberBodyState();
}

class _VerifyNumberBodyState extends State<VerifyNumberBody> {
  Country? _selectedCountry;
  final TextEditingController _countryController = TextEditingController();

  @override
  void initState() {
    initCountry();
    super.initState();
  }

  void initCountry() async {
    final country = await getDefaultCountry(context);
    setState(() {
      _selectedCountry = country;
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
                "Phone \nVerification",
                style: FrontendConfigs.kHeadingStyle,
              ),
              const SizedBox(
                height: 34,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset("assets/svg/verification.svg"),
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              SizedBox(
                height: 49,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _countryController,
                  decoration: InputDecoration(
                    hintText: "Phone Number",
                    hintStyle: TextStyle(
                        color: FrontendConfigs.kIconColor,
                        fontSize: 14,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w400),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none),
                    fillColor: FrontendConfigs.kAuthColor,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_selectedCountry != null)
                            Image.asset(
                              _selectedCountry!.flag.toString(),
                              package: countryCodePackageName,
                              height: 30,
                              width: 30,
                            ),
                          const SizedBox(
                            width: 6,
                          ),
                          InkWell(
                              onTap: () {
                                _onPressedShowDialog();
                              },
                              child: Icon(
                                Icons.keyboard_arrow_down_sharp,
                                size: 20,
                                color: FrontendConfigs.kIconColor,
                              )),
                          const SizedBox(
                            width: 4,
                          ),
                          Container(
                            width: 1,
                            color: FrontendConfigs.kIconColor.withOpacity(0.5),
                          ),
                          const SizedBox(
                            width: 6,
                          )
                        ],
                      ),
                    ),
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(
                height: 34,
              ),
              AppButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OTPView()));
                  },
                  btnLabel: "Verify Number")
            ],
          ),
        ),
      ),
    );
  }

  void _onPressedShowDialog() async {
    final country = await showCountryPickerDialog(
      context,
    );
    if (country != null) {
      setState(() {
        _selectedCountry = country;
      });
    }
  }
}
