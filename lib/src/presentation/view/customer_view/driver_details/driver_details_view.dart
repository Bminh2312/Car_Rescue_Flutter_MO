import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/view/customer_view/chat_with_driver/chat_view.dart';
import '../../../../configuration/frontend_configs.dart';
import '../../../elements/round_button.dart';
import 'layout/body.dart';

class DriverDetailsView extends StatelessWidget {
  const DriverDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Driver Detail",
          style: TextStyle(
              color: FrontendConfigs.kPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w400),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(100),
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: FrontendConfigs.kPrimaryColor)),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: FrontendConfigs.kPrimaryColor,
                  size: 15,
                ),
              ),
            ),
          )
        ],
      ),
      body: const DriverDetailsBody(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoundButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChatView()));
              },
              icon: 'assets/svg/message.svg',
            ),
            const SizedBox(
              width: 24,
            ),
            RoundButton(
              onPressed: () {},
              icon: 'assets/svg/telephone_icon.svg',
            ),
          ],
        ),
      ),
    );
  }
}
