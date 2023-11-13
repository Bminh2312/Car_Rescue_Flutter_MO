import 'package:CarRescue/src/presentation/view/car_owner_view/wallet/layout/widgets/wallet_statistics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/top-up/top_up_view.dart';
import 'widgets/debit_card.dart';
import 'widgets/wallet_driver_widget.dart';

class WalletBody extends StatelessWidget {
  const WalletBody({Key? key, required this.userId}) : super(key: key);
  final String userId;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 8,
              ),
              WalletCardWidget(userId: userId),
              const SizedBox(
                height: 18,
              ),
              WalletStatisticsCard(),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: 'Lịch sử giao dịch',
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                      Icon(
                        CupertinoIcons.arrow_right_circle,
                        color: FrontendConfigs.kPrimaryColor,
                      )
                    ],
                  ),

                  const SizedBox(
                    height: 18,
                  ),
                  const WalletDriverWidget(
                    profileImage: 'assets/images/profile_one.png',
                    name: 'Lionel Messi',
                    details: 'Jun 20, 2022 | 10:00AM',
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  //

                  const WalletDriverWidget(
                    profileImage: 'assets/images/profile_one.png',
                    name: 'Harry Kane',
                    details: 'Jun 20, 2022 | 10:00AM',
                  ),

                  const SizedBox(
                    height: 18,
                  ),
                  const WalletDriverWidget(
                    profileImage: 'assets/images/profile_one.png',
                    name: 'Kylian',
                    details: 'Jun 20, 2022 | 10:00AM',
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                ],
              ),
              //
            ],
          ),
        ),
      ),
    );
  }
}
