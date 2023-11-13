import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/top-up/top_up_view.dart';
import 'widgets/debit_card.dart';
import 'widgets/wallet_driver_widget.dart';

class WalletBody extends StatelessWidget {
  const WalletBody({Key? key}) : super(key: key);

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
              const WalletCardWidget(),
              const SizedBox(
                height: 18,
              ),
              CustomText(
                text: 'Transaction History',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(
                height: 18,
              ),
              const WalletDriverWidget(
                profileImage: 'assets/images/profile_one.png',
                name: 'Harry potter',
                details: 'Jun 20, 2022 | 10:00AM',
              ),
              const SizedBox(
                height: 18,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TopUpView()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 51,
                          width: 51,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: const Color(0xff252525).withOpacity(0.20)),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                              height: 39,
                              width: 39,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Color(0xff2DBB54)),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SvgPicture.asset(
                                  'assets/svg/wallet_icon.svg',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 11,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: "Top Up Wallet",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            CustomText(
                              text: 'Jun 20, 2022 | 10:00AM',
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            CustomText(
                              text: "\$120.00",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            CustomText(
                              text: 'Top up',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            SvgPicture.asset('assets/svg/green_arrow.svg')
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              const WalletDriverWidget(
                profileImage: 'assets/images/profile_one.png',
                name: 'Harry potter',
                details: 'Jun 20, 2022 | 10:00AM',
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 51,
                        width: 51,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: const Color(0xff252525).withOpacity(0.20)),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Container(
                            height: 39,
                            width: 39,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Color(0xff2DBB54)),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SvgPicture.asset(
                                'assets/svg/wallet_icon.svg',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 11,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: "Top Up Wallet",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          CustomText(
                            text: 'Jun 20, 2022 | 10:00AM',
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          CustomText(
                            text: "\$120.00",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          CustomText(
                            text: 'Top up',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          SvgPicture.asset('assets/svg/green_arrow.svg')
                        ],
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              const WalletDriverWidget(
                profileImage: 'assets/images/profile_one.png',
                name: 'Harry potter',
                details: 'Jun 20, 2022 | 10:00AM',
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 51,
                        width: 51,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: const Color(0xff252525).withOpacity(0.20)),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Container(
                            height: 39,
                            width: 39,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Color(0xff2DBB54)),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SvgPicture.asset(
                                'assets/svg/wallet_icon.svg',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 11,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: "Top Up Wallet",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          CustomText(
                            text: 'Jun 20, 2022 | 10:00AM',
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          CustomText(
                            text: "\$120.00",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          CustomText(
                            text: 'Top up',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          SvgPicture.asset('assets/svg/green_arrow.svg')
                        ],
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
